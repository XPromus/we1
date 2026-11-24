#import "../../../Template/hszg.typ": *

== send vs. read

#slide(align: horizon)[
    - *Cross-origin writes sind erlaubt:* Es können Forms abgegeben, Bilder geladen, Scripts included und `fetch()` ausgeführt werden. Alles erreicht den anderen Server, potenziell mit den Cookies
    - *Cross-origin reads sind blockiert:* SOP verhindert, dass der _response body_ zu meinem Script zurückkommt
]

#slide(align: horizon)[
    #set text(20pt)
    Warum dieses Design? Was würde passieren, wenn reads erlaubt wären?

    #pause

    #textbox()[
        Du bist eingeloggt in `bank.com` in einem anderen Tab.
        Danach besuchst du `evil.com`, die `fetch('https://bank.com/account/overview', { credentials: 'include' })` ausführen. 

        #pause

        Der Browser hängt den `bank.com` Session-Cookie an die Request, aber nur wenn `bank.com` mitspielt 
        - `fetch` sendet Cookies nur cross-origin, wenn `credentials: include` dabei ist
        - Cookies ohne `SameSite` gelten seit 2020 als Lax und werden bei cross-site Requests nicht angehangen (Cookie ist hier also `SameSite=None`)

        #pause

        Wenn JS bei `evil.com` die Response lesen könnte, hätte der Angreifer die gesamte Accountseite mit deinen privaten Auth-Daten. 
    ]

    #pause

    *SOP bricht diese Attacke:* Die Request wird geschickt, die Bank antwortet, der Browser erhält sie und verweigert die Bytes an das Skript des Angreifers zu geben.

    #speaker-note()[
        #set text(size: 21pt)

        Zum letzten Satz: 
        - Ein Network Tool wie Wireshark kann dennoch die volle Response auslesen. 
        - Impliziert aber, dass es einen anderen Angreifer gibt
        - SOP stoppt nur auf Browser-Ebene

        #table(
            columns: (1fr, 1fr, 1fr),
            table.header(
                [Angreifer], [Beispiel], [Was hält auf?]
            ),
            [Böser Code der im Browser des Opfers läuft], [Ein Skript von `evil.com` während man browst], [*SOP* (+ CORS, Cookies und Storage Regeln)],
            [Passiver Observer auf dem Netzwerk-Pfad], [Offenes WiFi, feindlicher Router, ISP], [*TLS/HTTPS*: keine Relation zu SOP],
            [Angreifer mit Kontrolle über Endpoint], [Malware oder legitimer Nutzer mit DevTools], [*OS Sicherheit/nichts*: Der Browser hat hier nichts mehr zu tun]
        )
    ]
]
