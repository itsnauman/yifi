//
//  NetworkMetric.swift
//  yifi
//
//  Created by Nauman Ahmad on 2/3/26.
//

import SwiftUI

// MARK: - Metric Availability

/// Represents why a metric is unavailable
enum MetricUnavailableReason: Equatable {
    /// The probe failed entirely (e.g., command timed out, network unreachable)
    case probeFailed
    /// The metric cannot be computed (e.g., latency when packet loss is 100%)
    case notComputable
    /// The data source is unavailable (e.g., Wi-Fi disconnected, no gateway)
    case sourceUnavailable
    /// No data has been collected yet
    case neverMeasured
}

/// Represents the availability state of a metric
enum MetricAvailability: Equatable {
    /// Metric has a fresh, valid value
    case available
    /// Metric data is stale (older than expected refresh interval)
    case stale
    /// Metric is unavailable with a reason
    case unavailable(MetricUnavailableReason)
    
    var isAvailable: Bool {
        if case .available = self { return true }
        return false
    }
    
    var isUnavailable: Bool {
        if case .unavailable = self { return true }
        return false
    }
}

// MARK: - Status Types

/// Represents the health status of a network metric
enum MetricStatus: Equatable {
    case good
    case warning
    case bad
    case neutral
    
    var color: Color {
        switch self {
        case .good: return .green
        case .warning: return .yellow
        case .bad: return .red
        case .neutral: return .gray
        }
    }
}

// MARK: - Metric Types

/// Types of network metrics the app can display
enum MetricType: String, CaseIterable, Identifiable {
    // Connection to Router
    case linkRate = "Link Rate"
    case signalStrength = "Signal Strength"
    case noiseLevel = "Noise Level"
    
    // Inside Home Network
    case routerLatency = "Latency (Router)"
    case routerJitter = "Jitter (Router)"
    case routerPacketLoss = "Packet Loss (Router)"
    
    // Connection to Internet
    case internetLatency = "Latency (Internet)"
    case internetJitter = "Jitter (Internet)"
    case internetPacketLoss = "Packet Loss (Internet)"
    
    // Website Name Lookup
    case dnsLatency = "DNS Lookup"
    
    var id: String { rawValue }
    
    var unit: String {
        switch self {
        case .linkRate:
            return "Mbps"
        case .signalStrength, .noiseLevel:
            return "dBm"
        case .routerLatency, .internetLatency, .dnsLatency:
            return "ms"
        case .routerJitter, .internetJitter:
            return "ms"
        case .routerPacketLoss, .internetPacketLoss:
            return "%"
        }
    }
    
    /// Shorter display name for the metric row
    var displayName: String {
        switch self {
        case .linkRate: return "Link Rate"
        case .signalStrength: return "Signal Strength"
        case .noiseLevel: return "Noise Level"
        case .routerLatency, .internetLatency: return "Latency"
        case .routerJitter, .internetJitter: return "Jitter"
        case .routerPacketLoss, .internetPacketLoss: return "Packet Loss"
        case .dnsLatency: return "DNS Lookup"
        }
    }
    
    var isHigherBetter: Bool {
        switch self {
        case .linkRate:
            return true
        case .signalStrength:
            // Signal strength is negative dBm, so higher (closer to 0) is better
            return true
        case .noiseLevel:
            // Noise is informational
            return false
        case .routerLatency, .internetLatency, .dnsLatency:
            return false
        case .routerJitter, .internetJitter:
            return false
        case .routerPacketLoss, .internetPacketLoss:
            return false
        }
    }
    
    /// A short, non-technical description of what this metric means
    var description: String {
        switch self {
        case .linkRate:
            return "How fast your Wi-Fi connection can transfer data"
        case .signalStrength:
            return "How well your device can hear the router"
        case .noiseLevel:
            return "Background interference that can affect your connection"
        case .routerLatency:
            return "How quickly your router responds to requests"
        case .routerJitter:
            return "How consistent your router's response time is"
        case .routerPacketLoss:
            return "How often data fails to reach your router"
        case .internetLatency:
            return "How quickly you can reach the internet"
        case .internetJitter:
            return "How consistent your internet response time is"
        case .internetPacketLoss:
            return "How often data fails to reach the internet"
        case .dnsLatency:
            return "How quickly website names are looked up"
        }
    }
    
    /// Returns the status based on the metric value
    func status(for value: Double) -> MetricStatus {
        switch self {
        case .linkRate:
            if value >= 200 { return .good }
            if value >= 50 { return .warning }
            return .bad
            
        case .signalStrength:
            if value > -60 { return .good }
            if value >= -75 { return .warning }
            return .bad
            
        case .noiseLevel:
            return .neutral
            
        case .routerLatency, .internetLatency:
            if value < 20 { return .good }
            if value <= 100 { return .warning }
            return .bad
            
        case .routerJitter, .internetJitter:
            if value < 10 { return .good }
            if value <= 50 { return .warning }
            return .bad
            
        case .routerPacketLoss, .internetPacketLoss:
            if value == 0 { return .good }
            if value <= 5 { return .warning }
            return .bad
            
        case .dnsLatency:
            if value < 50 { return .good }
            if value <= 200 { return .warning }
            return .bad
        }
    }
}

// MARK: - Network Section

/// Represents a grouping of related network metrics
enum NetworkSection: String, CaseIterable, Identifiable {
    case connectionToRouter = "Connection to Router"
    case insideHomeNetwork = "Inside Home Network"
    case connectionToInternet = "Connection to Internet"
    case websiteNameLookup = "Website Name Lookup"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .connectionToRouter:
            return "wifi"
        case .insideHomeNetwork:
            return "house"
        case .connectionToInternet:
            return "globe"
        case .websiteNameLookup:
            return "magnifyingglass"
        }
    }
    
    var metrics: [MetricType] {
        switch self {
        case .connectionToRouter:
            return [.linkRate, .signalStrength, .noiseLevel]
        case .insideHomeNetwork:
            return [.routerLatency, .routerJitter, .routerPacketLoss]
        case .connectionToInternet:
            return [.internetLatency, .internetJitter, .internetPacketLoss]
        case .websiteNameLookup:
            return [.dnsLatency]
        }
    }
}

// MARK: - Metric Data

/// Holds the current value and history for a network metric
struct MetricData: Identifiable {
    let id = UUID()
    let type: MetricType
    var currentValue: Double
    var history: [Double]
    
    /// Timestamp of the last successful measurement
    var lastUpdatedAt: Date?
    
    /// Current availability state of this metric
    var availability: MetricAvailability = .unavailable(.neverMeasured)
    
    /// Maximum number of historical data points to keep
    static let maxHistoryCount = 30
    
    /// How long before a metric is considered stale (seconds)
    static let staleThreshold: TimeInterval = 15
    
    var status: MetricStatus {
        switch availability {
        case .unavailable, .stale:
            return .neutral
        case .available:
            return type.status(for: currentValue)
        }
    }
    
    var formattedValue: String {
        guard availability.isAvailable else {
            return "N/A"
        }
        switch type {
        case .linkRate:
            return String(format: "%.0f", currentValue)
        case .signalStrength, .noiseLevel:
            return String(format: "%.0f", currentValue)
        case .routerLatency, .internetLatency, .dnsLatency:
            return String(format: "%.1f", currentValue)
        case .routerJitter, .internetJitter:
            return String(format: "%.1f", currentValue)
        case .routerPacketLoss, .internetPacketLoss:
            return String(format: "%.1f", currentValue)
        }
    }
    
    init(type: MetricType, currentValue: Double = 0, history: [Double] = [], availability: MetricAvailability = .unavailable(.neverMeasured)) {
        self.type = type
        self.currentValue = currentValue
        self.history = history
        self.availability = availability
        self.lastUpdatedAt = history.isEmpty ? nil : Date()
    }
    
    /// Adds a new value to the history and updates current value
    mutating func addValue(_ value: Double) {
        currentValue = value
        history.append(value)
        if history.count > Self.maxHistoryCount {
            history.removeFirst()
        }
        lastUpdatedAt = Date()
        availability = .available
    }
    
    /// Marks the metric as unavailable with a reason
    mutating func markUnavailable(reason: MetricUnavailableReason) {
        availability = .unavailable(reason)
        // Don't clear lastUpdatedAt - we want to know when it was last valid
    }
    
    /// Checks and updates staleness based on time since last update
    mutating func updateStaleness() {
        guard case .available = availability,
              let lastUpdate = lastUpdatedAt else {
            return
        }
        if Date().timeIntervalSince(lastUpdate) > Self.staleThreshold {
            availability = .stale
        }
    }
}

// MARK: - Section Data

/// Holds all metric data for a network section
struct SectionData: Identifiable {
    let id = UUID()
    let section: NetworkSection
    var metrics: [MetricData]
    var isExpanded: Bool
    
    /// Overall status is the worst status among available metrics in the section.
    /// If all metrics are unavailable, returns neutral.
    var overallStatus: MetricStatus {
        // Only consider metrics that have available data
        let availableMetrics = metrics.filter { $0.availability.isAvailable }
        
        // If no metrics are available, return neutral
        guard !availableMetrics.isEmpty else {
            return .neutral
        }
        
        let statuses = availableMetrics.map { $0.status }
        if statuses.contains(.bad) { return .bad }
        if statuses.contains(.warning) { return .warning }
        if statuses.contains(.good) { return .good }
        return .neutral
    }
    
    /// Returns true if all metrics in this section are unavailable
    var allMetricsUnavailable: Bool {
        metrics.allSatisfy { $0.availability.isUnavailable }
    }
    
    init(section: NetworkSection, isExpanded: Bool = true) {
        self.section = section
        self.metrics = section.metrics.map { MetricData(type: $0) }
        self.isExpanded = isExpanded
    }
}
