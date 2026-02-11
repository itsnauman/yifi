//
//  LocationManager.swift
//  yifi
//
//  Created by Nauman Ahmad on 2/3/26.
//

import CoreLocation
import SwiftUI

/// Manages location services permissions required for network health metrics
@MainActor
@Observable
final class LocationManager: NSObject {
    
    enum AuthorizationStatus {
        case notDetermined
        case denied
        case authorized
    }
    
    private let locationManager = CLLocationManager()
    
    var authorizationStatus: AuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        updateAuthorizationStatus()
    }
    
    /// Request location services authorization
    /// On macOS, we need to start location services to trigger the authorization prompt
    func requestAuthorization() {
        // On macOS, calling requestWhenInUseAuthorization alone doesn't show a prompt.
        // We need to actually start location services to trigger the system prompt.
        locationManager.startUpdatingLocation()
    }
    
    /// Open System Settings to the Location Services pane
    func openLocationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func updateAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .restricted, .denied:
            authorizationStatus = .denied
        case .authorizedAlways, .authorizedWhenInUse:
            authorizationStatus = .authorized
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            updateAuthorizationStatus()
            // Stop location updates once we have a determined status
            // We only needed them to trigger the authorization prompt
            if manager.authorizationStatus != .notDetermined {
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // We don't need location data, just the authorization prompt
        // Stop updates after receiving first location
        Task { @MainActor in
            locationManager.stopUpdatingLocation()
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle authorization denial or other errors
        Task { @MainActor in
            locationManager.stopUpdatingLocation()
            updateAuthorizationStatus()
        }
    }
}
