#import "../../Template/hszg.typ": *

= Server-Side Paradigms
<server_side_paradigms>

#slide(align: horizon)[
  #text(
    size: 25pt,
    weight: "bold",
  )[
    Was würde passieren, wenn der Server (fast) alles selbst erledigt?
  ]
]

== Multi-Page Applications (MPA) / MVC
<multi_page_applications>

#slide(align: horizon)[
  Das Modell:
  - Jede User-Interaktion löst eine volle HTTP-Request aus
  - Der Server rendert eine komplett neue HTML Seite
  - Der Browser ersetzt das Dokument
  - Für ~15 Jahre der Standard im Web
  - Immer noch Standard bei Seiten mit viel Inhalt und SEO

  *Lebenszyklus einer Request*
  ```
  Click link → GET /products/42
  → Router matches URL
  → Controller receives request
  → Model (business layer) loads/updates data
  → View renders HTML from model data
  → Response → browser paints full page
  ```
]

#slide(align: horizon)[
  *Zwei Versionen von MVC*
  - *Original:* Controller erhält Input $arrow$ Model update $arrow$ Model benachrichtigt Observer $arrow$ Views re-rendern
  - *Web MVC (Rails, Django, Spring):* 
    - Controller ist Request Handler
    - Ruft Model auf und schickt ein Template
    - Es gibt kein Observer-Pattern

  *Klassifizierung im Layered Model:*
  - View $arrow$ Präsentationsschicht
  - Model $arrow$ Business-Schicht + Datenbank
  - Controller $arrow$ Verbindung zwischen Response und Request

  #textbox()[
    $arrow$ MVC ist ein geschichtetes Modell mit Namenskonvention und Routing 
  ]
]

#slide(align: horizon)[
  *Stärken:* 
  - Einfaches mentales Modell
  - SEO ist einfach da HTML die Response ist
  - Kein Client JS Framework benötigt
  *Schwächen:*
  - Seiten neuladen fühlt sich träge an
  - Jede Interaktion ist ein Round-Trip
  - UI Features eher limitiert (SPA als Antwort)

  *Wie blieben MPAs am leben?* 
  - AJAX für partielle Updates
  - Turbolinks/Hotwire (Rails) und htmx als moderne MPA+ Ansätze
]

== Serverless & Backend-as-a-Service (BaaS)
<serverless_baas>

#slide(align: horizon)[
  #textbox()[
    *Definition:* Ihr schreibt die Application-Logik als Funktionen (FaaS) oder nutzt bereitgestellte Backend Serivces (BaaS). 
    Der Provider kümmert sich um Server, Skalierung usw.
  ]
  
  #textbox()[
    *Wichtig:* Serverless heißt nicht _kein Server_. 
    Nur das Server-Management wird abgegeben.
  ]

  *FaaS (Function-as-a-Service):*
  - AWS Lambda, Cloudflare Workers, Azure Functions, Google Cloud Functions
  - Einheit im Deployment: Eine einzelne Function, die durch Event aufgerufen wird (HTTP Request)
  - Skaliert mit Aufrufszahlen (wird berechnet nach Aufrufen)
]

#slide(align: horizon)[
  *BaaS (Backend-as-a-Service):*
  - Firebase, Supabase, Auth0, Pocketbase
  - Erfüllt häufige Backend-Anforderungen (Auth, Datenbank, File Storage, Push Notifications)
  - Browser interagiert oft direkt mit dem BaaS
  - Eigener Code wird genutzt um die Verbindung zu konfigurieren und Edge-Cases zu implementieren
]

= Thin Server vs. Thick Server
<thin_thick_server>

#slide(align: horizon)[
  #set text(size: 18pt)
  ```
    THIN CLIENT ←──────────────────────────────────→ THICK CLIENT
    MPA, htmx,      Rails/Django      JSON API      SPA + BaaS,
    SSR-first       full-stack apps    (server as    serverless glue,
    "classic web"                      pure backend)  offline-first PWA
    THICK SERVER ←──────────────────────────────────→ THIN SERVER
  ```
  #pause
  *Thick Server / Thin Client:* 
  - Der Server rendert, besitzt State, enthält ganze Logik
  - Browser ist nur zur Darstellung da
  - Pros: Logik an einem Ort, konsistentes Verhalten, wenige Anforderungen an den Client
  - Cons: Jede Interaktion ist ein Round-Trip, Server Auslastung skaliert mit Zugriffen, nicht Usern
  #pause
  *Thin Server / Thick Client:*
  - Server ist Daten/API Schicht, Browser hat State und Logik
  - Grundprinzip der SPA
  #pause
  #textbox()[
    *Wichtig:* Das ist ein Spektrum und keine absolute Ausrichtung. Jede Anwendung richtet sich zwischen diesen beiden Ansätzen aus. 
  ]
]

= Vergleich
<server_side_comparison>

#slide(align: horizon)[
  #set text(20pt)
  #table(
    columns: (auto, 1fr, 1fr, 1fr),
    table.header(
      [], [MPA/MVC], [Serverless/BaaS], [SPA + API]
    ),
    [], [], [], [],
    [Ort der Logik], [Server, in Schichten], [Provider + Funktionen], [Client + API Server],
    [Rendering], [Server], [Server oder Client], [Client],
    [State], [Server Session / DB], [Externe Stores], [Client Store + Server],
    [Ops Zuständigkeit], [Ihr selbst], [Provider], [Ihr selbst],
    [Typischer Stack], [Rails, Django, Spring, Laravel], [Lambda + API Gateway, Firebase, Supabase], [React/Vue + REST/GraphQL],
    [Sweet Spot], [Content Seiten, SEO, Forms], [Kleine Teams, Prototypen], [Interaktive Apps],
  )
]
