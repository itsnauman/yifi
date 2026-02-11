import Foundation

/// Service for running ping commands and discovering network gateway.
enum PingService {
    struct PingResult {
        let averageLatency: Double
        let jitter: Double
        let packetLoss: Double
        
        /// Whether we actually received any ICMP replies
        let hasValidLatency: Bool
    }
    
    /// Discovers the default gateway IP address.
    /// - Returns: Gateway IP address or nil if not found
    nonisolated static func discoverGateway() async -> String? {
        do {
            let result = try await ShellExecutor.run(
                "/sbin/route",
                arguments: ["-n", "get", "default"],
                timeout: 5
            )
            return parseGateway(from: result.output)
        } catch {
            return nil
        }
    }
    
    /// Pings a host and returns latency statistics.
    /// - Parameter host: IP address or hostname to ping
    /// - Returns: PingResult with latency, jitter, and packet loss, or nil if the ping command itself failed
    nonisolated static func ping(host: String) async -> PingResult? {
        do {
            // -c 10: send 10 pings for finer-grained packet loss detection (10% granularity)
            // -i 0.2: 200ms interval between pings
            // -W 1000: 1 second timeout per ping
            let result = try await ShellExecutor.run(
                "/sbin/ping",
                arguments: ["-c", "10", "-i", "0.2", "-W", "1000", host],
                timeout: 15
            )
            return parsePingOutput(result.output)
        } catch {
            // Command execution failed (not the same as 100% packet loss)
            return nil
        }
    }
    
    /// Parses gateway IP from route command output.
    private nonisolated static func parseGateway(from output: String) -> String? {
        // Look for "gateway: X.X.X.X" in output
        let lines = output.components(separatedBy: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("gateway:") {
                let parts = trimmed.components(separatedBy: ":")
                if parts.count >= 2 {
                    let gateway = parts[1].trimmingCharacters(in: .whitespaces)
                    // Validate it looks like an IP address
                    if gateway.contains(".") {
                        return gateway
                    }
                }
            }
        }
        return nil
    }
    
    /// Parses ping command output to extract latency statistics.
    private nonisolated static func parsePingOutput(_ output: String) -> PingResult? {
        var rtts: [Double] = []
        var packetLoss: Double?
        var packetsTransmitted: Int?
        var packetsReceived: Int?
        
        let lines = output.components(separatedBy: "\n")
        
        for line in lines {
            // Parse individual RTT values from lines like:
            // "64 bytes from 1.1.1.1: icmp_seq=0 ttl=55 time=12.345 ms"
            if line.contains("time=") {
                if let timeRange = line.range(of: "time=") {
                    let afterTime = line[timeRange.upperBound...]
                    let valueString = afterTime.prefix(while: { $0.isNumber || $0 == "." })
                    if let rtt = Double(valueString) {
                        rtts.append(rtt)
                    }
                }
            }
            
            // Parse packet statistics from line like:
            // "10 packets transmitted, 10 packets received, 0.0% packet loss"
            // or "5 packets transmitted, 0 packets received, 100.0% packet loss"
            if line.contains("packets transmitted") {
                // Parse transmitted count
                let parts = line.components(separatedBy: ",")
                for part in parts {
                    let trimmed = part.trimmingCharacters(in: .whitespaces)
                    if trimmed.contains("transmitted") {
                        let numPart = trimmed.components(separatedBy: " ").first ?? ""
                        packetsTransmitted = Int(numPart)
                    } else if trimmed.contains("received") && !trimmed.contains("%") {
                        let numPart = trimmed.components(separatedBy: " ").first ?? ""
                        packetsReceived = Int(numPart)
                    } else if trimmed.contains("% packet loss") {
                        // Extract the percentage value
                        let lossString = trimmed.replacingOccurrences(of: "% packet loss", with: "")
                            .trimmingCharacters(in: .whitespaces)
                        packetLoss = Double(lossString)
                    }
                }
            }
        }
        
        // Validate we got packet statistics from the output
        // If we can't parse the statistics line, consider it a failed probe
        guard packetsTransmitted != nil else {
            return nil
        }
        
        // Calculate packet loss if not explicitly parsed
        let finalPacketLoss: Double
        if let loss = packetLoss {
            finalPacketLoss = loss
        } else if let transmitted = packetsTransmitted, let received = packetsReceived, transmitted > 0 {
            finalPacketLoss = Double(transmitted - received) / Double(transmitted) * 100.0
        } else {
            // Can't determine packet loss - treat as probe failure
            return nil
        }
        
        // Handle case where we have no RTTs (100% packet loss)
        if rtts.isEmpty {
            return PingResult(
                averageLatency: 0,
                jitter: 0,
                packetLoss: finalPacketLoss,
                hasValidLatency: false
            )
        }
        
        // Calculate average latency
        let averageLatency = rtts.reduce(0, +) / Double(rtts.count)
        
        // Calculate jitter (standard deviation of RTTs)
        let variance = rtts.map { pow($0 - averageLatency, 2) }.reduce(0, +) / Double(rtts.count)
        let jitter = sqrt(variance)
        
        return PingResult(
            averageLatency: averageLatency,
            jitter: jitter,
            packetLoss: finalPacketLoss,
            hasValidLatency: true
        )
    }
}
