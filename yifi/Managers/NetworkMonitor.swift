import Foundation
import Observation

/// Central coordinator for collecting all network metrics.
@Observable
final class NetworkMonitor {
    /// Sections with metric data for the UI
    var sections: [SectionData] = NetworkSection.allCases.map { SectionData(section: $0) }
    
    /// Cached gateway IP address, re-discovered on failure
    var gatewayIP: String?
    
    /// The background collection task
    private var collectionTask: Task<Void, Never>?
    
    /// Poll interval in seconds
    private let pollInterval: TimeInterval = 3
    
    init() {
        start()
    }
    
    /// Starts the background metrics collection loop.
    func start() {
        guard collectionTask == nil else { return }
        
        collectionTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.collectAllMetrics()
                try? await Task.sleep(for: .seconds(self?.pollInterval ?? 3))
            }
        }
    }
    
    /// Stops the background metrics collection.
    func stop() {
        collectionTask?.cancel()
        collectionTask = nil
    }
    
    /// Collects all network metrics and updates the sections.
    private func collectAllMetrics() async {
        // Discover gateway if not cached
        if gatewayIP == nil {
            gatewayIP = await PingService.discoverGateway()
        }
        
        // Capture gateway IP before launching concurrent tasks
        let currentGatewayIP = gatewayIP
        
        // Collect Wi-Fi metrics synchronously (fast, safe on MainActor)
        let wifiSnapshot = WiFiMetricsCollector.collect()
        
        // Launch concurrent network probes
        // Pass gateway IP directly to avoid race condition
        async let routerPingResult = currentGatewayIP != nil ? PingService.ping(host: currentGatewayIP!) : nil
        async let internetPingResult = PingService.ping(host: "1.1.1.1")
        async let dnsLatencyResult = DNSService.measureLatency()
        
        // Await all results
        let routerPing = await routerPingResult
        let internetPing = await internetPingResult
        let dnsLatency = await dnsLatencyResult
        
        // Update Wi-Fi metrics (Connection to Router section)
        if let wifi = wifiSnapshot {
            updateMetric(.linkRate, value: wifi.linkRate)
            updateMetric(.signalStrength, value: wifi.signalStrength)
            updateMetric(.noiseLevel, value: wifi.noiseLevel)
        }
        
        // Update router ping metrics (Inside Home Network section)
        if let router = routerPing {
            updateMetric(.routerPacketLoss, value: router.packetLoss)
            // Only update latency/jitter if not 100% packet loss
            if router.packetLoss < 100 {
                updateMetric(.routerLatency, value: router.averageLatency)
                updateMetric(.routerJitter, value: router.jitter)
            }
        } else if currentGatewayIP != nil {
            // Router ping failed (but we had a gateway), clear gateway to re-discover next cycle
            gatewayIP = nil
        }
        
        // Update internet ping metrics (Connection to Internet section)
        if let internet = internetPing {
            updateMetric(.internetPacketLoss, value: internet.packetLoss)
            // Only update latency/jitter if not 100% packet loss
            if internet.packetLoss < 100 {
                updateMetric(.internetLatency, value: internet.averageLatency)
                updateMetric(.internetJitter, value: internet.jitter)
            }
        }
        
        // Update DNS latency metric (Website Name Lookup section)
        if let dns = dnsLatency {
            updateMetric(.dnsLatency, value: dns)
        }
    }
    
    /// Updates a specific metric with a new value.
    private func updateMetric(_ type: MetricType, value: Double) {
        for sectionIndex in sections.indices {
            for metricIndex in sections[sectionIndex].metrics.indices {
                if sections[sectionIndex].metrics[metricIndex].type == type {
                    sections[sectionIndex].metrics[metricIndex].addValue(value)
                    return
                }
            }
        }
    }
}
