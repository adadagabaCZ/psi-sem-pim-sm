# 2026-11-17 13:37:43 by RouterOS 7.25.1
# system id = ++Q/Ml2WbpF
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no name=ether1-R3
set [ find default-name=ether2 ] disable-running-check=no name=ether2-R5
set [ find default-name=ether3 ] disable-running-check=no name=ether3-R7
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no
set [ find default-name=ether6 ] disable-running-check=no
set [ find default-name=ether7 ] disable-running-check=no
set [ find default-name=ether8 ] disable-running-check=no
/ip address
add address=10.0.0.37/30 interface=ether3-R7 network=10.0.0.36
add address=10.0.0.26/30 interface=ether1-R3 network=10.0.0.24
add address=10.0.0.34/30 interface=ether2-R5 network=10.0.0.32
add address=192.168.255.1 interface=lo network=192.168.255.1
/ip dns
set allow-remote-requests=yes servers=8.8.8.8
/routing ospf instance
add disabled=no name=instance router-id=10.0.0.37 version=2 vrf=main
/routing ospf area
add area-id=0.0.0.0 instance=instance name=area type=default
/routing ospf interface-template
add area=area disabled=no interfaces=ether3-R7 networks=10.0.0.36/30
add area=area disabled=no interfaces=ether1-R3 networks=10.0.0.24/30
add area=area disabled=no interfaces=ether2-R5 networks=10.0.0.32/30
add area=area disabled=no interfaces=lo networks=192.168.255.1/32
/routing pimsm instance
add disabled=no name=pimsm-instance1 rp-static-override=no vrf=main
/routing pimsm bsr rp-candidate
add address=192.168.255.1%lo disabled=no group=224.0.0.0/4 instance=pimsm-instance1
/routing pimsm igmp-interface-template
add disabled=yes instance=pimsm-instance1 interfaces=ether1-R3,ether2-R5,ether3-R7,lo query-interval=1m
/routing pimsm interface-template
add disabled=no hello-period=30s instance=pimsm-instance1 interfaces=ether1-R3,ether2-R5,ether3-R7,lo
/routing pimsm static-rp
add address=192.168.255.1 comment="staticky RP pro vsechny multicast adresy" disabled=yes group=238.0.0.0/4 instance=pimsm-instance1
/system identity
set name=R6-MikroTik-CHR
