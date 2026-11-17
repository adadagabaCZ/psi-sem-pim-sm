# 2026-11-17 13:33:30 by RouterOS 7.25.1
# system id = 2TS7IDRlPKF
#
/ip dhcp-server network
add address=192.168.1.0/24 dns-server=8.8.8.8 gateway=192.168.1.1
/ip pool
add name=dhcp-pool ranges=192.168.1.100-192.168.1.199
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no name=ether1-R2
set [ find default-name=ether2 ] disable-running-check=no name=ether2-R3
set [ find default-name=ether3 ] disable-running-check=no name=ether3-R4
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no
set [ find default-name=ether6 ] disable-running-check=no
set [ find default-name=ether7 ] disable-running-check=no name=ether7-lan
set [ find default-name=ether8 ] disable-running-check=no name=ether8-wan
/ip address
add address=192.168.1.1/24 interface=ether7-lan network=192.168.1.0
add address=10.0.0.1/30 interface=ether1-R2 network=10.0.0.0
add address=10.0.0.5/30 interface=ether2-R3 network=10.0.0.4
add address=10.0.0.9/30 interface=ether3-R4 network=10.0.0.8
/ip dhcp-client
add interface=ether8-wan name=dhcp-inet
/ip dhcp-server
add address-pool=dhcp-pool interface=ether7-lan lease-time=1d name=dhcp-local
/ip dhcp-server lease
add address=192.168.1.199 client-id=1:2:42:32:1c:7b:0 comment=psi-base-node-1 mac-address=02:42:32:1C:7B:00 server=dhcp-local
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether8-wan src-address=192.168.1.0/24
add action=netmap chain=dstnat comment=R4 dst-port=8292 in-interface=ether8-wan protocol=tcp to-addresses=10.0.0.10 to-ports=8291
add action=netmap chain=dstnat comment=R7 dst-port=8293 in-interface=ether8-wan protocol=tcp to-addresses=10.0.0.30 to-ports=8291
add action=masquerade chain=srcnat out-interface=ether8-wan src-address=10.0.0.0/8
add action=netmap chain=dstnat comment=R6 dst-port=8294 in-interface=ether8-wan protocol=tcp to-addresses=10.0.0.37 to-ports=8291
/routing ospf instance
add disabled=no name=ospf-instance-1 originate-default=always redistribute=connected,ospf router-id=10.0.0.1 version=2 vrf=main
/routing ospf area
add area-id=0.0.0.0 disabled=no instance=ospf-instance-1 name=ospf-area-1 type=default
/routing ospf interface-template
add area=ospf-area-1 disabled=no interfaces=ether3-R4 networks=10.0.0.8/30
add area=ospf-area-1 disabled=no interfaces=ether1-R2 networks=10.0.0.0/30
add area=ospf-area-1 disabled=no interfaces=ether2-R3 networks=10.0.0.4/30
/routing pimsm instance
add disabled=no name=pimsm-instance1 rp-static-override=yes vrf=main
/routing pimsm igmp-interface-template
add disabled=no instance=pimsm-instance1 interfaces=ether1-R2,ether2-R3,ether3-R4,ether7-lan query-interval=1m
/routing pimsm interface-template
add disabled=no hello-period=30s instance=pimsm-instance1 interfaces=ether1-R2,ether2-R3,ether3-R4,ether7-lan
/routing pimsm static-rp
add address=192.168.255.1 comment="static rp pro vsechny multicast adresy" disabled=yes group=224.0.0.0/4 instance=pimsm-instance1
/system identity
set name=R1-MikroTik-CHR