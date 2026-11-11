import socket
import struct

multicast_group = "232.0.0.1"
multicast_source = "192.168.1.199"
IP_ADD_SOURCE_MEMBERSHIP = getattr(socket, "IP_ADD_SOURCE_MEMBERSHIP", 39)

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.bind(("", 10000))

# struct ip_mreq_source:
#   imr_multiaddr
#   imr_interface
#   imr_sourceaddr
mreq = struct.pack(
    "=4s4s4s",
    socket.inet_aton(multicast_group),
    socket.inet_aton("0.0.0.0"),
    socket.inet_aton(multicast_source)
)


sock.setsockopt(socket.IPPROTO_IP, IP_ADD_SOURCE_MEMBERSHIP, mreq) # set multicast group and specific source

print(f"Listening for {multicast_source} -> {multicast_group}:10000")

while True:
    data, address = sock.recvfrom(1024)
    print(f"{address}: {data.decode('utf-8')}")