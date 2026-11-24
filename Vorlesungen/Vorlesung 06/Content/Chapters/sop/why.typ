#import "../../../Template/hszg.typ": *

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
