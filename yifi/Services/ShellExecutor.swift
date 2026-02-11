import Foundation

/// A utility for running shell commands asynchronously.
enum ShellExecutor {
    struct CommandResult: Sendable {
        let output: String
        let exitCode: Int32
    }
    
    enum ExecutorError: Error, Sendable {
        case timeout
        case executionFailed(String)
    }
    
    /// Thread-safe completion state tracker.
    private final class CompletionState: @unchecked Sendable {
        private nonisolated(unsafe) var _didComplete = false
        private let lock = NSLock()
        
        nonisolated init() {}
        
        /// Attempts to mark as complete. Returns true if this call performed the completion.
        nonisolated func tryComplete() -> Bool {
            lock.lock()
            defer { lock.unlock() }
            if _didComplete {
                return false
            }
            _didComplete = true
            return true
        }
    }
    
    /// Runs a shell command and returns its output.
    /// - Parameters:
    ///   - executablePath: Full path to the executable (e.g., "/sbin/ping")
    ///   - arguments: Command line arguments
    ///   - timeout: Maximum time to wait for completion (default 10 seconds)
    /// - Returns: CommandResult containing stdout and exit code
    nonisolated static func run(
        _ executablePath: String,
        arguments: [String],
        timeout: TimeInterval = 10
    ) async throws -> CommandResult {
        try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            let pipe = Pipe()
            
            process.executableURL = URL(fileURLWithPath: executablePath)
            process.arguments = arguments
            process.standardOutput = pipe
            process.standardError = pipe
            
            let state = CompletionState()
            
            // Timeout handler
            let timeoutWorkItem = DispatchWorkItem {
                if state.tryComplete() {
                    process.terminate()
                    continuation.resume(throwing: ExecutorError.timeout)
                }
            }
            
            DispatchQueue.global().asyncAfter(
                deadline: .now() + timeout,
                execute: timeoutWorkItem
            )
            
            process.terminationHandler = { _ in
                timeoutWorkItem.cancel()
                
                if state.tryComplete() {
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8) ?? ""
                    let result = CommandResult(output: output, exitCode: process.terminationStatus)
                    continuation.resume(returning: result)
                }
            }
            
            do {
                try process.run()
            } catch {
                timeoutWorkItem.cancel()
                if state.tryComplete() {
                    continuation.resume(throwing: ExecutorError.executionFailed(error.localizedDescription))
                }
            }
        }
    }
}
