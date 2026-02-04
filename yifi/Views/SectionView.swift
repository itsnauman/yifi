//
//  SectionView.swift
//  yifi
//
//  Created by Nauman Ahmad on 2/3/26.
//

import SwiftUI

/// A section that groups related network metrics
struct SectionView: View {
    let sectionData: SectionData
    
    var body: some View {
        VStack(spacing: 0) {
            // Section header
            sectionHeader
            
            // Metrics
            metricsContent
        }
    }
    
    // MARK: - Private Views
    
    private var sectionHeader: some View {
        HStack(spacing: 6) {
            // Section title
            Text(sectionData.section.rawValue.uppercased())
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
            
            Spacer()
            
            // Overall status indicator
            Circle()
                .fill(sectionData.overallStatus.color)
                .frame(width: 6, height: 6)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }
    
    private var metricsContent: some View {
        VStack(spacing: 0) {
            ForEach(sectionData.metrics) { metric in
                MetricRowView(metric: metric)
            }
        }
    }
}

// MARK: - Preview

#Preview("Sections") {
    VStack(spacing: 0) {
        SectionView(
            sectionData: SectionData(
                section: .connectionToRouter,
                isExpanded: true
            ).withMockData(status: .good)
        )
        
        Divider()
        
        SectionView(
            sectionData: SectionData(
                section: .insideHomeNetwork,
                isExpanded: true
            ).withMockData(status: .warning)
        )
        
        Divider()
        
        SectionView(
            sectionData: SectionData(
                section: .connectionToInternet,
                isExpanded: true
            ).withMockData(status: .bad)
        )
        
        Divider()
        
        SectionView(
            sectionData: SectionData(
                section: .websiteNameLookup,
                isExpanded: true
            ).withMockData(status: .good)
        )
    }
    .frame(width: 320)
    .background(.ultraThinMaterial)
}

// MARK: - Preview Helpers

extension SectionData {
    /// Creates mock data for preview purposes
    func withMockData(status: MetricStatus) -> SectionData {
        var copy = self
        copy.metrics = section.metrics.map { type in
            MetricData(
                type: type,
                currentValue: mockValue(for: type, status: status),
                history: mockHistory(for: type, status: status)
            )
        }
        return copy
    }
    
    private func mockValue(for type: MetricType, status: MetricStatus) -> Double {
        switch type {
        case .linkRate:
            switch status {
            case .good: return 450
            case .warning: return 120
            case .bad, .neutral: return 30
            }
        case .signalStrength:
            switch status {
            case .good: return -55
            case .warning: return -68
            case .bad, .neutral: return -82
            }
        case .noiseLevel:
            return -90
        case .routerLatency, .internetLatency:
            switch status {
            case .good: return 12
            case .warning: return 55
            case .bad, .neutral: return 150
            }
        case .routerJitter, .internetJitter:
            switch status {
            case .good: return 5
            case .warning: return 25
            case .bad, .neutral: return 80
            }
        case .routerPacketLoss, .internetPacketLoss:
            switch status {
            case .good: return 0
            case .warning: return 2.5
            case .bad, .neutral: return 8
            }
        case .dnsLatency:
            switch status {
            case .good: return 25
            case .warning: return 120
            case .bad, .neutral: return 350
            }
        }
    }
    
    private func mockHistory(for type: MetricType, status: MetricStatus) -> [Double] {
        let baseValue = mockValue(for: type, status: status)
        let variance = baseValue * 0.15
        return (0..<15).map { _ in
            baseValue + Double.random(in: -variance...variance)
        }
    }
}
