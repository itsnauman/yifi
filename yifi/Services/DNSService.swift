import Foundation

/// Errors that can occur during DNS measurement
enum DNSError: Error {
    /// The dig command failed to execute
    case commandFailed
    /// Could not parse the query time from output
    case parseError
    /// DNS query failed (SERVFAIL, NXDOMAIN, etc.)
    case queryFailed(status: String)
}

/// Service for measuring DNS query latency.
/// Measures the time to resolve a domain name using the system's configured DNS resolver.
enum DNSService {
    /// Measures DNS query latency by running dig.
    /// - Returns: Result with query time in milliseconds, or an error
    nonisolated static func measureLatency() async -> Result<Double, DNSError> {
        do {
            let result = try await ShellExecutor.run(
                "/usr/bin/dig",
                arguments: ["google.com", "+tries=1", "+time=5"],
                timeout: 10
            )
            return parseDigOutput(result.output)
        } catch {
            return .failure(.commandFailed)
        }
    }
    
    /// Parses dig output to extract query time and validate status.
    private nonisolated static func parseDigOutput(_ output: String) -> Result<Double, DNSError> {
        let lines = output.components(separatedBy: "\n")
        
        var queryTime: Double?
        var status: String?
        
        for line in lines {
            // Parse status from header like: ";; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12345"
            if line.contains("status:") {
                if let statusRange = line.range(of: "status:") {
                    let afterStatus = line[statusRange.upperBound...]
                    // Extract status until comma or end
                    let statusPart = afterStatus.prefix(while: { $0 != "," })
                    status = statusPart.trimmingCharacters(in: .whitespaces)
                }
            }
            
            // Parse query time from line like: ";; Query time: 12 msec" or ";; Query time: 0 msec"
            if line.contains("Query time:") {
                if let timeRange = line.range(of: "Query time:") {
                    let afterTime = line[timeRange.upperBound...]
                    // Extract the number - can be 0 or any positive integer
                    let trimmed = afterTime.trimmingCharacters(in: .whitespaces)
                    let numberPart = trimmed.prefix(while: { $0.isNumber })
                    if let time = Double(numberPart) {
                        queryTime = time
                    }
                }
            }
        }
        
        // Validate status - NOERROR means success
        if let status = status, status != "NOERROR" {
            return .failure(.queryFailed(status: status))
        }
        
        // Return query time if found (0 is valid - cached response)
        if let time = queryTime {
            return .success(time)
        }
        
        return .failure(.parseError)
    }
}
