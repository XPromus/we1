#import "../../Template/hszg.typ": *

= Client-Side-Paradigma
<client_side_paradigm>

#slide(align: horizon)[
  #text(size: 25pt, weight: "bold")[
    Was würde passieren, wenn der Client (fast) alles erledigt und der Server nur ein Dateninterface ist?
  ]
]

== Wie kam das Paradigma zustande?

#slide(align: horizon)[
  - Paradigma entstand ca. 2010 ... warum?
  - *JavaScript Engines:* V8 (2008) machte JS 10-100x schneller $arrow$ Applikationen im Browser wurden möglich
  - *AJAX:* Partielle Updates zeigten, dass User für eine ganze Session auf einer Seite bleiben
  - *HTML5 APIs:* `history.pushState()`, `localStorage`, Application Cache, Canvas, Web Sockets
  - *Smartphones:* Native Apps setzen den Maßstab für flüssiges Interagieren $arrow$ User erwarten, dass Web Apps dasselbe Gefühl mitbringen
  - *Gmail (2004) und Google Maps (2005)* waren der Proof-of-Concept
]

= Single-Page-Application (SPA)
<single_page_application>

#slide(align: horizon)[
  *Definition:* Der Browser lädt eine HTML-Shell und ein JavaScript-Bundle. 
  Jede weitere Navigation passiert auf der gleichen Seite. 
  Der Server liefert Daten, keine Dokumente. 

  Neues Konzept: *Client-Side-Routing*
  - Die URL ist State auf der Userseite
  - URL wird vom JS-Router interpretiert
  - Bei URL-Wechsel:
    - Keine Anfrage an den Server
    - Router überprüft den Pfad und wechselt die View-Komponente
    - `history.pushState()`, damit die URL teilbar bleibt
  
  *Probleme:*
  - Back/Forward im Browser muss berücksichtigt werden
  - Beim Neuladen muss die Seite basierend auf der URL rekonstruiert werden
]

== Client-Side-Rendering-Pipeline

#slide(align: horizon)[
  ```
    Load shell.html + app.js
    → Router matches URL → renders view components
    → View fetches data from API (JSON)
    → Render → user interacts → router swaps views (repeat)
  ```

  *Neues Problem:* Client State
  - State in einer SPA lebt an mehreren Orten gleichzeitig (Komponenten, Client-Side-Store (Redux), URL und `localStorage`)
  - Keine festgelegte Parität zwischen den States

  *3 Ansätze:*
  - Server-Cache-State: Daten leben auf dem Server (z.B. TanStack Query)
  - Client-Side-Cache: State wird in der UI gespeichert
  - URL-State: State über Filter und Pagination 
]

== Stärken und Schwächen

#slide(align: horizon)[
  *Stärken:*
  - Interaktivität wie bei einer App
  - Keine vollen Reloads
  - Viele Möglichkeiten für komplexe UIs
  - Klarer API-Vertrag kann mehrere Clients ermöglichen

  *Schwächen:*
  - *Time-to-First-Byte vs. Time-to-Interactive:* HTML kommt schnell an, danach JS downloaden, parsen, ausführen, Daten fetchen, rendern: Kann bei langsamen Verbindungen lange dauern
  - *JS Bundle Wachstum:* JS bringt mehr Kosten pro Byte als HTML
  - *SEO Probleme:* Crawlers können JS ausführen aber HTML vom Server ist 
  - *Das Rad neu erfinden:* SPAs implementieren viele Browsernative Funktionen neu (Routing, Scroll Restoration, ...)
]

= Progressive Web Apps (PWA)
<progressive_web_app>

#slide(align: horizon)[
  *Letzter Schritt beim Thick-Client:* Der Client kann komplett ohne den Server laufen (zumindest temporär)

  *Drei Prinzipien:*
  #set enum(numbering: "1.")
  + *Service Worker:* Ein programmierbarer Proxy zwischen Seite und Netzwerk. Fängt Requests ab und stellt Daten vom Cache bereit $arrow$ Offline Funktionalitäten
  + *Wep App Manifest:* Metadaten (Name, Icons, Display Mode) erlauben "Installieren" der App zum Home Screen
  + *HTTPS:* Benötigt für die Service Worker mit eingebauter Sicherheit
]

= Vergleich 
<server_client_comparison>

#slide(align: horizon)[
  #table(
    columns: (auto, 1fr, 1fr, 1fr),
    table.header(
      [], [#link(<multi_page_applications>)[MPA]], [#link(<single_page_application>)[SPA]], [#link(<progressive_web_app>)[PWA]],
    ),
    [Erstes Rendern], [Server, schnell], [Client, langsam (JS + Daten)], [Client, langsam, danach sofort],
  [Navigation], [Volles Laden der Seite], [Wechseln der Routen in der Seite], [In der Seite, Offline],
  [SEO], [Sehr gut], [benötigt Workaround], [benötigt Workaround],
  [State], [Server Session], [Aufteilung Client + Server], [Zuerst lokal],
  [Funktioniert offline], [Nein], [Nein], [Ja],
  [Komplexität], [gering], [mittel-hoch], [hoch],
  ),
] 
