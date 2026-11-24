#import "../../../Template/hszg.typ": *

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

#let embedding_allowed_diagram = read("../../../Images/embedding_allowed.mmd")
#let reading_blocked_diagram = read("../../../Images/reading_blocked.mmd")
#let decision_graph = read("../../../Images/decision_graph.mmd")

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
