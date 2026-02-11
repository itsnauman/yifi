import Testing
import Foundation
@testable import yifi

@Suite("MetricData")
struct MetricDataTests {
    // MARK: - addValue

    @Test("addValue updates currentValue")
    func addValueUpdatesCurrentValue() {
        var metric = MetricData(type: .routerLatency)
        metric.addValue(42.5)
        #expect(metric.currentValue == 42.5)
    }

    @Test("addValue appends to history")
    func addValueAppendsHistory() {
        var metric = MetricData(type: .routerLatency)
        metric.addValue(10)
        metric.addValue(20)
        #expect(metric.history == [10, 20])
    }

    @Test("addValue caps history at 30")
    func addValueCapsHistory() {
        var metric = MetricData(type: .routerLatency)
        for i in 0..<35 {
            metric.addValue(Double(i))
        }
        #expect(metric.history.count == 30)
        #expect(metric.history.first == 5)
        #expect(metric.history.last == 34)
    }

    @Test("addValue sets availability to available")
    func addValueSetsAvailable() {
        var metric = MetricData(type: .routerLatency)
        #expect(metric.availability == .unavailable(.neverMeasured))
        metric.addValue(10)
        #expect(metric.availability == .available)
    }

    @Test("addValue sets lastUpdatedAt")
    func addValueSetsLastUpdated() {
        var metric = MetricData(type: .routerLatency)
        #expect(metric.lastUpdatedAt == nil)
        metric.addValue(10)
        #expect(metric.lastUpdatedAt != nil)
    }

    // MARK: - updateStaleness

    @Test("updateStaleness marks stale after 15 seconds")
    func stalenessAfterThreshold() {
        var metric = MetricData(type: .routerLatency)
        metric.addValue(10)
        // Backdate to 16 seconds ago
        metric.lastUpdatedAt = Date().addingTimeInterval(-16)
        metric.updateStaleness()
        #expect(metric.availability == .stale)
    }

    @Test("updateStaleness does not mark stale within threshold")
    func notStaleWithinThreshold() {
        var metric = MetricData(type: .routerLatency)
        metric.addValue(10)
        // Backdate to 5 seconds ago (well within threshold)
        metric.lastUpdatedAt = Date().addingTimeInterval(-5)
        metric.updateStaleness()
        #expect(metric.availability == .available)
    }

    @Test("updateStaleness is no-op when unavailable")
    func stalenessNoOpWhenUnavailable() {
        var metric = MetricData(type: .routerLatency)
        metric.markUnavailable(reason: .probeFailed)
        metric.updateStaleness()
        #expect(metric.availability == .unavailable(.probeFailed))
    }

    @Test("updateStaleness is no-op when already stale")
    func stalenessNoOpWhenStale() {
        var metric = MetricData(type: .routerLatency)
        metric.addValue(10)
        metric.lastUpdatedAt = Date().addingTimeInterval(-16)
        metric.updateStaleness()
        #expect(metric.availability == .stale)
        // Call again - should remain stale (guard checks for .available)
        metric.updateStaleness()
        #expect(metric.availability == .stale)
    }

    // MARK: - status

    @Test("Status returns neutral when unavailable")
    func statusNeutralWhenUnavailable() {
        let metric = MetricData(type: .routerLatency)
        #expect(metric.status == .neutral)
    }

    @Test("Status returns neutral when stale")
    func statusNeutralWhenStale() {
        var metric = MetricData(type: .routerLatency)
        metric.addValue(5) // good latency
        metric.lastUpdatedAt = Date().addingTimeInterval(-16)
        metric.updateStaleness()
        #expect(metric.status == .neutral)
    }

    @Test("Status delegates to MetricType when available")
    func statusDelegatesToType() {
        var metric = MetricData(type: .routerLatency)
        metric.addValue(5) // < 20ms = good
        #expect(metric.status == .good)
    }

    // MARK: - formattedValue

    @Test("formattedValue returns N/A when unavailable")
    func formattedValueNA() {
        let metric = MetricData(type: .routerLatency)
        #expect(metric.formattedValue == "N/A")
    }

    @Test("formattedValue linkRate uses 0 decimal places")
    func formattedValueLinkRate() {
        var metric = MetricData(type: .linkRate)
        metric.addValue(866.7)
        #expect(metric.formattedValue == "867")
    }

    @Test("formattedValue latency uses 1 decimal place")
    func formattedValueLatency() {
        var metric = MetricData(type: .routerLatency)
        metric.addValue(12.345)
        #expect(metric.formattedValue == "12.3")
    }

    @Test("formattedValue packetLoss uses 1 decimal place")
    func formattedValuePacketLoss() {
        var metric = MetricData(type: .routerPacketLoss)
        metric.addValue(3.14159)
        #expect(metric.formattedValue == "3.1")
    }
}
