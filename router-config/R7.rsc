# 2026-11-17 13:36:44 by RouterOS 7.25.1
# system id = F00OVHGvkxN
#
/ip dhcp-server network
add address=192.168.2.0/24 dns-server=8.8.8.8 gateway=192.168.2.1
/ip pool
add name=dhcp-pool ranges=192.168.2.100-192.168.2.200
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no name=ether1-R4
set [ find default-name=ether2 ] disable-running-check=no name=ether2-R6
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
set [ find default-name=ether5 ] disable-running-check=no
set [ find default-name=ether6 ] disable-running-check=no
set [ find default-name=ether7 ] disable-running-check=no
set [ find default-name=ether8 ] disable-running-check=no name=ether8-LAN
/ip address
add address=10.0.0.30/30 interface=ether1-R4 network=10.0.0.28
add address=10.0.0.38/30 interface=ether2-R6 network=10.0.0.36
add address=192.168.2.1/24 interface=ether8-LAN network=192.168.2.0
/ip dhcp-server
add address-pool=dhcp-pool interface=ether8-LAN lease-time=1d name=dhcp-server
/ip dns
set allow-remote-requests=yes servers=8.8.8.8
/ip firewall nat
add action=masquerade chain=srcnat out-interface=!ether8-LAN src-address=192.168.2.0/24
/routing filter rule
add chain=ospf-in rule="accept;"
/routing ospf instance
add disabled=no in-filter-chain=ospf-in name=ospf-instance-1 originate-default=never redistribute=connected,ospf router-id=main version=2 vrf=main
/routing ospf area
add area-id=0.0.0.0 instance=ospf-instance-1 name=ospf-area-1 type=default
/routing ospf interface-template
add area=ospf-area-1 disabled=no interfaces=ether1-R4 networks=10.0.0.28/30
add area=ospf-area-1 disabled=no interfaces=ether2-R6 networks=10.0.0.36/30
/routing pimsm instance
add disabled=no name=pimsm-instance1 rp-static-override=yes vrf=main
/routing pimsm igmp-interface-template
add disabled=no instance=pimsm-instance1 interfaces=ether1-R4,ether2-R6,ether8-LAN query-interval=30s
/routing pimsm interface-template
add disabled=no hello-period=30s instance=pimsm-instance1 interfaces=ether1-R4,ether2-R6,ether8-LAN
/routing pimsm static-rp
add address=192.168.255.1 comment="staticky RP pro vsechny multicast adresy" disabled=yes group=238.0.0.0/4 instance=pimsm-instance1
/system identity
set name=R7-MikroTik-CHR
