#import "../../Template/hszg.typ": *

= Server-Side Rendering (SSR) & Hydration

== Übersicht

#slide(align: horizon)[
  *Die Idee: Isomorphes Rendering*
  - Gleicher Code rendert auf dem Server *und* im Browser
  - Ein Paradigma, zwei Laufzeitumgebungen
  - Antwort auf die SPA-Schwäche: langsames erstes Rendern

  #pause

  *Lebenszyklus:*
  1. `GET /products/42`
  2. Server führt die Komponenten aus $arrow$ generiert HTML
  3. Browser zeigt sofort das fertige HTML (schnelleres erstes Darstellen und SEO)
  4. JS-Bundle lädt und führt _Hydration_ aus: Framework hängt Event-Listener and DOM
  5. Seite wird interaktiv
]

== Der Preis

#slide(align: horizon)[
  *Was passiert hier wirklich?*
  - Der Browser muss den kompletten Komponentenbaum erneut ausführen, um Event-Listener anzuhängen
  - Das HTML ist lange da, aber _tot_ bis Hydration fertig ist
  - Nutzer sieht eine volle Seite, bevor sie interaktiv ist
  
  *Zwei Zeitpunkte driften auseinander:*
  - Time-to-First-Paint: schnell (Server liefert HTML)
  - Time-to-Interactive: langsam (JS laden, parsen, ausführen, Hydration)

  *Folge:*
  - Meistens ist der größte Teil einer Seite statisch
  - Hydration lässt ganze Seite für wenig Interaktivität bezahlen
]

== Islands Architektur

#slide(align: horizon)[
  #set text(size: 20pt)

  - *Gegenidee:* Nicht die ganze Seite hydraten
  - Nur interaktive Teile werden hydrated
  - Seite besteht aus statischem Server-HTML
  - Nur einzelne _Inseln_ werden hydriert
  - Alles außerhalb der Inseln liefert null JavaScript

  #pause

  *Entscheidung fällt pro Komponente, nicht pro App*
  - `client:load` $arrow$ sofort hydrieren
  - `client:idle` $arrow$ wenn der Browser nichts zu tun hat
  - `client:visible` $arrow$ erst wenn die Insel sichtbar ist

  #pause

  *Beispiel: Astro (framework-agnostisch)*
  #table(
    columns: (auto, 1fr, 1fr),
    table.header(
      [], [SSR + Hydration], [Islands]
    ),
    [JS für statischen Content], [Ja (Framework)], [Null],
    [Granularität], [Ganze Seite], [Einzelne Komponenten],
    [Sweet Spot], [Interaktive Apps], [Content-Seiten],
  )
]
