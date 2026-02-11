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
            .frame(minWidth: 300, minHeight: 360)
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
        let statuses = networkMonitor.sections.map { $0.overallStatus }
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
    
}

#Preview {
    MenuBarView(networkMonitor: NetworkMonitor())
}
