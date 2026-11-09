#import "../../Template/hszg.typ": *

= Microservices

#slide(align: horizon)[
  #textbox()[
    *Definition:* Ein Architekturstil, der eine Applikation in unabhängige Services unterteilt. 
    Jeder Service hat eine eigenen Daten, die um Business Anforderungen gebaut sind.
  ]
  
  *Wichtiges Axiom*
  - Microservices leben entlang der Domain Grenze, keiner technischen Grenze
  - *Gut:* Order Service, Payment Service, Inventory Service
  - #text(fill: red, weight: "bold")[Schlecht:] UI Service, Logic Service, Database Service
]

== Motivation

#slide(align: horizon)[
  - *Autonomie für Organisation:* Teams können Services end-to-end besitzen und deployen
  - *Unabhängiges Skalieren:* Netflix: Die Recommendation-Engine kann zu hunderten Instanzen skalieren, aber der Invoice-Service läuft auf zwei.
  - *Fehlerisolierung:* Ein fehlerhafter Service bringt nicht die ganze Anwendung zum anhalten (sofern Implementation stimmt)
  - *Technologische Optimierung:* Jeder Service erhält die besten Technologien für seine Anforderungen
  - *Risikoverringerung beim Deployment:* kleine, häufige, rücksetzbare Deploys
]

== Die Kosten

#slide(align: horizon)[
  - *Netzwerk ersetzt Methodenaufrufe:* Latenz, Retries, Timeouts... jeder Aufruf zwischen Services kann auf Wegen fehlschlagen, die bei Funktionsaufrufen nicht passieren würden
  - *Verteilte Transaktionen:* _siehe ACID_
  - *Mehr Ops Aufwand:* 50 Services brauchen Discovery, Config, Observability und ein Team auf sie zu bauen $arrow$ viel Overhead
  - *Datenparität:* Service-Datenbanken bringen Composition for Anfragen auf andere Services

  #textbox()[
    *Wichtige Regel:* Services dürfen andere Service-APIs Anfragen und Subscriben, aber niemals die Datenbank dieser Services direkt ansteuern.
  ]
]

= Auswahlverfahren

#slide(align: horizon)[
  *Welche Architektur wählt man nun?*
  1. Starte mit einem modularen Monolithen, außer es gibt spezifische Anforderungen
  #textbox()[
    *Fowlers Regel:* Man kennt selten die vollen Grenzen aller Services früh in der Entwicklung. 
    Falsch gesetzte Grenzen sind mit die teuersten Fehler, die man später ausbessern muss. 
  ] 
  2. Extrahiere einen Service, wenn das Modul tatsächlich anders ist (z.B. Skalierungsprofil, Verfügbarkeitsanforderungen, Frequenz des Deployments...)
  3. Extrahiere niemals wegen Technologischen Anforderungen
  4. Achte auf Signale, dass ein Wechsel gut wäre: Komplizierte Deployments, Team Koordination wird schwer...
]
