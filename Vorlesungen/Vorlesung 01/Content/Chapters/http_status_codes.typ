#import "../../Template/template.typ": *

= HTTP Status Codes

== HTTP Status Codes

#slide(align: horizon)[
  - Status Code gehört zu jeder HTTP Response
  - Zwischen 100 und 599
  - Erste Ziffer gibt Klasse der Response an
    - *1xx (Informational)*: Die Request wurde erhalten und wird verarbeitet
    #pause
    - *2xx (Successful)*: Die Request wurde erfolgreich erhalten, verstanden und akzeptiert
    #pause
    - *3xx (Redirection)*: Es müssen weitere Schritte durchgeführt werden, damit die Request verarbeitet werden kann
    #pause
    - *4xx (Client Error)*: Die Request enthält falsche Syntax oder kann nicht erfüllt werden
    #pause
    - *5xx (Server Error)*: Der Server konnte eine eigentlich valide Request nicht erfüllen
]

#slide(align: horizon)[
  #set text(size: 16pt)
  #table(
    columns: (auto, 1fr),
    align: horizon,
    table.header(
      [Status Code], [Bedeutung]
    ),
    [200 (OK)], [Standardantwort für Erfolg],
    [201 (CREATED)], [Standardantwort für neue Ressource],
    [204 (NO CONTENT)], [Standardantwort für Erfolg ohne Daten im Response Body],
    [301 (MOVED PERMANENTLY)], [Ressource ist an der Adresse im „Location“-Header-Feld],
    [302 (FOUND) (MOVED TEMPORARILY)], [Ressource ist vorübergehend an der Adresse im „Location“-Header-Feld],
    [400 (BAD REQUEST)], [Die Request konnte nicht verarbeitet werden],
    [403 (FORBIDDEN)], [Der Client hat keine Rechte auf diese Ressource],
    [404 (NOT FOUND)], [Die gewünschte Ressource konnte nicht gefunden werden],
    [409 (CONFLICT)], [Die Anfrage steht im Konflikt mit dem aktuellen Zustand der Ressource (z.B. gleichzeitige Änderung durch Dritte)],
    [415 (UNSUPPORTED MEDIA TYPE)], [Inhalt der Anfrage wurde mit ungültigem Medientyp übermittelt.],
    [422 (UNPROCESSABLE CONTENT)], [Die Anfrage ist formal korrekt, der Inhalt aber fachlich ungültig],
    [500 (INTERNAL SERVER ERROR)], [Standardantwort für einen unerwarteten Fehler],
  )
]
