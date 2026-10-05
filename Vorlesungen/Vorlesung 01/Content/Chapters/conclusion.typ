#import "../../Template/hszg.typ": *

= Zusammenfassung

== Grundlagen

#slide(align: horizon)[
  - Ein *Client* fordert Dienste an, ein *Server* beantwortet die Anfrage
  - Host kann Client und Server sein
  - Jede Interaktion folgt dem Muster *Request, dann Response*
  - Neue Daten brauchen neue Request
  - HTTP ist *zustandslos*: Kontext entsteht erst durch Cookies, Sessions oder JSON Web Tokens
  - Eine URL besteht aus: Protokoll, Host, Port, Pfad, Query String und Fragment
  - Ablauf beim Aufruf: DNS, TCP Handshake, TLS Handshake, HTTP Request, Verarbeitung, Rendering
  - HTTPS verschlüsselt Übertragung
]

== HTTP

#slide(align: horizon)[
  - Request besteht aus: Request Line (Verb, Pfad und Version), Headern und optionalem Body
  - Response besteht aus: Status Line, Headern und optionalem Body (Content-Type beschreibt den Datentyp)
  - *GET* liest, *POST* erstellt und verarbeitet, *PUT* ersetzt oder erstellt, *PATCH* ändert teilweise, *DELETE* löscht
  - *Safe* heißt: keine beabsichtigte Zustandsänderung
  - *Idempotent* heißt: mehrfaches Ausführen wirkt wie einmaliges
  - Jede safe Methode ist idempotent, aber nicht jede idempotente Methode ist safe
  - *Status Codes:* 2xx Erfolg, 3xx Umleitung, 4xx Fehler des Clients, 5xx Fehler des Servers
]

== Übersicht: HTTP Methoden

#slide(align: horizon)[
  #table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr),
    table.header(
      [Methode], [Safe], [Idempotent], [Erfolg], [Fehler]
    ),
    [GET], [ja], [ja], [200], [404, 403],
    [HEAD], [ja], [ja], [200], [404, 403],
    [OPTIONS], [ja], [ja], [200], [403],
    [POST], [nein], [nein], [200, 201, 204], [400, 409, 422],
    [PUT], [nein], [ja], [200, 201, 204], [400, 409, 422],
    [PATCH], [nein], [nein (nicht garantiert)], [200, 204], [404, 409, 422],
    [DELETE], [nein], [ja], [200, 202, 204], [404, 403, 409],
  )
]
