# 2026-11-17 13:34:59 by RouterOS 7.25.1
# system id = 5Wl/AgDBIOD
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no name=ether1-R1
set [ find default-name=ether2 ] disable-running-check=no name=ether2-R3
set [ find default-name=ether3 ] disable-running-check=no name=ether3-R7
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no
set [ find default-name=ether6 ] disable-running-check=no
set [ find default-name=ether7 ] disable-running-check=no
set [ find default-name=ether8 ] disable-running-check=no
/ip address
add address=10.0.0.10/30 interface=ether1-R1 network=10.0.0.8
add address=10.0.0.29/30 interface=ether3-R7 network=10.0.0.28
add address=10.0.0.18/30 interface=ether2-R3 network=10.0.0.16
/ip dhcp-client
add interface=ether1-R1 name=client1
/ip dns
set allow-remote-requests=yes servers=8.8.8.8
/routing filter rule
add chain=ospf-in rule="accept;"
/routing ospf instance
add disabled=no in-filter-chain=ospf-in name=ospf-instance-1 originate-default=never redistribute=connected,ospf router-id=10.0.0.10 version=2 vrf=main
/routing ospf area
add area-id=0.0.0.0 instance=ospf-instance-1 name=ospf-area-1 type=default
/routing ospf interface-template
add area=ospf-area-1 interfaces=ether1-R1 networks=10.0.0.8/30
add area=ospf-area-1 disabled=no interfaces=ether2-R3 networks=10.0.0.12/30
add area=ospf-area-1 disabled=no interfaces=ether3-R7 networks=10.0.0.28/30
/routing pimsm instance
add disabled=no name=pimsm-instance1 rp-static-override=no vrf=main
/routing pimsm igmp-interface-template
add disabled=no instance=pimsm-instance1 interfaces=ether1-R1,ether2-R3,ether3-R7 query-interval=1m
/routing pimsm interface-template
add disabled=no hello-period=30s instance=pimsm-instance1 interfaces=ether1-R1,ether2-R3,ether3-R7
/routing pimsm static-rp
add address=192.168.255.1 comment="static RP pro vsechny multicast adresy" disabled=yes group=238.0.0.0/4 instance=pimsm-instance1
/system identity
set name=R4-MikroTik-CHR
