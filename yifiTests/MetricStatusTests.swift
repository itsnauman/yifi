import Testing
@testable import yifi

@Suite("MetricType.status boundary thresholds")
struct MetricStatusTests {
    // MARK: - Link Rate

    @Test("Link rate 200 Mbps is good")
    func linkRateGood() {
        #expect(MetricType.linkRate.status(for: 200) == .good)
    }

    @Test("Link rate 199.9 Mbps is warning")
    func linkRateWarningBoundary() {
        #expect(MetricType.linkRate.status(for: 199.9) == .warning)
    }

    @Test("Link rate 50 Mbps is warning")
    func linkRateWarning() {
        #expect(MetricType.linkRate.status(for: 50) == .warning)
    }

    @Test("Link rate 49.9 Mbps is bad")
    func linkRateBad() {
        #expect(MetricType.linkRate.status(for: 49.9) == .bad)
    }

    // MARK: - Signal Strength

    @Test("Signal -59 dBm is good")
    func signalGood() {
        #expect(MetricType.signalStrength.status(for: -59) == .good)
    }

    @Test("Signal -60 dBm is warning (boundary: > -60 is good)")
    func signalWarningBoundary() {
        #expect(MetricType.signalStrength.status(for: -60) == .warning)
    }

    @Test("Signal -75 dBm is warning")
    func signalWarning() {
        #expect(MetricType.signalStrength.status(for: -75) == .warning)
    }

    @Test("Signal -76 dBm is bad")
    func signalBad() {
        #expect(MetricType.signalStrength.status(for: -76) == .bad)
    }

    // MARK: - Noise Level

    @Test("Noise level always returns neutral")
    func noiseLevelAlwaysNeutral() {
        #expect(MetricType.noiseLevel.status(for: -90) == .neutral)
        #expect(MetricType.noiseLevel.status(for: -50) == .neutral)
        #expect(MetricType.noiseLevel.status(for: 0) == .neutral)
    }

    // MARK: - Latency (Router & Internet share thresholds)

    @Test("Latency 19.9 ms is good")
    func latencyGood() {
        #expect(MetricType.routerLatency.status(for: 19.9) == .good)
        #expect(MetricType.internetLatency.status(for: 19.9) == .good)
    }

    @Test("Latency 20 ms is warning (boundary: < 20 is good)")
    func latencyWarningBoundary() {
        #expect(MetricType.routerLatency.status(for: 20) == .warning)
        #expect(MetricType.internetLatency.status(for: 20) == .warning)
    }

    @Test("Latency 100 ms is warning")
    func latencyWarning() {
        #expect(MetricType.routerLatency.status(for: 100) == .warning)
        #expect(MetricType.internetLatency.status(for: 100) == .warning)
    }

    @Test("Latency 100.1 ms is bad")
    func latencyBad() {
        #expect(MetricType.routerLatency.status(for: 100.1) == .bad)
        #expect(MetricType.internetLatency.status(for: 100.1) == .bad)
    }

    // MARK: - Jitter (Router & Internet share thresholds)

    @Test("Jitter 9.9 ms is good")
    func jitterGood() {
        #expect(MetricType.routerJitter.status(for: 9.9) == .good)
        #expect(MetricType.internetJitter.status(for: 9.9) == .good)
    }

    @Test("Jitter 10 ms is warning (boundary: < 10 is good)")
    func jitterWarningBoundary() {
        #expect(MetricType.routerJitter.status(for: 10) == .warning)
        #expect(MetricType.internetJitter.status(for: 10) == .warning)
    }

    @Test("Jitter 50 ms is warning")
    func jitterWarning() {
        #expect(MetricType.routerJitter.status(for: 50) == .warning)
        #expect(MetricType.internetJitter.status(for: 50) == .warning)
    }

    @Test("Jitter 50.1 ms is bad")
    func jitterBad() {
        #expect(MetricType.routerJitter.status(for: 50.1) == .bad)
        #expect(MetricType.internetJitter.status(for: 50.1) == .bad)
    }

    // MARK: - Packet Loss (Router & Internet share thresholds)

    @Test("Packet loss 0% is good")
    func packetLossGood() {
        #expect(MetricType.routerPacketLoss.status(for: 0) == .good)
        #expect(MetricType.internetPacketLoss.status(for: 0) == .good)
    }

    @Test("Packet loss 0.1% is warning")
    func packetLossWarningBoundary() {
        #expect(MetricType.routerPacketLoss.status(for: 0.1) == .warning)
        #expect(MetricType.internetPacketLoss.status(for: 0.1) == .warning)
    }

    @Test("Packet loss 5% is warning")
    func packetLossWarning() {
        #expect(MetricType.routerPacketLoss.status(for: 5) == .warning)
        #expect(MetricType.internetPacketLoss.status(for: 5) == .warning)
    }

    @Test("Packet loss 5.1% is bad")
    func packetLossBad() {
        #expect(MetricType.routerPacketLoss.status(for: 5.1) == .bad)
        #expect(MetricType.internetPacketLoss.status(for: 5.1) == .bad)
    }

    // MARK: - DNS Latency

    @Test("DNS latency 49.9 ms is good")
    func dnsGood() {
        #expect(MetricType.dnsLatency.status(for: 49.9) == .good)
    }

    @Test("DNS latency 50 ms is warning (boundary: < 50 is good)")
    func dnsWarningBoundary() {
        #expect(MetricType.dnsLatency.status(for: 50) == .warning)
    }

    @Test("DNS latency 200 ms is warning")
    func dnsWarning() {
        #expect(MetricType.dnsLatency.status(for: 200) == .warning)
    }

    @Test("DNS latency 200.1 ms is bad")
    func dnsBad() {
        #expect(MetricType.dnsLatency.status(for: 200.1) == .bad)
    }
}
