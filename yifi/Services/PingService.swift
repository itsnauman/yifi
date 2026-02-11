import Foundation

/// Service for running ping commands and discovering network gateway.
enum PingService {
    struct PingResult {
        let averageLatency: Double
        let jitter: Double
        let packetLoss: Double
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
    /// - Returns: PingResult with latency, jitter, and packet loss, or nil on failure
    nonisolated static func ping(host: String) async -> PingResult? {
        do {
            // -c 5: send 5 pings
            // -i 0.2: 200ms interval between pings
            // -W 1000: 1 second timeout per ping
            let result = try await ShellExecutor.run(
                "/sbin/ping",
                arguments: ["-c", "5", "-i", "0.2", "-W", "1000", host],
                timeout: 10
            )
            return parsePingOutput(result.output)
        } catch {
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
        var packetLoss: Double = 0
        
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
            
            // Parse packet loss from line like:
            // "5 packets transmitted, 5 packets received, 0.0% packet loss"
            if line.contains("packet loss") {
                // Find the percentage value before "% packet loss"
                if let percentRange = line.range(of: "% packet loss") {
                    let beforePercent = line[..<percentRange.lowerBound]
                    // Get the number before the %
                    let parts = beforePercent.components(separatedBy: CharacterSet(charactersIn: ", "))
                    if let lastPart = parts.last, let loss = Double(lastPart) {
                        packetLoss = loss
                    }
                }
            }
        }
        
        // Handle 100% packet loss case
        if rtts.isEmpty {
            return PingResult(averageLatency: 0, jitter: 0, packetLoss: packetLoss > 0 ? packetLoss : 100)
        }
        
        // Calculate average latency
        let averageLatency = rtts.reduce(0, +) / Double(rtts.count)
        
        // Calculate jitter (standard deviation of RTTs)
        let variance = rtts.map { pow($0 - averageLatency, 2) }.reduce(0, +) / Double(rtts.count)
        let jitter = sqrt(variance)
        
        return PingResult(
            averageLatency: averageLatency,
            jitter: jitter,
            packetLoss: packetLoss
        )
    }
}
