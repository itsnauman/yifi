import Foundation

/// Service for measuring DNS query latency.
enum DNSService {
    /// Measures DNS query latency by running dig.
    /// - Returns: Query time in milliseconds, or nil on failure
    nonisolated static func measureLatency() async -> Double? {
        do {
            let result = try await ShellExecutor.run(
                "/usr/bin/dig",
                arguments: ["google.com"],
                timeout: 10
            )
            return parseQueryTime(from: result.output)
        } catch {
            return nil
        }
    }
    
    /// Parses query time from dig output.
    /// Looks for line like: ";; Query time: 12 msec"
    private nonisolated static func parseQueryTime(from output: String) -> Double? {
        let lines = output.components(separatedBy: "\n")
        
        for line in lines {
            if line.contains("Query time:") {
                // Extract the number from ";; Query time: 12 msec"
                let components = line.components(separatedBy: CharacterSet.decimalDigits.inverted)
                for component in components {
                    if let time = Double(component), time > 0 {
                        return time
                    }
                }
            }
        }
        
        return nil
    }
}
