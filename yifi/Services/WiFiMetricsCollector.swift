import CoreWLAN

/// Collector for Wi-Fi metrics using CoreWLAN.
enum WiFiMetricsCollector {
    struct WiFiSnapshot {
        /// Link rate in Mbps
        let linkRate: Double
        /// Signal strength in dBm (typically -30 to -90)
        let signalStrength: Double
        /// Noise level in dBm (typically -80 to -100)
        let noiseLevel: Double
    }
    
    /// Collects current Wi-Fi metrics.
    /// - Returns: WiFiSnapshot with current values, or nil if Wi-Fi is off/disconnected
    static func collect() -> WiFiSnapshot? {
        guard let interface = CWWiFiClient.shared().interface() else {
            return nil
        }
        
        // Check if Wi-Fi is powered on and connected
        guard interface.powerOn(), interface.ssid() != nil else {
            return nil
        }
        
        let linkRate = interface.transmitRate()
        let signalStrength = Double(interface.rssiValue())
        let noiseLevel = Double(interface.noiseMeasurement())
        
        return WiFiSnapshot(
            linkRate: linkRate,
            signalStrength: signalStrength,
            noiseLevel: noiseLevel
        )
    }
}
