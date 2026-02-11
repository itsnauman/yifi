import Foundation

enum PingFixtures {
    // MARK: - Route Output

    static let routeOutputNormal = """
       route to: default
    destination: default
           mask: default
        gateway: 192.168.1.1
      interface: en0
          flags: <UP,GATEWAY,DONE,STATIC,PRCLONING,GLOBAL>
     recvpipe  sendpipe  ssthresh  rtt,msec    mtu        weight    expire
           0         0         0         0      1500         1         0
    """

    static let routeOutputNoGateway = """
       route to: default
    destination: default
           mask: default
      interface: en0
          flags: <UP,DONE,STATIC>
    """

    static let routeOutputIPv6LinkLocal = """
       route to: default
    destination: default
           mask: default
        gateway: fe80::1%en0
      interface: en0
          flags: <UP,GATEWAY,DONE,STATIC,PRCLONING,GLOBAL>
    """

    static let routeOutputExtraWhitespace = """
       route to: default
    destination: default
           mask: default
        gateway:   10.0.0.1
      interface: en0
          flags: <UP,GATEWAY,DONE,STATIC,PRCLONING,GLOBAL>
    """

    // MARK: - Ping Output

    static let pingOutput10Packets = """
    PING 192.168.1.1 (192.168.1.1): 56 data bytes
    64 bytes from 192.168.1.1: icmp_seq=0 ttl=64 time=2.123 ms
    64 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=3.456 ms
    64 bytes from 192.168.1.1: icmp_seq=2 ttl=64 time=2.789 ms
    64 bytes from 192.168.1.1: icmp_seq=3 ttl=64 time=3.012 ms
    64 bytes from 192.168.1.1: icmp_seq=4 ttl=64 time=2.567 ms
    64 bytes from 192.168.1.1: icmp_seq=5 ttl=64 time=3.890 ms
    64 bytes from 192.168.1.1: icmp_seq=6 ttl=64 time=2.345 ms
    64 bytes from 192.168.1.1: icmp_seq=7 ttl=64 time=3.678 ms
    64 bytes from 192.168.1.1: icmp_seq=8 ttl=64 time=2.901 ms
    64 bytes from 192.168.1.1: icmp_seq=9 ttl=64 time=3.234 ms

    --- 192.168.1.1 ping statistics ---
    10 packets transmitted, 10 packets received, 0.0% packet loss
    round-trip min/avg/max/stddev = 2.123/2.999/3.890/0.512 ms
    """

    static let pingOutput100PercentLoss = """
    PING 192.168.1.1 (192.168.1.1): 56 data bytes
    Request timeout for icmp_seq 0
    Request timeout for icmp_seq 1
    Request timeout for icmp_seq 2
    Request timeout for icmp_seq 3
    Request timeout for icmp_seq 4
    Request timeout for icmp_seq 5
    Request timeout for icmp_seq 6
    Request timeout for icmp_seq 7
    Request timeout for icmp_seq 8
    Request timeout for icmp_seq 9

    --- 192.168.1.1 ping statistics ---
    10 packets transmitted, 0 packets received, 100.0% packet loss
    """

    static let pingOutputPartialLoss = """
    PING 1.1.1.1 (1.1.1.1): 56 data bytes
    64 bytes from 1.1.1.1: icmp_seq=0 ttl=55 time=12.345 ms
    64 bytes from 1.1.1.1: icmp_seq=1 ttl=55 time=15.678 ms
    Request timeout for icmp_seq 2
    64 bytes from 1.1.1.1: icmp_seq=3 ttl=55 time=14.123 ms
    Request timeout for icmp_seq 4
    64 bytes from 1.1.1.1: icmp_seq=5 ttl=55 time=13.456 ms
    Request timeout for icmp_seq 6
    64 bytes from 1.1.1.1: icmp_seq=7 ttl=55 time=16.789 ms
    64 bytes from 1.1.1.1: icmp_seq=8 ttl=55 time=11.234 ms
    64 bytes from 1.1.1.1: icmp_seq=9 ttl=55 time=14.567 ms

    --- 1.1.1.1 ping statistics ---
    10 packets transmitted, 7 packets received, 30.0% packet loss
    round-trip min/avg/max/stddev = 11.234/14.027/16.789/1.725 ms
    """

    static let pingOutputSinglePacket = """
    PING 192.168.1.1 (192.168.1.1): 56 data bytes
    64 bytes from 192.168.1.1: icmp_seq=0 ttl=64 time=5.000 ms

    --- 192.168.1.1 ping statistics ---
    1 packets transmitted, 1 packets received, 0.0% packet loss
    round-trip min/avg/max/stddev = 5.000/5.000/5.000/0.000 ms
    """

    static let pingOutputTruncated = """
    PING 192.168.1.1 (192.168.1.1): 56 data bytes
    64 bytes from 192.168.1.1: icmp_seq=0 ttl=64 time=2.123 ms
    64 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=3.456 ms
    """

    static let pingOutputKnownRTTs = """
    PING 192.168.1.1 (192.168.1.1): 56 data bytes
    64 bytes from 192.168.1.1: icmp_seq=0 ttl=64 time=10.000 ms
    64 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=20.000 ms
    64 bytes from 192.168.1.1: icmp_seq=2 ttl=64 time=30.000 ms

    --- 192.168.1.1 ping statistics ---
    3 packets transmitted, 3 packets received, 0.0% packet loss
    round-trip min/avg/max/stddev = 10.000/20.000/30.000/8.165 ms
    """

    static let pingOutputSubMillisecond = """
    PING 192.168.1.1 (192.168.1.1): 56 data bytes
    64 bytes from 192.168.1.1: icmp_seq=0 ttl=64 time=0.123 ms
    64 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=0.456 ms
    64 bytes from 192.168.1.1: icmp_seq=2 ttl=64 time=0.234 ms

    --- 192.168.1.1 ping statistics ---
    3 packets transmitted, 3 packets received, 0.0% packet loss
    round-trip min/avg/max/stddev = 0.123/0.271/0.456/0.139 ms
    """

    static let pingOutputComputedLoss = """
    PING 192.168.1.1 (192.168.1.1): 56 data bytes
    64 bytes from 192.168.1.1: icmp_seq=0 ttl=64 time=5.000 ms
    64 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=6.000 ms
    64 bytes from 192.168.1.1: icmp_seq=2 ttl=64 time=7.000 ms

    --- 192.168.1.1 ping statistics ---
    5 packets transmitted, 3 packets received
    round-trip min/avg/max/stddev = 5.000/6.000/7.000/0.816 ms
    """
}
