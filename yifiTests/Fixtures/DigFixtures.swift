import Foundation

enum DigFixtures {
    static let normalResponse = """
    ; <<>> DiG 9.10.6 <<>> google.com +tries=1 +time=5
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12345
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 512
    ;; QUESTION SECTION:
    ;google.com.			IN	A

    ;; ANSWER SECTION:
    google.com.		300	IN	A	142.250.80.46

    ;; Query time: 42 msec
    ;; SERVER: 8.8.8.8#53(8.8.8.8)
    ;; WHEN: Mon Feb 03 12:00:00 PST 2026
    ;; MSG SIZE  rcvd: 55
    """

    static let cachedResponse = """
    ; <<>> DiG 9.10.6 <<>> google.com +tries=1 +time=5
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 54321
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

    ;; ANSWER SECTION:
    google.com.		300	IN	A	142.250.80.46

    ;; Query time: 0 msec
    ;; SERVER: 8.8.8.8#53(8.8.8.8)
    ;; WHEN: Mon Feb 03 12:00:00 PST 2026
    ;; MSG SIZE  rcvd: 55
    """

    static let servfailResponse = """
    ; <<>> DiG 9.10.6 <<>> google.com +tries=1 +time=5
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: SERVFAIL, id: 11111
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

    ;; Query time: 15 msec
    ;; SERVER: 8.8.8.8#53(8.8.8.8)
    ;; WHEN: Mon Feb 03 12:00:00 PST 2026
    ;; MSG SIZE  rcvd: 40
    """

    static let nxdomainResponse = """
    ; <<>> DiG 9.10.6 <<>> nonexistent.invalid +tries=1 +time=5
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 22222
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

    ;; Query time: 25 msec
    ;; SERVER: 8.8.8.8#53(8.8.8.8)
    ;; WHEN: Mon Feb 03 12:00:00 PST 2026
    ;; MSG SIZE  rcvd: 115
    """

    static let missingQueryTime = """
    ; <<>> DiG 9.10.6 <<>> google.com +tries=1 +time=5
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 33333
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

    ;; ANSWER SECTION:
    google.com.		300	IN	A	142.250.80.46

    ;; SERVER: 8.8.8.8#53(8.8.8.8)
    ;; WHEN: Mon Feb 03 12:00:00 PST 2026
    ;; MSG SIZE  rcvd: 55
    """

    static let missingStatusValidQueryTime = """
    ;; Query time: 35 msec
    ;; SERVER: 8.8.8.8#53(8.8.8.8)
    """
}
