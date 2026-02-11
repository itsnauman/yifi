import Testing
@testable import yifi

@Suite("PingService.parsePingOutput")
struct PingParseOutputTests {
    @Test("Normal 10-packet ping extracts correct average")
    func normalPingAverage() {
        let result = PingService.parsePingOutput(PingFixtures.pingOutput10Packets)
        #expect(result != nil)
        // RTTs: 2.123, 3.456, 2.789, 3.012, 2.567, 3.890, 2.345, 3.678, 2.901, 3.234
        // Sum = 29.995, avg = 2.9995
        #expect(abs(result!.averageLatency - 2.9995) < 0.001)
    }

    @Test("Normal 10-packet ping has zero packet loss")
    func normalPingZeroLoss() {
        let result = PingService.parsePingOutput(PingFixtures.pingOutput10Packets)
        #expect(result != nil)
        #expect(result!.packetLoss == 0.0)
    }

    @Test("Normal 10-packet ping has valid latency")
    func normalPingHasValidLatency() {
        let result = PingService.parsePingOutput(PingFixtures.pingOutput10Packets)
        #expect(result != nil)
        #expect(result!.hasValidLatency == true)
    }

    @Test("Normal 10-packet ping has non-zero jitter")
    func normalPingJitter() {
        let result = PingService.parsePingOutput(PingFixtures.pingOutput10Packets)
        #expect(result != nil)
        #expect(result!.jitter > 0)
    }

    @Test("100% packet loss returns hasValidLatency=false")
    func totalPacketLoss() {
        let result = PingService.parsePingOutput(PingFixtures.pingOutput100PercentLoss)
        #expect(result != nil)
        #expect(result!.packetLoss == 100.0)
        #expect(result!.hasValidLatency == false)
    }

    @Test("100% packet loss returns zero latency and jitter")
    func totalPacketLossZeroValues() {
        let result = PingService.parsePingOutput(PingFixtures.pingOutput100PercentLoss)
        #expect(result != nil)
        #expect(result!.averageLatency == 0)
        #expect(result!.jitter == 0)
    }

    @Test("Partial loss reports correct loss percentage")
    func partialPacketLoss() {
        let result = PingService.parsePingOutput(PingFixtures.pingOutputPartialLoss)
        #expect(result != nil)
        #expect(result!.packetLoss == 30.0)
        #expect(result!.hasValidLatency == true)
    }

    @Test("Partial loss computes jitter from received packets only")
    func partialLossJitter() {
        let result = PingService.parsePingOutput(PingFixtures.pingOutputPartialLoss)
        #expect(result != nil)
        // 7 RTTs: 12.345, 15.678, 14.123, 13.456, 16.789, 11.234, 14.567
        // Should have meaningful jitter from these values
        #expect(result!.jitter > 0)
    }

    @Test("Single packet returns zero jitter")
    func singlePacketZeroJitter() {
        let result = PingService.parsePingOutput(PingFixtures.pingOutputSinglePacket)
        #expect(result != nil)
        #expect(result!.jitter == 0)
        #expect(result!.averageLatency == 5.0)
        #expect(result!.hasValidLatency == true)
    }

    @Test("Truncated output missing statistics returns nil")
    func truncatedOutputReturnsNil() {
        let result = PingService.parsePingOutput(PingFixtures.pingOutputTruncated)
        #expect(result == nil)
    }

    @Test("Empty output returns nil")
    func emptyOutputReturnsNil() {
        let result = PingService.parsePingOutput("")
        #expect(result == nil)
    }

    @Test("Known RTTs [10, 20, 30] compute correct jitter")
    func knownRTTsJitter() {
        let result = PingService.parsePingOutput(PingFixtures.pingOutputKnownRTTs)
        #expect(result != nil)
        // avg = 20, variance = ((10-20)^2 + (20-20)^2 + (30-20)^2) / 3 = 200/3 = 66.667
        // jitter = sqrt(66.667) ≈ 8.165
        #expect(abs(result!.averageLatency - 20.0) < 0.001)
        #expect(abs(result!.jitter - 8.165) < 0.01)
    }

    @Test("Sub-millisecond RTTs are parsed correctly")
    func subMillisecondRTTs() {
        let result = PingService.parsePingOutput(PingFixtures.pingOutputSubMillisecond)
        #expect(result != nil)
        // RTTs: 0.123, 0.456, 0.234
        // avg = 0.271
        #expect(abs(result!.averageLatency - 0.271) < 0.001)
        #expect(result!.hasValidLatency == true)
    }

    @Test("Computed packet loss when % substring missing")
    func computedPacketLoss() {
        let result = PingService.parsePingOutput(PingFixtures.pingOutputComputedLoss)
        #expect(result != nil)
        // 5 transmitted, 3 received → 40% loss
        #expect(abs(result!.packetLoss - 40.0) < 0.001)
    }
}

@Suite("PingService.parseGateway")
struct PingParseGatewayTests {
    @Test("Extracts correct IP from realistic route output")
    func normalGateway() {
        let result = PingService.parseGateway(from: PingFixtures.routeOutputNormal)
        #expect(result == "192.168.1.1")
    }

    @Test("Returns nil when no gateway line")
    func noGatewayLine() {
        let result = PingService.parseGateway(from: PingFixtures.routeOutputNoGateway)
        #expect(result == nil)
    }

    @Test("Returns nil for IPv6 link-local gateway")
    func ipv6LinkLocal() {
        let result = PingService.parseGateway(from: PingFixtures.routeOutputIPv6LinkLocal)
        #expect(result == nil)
    }

    @Test("Returns nil for empty output")
    func emptyOutput() {
        let result = PingService.parseGateway(from: "")
        #expect(result == nil)
    }

    @Test("Trims extra whitespace around gateway IP")
    func extraWhitespace() {
        let result = PingService.parseGateway(from: PingFixtures.routeOutputExtraWhitespace)
        #expect(result == "10.0.0.1")
    }
}
