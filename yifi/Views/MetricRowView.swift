//
//  MetricRowView.swift
//  yifi
//
//  Created by Nauman Ahmad on 2/3/26.
//

import SwiftUI

/// Displays a single network metric with label, value, status indicator, and sparkline
struct MetricRowView: View {
    let metric: MetricData
    
    /// Whether this metric has valid data to display
    private var isAvailable: Bool {
        metric.availability.isAvailable
    }
    
    /// Whether the metric is stale but has historical data
    private var isStale: Bool {
        if case .stale = metric.availability { return true }
        return false
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Status indicator - neutral for unavailable/stale metrics
            Circle()
                .fill(metric.status.color)
                .frame(width: 6, height: 6)
                .padding(.trailing, 10)
            
            // Metric label
            Text(metric.type.displayName)
                .font(.system(size: 13))
                .foregroundStyle(isAvailable ? .primary : .secondary)
                .lineLimit(1)
            
            Spacer()
            
            // Sparkline graph - show history even for stale metrics, hide for unavailable
            if !metric.history.isEmpty {
                SparklineView(
                    data: metric.history,
                    color: isAvailable ? metric.status.color : .gray,
                    isHigherBetter: metric.type.isHigherBetter
                )
                .frame(width: 50, height: 14)
                .padding(.trailing, 12)
                .opacity(isAvailable ? 1.0 : 0.5)
            } else {
                Spacer()
                    .frame(width: 50, height: 14)
                    .padding(.trailing, 12)
            }
            
            // Current value with unit
            HStack(spacing: 2) {
                Text(metric.formattedValue)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(isAvailable ? .primary : .secondary)
                
                if isAvailable {
                    Text(metric.type.unit)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minWidth: 65, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .help(metric.type.description)
    }
}

// MARK: - Preview

#Preview("Metric Rows") {
    VStack(spacing: 0) {
        // Good status
        MetricRowView(
            metric: MetricData(
                type: .linkRate,
                currentValue: 450,
                history: [400, 420, 380, 450, 440, 430, 460, 450, 445, 450],
                availability: .available
            )
        )
        
        Divider()
            .padding(.leading, 24)
        
        // Warning status
        MetricRowView(
            metric: MetricData(
                type: .signalStrength,
                currentValue: -68,
                history: [-65, -67, -70, -68, -66, -69, -68, -67, -68],
                availability: .available
            )
        )
        
        Divider()
            .padding(.leading, 24)
        
        // Bad status
        MetricRowView(
            metric: MetricData(
                type: .routerLatency,
                currentValue: 150,
                history: [120, 130, 140, 160, 145, 150, 155, 150],
                availability: .available
            )
        )
        
        Divider()
            .padding(.leading, 24)
        
        // Neutral status (noise level)
        MetricRowView(
            metric: MetricData(
                type: .noiseLevel,
                currentValue: -90,
                history: [-88, -90, -92, -89, -91, -90, -88, -90],
                availability: .available
            )
        )
        
        Divider()
            .padding(.leading, 24)
        
        // Unavailable - never measured
        MetricRowView(
            metric: MetricData(
                type: .dnsLatency,
                availability: .unavailable(.neverMeasured)
            )
        )
        
        Divider()
            .padding(.leading, 24)
        
        // Unavailable - probe failed (with stale history)
        MetricRowView(
            metric: MetricData(
                type: .internetLatency,
                currentValue: 45,
                history: [40, 42, 45, 43, 44, 45],
                availability: .unavailable(.probeFailed)
            )
        )
    }
    .frame(width: 300)
    .padding(.vertical, 8)
    .background(.ultraThinMaterial)
}
