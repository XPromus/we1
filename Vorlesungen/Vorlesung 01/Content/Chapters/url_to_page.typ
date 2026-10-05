#import "../../Template/packages.typ": *
#import "../../Template/colors.typ": *

= Von der URL zur Seite

== Aufbau einer URL

#slide[
  #align(center)[
    ```
      https://api.example.com:443/users/5?active=true#profile
    ```
  ]
  
  - `https://`: Genutztes Protokoll
  #pause
  - `api.example.com`: Adresse des Hosts (Welcher Server wird angesprochen)
  #pause
  - `:443`: Port der Applikation auf dem Server
  #pause
  - `/users/5`: Pfad (Welche Ressource auf dem Server)
  #pause
  - `?active=true`: Query String mit Parametern
  #pause
  - `#profile`: Fragment welches beim Client verbleibt
]

== Beispiele

#slide[

  ```
    https://github.com/typst/typst#example
  ```

  #alert([Benenne die URL Komponenten])

  #pause
  
  #grid(
    columns: (0.25fr, .75fr),
    align: center + horizon,
    inset: 10pt,
    gutter: 5pt,
    stroke: (x, y) => {
      if x == 0 {
        hszg-green + 2pt
      } else {
        dark + 2pt
      }
    },
    fill: (x, y) => {
      if x == 0 {
        hszg-green.lighten(80%)
      } else {
        dark.lighten(90%)
      }
    },
    [`https://`], [Genutztes Protokoll],
    [`github.com`], [Adresse des Hosts],
    [`/typst/typst`], [Pfad zur Ressource],
    [`#example`], [Fragment welches beim Client verbleibt],
  )
]

#slide()[
  === Beispiele

  ```
    https://github.com/search?q=Typst&type=repositories
  ```

  #alert([Benenne die URL Komponenten])

  #pause

  #grid(
    columns: (auto, 1fr),
    align: center + horizon,
    inset: 10pt,
    gutter: 5pt,
    stroke: (x, y) => {
      if x == 0 {
        hszg-green + 2pt
      } else {
        dark + 2pt
      }
    },
    fill: (x, y) => {
      if x == 0 {
        hszg-green.lighten(80%)
      } else {
        dark.lighten(90%)
      }
    },
    [`https://`], [Genutztes Protokoll],
    [`github.com`], [Adresse des Hosts],
    [`/search`], [Pfad zur Ressource],
    [`?q=Typst&type=repositories`], [Query String mit Parametern \ (hier für die Suche)]
  )
]

== DNS & TCP

#slide(align: horizon)[
  === DNS

  - _Das Telefonbuch des Internets_
  - Computer kennen keine Domains, nur IP-Adressen
  - Bei Angabe einer Domain wird ein DNS-Resolver gefragt, welche IP-Adresse dahinter liegt

  #pause

  === TCP Handshake

  - Vor HTTP-Versendung muss stabile Verbindung hergestellt werden
  - Drei Schritte:
    1. Bist du da?
    2. Ja ich bin da!
    3. Lass uns reden!
]

== HTTP/TLS

#slide(align: horizon)[
  - HTTP allein schickt nur in Klartext $arrow$ jeder kann Daten lesen
  - HTTPS _umschließt_ HTTP in einem verschlüsselter Tunnel (TLS)
  - Der Inhalt ist während der Übertragung unlesbar

  #figure(
    image("../../Images/https_marker.png", width: 50%),
    caption: [
      Markierung im Browser, dass eine Website HTTPS benutzt. Es sagt jedoch nicht aus, dass die Seite selbst sicher ist.
    ]
  )
]

== Kompletter Ablauf

#slide(align: horizon)[
  1. User öffnet URL
  2. DNS wandelt den Host zu einer IP um
  3. TCP Handshake etabliert die Verbindung
  4. TLS Handshake verschlüsselt die Verbindung, sofern HTTPS genutzt wird
  5. Browser schickt HTTP Request
  6. Server verarbeitet die Request
  7. Browser wandelt Response um und rendert Website
]

== Fehlersuche

#slide(align: horizon)[
  === Beispiel

  #align(left)[
    Ein User berichtet, dass eine Website nicht lädt. Die DevTools zeigen, dass die Request nie den Browser verlassen hat.
  ]

  #v(25pt)

  #align(center)[
    #alert([Bei welchen Schritten des Ablaufs kann das Problem liegen?])
  ]
]

#slide(align: horizon)[
  #table(
    columns: (1fr, auto),
    table.header(
      [Ursache], [Typische Fehlermeldung]
    ),
    [DNS (Schritt 2): Domain lässt sich nicht auflösen], [`ERR_NAME_NOT_RESOLVED`],
    [TCP (Schritt 3): Server nicht erreichbar, Port gesperrt, Firewall], [`ERR_CONNECTION_REFUSED`, \ `ERR_CONNECTION_TIMED_OUT`],
    [TLS (Schritt 4): Zertifikat abgelaufen oder ungültig], [`ERR_CERT_DATE_INVALID`],
    [Client: kein Netzwerk, Adblocker oder Extension], [`ERR_INTERNET_DISCONNECTED`, \ `ERR_BLOCKED_BY_CLIENT`]
  )

  *Merke:* Auch ein ausgefallener Server kann die Ursache sein, nämlich wenn der Fehler schon beim TCP Handshake auftritt.
]
