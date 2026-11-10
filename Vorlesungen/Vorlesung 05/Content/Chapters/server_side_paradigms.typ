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

  #speaker-note()[
    #set text(size: 20pt)
    *Durch den Zyklus sprechen:*
    - Am Beispiel bleiben: Klick auf Produkt in einer Übersicht $arrow$ GET /products/42
    - Router = Tabelle URL $arrow$ Controller-Aktion; bei Rails/Django Konventionen (convention over configuration) statt manueller Konfiguration: GET /products/42 mappt automatisch auf ProductsController\#show mit id=42
    - Controller ist dünn: validieren, Model aufrufen, View auswählen,  Logik gehört ins Model
    - View ist auch dünn: nur Template + Model-Daten, keine Business-Logik (sonst wächst die Logik zurück in die View)
    - HTTP ist zustandslos: der Server baut bei jeder Request den Kontext neu auf (Session-Cookie, ggf. Datenbank-Lookup),  kein "eingeloggtes Benutzer-Objekt" im Speicher, das zwischen Requests überlebt
    - Historisch: ~1995, 2010 Standard, klassisches LAMP/CGI, ab 2004 Rails machte MVC im Web populär (Django 2005, danach Spring MVC, Laravel)
  ]
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

  #speaker-note()[
    #set text(size: 20pt)
    *Hintergrund: warum zwei Versionen?*
    - Original: Smalltalk-80, Trygve Reenskaug (1979),  Desktop-GUI, keine Requests
    - Observer-Pattern wirkt dort, weil View und Model dauerhaft im selben Prozess leben: Model ändert sich, View wird sofort benachrichtigt und neu gezeichnet
    - Im Web gibt es dieses dauerhafte Verhältnis nicht: Request kommt, Antwort geht, Server "vergisst" den Client (Request/Response ist one-shot)
    - Daher: Web MVC ist nicht das klassische MVC,  die Observer-Beziehung wird durch das Request/Response-Schema ersetzt
    - In der Literatur heißt Web MVC auch "Model 2" (JSP Model 2 Architektur); "Passive View" für Views ohne eigene Logik
    - Anschluss zum Kapitel Layered Model: MVC ist eine konkrete Ausprägung, Controller sitzt zwischen Transport- und Präsentationsschicht
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

  #speaker-note()[
    #set text(size: 20pt)
    *Was hier wirklich passiert:*
    - Deployment-Einheit ist eine Funktion, nicht ein Prozess: kein eigenständiger Webserver, kein App-Server, der dauerhaft läuft
    - Provider ruft die Funktion bei Bedarf auf ("Event-getrieben": HTTP Request, Datei-Upload, Cron, Queue-Nachricht)
    - *Cold Starts:* Instanz wird bei Bedarf gestartet,  der erste Aufruf ist langsamer (Lambdas: oft 100 ms,  Sekunden je nach Runtime; Cloudflare Workers: V8-Isolates, Millisekunden)
    - *Billing:* zahlt pro Aufruf + Ausführungszeit,  bei null Traffic fallen Kosten gegen null (Achtung: API Gateway, Speicher etc. können trotzdem kosten)
    - *Stateless by design:* Funktionen dürfen keinen dauerhaften lokalen State halten,  State gehört in externe Stores (DB, Redis, S3)
    - Typische Einsatzfälle: Webhooks, Cron-Jobs, Bildresizen nach Upload, kleine Glue-Logik,  nicht: langlebige Verbindungen (WebSockets), CRON-freie Dauerprozesse
  ]
]

#slide(align: horizon)[
  *BaaS (Backend-as-a-Service):*
  - Firebase, Supabase, Auth0, Pocketbase
  - Erfüllt häufige Backend-Anforderungen (Auth, Datenbank, File Storage, Push Notifications)
  - Browser interagiert oft direkt mit dem BaaS
  - Eigener Code wird genutzt um die Verbindung zu konfigurieren und Edge-Cases zu implementieren

  #speaker-note()[
    #set text(size: 20pt)
    *Radikaler Punkt auf dieser Folie:*
    - Der Browser spricht direkt mit dem BaaS,  kein eigener Server dazwischen! SDK im Frontend, z.B. #raw("firebase.auth()") oder Supabase-JS-Client
    - Fragt die Studierenden: wenn der Client direkten DB-Zugriff hat, was hindert einen Angreifer daran, beliebige Daten zu manipulieren?
    - Antwort: Sicherheit liegt in den *Regeln*, nicht im versteckten Backend,  Firebase Security Rules, Supabase Row Level Security (RLS) auf PostgreSQL-Ebene
    - Das ist ein Paradigmenwechsel: Autorisierung wandert in die Datenschicht (deklarativ), statt in Controller-Code
    - Trade-offs: schneller Start, wenig Boilerplate,  aber Vendor Lock-in, begrenzte Query-Fähigkeiten, Regeln werden schnell komplex
    - Einordnung der Angebote: Firebase/Supabase = alles (DB, Auth, Storage, Realtime); Auth0 = nur Auth; Pocketbase = self-hosted (ein Binary, eigene Kontrolle)
  ]
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

  #speaker-note()[
    #set text(size: 20pt)
    *Vor dem ersten Pause-Schritt:*
    - Spektrum erst still wirken lassen; beim ersten Klick fragen: Rails und JSON API schicken beide Antworten vom selben Server,  worin liegt der Unterschied? Nicht im Format, sondern darin, wo Logik und State liegen
    *Erklärung zu "skaliert mit Zugriffen, nicht Usern":*
    - MPA: der Server rendert bei jedem Klick die komplette Seite,  drei User, die viel klicken, erzeugen mehr Last als zehn ruhige User
    - SPA: Rendering passiert im Client, der Server liefert nur Daten (billiger pro Interaktion)
    - Trade-off: Rendering-Kosten werden auf die Geräte der User verlagert,  alte Handys fühlen sich träge an, und auf euren Servern seht ihr davon nichts
    *Drei Leitfragen zur Einordnung einer Anwendung:*
    - Wo lebt der State? (Session/DB vs. Client Store)
    - Wer rendert? (Server vs. Browser)
    - Was passiert bei Verbindungsverlust? (MPA: gar nichts mehr; offline-first PWA: weiter arbeitbar)
    *Beispiele für Mischformen:*
    - Next.js/Remix: SPA plus erstes Rendering auf dem Server (SSR),  Mitte des Spektrums
    - htmx: thick server, aber keine vollen Seiten-Reloads,  Zwischending
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

  #speaker-note()[
    #set text(size: 20pt)
    *Spaltenweise durchgehen, mit je einem konkreten Beispiel:*
    - MPA/MVC: Online-Shop oder Nachrichtenseite,  SEO entscheidend, Crawler brauchen fertiges HTML
    - Serverless/BaaS: Hackathon-Projekt oder MVP eines Startups,  kleine Teams wollen keine Ops-Arbeit, brauchen aber sofort Auth und DB
    - SPA + API: Dashboard, Editor, Mail-Client,  hohe Interaktivität, immer eingeloggt, SEO irrelevant
    *Zwei Zeilen besonders betonen (Klausur-Kandidaten):*
    - "Ort der Logik" und "Rendering" sind die entscheidenden Fragen,  aus ihnen folgt fast alles andere
    - "Ops Zuständigkeit": der eigentliche Verkaufspunkt von Serverless,  bei den anderen Paradigmen pflegt ihr selbst Container, Updates und Zertifikate
    *Abschlussdiskussion (2, 3 Minuten):*
    - Welches Paradigma würdet ihr für das Semesterprojekt wählen? Begründung einfordern,  die richtige Antwort verweist auf die Folie "Thin/Thick Server": es ist ein Spektrum, keine Binärwahl
    *Überleitung:*
    - Microservices im nächsten Kapitel,  dort wird "Ort der Logik" nochmal neu verteilt
  ]
]
