
#
# mostly copied from
#   https://github.com/moozer/multicasting/blob/master/sender.py
#

import socket
import struct
import sys
import time

message = "The Bee Movie Script:"
multicast_group = ("239.0.0.1", 10000) # First address in the private block

# Create the datagram socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 32)

# Set a timeout so the socket does not block indefinitely when trying
# to receive data.
sock.settimeout(0.2)

counter = 0
with (open("bee.txt", "r")) as file:
    try:
        
        while True:
            counter += 1

            # Send data to the multicast group
            print("%d: sending \"%s\"" % (counter, message))
            sent = sock.sendto(message.encode("utf-8"), multicast_group)

            message = file.readline().strip() #read another line
            if (len(message) == 0):
                file.seek(0) #reset to start so we can keep looping indefinitely
            time.sleep( 5 )
        
    finally:
        print("closing socket")
        sock.close()