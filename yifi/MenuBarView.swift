//
//  MenuBarView.swift
//  yifi
//
//  Created by Nauman Ahmad on 2/3/26.
//

import SwiftUI

struct MenuBarView: View {
    @State private var sections: [SectionData] = NetworkSection.allCases.map {
        SectionData(section: $0, isExpanded: true)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header section
            headerSection
            
            // Network metrics sections
            ForEach(sections) { sectionData in
                SectionView(sectionData: sectionData)
            }
        }
        .padding(.bottom, 8)
        .frame(width: 300)
        .onAppear {
            loadMockData()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack(spacing: 10) {
            // Wi-Fi icon with status color
            Image(systemName: "wifi")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(overallStatus.color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Network Health")
                    .font(.system(size: 16, weight: .semibold))
                
                Text(statusDescription)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }
    
    // MARK: - Computed Properties
    
    private var overallStatus: MetricStatus {
        let statuses = sections.map { $0.overallStatus }
        if statuses.contains(.bad) { return .bad }
        if statuses.contains(.warning) { return .warning }
        if statuses.contains(.good) { return .good }
        return .neutral
    }
    
    private var statusDescription: String {
        switch overallStatus {
        case .good:
            return "All systems operational"
        case .warning:
            return "Some metrics need attention"
        case .bad:
            return "Connection issues detected"
        case .neutral:
            return "Gathering data..."
        }
    }
    
    // MARK: - Mock Data Loading
    
    private func loadMockData() {
        // Load mock data for UI preview
        // This will be replaced with real network monitoring in the future
        sections = [
            createMockSection(.connectionToRouter, status: .good),
            createMockSection(.insideHomeNetwork, status: .good),
            createMockSection(.connectionToInternet, status: .warning),
            createMockSection(.websiteNameLookup, status: .good)
        ]
    }
    
    private func createMockSection(_ section: NetworkSection, status: MetricStatus) -> SectionData {
        var sectionData = SectionData(section: section, isExpanded: true)
        sectionData.metrics = section.metrics.map { type in
            MetricData(
                type: type,
                currentValue: mockValue(for: type, status: status),
                history: mockHistory(for: type, status: status)
            )
        }
        return sectionData
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
        let variance = abs(baseValue) * 0.15
        return (0..<20).map { _ in
            baseValue + Double.random(in: -variance...variance)
        }
    }
}

#Preview {
    MenuBarView()
}
