import Testing
import Foundation
@testable import yifi

@Suite("SectionData")
struct SectionDataTests {
    @Test("overallStatus returns neutral when all metrics unavailable")
    func overallStatusNeutralWhenUnavailable() {
        let section = SectionData(section: .insideHomeNetwork)
        // All metrics start as .unavailable(.neverMeasured)
        #expect(section.overallStatus == .neutral)
    }

    @Test("overallStatus returns worst status among available metrics")
    func overallStatusWorstWins() {
        var section = SectionData(section: .insideHomeNetwork)
        // latency = good (5ms), jitter = bad (60ms), packetLoss stays unavailable
        section.metrics[0].addValue(5)    // routerLatency: good
        section.metrics[1].addValue(60)   // routerJitter: bad
        #expect(section.overallStatus == .bad)
    }

    @Test("overallStatus ignores unavailable metrics")
    func overallStatusIgnoresUnavailable() {
        var section = SectionData(section: .insideHomeNetwork)
        // Only set latency to good, leave others unavailable
        section.metrics[0].addValue(5)    // routerLatency: good
        #expect(section.overallStatus == .good)
    }

    @Test("overallStatus returns warning when warning is worst")
    func overallStatusWarning() {
        var section = SectionData(section: .insideHomeNetwork)
        section.metrics[0].addValue(5)    // routerLatency: good
        section.metrics[1].addValue(15)   // routerJitter: warning (>= 10, <= 50)
        #expect(section.overallStatus == .warning)
    }

    @Test("allMetricsUnavailable is true when all unavailable")
    func allMetricsUnavailableTrue() {
        let section = SectionData(section: .insideHomeNetwork)
        #expect(section.allMetricsUnavailable == true)
    }

    @Test("allMetricsUnavailable is false when stale")
    func allMetricsUnavailableFalseWhenStale() {
        var section = SectionData(section: .insideHomeNetwork)
        section.metrics[0].addValue(5)
        section.metrics[0].lastUpdatedAt = Date().addingTimeInterval(-16)
        section.metrics[0].updateStaleness()
        // Stale is not the same as unavailable
        #expect(section.allMetricsUnavailable == false)
    }

    @Test("allMetricsUnavailable is false when any metric available")
    func allMetricsUnavailableFalseWhenAvailable() {
        var section = SectionData(section: .insideHomeNetwork)
        section.metrics[0].addValue(5)
        #expect(section.allMetricsUnavailable == false)
    }
}
