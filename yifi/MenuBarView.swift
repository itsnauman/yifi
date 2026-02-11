//
//  MenuBarView.swift
//  yifi
//
//  Created by Nauman Ahmad on 2/3/26.
//

import SwiftUI

struct MenuBarView: View {
    var networkMonitor: NetworkMonitor
    @State private var locationManager = LocationManager()
    
    var body: some View {
        ZStack {
            // Main content
            VStack(alignment: .leading, spacing: 0) {
                // Header section
                headerSection
                
                // Network metrics sections
                ForEach(networkMonitor.sections) { sectionData in
                    SectionView(sectionData: sectionData)
                }
            }
            .padding(.vertical, 12)
            .frame(minWidth: 300, minHeight: 540)
            .background(.windowBackground)
            
            // Location permission overlay
            if locationManager.authorizationStatus != .authorized {
                LocationPermissionOverlay(
                    locationManager: locationManager,
                    status: locationManager.authorizationStatus
                )
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // App branding
            HStack(spacing: 10) {
                Image(systemName: "stethoscope")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Yifi")
                        .font(.system(size: 15, weight: .semibold))
                    
                    Text("See what's slowing you down.")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
            }
            
            // Network name pill with Liquid Glass effect
            HStack(spacing: 8) {
                Image(systemName: "wifi")
                    .font(.system(size: 12, weight: .semibold))
                
                Text(networkMonitor.currentSSID ?? "Not Connected")
                    .font(.system(size: 13, weight: .medium))
                
                Spacer()
                
                if let band = networkMonitor.currentBand {
                    Text(band)
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .glassEffect(.regular.tint(networkMonitor.currentSSID != nil ? .blue : .gray))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .glassEffect(.regular.tint(networkMonitor.currentSSID != nil ? .blue : .gray), in: .rect(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
    
    // MARK: - Computed Properties
    
    /// Whether all sections have unavailable metrics (no data collected yet)
    private var allMetricsUnavailable: Bool {
        networkMonitor.sections.allSatisfy { $0.allMetricsUnavailable }
    }
    
    private var overallStatus: MetricStatus {
        // If all metrics are unavailable, return neutral
        guard !allMetricsUnavailable else {
            return .neutral
        }
        
        let statuses = networkMonitor.sections.map { $0.overallStatus }
        if statuses.contains(.bad) { return .bad }
        if statuses.contains(.warning) { return .warning }
        if statuses.contains(.good) { return .good }
        return .neutral
    }
    
    private var statusDescription: String {
        // Special case: no data yet
        if allMetricsUnavailable {
            return "Gathering data..."
        }
        
        switch overallStatus {
        case .good:
            return "All systems operational"
        case .warning:
            return "Some metrics need attention"
        case .bad:
            return "Connection issues detected"
        case .neutral:
            return "Some metrics unavailable"
        }
    }
    
}

#Preview {
    MenuBarView(networkMonitor: NetworkMonitor())
}
