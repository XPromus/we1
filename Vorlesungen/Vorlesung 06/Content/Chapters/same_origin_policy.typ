// LTeX: enabled=true language=de-DE

#import "../../Template/hszg.typ": *

= Same-Origin Policy (SOP)

== Was ist ein Origin?

#let speaker-note-1 = speaker-note()[
    #set text(size: 21pt)
    - *Path, Query String und Fragmente sind egal*: `http://example.com/a` und `http://example.com/b?x=1` sind der gleiche Origin (Origin beantwortet _wer_ und nicht _wo genau_)
    - Origins werden *pro Page Load* verglichen: Was wichtig ist, ist der Origin des Dokuments, das das Script ausführt
    - In JS kann der aktuelle Origin mit `location.origin` abgelesen werden (z.B. `http://example.com:8080`)
    - Die meisten Browser zeigen auch den `origin` in Error Events und `fetch` Requests
    - Die Port-Default-Regel bedeutet: _nicht geschrieben_ und _explizit geschrieben_ können trotzdem übereinstimmen: `http://example.com` und `http://example.com:80` *sind der gleiche* Origin
    - Für *non-HTTP*-Schemen kann das Tuple unvollständig sein: z.B. `file:` URLs erhalten einen _unique opaque origin_ für jedes Dokument $arrow$ `data:` Seiten können nichts erreichen
]

#slide(align: horizon)[
    #set text(size: 20pt)
    *Scheme (bzw. Protokoll):* 
    - `http` vs. `https` vs. `ws` sind unterschiedliche origins (selbst auf dem gleichen Host und Port)
    - `http://example.com` geht zum Port `80`
    - `https://example.com` geht zum Port `443` 
    - Zusätzlich zum anderen Schema auch anderer Port

    *Host*
    - Vergleicht exakt aber ist _case-insensitive_
    - `example.com` und `www.example.com` sind unterschiedliche Origins: eine Subdomain ist ein unterschiedlicher Host
    - Es gibt keine "same registrable domain" Exception in SOP
    
    *Port*
    - Muss exakt übereinstimmen
    - `example.com:8080` und `example.com:3000` sind unterschiedliche Origins
    - Wenn kein Port geschrieben wurde, wird der default Port des Schemas genutzt

    #speaker-note-1
]

== Vergleich

#slide(align: horizon)[
    Vergleich gegen: `http://example.com:8080/page`
    #set text(size: 20pt)
    #table(
        columns: (auto, auto, 1fr),
        align: (left, center, left),
        table.header(
            [URL Verglichen], [Same-Origin?], [Warum?]
        ),
        [`http://example.com:8080/other`], [#emoji.checkmark], [Gleiches Schema, Host, Port: Pfad ist egal],
        [`https://example.com:8080/`], [#emoji.crossmark], [Unterschiedliches Schema],
        [`http://www.example.com:8080/`], [#emoji.crossmark], [Unterschiedlicher Host (Subdomain)],
        [`http://example.com:3000/`], [#emoji.crossmark], [Unterschiedlicher Port],
        [`http://example.com/`], [#emoji.crossmark], [Default Port 80, nicht 8080],
        [`http://user:pass@example.com:8080`], [#emoji.checkmark], [Username/Password sind nicht Teil des Origin],
    )

    #speaker-note-1
]

== SOP als Security Modell

#slide(align: horizon)[
    *Kernaussage:* Das primäre Ziel von SOP ist es nicht Requests zu verhindern. 
    Es ist das Lesen der Antworten zu verhindern.

    *Was sagt SOP aus?*
    Ein Skript, welches im Context eines Origins A läuft darf nicht Daten lesen, die zum Origin B gehören. 

    Es werden drei Bereiche abgesichert:
    1. *Cross-window/iframe DOM Zugriff:* `iframe.contentDocument` ist `null` außer der Frame ist same-origin. Kein lesen, schreiben oder Event abfangen in dem Dokument
    2. *Network Responses:* `fetch()` oder XHR kann zu jeder URL geschickt werden. Aber die Response wird JS vorenthalten, solange der Server nicht per CORS zustimmt.
    3. *Storage und Cookies:* `localStorage`/`sessionStorage`/IndexedDB werden durch Origin verschlossen. Eine Seite von `evil.com` kann den Storage von `bank.com` nicht öffnen.
]

== send vs. read

#slide(align: horizon)[
    #set text(size: 35pt)
    - *Cross-origin writes sind erlaubt:* Es können Forms abgegeben, Bilder geladen, Scripts included und `fetch()` ausgeführt werden. Alles erreicht den anderen Server, potenziell mit den Cookies
    - *Cross-origin reads sind blockiert:* SOP verhindert, dass der _response body_ zu meinem Script zurückkommt
]

#slide(align: horizon)[
    Warum dieses Design? Was würde passieren, wenn reads erlaubt wären?

    #pause

    #textbox()[
        Du bist eingeloggt in `bank.com` in einem anderen Tab.
        Danach besuchst du `evil.com`, die `fetch('https://bank.com/account/overview')` ausführen. 

        #pause

        Der Browser hängt den `bank.com` Session-Cookie an die Request (automatischer Prozess, Cookies folgen der Domain in der Request, egal wer sie initialisiert).

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

== Konsequenzen des Splits

#slide(align: horizon)[
    - *CSRF existiert weil Schicken erlaubt ist:* Ein Angreifer kann Requests auslösen, die State verändern mit den User-Cookies. SOP hilft da nicht. Es werden CSRF Tokens und `SameSite` Cookies verwendet
    - *XSS kann SOP einfach umgehen:* Wenn böser Code in deinem Origin läuft, bringt SOP keinen Schutz (aus der Sicht des Codes bist du es)
    - *Informationen können auch ohne read leaken:* Error Nachrichten, (Miss)Erfolg des Ladens. Dafür gibt es CORP/CORB
]

== Warum der Browser?

#slide(align: horizon)[
    - SOP wird durch den User Agent durchgesetzt, nicht den Server
    - Server kann nicht zuverlässig sagen, wer eine Request ausgelöst hat (`Origin`/`Referer` können fehlen oder geändert werden)
    - Browser ist die einzige Komponente, die zuverlässig weiß, in welchem Origin ein Skript läuft
    - Server ist nur für opt-in zuständig: CORS Header $arrow$ "Ich erlaube Origin X, das zu lesen."
]

== Grundsatz

#slide(align: horizon)[
    SOP geht davon aus, dass jeder Origin feindlich zu jedem anderen Origin ist, blockiert das Lesen von cross-origin Daten und zwingt jeden, der Lesen möchte, es explizit zu erlauben.
]

== Was wird blockiert und was nicht

#slide(align: horizon)[
    #table(
        columns: (auto, 1fr, auto),
        align: (left, left, center),
        table.header(
            [Interaktion], [Beispiel], [Erlaubt?]
        ),
        [Embed], [`<img>`, `<script src>`, `<link>`, `<iframe>`, `<video>`], [#emoji.checkmark],
        [Write], [Form submission, Navigation, POST mit `fetch`], [#emoji.checkmark],
        [Read], [Response Bodies, DOM Inhalt, Pixeldaten], [#emoji.crossmark],
    )

    #speaker-note()[
        #set text(size: 23pt)
        - `<img>`: Der Browser wird ohne Probleme ein cross-origin Bild runterladen und rendern. Rendering ist ok, da nur Pixel interpretiert werden (kein Script)
        - `<script src>`: Cross-origin Scripte werden ausgeführt. Warum nicht blockiert?
            - Ein Script-Tag einzufügen ist ein Akt des Vertrauens durch den Entwickler
            - Der geladene Code wird im eigenen Origin ausgeführt
            - Keine Intervention durch SOP (deshalb ist Script embedding gefährlich. compromised CDN = XSS)
            - `<script src="..." integrity="sha384-..."` für integrität
        - `<link rel="stylesheet">`: Benutzen ja, inspizieren nein
        - `<iframe>`: Cross-origin frame wird auf eigener Seite gerendert
            - `iframe.contentDocument` gibt `null` zurück
            - Andere Seite wird embedded aber man kann auf nichts im DOM zugreifen
    ]
]

== Pattern

#slide(align: horizon)[
    1. *Embedding* = der Seitenersteller deklariert Vertrauen:
        - Autor von `a.com` hat entschieden eine Ressource von `b.com` zu laden
        - SOP erlaubt dem Browser es zu konsumieren, darstellen, ausführen, anwenden
        - *Weil:* Entscheidung es einzubinden kam vom Origin `a`
    2. *Reading* = Daten vom anderen Origin kommen in deinen Kontext:
        - Sobald Daten von `b.com` durch `a`-JavaScript lesbar sind, kann `a` Code: kopieren, modifizieren, exfiltrieren (auch Daten von `b.com`)
        - SOP verweigert
]

#let embedding_allowed_diagram = read("../../Images/embedding_allowed.mmd")
#let reading_blocked_diagram = read("../../Images/reading_blocked.mmd")
#let decision_graph = read("../../Images/decision_graph.mmd")

#slide(align: horizon)[
    #mermaid(embedding_allowed_diagram)
    #speaker-note()[
        - Der Autor von `evil.com` embedded ein Bild von `bank.com`
        - Das Bild wird gefetched mit den Bank-Cookies des Users und gerendert
        - *Aber:* sobald das Script nach den Pixeln fragt, schreitet SOP ein
        - Pixel sind sichtbar, aber das Script erhält nie eine Kopie
        - Nichts kann extrahiert werden
    ]
]

#slide(align: horizon)[
    #mermaid(reading_blocked_diagram)
    #speaker-note()[
        - Das gleiche Script überspringt `<img>` und versucht Daten direkt zu fetchen
        - Request wird nicht blockiert und auch nicht das Erhalten der Daten im Browser
        - SOP greift nur beim finalen Handoff ein
        - Sobald die Bytes den Scripting Context erreichen würden, ist es vorbei
    ]
]

#slide(align: horizon)[
    #mermaid(decision_graph, theme-preset: "paper-cut", width: 100%, document-context: true)
    #speaker-note()[
        - Die Daten werden immer zum Client kommen (SOP kann das nicht verhindern)
        - SOP garantiert, dass das letzte Stück, der Handoff vom Browser zum Script, nicht passiert (außer der Besitzer der Daten erlaubt es)
    ]
]

== Same-Origin vs. Cross-Origin: Walkthrough

#slide(align: horizon)[
    Base-URL: `https://app.example.com:443` (`443` ist HTTPS Port)
    #table(
        columns: (auto, auto, 1fr),
        align: (left, center, left),
        table.header(
            [andere URL], [Ergebnis], [Grund]
        ),
        [`https://app.example.com:443/`], [#emoji.checkmark Same-Origin], [443 explizit geschrieben = HTTPS default],
        [`https://app.example.com:8443/`], [#emoji.crossmark Cross-Origin], [Port ist anders],
        [`http://app.example.com`], [#emoji.crossmark Cross-Origin], [Zwei Violations: `http` $eq.not$ `https` und Default Port `80` $eq.not$ `443`],
    )
]

== Warum existiert SOP?

#slide(align: horizon)[
    === Der pre-SOP Browser (~1995)

    - Netscape shipped JavaScript und Frames im gleichen Release ohne Restriktionen für cross-window Zugriff
    - Jedes Skript kann alle anderen offenen DOMs lesen und bearbeiten
    - Cookies waren das große Risiko: Nach Login werden Session Details an jede Request angehängt

    *Ergebnis*
    - Der Nutzer ist bei `bank.com` eingeloggt
    - `evil.com` ist in einem anderen Tab offen
    - Skripte von `evil.com` können auf den DOM von `bank.com` zugreifen und Daten auslesen
    - SOP wurde als Lösung für dieses Risiko eingeführt
]

== Was wird angefangen?

#slide(align: horizon)[
    #set text(size: 21pt)
    #table(
        columns: (1fr, auto, 1fr),
        align: (left, center, left),
        table.header(
            [Angriff], [Stoppt SOP?], [Was übernimmt den Schutz?]
        ),
        [Cross-Window DOM lesen], [#emoji.checkmark], [-],
        [Lesen von Cross-Origin Responses], [#emoji.checkmark], [-],
        [Cookies stehlen mit Foreign-Script], [#emoji.checkmark], [`HttpOnly` als zweite Schicht innerhalb des Origins],
        [CSRF (state-changing forged requests)], [#emoji.crossmark], [`SameSite` Cookies, CSRF Tokens],
        [XSS innerhalb des Origins], [#emoji.crossmark], [Output encoding, CSP],
        [Network Sniffing], [#emoji.crossmark], [HTTPS],
    )
]
