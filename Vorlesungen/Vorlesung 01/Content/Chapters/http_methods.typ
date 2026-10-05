#import "../../Template/hszg.typ": *

= HTTP Methoden

== Verben

#slide(align: horizon)[
  Definition von Verben, die Ziele von Requests genauer beschreiben

  #side-by-side[
    *Häufige Verben*
    - GET
    - POST
    - PUT
    - DELETE
  ][
    *Weitere Verben*
    - HEAD
    - CONNECT
    - OPTIONS
    - TRACE
    - PATCH
  ]
]

== GET

#slide(align: horizon)[
  - Stellt einen Request an den Server, um eine Ressource zu transferieren
  - Ist safe und idempotent
  - Content sollte nie mit einer GET-Request erstellt werden
  - Caching ist möglich

  #textbox()[
    *Informationen in der URL:* Es ist zu beachten, dass, wenn Ressourcen nur über URLs angefragt werden, potentiell sicherheitskritische Informationen in dieser URL landen können. 
    Wenn es nicht möglich ist, diese Informationen in weniger kritische zu transformieren, wird das Nutzen einer POST Request mit den Daten im Request Content empfohlen.
  ]
]

== POST

#slide(align: horizon)[
  - Wird genutzt, um transferierte Daten nach Server-Spezifikation zu verarbeiten
  - Beispiel:
    - Daten in Inputfeldern übergeben
    - Nachrichten posten (Foren, Social Media usw.)
    - Erstellen von neuen Ressourcen
    - Daten an vorhandene Ressourcen anhängen
  - Server kommuniziert mit Status Codes das Ergebnis der POST Request
  - Bei Erfolg: 200 oder 204
  - Bei erfolgreichem Erstellen einer neuen Ressource: 201 mit Pfad zur neuen Ressource
]

== PUT

#slide(align: horizon)[
  - Editieren von vorhandener Ressource oder Erstellung von neuen Ressources
  - Request basiert auf mitgeschickten Daten
  - Wenn Ressource nicht vorhanden ist, wird sie neu erstellt
  - Status Code 201 nach Erstellen neuer Ressource
  - Wenn kein neuer Eintrag erstellt wurde: Status Code 200 oder 204
  - Server sollte Daten in der PUT Request validieren
  - Wenn Fehler in den Daten: selbst versuchen Daten in passendes Format zu bringen oder 400, 409 oder 422 zurückgeben
]

== PATCH

#slide(align: horizon)[
  - Ändert eine vorhandene Ressource teilweise
  - Body enthält nur die Änderungen
  - Im Gegensatz dazu ersetzt PUT die Ressource vollständig, fehlende Felder gehen verloren
  - Nicht safe, und nicht garantiert idempotent (hängt von der Änderung ab)
  - *Erfolg*: 200 (mit aktualisierter Ressource) oder 204
  - *Fehler*: 404 (Ressource existiert nicht), 409 oder 422 (Änderung nicht anwendbar oder ungültig)
]

== DELETE

#slide(align: horizon)[
  - Request an den Server, Ressource zu löschen
  - Entweder Entfernen von Referenzen oder komplettes Löschen der Ressource
  - DELETE sollte nur bei Ressourcen erlaubt sein, die definierte Löschoperationen besitzen 
  - Bei Erfolg einer der folgenden Codes:
    - *202 (Accepted)* wenn das Löschen wahrscheinlich erfolgreich sein wird, aber noch nicht durchgeführt wurde
    - *204 (No Content)* Löschen wurde ausgeführt und keine weiteren Informationen sind nötig
    - *200 (OK)* Löschen war erfolgreich und die Response enthält noch Informationen über den aktuellen Status
]

== Safe Methods

#slide(align: horizon)[
  - Eine Methode ist _safe_, wenn sie nur lesen soll und keine Zustandsänderungen auf dem Server beabsichtigt
  - Der Client fordert keine Änderung an und ist nicht dafür verantwortlich
  - Safe: GET, HEAD, OPTIONS, TRACE
  - Server darf Side Effects haben, solange sie nicht Änderungen an Ressourcen vornehmen auf die sich der Client verlässt (z.B.: Logs, Counter, Cache)

  #pause

  #block(stroke: hszg-green + 2pt, fill: background, inset: 15pt)[
    *Folgen:* Safe Methods können gefahrlos gecached werden, vorab geladen und wiederholt werden.
  ]

  #pause

  #block(stroke: hszg-green + 2pt, fill: background, inset: 15pt)[
    *Hinweis:* _Safe_ ist ein Versprechen, keine Garantie. 
    GET Endpoints können theoretisch so geschrieben werden, dass sie Daten löschen. 
  ]
]

== Idempotente Methoden

#slide(align: horizon)[
  - Mehrfache Ausführung hat den gleichen Effekt auf dem Server
  - Wichtig bei automatischen Requests (z.B.: Wiederholung bei Fehlschlag)
  - PUT und DELETE sollen nach Spezifikation idempotent sein
  - POST und PATCH sind nicht idempotent
  - _safe request methods_ sind idempotent
  - Server kann trotzdem Side Effects einfügen (z.B.: Logs)
  - Side Effects dürfen Ergebnis nicht verändern 
  - Nicht idempotente Methoden sollten nicht automatisch wiederholt werden (Außer, wenn die Implementierung idempotent ist)
]

== Idempotent vs. Safe

#slide(align: horizon)[
  - _Idempotent_: Mehrfache Ausführung hat den gleichen Effekt auf dem Server
  - _Safe_: Methode verändert den Server-Zustand gar nicht (aus Sicht des Clients)
  - Jede safe Methode ist idempotent - nicht jede idempotente Methode ist safe

  #table(
    columns: (1fr, 1fr, 1fr),
    table.header(
      [Methode], [Safe], [Idempotent]
    ),
    [GET], [ja], [ja],
    [HEAD], [ja], [ja],
    [OPTIONS], [ja], [ja],
    [PUT], [nein], [ja],
    [DELETE], [nein], [ja],
    [POST], [nein], [nein],
    [PATCH], [nein], [nein (nicht garantiert)]
  )
]

== Beispiele

#slide(align: horizon)[


  ```
    DELETE /todos/5
  ```

  - Nicht safe, denn es löscht Einträge vom Server
  - Ist idempotent, denn nach dem ersten Ausführen ist der Eintrag weg und der Zustand ändert sich nicht

  ```
    POST /todos
  ```

  - Weder safe noch idempotent
  - Jeder Aufruf erzeugt neuen Eintrag

]
