//
//  NetworkMetric.swift
//  yifi
//
//  Created by Nauman Ahmad on 2/3/26.
//

import SwiftUI

// MARK: - Status Types

/// Represents the health status of a network metric
enum MetricStatus {
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
    
    /// Maximum number of historical data points to keep
    static let maxHistoryCount = 30
    
    var status: MetricStatus {
        if history.isEmpty { return .neutral }
        return type.status(for: currentValue)
    }
    
    var formattedValue: String {
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
    
    init(type: MetricType, currentValue: Double = 0, history: [Double] = []) {
        self.type = type
        self.currentValue = currentValue
        self.history = history
    }
    
    /// Adds a new value to the history and updates current value
    mutating func addValue(_ value: Double) {
        currentValue = value
        history.append(value)
        if history.count > Self.maxHistoryCount {
            history.removeFirst()
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
    
    /// Overall status is the worst status among all metrics in the section
    var overallStatus: MetricStatus {
        let statuses = metrics.map { $0.status }
        if statuses.contains(.bad) { return .bad }
        if statuses.contains(.warning) { return .warning }
        if statuses.contains(.good) { return .good }
        return .neutral
    }
    
    init(section: NetworkSection, isExpanded: Bool = true) {
        self.section = section
        self.metrics = section.metrics.map { MetricData(type: $0) }
        self.isExpanded = isExpanded
    }
}
