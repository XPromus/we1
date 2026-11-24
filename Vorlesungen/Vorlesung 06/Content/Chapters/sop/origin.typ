#import "../../../Template/hszg.typ": *

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
