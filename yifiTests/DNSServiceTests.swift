import Testing
@testable import yifi

@Suite("DNSService.parseDigOutput")
struct DNSServiceTests {
    @Test("Normal NOERROR response extracts query time")
    func normalResponse() {
        let result = DNSService.parseDigOutput(DigFixtures.normalResponse)
        #expect(result == .success(42))
    }

    @Test("Cached response with 0 msec query time")
    func cachedResponse() {
        let result = DNSService.parseDigOutput(DigFixtures.cachedResponse)
        #expect(result == .success(0))
    }

    @Test("SERVFAIL returns queryFailed error")
    func servfailResponse() {
        let result = DNSService.parseDigOutput(DigFixtures.servfailResponse)
        #expect(result == .failure(.queryFailed(status: "SERVFAIL")))
    }

    @Test("NXDOMAIN returns queryFailed error")
    func nxdomainResponse() {
        let result = DNSService.parseDigOutput(DigFixtures.nxdomainResponse)
        #expect(result == .failure(.queryFailed(status: "NXDOMAIN")))
    }

    @Test("Missing Query time line returns parseError")
    func missingQueryTime() {
        let result = DNSService.parseDigOutput(DigFixtures.missingQueryTime)
        #expect(result == .failure(.parseError))
    }

    @Test("Empty output returns parseError")
    func emptyOutput() {
        let result = DNSService.parseDigOutput("")
        #expect(result == .failure(.parseError))
    }

    @Test("Missing status but valid query time returns success")
    func missingStatusValidQueryTime() {
        // When status line is absent, status is nil, so the check `status != "NOERROR"` is skipped
        let result = DNSService.parseDigOutput(DigFixtures.missingStatusValidQueryTime)
        #expect(result == .success(35))
    }
}
