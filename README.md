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

Routery od Cisca nemají implementované přihlašování pro správu, routery od firmy MikroTik používají uživatelské jméno "admin" a prázdné heslo (stačí formulář/dotaz potvrdit klávesou ENTER).
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
Jedná se o modifikaci předchozích skriptů. Zdroj pouze vysílá na jinou multicastovou adresu - 232.0.0.1 (pro source-specific multicast). Příjemce se přihlašuje k odběru od specifické adresy (192.168.1.199 - rezervovaná adresa přidělená protokolem DHCP stanici psi-base-node-1).

## Multicast pomocí PIM-SM
Protokol "Protocol independent multicast - sparse mode" byl zvolen z důvodu kompatibility s routery výrobce MikroTik. Ostatní multicastové protokoly (včetně příbuzného PIM-DM) nejsou plně (či vůbec) v operačním systému MikroTik ROS implementovány.
### Statický Rendezvous Point (RP)
Nejjednodušší, ale nejzdlouhavější konfigurace - každý router dostal od administrátora informaci o tom, který router byl předurčen jako rendezvous point. Pro účely této semestrální práce byl zvolen router R6. Jako adresa rendezvous pointu byla zadána adresa na rozhraní "loopback", konkrétně "192.168.255.1". Pozn.: Tato konfigurace je sice součástí konfiguračních skriptů, ale není povolená (prefix "no" u Cisca, resp "disabled=yes" u MikroTiku).
### Bootstrap Router (BSR)
Tato konfigurace vyžaduje pouze specifikování "rozhodčího" - Bootstrap routeru - a alespoň jednoho kandidáta (Candidate RP). Jako Bootstrapt router byl zvolen R3 s adresou "192.168.255.2", jako kandidát opět R6 (stejně jako u předchozího příkladu). Ostatní routery nepotřebují žádnou znalost navíc - veškeré informace se sítí šíří dynamicky protokolem PIM-SM.
### Source-Specific Multicast
Multicast se specifickým zdrojem nahrazuje klasickou (*, R) strukturu jednodušší (S, R). V této konfiguraci není vůbec potřeba rendezvous point, konvergence multicastoveho stromu je řešena dynamicky přes protokol PIM-SM. Proto lze BSR i SSM demonstrovat na stejné konfiguraci sítě. Tato varianta je vhodná pro případy, kdy příjemci znají adresu zdroje, která je v čase neměnná. Příkladem z praxe by mohla být internetová televize - zdrojem vysílání v rámci sítě je jedna určitá koncová stanice, která např. spojuje různé kanály od různých televizních společností do jednoho multiplexu, který se pak může multicastově šířit sítí.

## Problémy při implementaci
Během implemenetace jsem narazil na několik problémů.
### OSPF - výchozí Router ID
Při prvním pokusu o zprovoznění sítě jsem nastavil všem "domácím" sítím stejný rozsah "192.168.0.0/24", čiže R1, R5 a R7 měli všechny na nějakém rozhranní adresu "192.168.0.1" (byly výchozí branou dané sítě). OSPF bere jako výchozí Router ID nejvyšší adresu, která se na daném zařízení vyskytuje. Došlo ke kolizi Router ID, která se vzhledem k cachování záznamů velice obtížně diagnostikovala. Řešením bylo nastavit každému routeru statickoé Router ID dle jeho nejnižší adresy v rozsahu "10.0.0.0/8", mezi nimiž je administrátorem zaručena unikátnost.
### IGMP Query Period - Cisco vs Mikrotik 
Jediná neshoda ve výchozích hodnotách mezi výrobci byla zaznemenána v IGMP Query Period - MikroTik má hodnotu 2 minuty 5 sekund, Cisco 30 sekund. Routery od Cisca na tuto skutečnost poměrně důsledně upozornily. V původně užívané verzi ROS 7.22.1 z neznámých důvodů chybí možnost tuto periodu změnit, proto jsem byl nucen přejít na novější verzi ROS 7.25.1.
### NAT
NAT je navržen především pro překlad unicastové komunikace a běžně nepřekládá multicastové skupiny ani řídicí zprávy IGMP a PIM. Multicastový provoz proto přes hranici NATu zpravidla neprojde, pokud zařízení nepodporuje speciální multicastové funkce. V této topologii se proto multicast routuje v hlavní síti bez NATu; domácí sítě za R5 a R7 jsou od ní naopak oddělené překladem adres (NAT je zde implementován, experimentálně ověřeno že příjemcům multicastové komunikace nevadí).

## Spuštění projektu
Projekt včetně obrazů stanic je součástí tohoto git repozitáře. Lze jej spustit v aplikaci GNS3. Bázové stanice mají nejaktuálnější možnou verzi tohoto repozitáře uloženou v adresářích "/gns3volumes/src/psi-sem-pim-sm/". Příkazem "python3 source.py" lze spustit zdroj dat, ostatní skripty lze spustit obdobně.

Pomocí nástroje WireShark je možné sledovat tok dat mezi routery. Ve výchozí konfiguraci není dobře vidět multicastovost přenosu (přenos se hned na R1 rozdělí mezi R2 a R4), ovšem při nasimulování výpadků v síti dojde k přepočítání distribučního stromu do mnohem názornější podoby. Také je dobře vidět skutečnost, že multicastové spojení nemusí procházet přes rendezvous point ani bootstrap router.

## Závěr
Tento projekt demonstruje implementaci protokolu PIM-SM v síti složené z více routerů od více výrobců. Ukazuje efektivitu multicastového přenosu (šetření šířky pásma, nepotřebnost replikovaných unicastových spojení...) a lze demonstrovat rychlost konvergence distribučního stromu při výpadku některého z routerů.

Při vývoji bylo lehkým omezením maximální rychlost na jednotlivých rozhraních routerů od firmy MikroTik bez zakoupené licence - zejména při vzdáleném připojování do koncových stanic, respektive při inicializaci vzdáleného pracovního prostoru (dochází ke stahování nemalého množství dat, což při rychlosti 1Mbit/s prostě chvíli trvá).

