# Semestrální práce KIV/PSI
-   Téma: PIM-SM
-   Autor: Adam Gabriel
## Popis projektu
Tato semestrální práce demonstruje využití protokolu PIM-SM v různých režimech v síti s netriviální topologií a routery od více výrobců. 

## Popis topologie sítě
Síť lze rozdělit na "hlavní" síť, propojující jednotlivé routery, a na "domácí" sítě, ve kterých se nachází koncové stanice.
### Routery
Síť obsahuje celkem 7 routerů,
-   R1, R4, R6 a R7 typu Mikrotik CHR 7.22.1 (s operačním systémem Mikrotik ROS 7.25.1)
-   R2, R3 a R5 typu Cisco 7200 150-1.M
Routery R2, R3, R4 a R6 slouží čistě k směrování v topologii, routery R5 a R7 obsluhují koncové stanice. Router R1 se stará o připojení modelované topologie k internetu, obsluhuje koncovou stanici a mapuje porty pro nástroj MikroTik WinBox - nástroj pro správu a konfiguraci routerů s grafickým uživatelským rozhraním. Jednotlivé konfigurace lze nalézt ve složce "router-config". Konfigurace byly získány příkazy /export compact, resp. show running-config brief. Skripty s příponou .rsc lze přímo použít k dávkové konfiguraci nového routeru. Tyto skripty odpovídají variantě PIM-BSR, resp PIM-SSM (konfiguračně shodné).
### Adresace
V síti jsou použita následující adresační pravidla:
-    "Domácí" sítě jsou typu "192.168.x.0/24", kde x je unikátní pro každou domácí síť (Unikátnost je potřeba vzhledem k implicitní nekompatibilitě multicastoveho routování s technikou NAT)
-   "Propojovací" segmenty sítě jsou typu "10.0.0.x/30", kde x je pořadí síťového segmentu dle jeho pozice v GNS3 topologii, a adresa jednotlivých routerů je dána jejich označením, kdy router s vyšším pořadovým číslem dostane vyšší adresu v segmentu. Příklad: Segment mezi R3 a R6 je 7. v pořadí, jeho adresa bude 10.0.0.24/30. R3 má nižší pořadové číslo, proto jeho adresa bude 10.0.0.25 a adresa R6 bude 10.0.0.26.
### Směrování
Směrování skrzeva síť je zajištěno protokolem OSPF. Celý rozsah 10.0.0.0/8 je skryt technikou NAT; koncová stanice za routerem R1 je vůči internetu také skryta technikou NAT, ovšem z rozsahu 10.0.0.0/8 je volně přístupná (kvůli nekompatibilitě NAT a multicastu). Koncové stanice za routery R5 a R7 jsou vůči celé síti skryty technikou NAT.

## Demonstrační skripty
### source.py, reciever.py
Tyto skripty zastupují "klasický" (*, R) multicast, kdy zařízení se skriptem source.py (např. psi-base-node-1) zahájí vysílání načítáním textového souboru bee.txt (přepis dialogu filmu Pan Včelka (The Bee Movie), dostupný na https://gist.github.com/MattIPv4/045239bc27b16b2bcf7a3a9a4648c08a). Tento soubor posílá řádku po řádce na multicastovou adresu 239.0.0.1 (první adresa "privátního" multicastového rozsahu). reciever.py se přihlásí k odběru z této multicast skupiny, a vypisuje do konzole přijatá data.
### source-ssm.py, reciever-ssm.py
Jedná se o modifikaci předchozích skriptů. Zdroj pouze vysílá na jinou multicastovou adresu - 232.0.0.1 (pro source-specific multicast). Příjemce se přihlašuje k odběru od specifické adresy