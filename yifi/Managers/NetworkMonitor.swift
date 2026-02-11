import Foundation
import CoreWLAN
import Observation

/// Central coordinator for collecting all network metrics.
@MainActor
@Observable
final class NetworkMonitor {
    /// Sections with metric data for the UI
    var sections: [SectionData] = NetworkSection.allCases.map { SectionData(section: $0) }
    
    /// Cached gateway IP address, re-discovered on failure or TTL expiry
    private(set) var gatewayIP: String?
    
    /// Timestamp when gateway was last discovered
    private var gatewayDiscoveredAt: Date?
    
    /// Current network SSID
    private(set) var currentSSID: String?
    
    /// Current WiFi band (e.g., "2.4 GHz", "5 GHz", "6 GHz")
    private(set) var currentBand: String?
    
    /// The background collection task
    private var collectionTask: Task<Void, Never>?
    
    /// Poll interval in seconds
    private let pollInterval: TimeInterval = 3
    
    /// How long before gateway IP is considered stale and should be re-discovered
    private let gatewayTTL: TimeInterval = 60
    
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
        // Collect Wi-Fi metrics first (fast, synchronous)
        let wifiSnapshot = WiFiMetricsCollector.collect()
        let interface = CWWiFiClient.shared().interface()
        let ssid = interface?.ssid()
        
        // Check if SSID changed (network switch) - invalidate gateway
        if let ssid = ssid, ssid != currentSSID {
            gatewayIP = nil
            gatewayDiscoveredAt = nil
        }
        currentSSID = ssid
        
        // Get WiFi band from channel
        if let channel = interface?.wlanChannel() {
            currentBand = Self.bandDescription(for: channel)
        } else {
            currentBand = nil
        }
        
        // Check if gateway TTL expired
        if let discoveredAt = gatewayDiscoveredAt,
           Date().timeIntervalSince(discoveredAt) > gatewayTTL {
            gatewayIP = nil
            gatewayDiscoveredAt = nil
        }
        
        // Discover gateway if not cached
        if gatewayIP == nil {
            let discoveredGateway = await PingService.discoverGateway()
            gatewayIP = discoveredGateway
            if discoveredGateway != nil {
                gatewayDiscoveredAt = Date()
            }
        }
        
        // Capture gateway IP before launching concurrent tasks
        let currentGatewayIP = gatewayIP
        
        // Launch concurrent network probes
        async let routerPingResult = currentGatewayIP != nil ? PingService.ping(host: currentGatewayIP!) : nil
        async let internetPingResult = PingService.ping(host: "1.1.1.1")
        async let dnsLatencyResult = DNSService.measureLatency()
        
        // Await all results
        let routerPing = await routerPingResult
        let internetPing = await internetPingResult
        let dnsResult = await dnsLatencyResult
        
        // Update Wi-Fi metrics (Connection to Router section)
        if let wifi = wifiSnapshot {
            updateMetric(.linkRate, value: wifi.linkRate)
            updateMetric(.signalStrength, value: wifi.signalStrength)
            updateMetric(.noiseLevel, value: wifi.noiseLevel)
        } else {
            // Wi-Fi disconnected or unavailable
            markMetricUnavailable(.linkRate, reason: .sourceUnavailable)
            markMetricUnavailable(.signalStrength, reason: .sourceUnavailable)
            markMetricUnavailable(.noiseLevel, reason: .sourceUnavailable)
        }
        
        // Update router ping metrics (Inside Home Network section)
        if currentGatewayIP == nil {
            // No gateway discovered - mark all router metrics unavailable
            markMetricUnavailable(.routerLatency, reason: .sourceUnavailable)
            markMetricUnavailable(.routerJitter, reason: .sourceUnavailable)
            markMetricUnavailable(.routerPacketLoss, reason: .sourceUnavailable)
        } else if let router = routerPing {
            // We have ping results
            updateMetric(.routerPacketLoss, value: router.packetLoss)
            
            if router.packetLoss >= 100 {
                // 100% packet loss - latency/jitter cannot be computed
                markMetricUnavailable(.routerLatency, reason: .notComputable)
                markMetricUnavailable(.routerJitter, reason: .notComputable)
            } else {
                updateMetric(.routerLatency, value: router.averageLatency)
                updateMetric(.routerJitter, value: router.jitter)
            }
        } else {
            // Ping command failed entirely - mark metrics as probe failed
            markMetricUnavailable(.routerLatency, reason: .probeFailed)
            markMetricUnavailable(.routerJitter, reason: .probeFailed)
            markMetricUnavailable(.routerPacketLoss, reason: .probeFailed)
            // Clear gateway to re-discover next cycle
            gatewayIP = nil
            gatewayDiscoveredAt = nil
        }
        
        // Update internet ping metrics (Connection to Internet section)
        if let internet = internetPing {
            updateMetric(.internetPacketLoss, value: internet.packetLoss)
            
            if internet.packetLoss >= 100 {
                // 100% packet loss - latency/jitter cannot be computed
                markMetricUnavailable(.internetLatency, reason: .notComputable)
                markMetricUnavailable(.internetJitter, reason: .notComputable)
            } else {
                updateMetric(.internetLatency, value: internet.averageLatency)
                updateMetric(.internetJitter, value: internet.jitter)
            }
        } else {
            // Ping command failed entirely
            markMetricUnavailable(.internetLatency, reason: .probeFailed)
            markMetricUnavailable(.internetJitter, reason: .probeFailed)
            markMetricUnavailable(.internetPacketLoss, reason: .probeFailed)
        }
        
        // Update DNS latency metric (Website Name Lookup section)
        switch dnsResult {
        case .success(let latency):
            updateMetric(.dnsLatency, value: latency)
        case .failure(let error):
            switch error {
            case .commandFailed:
                markMetricUnavailable(.dnsLatency, reason: .probeFailed)
            case .parseError:
                markMetricUnavailable(.dnsLatency, reason: .probeFailed)
            case .queryFailed:
                markMetricUnavailable(.dnsLatency, reason: .probeFailed)
            }
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
    
    /// Marks a specific metric as unavailable.
    private func markMetricUnavailable(_ type: MetricType, reason: MetricUnavailableReason) {
        for sectionIndex in sections.indices {
            for metricIndex in sections[sectionIndex].metrics.indices {
                if sections[sectionIndex].metrics[metricIndex].type == type {
                    sections[sectionIndex].metrics[metricIndex].markUnavailable(reason: reason)
                    return
                }
            }
        }
    }
    
    /// Returns a human-readable band description for a WiFi channel.
    private static func bandDescription(for channel: CWChannel) -> String {
        switch channel.channelBand {
        case .bandUnknown:
            return "Ch \(channel.channelNumber)"
        case .band2GHz:
            return "2.4 GHz"
        case .band5GHz:
            return "5 GHz"
        case .band6GHz:
            return "6 GHz"
        @unknown default:
            return "Ch \(channel.channelNumber)"
        }
    }
}
