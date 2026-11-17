#
# mostly from
#   https://github.com/moozer/multicasting/blob/master/receiver.py
#

import socket
import struct
import sys

multicast_group = "239.0.0.1"
server_address = ("", 10000)

# Create the socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
# Bind to the server address
sock.bind(server_address)

# Tell the operating system to add the socket to the multicast group
# on all interfaces.
group = socket.inet_aton(multicast_group)
mreq = struct.pack("=4s4s", group, socket.inet_aton("0.0.0.0"))
sock.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq)


print("\nWaiting to receive message")
# Receive/respond loop
while True:
    
    data, address = sock.recvfrom(1024)
    
    print("received %s bytes from %s" % (len(data), address))
    print(data.decode("utf-8"))