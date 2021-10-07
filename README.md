# modesfiltered
Dockerized feeder for www.live-military-mode-s.eu built and tested on Raspberry Pi 3 and 4

First of all: Thanks to [Mike](https://github.com/mikenye) for his fantastic (not only) ADSB-containers and brilliant [setup guide](https://mikenye.gitbook.io/ads-b/intro/overview) and [kx1t](https://github.com/kx1t) for his not less fantastic ADSB-containers and especially for his time to give me an easy and detailed walkthrough with lots of examples about "how to dockerize something"

Secondly: **Be warned!** This is highly experimental and might do unexpected and -wanted things. This is a first project and my knowledge is kind of limited.

### Requirements
* A running instance of `dump1090` or `readsb`. Works with bare metall or dockerized versions.
* Memory and a couple of CPU cycles. It's Java.

### example docker-compose.yml
```
version: '3.8'

services:

  modesfiltered:
    image: rhodan76/modesfiltered
    tty: true
    container_name: modesfiltered
    hostname: modesfiltered
    restart: always
#   in case you are using a containerized version of e.g. readsb, it's a good idea to make this container dependent on it.
#    depends_on:
#      - readsb
    environment:
      - MODES_HOST=192.168.2.5
      - MODES_PORT=30003
      - MODES_LOC=Friedrichsdorf, DE
      - MODES_WHITELIST=3E, 3F, AE, A3, AD, 3B, 4D, 15, 43
      - MODES_BLACKLIST=3C4,4CA,3C7,3C6,3C5,489,4B1,400,484,471,440,45A
      - MODES_CALLSIGNS=AAL, ADR, AIB, AFL, AFR, AMT, ANA, ASL, AUA, AUI, AWU, AZA, BAW, BCS, BEE, BEL, BER, BMR, BTI, CAL, CAO, CES, CFG, CHH, CHX, CLW, CLX, CMP, COA, CSA, CSN, CTN, DAL, DEO, DLH, EIN, EJU, ELO, ELY, ENT, EXS, EWG, ETH, EZY, FIN, GMI, GWI, HAL, HLX, IBK, IBS, ISR, JEA, KAL, KLM, LBT, LDA, LGL, LLP, MSC, NAX, NLY, NWA, PGT, PIA, QTR, ROT, RUS, RYR, SAS, SBI, SKS, SRN, SWR, SXS, TAP, TCX, THA, THY, TOM, TRA, TUI, UAE, UPS, VIM, VIR, VLG, VKG, WZZ, 2BB
```

`MODES_HOST` ip of you dump1090/readsb host or name of the container

`MODES_PORT` Standard is 30003, adjust to your needs, must be SBS format

`MODES_LOC`
Example for you location:
`Friedrichsdorf, DE`
So, basically the town / area of your receiver and the alpha-2 code of the corresponding country.

The data for whitelist, blacklist and callsigns is that what is shipped with the feeder. Adjust to your needs and location. Whitelist and Blacklist are the first two or three digits of the MODE-S hex code, the callsigns are those which are filtered out to see the interesting things. If there are no entries in the docker-compose.yml, the standard configuration will be used. What happens if you key in more than two or three digits or random stuff as callsign? I didn't try and maybe you shouldn't also.

Some more info about filtering out of the feeders readme:
>1) Filtering:
>
>During start the program looks for the file named 'blacklist.txt'. It contains a list of comma separated HexIDs (first 3 positions of ICAO24 HexID).
>
>Example: 3C4, 4CA, 484
>
>You should adapt the list to your region!
>
>If the first three symbols of a received message ICAO24 ID contains one of the IDs in the list, the message is ignored. This method can filter out a lot but not all of civil registrations.
>
>For a station in Germany at Su 17-04-2016 from 20:00 to 22:00 hours 1301534 messages were received. With an adapted blacklist 773364 of it have been filtered out. This is nearly 60 percent.
>
>Problem: false filtering of small government jets with civil registration. So be careful with adding HexIDs!
>
>The second file is called 'whitelist.txt' and contains a list of comma separated HexIDs (first two positions of ICAO24 HexID) that we know of being interesting.
>
>Example: 3E, 3F, AE, A3, AD, 3B, 4D, 43
>
>You should adapt the list to your region!
>
>Messages of type 3 (that contain position information) from planes whose IDs start with the symbols in the whitelist are sent to the server with a higher update rate of two minutes. For all other planes only the first message seen of each type (1, 3, 5, 6, 7) is sent to the server and all following messages are banned (ignored) for an hour. You can follow the behaviour of the ban system in the logs (if you redirect std-out or error-out to a log file).
>
>The third file is called 'callsigns.txt' and contains a list of comma separated callsigns (first 3 positions of ICAO24 callsign) that will be filtered out.
>
>Example: PGT, EZY, GWI, BER, NAX, AFL, KAL, KLM
>
>After having received a message without callsign the program suspends processing of the message for 10 s. This procedure is repeated up to 6 times. So all in all the program waits 60 seconds for updates of the field callsign.
>Just before sending the message to the SQL server, the program compares the value of this message to the callsigns list.

### Known issues
* The container is spamming your docker log - I'll silence it with a later version
* The feeder stops feeding - yes, happens and unfortunately I have no clue why. Yet.
