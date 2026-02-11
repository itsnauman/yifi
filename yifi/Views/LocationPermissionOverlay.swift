//
//  LocationPermissionOverlay.swift
//  yifi
//
//  Created by Nauman Ahmad on 2/3/26.
//

import SwiftUI

/// Overlay view displayed when location services permission is not granted
struct LocationPermissionOverlay: View {
    let locationManager: LocationManager
    let status: LocationManager.AuthorizationStatus
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            Image(systemName: "location.slash.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            // Title
            Text("Location Access Required")
                .font(.system(size: 18, weight: .semibold))
            
            // Description
            Text("Yifi needs location access to retrieve Wi-Fi network information and display health metrics. This is required by macOS to access wireless network details.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            
            // Action button
            if status == .notDetermined {
                Button(action: {
                    locationManager.requestAuthorization()
                }) {
                    Text("Grant Location Access")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal, 24)
            } else {
                // Permission was denied - show button to open settings
                VStack(spacing: 12) {
                    Text("Permission was denied. Please enable location access in System Settings.")
                        .font(.system(size: 12))
                        .foregroundStyle(.orange)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    
                    Button(action: {
                        locationManager.openLocationSettings()
                    }) {
                        Text("Open System Settings")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.horizontal, 24)
                }
            }
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.windowBackground)
    }
}

#Preview("Not Determined") {
    LocationPermissionOverlay(
        locationManager: LocationManager(),
        status: .notDetermined
    )
    .frame(width: 300, height: 400)
}

#Preview("Denied") {
    LocationPermissionOverlay(
        locationManager: LocationManager(),
        status: .denied
    )
    .frame(width: 300, height: 400)
}
