#import "../../Template/hszg.typ": *

= Übersicht

== Definition

#slide(align: horizon)[
  *Was ist (Web) Application Architektur*
  - Die High-Level Struktur einer Web Applikation
  - Wie ihre Komponenten organisiert werden
  - Wie sie miteinander interagieren
  - Wie Verantwortlichkeiten zwischen Client, Server und Netzwerk verteilt sind

  *Drei Ebenen der Abstraktion*
  1. *System-Ebene*: Welche Komponenten existieren?
  2. *Komponenten-Ebene:* Wie sind Verantwortlichkeiten verteilt?
  3. *Code-Ebene:* Wie ist der Code intern strukturiert
]

#slide(align: horizon)[
  *Mentales Modell:* 
  - Architektur: Eine Menge an Entscheidungen, die man später nur schwer ändern kann
  - Design: Füllt die Details innerhalb der Architektur

  #pause

  *Constraint der Web Umgebung:*
  Alles passiert über den HTTP Request/Response Zyklus zwischen Client und Server: Statelessness, Latenz und das Netzwerk sind unzuverlässige Medien, die Architekturentscheidungen beeinflussen
  
  #pause

  #textbox()[*Grundfrage für jedes Paradigma:* 
  Wo soll die Logik der Anwendung leben und wie viel von dieser Logik soll im Browser laufen?]
]

== Was entscheidet Architektur?

#slide(align: horizon)[
  - *Wo wird die Seite gerendert?* Server, Client oder beides? (SSR, CSR, hybrid)
  - *Data Flow & API Stil:* REST, GraphQL, gRPC, server push
  - *State Location:* Server Session, Client Store, URL, Datenbank
  - *Modularität:* Monolith, Modularer Monolith, Microservices, Micro-Frontends
  - *Kommunikation:* Synchrone Requests/Responses, Asynchrone Events
  - *Deployment:* Ein Artefakt, viele unabhängige Services
]

== Warum ist es wichtig?

#slide(align: horizon)[
  *Konsequenzen von schlechter Architektur:*
  - *Schwer zu ändern:* Jedes neue Feature verlangt nun Änderungen an mehreren Orten
  - *Schwer zu skalieren:* Ein aufwändiges Feature in einem Monolith kann das skalieren der ganzen App verlangen
  - *Schwer zu testen:* UI, Logik und Datenbank sind alle in einem Codesegment
  - *Schwierigkeiten im Team:* Mehrere Teams blockiert, weil sie auf der gleichen Codebase bzw. Pipeline arbeiten
  - *Niedrige Performance:* falsche Rendering-Strategie (z.B. pures CSR für Seiten mit viel Inhalt)
]

#slide(align: horizon)[
  *Konsequenzen von guter Architektur:*
  #table(
    columns: (auto, 1fr),
    table.header(
      [Qualitätsattribut], [Welche Architektur erlaubt es?]
    ),
    [Skalierbarkeit], [Stateless Server, Horizontales Skalieren, Caching Tiers],
    [Wartbarkeit], [Separation von Aufgaben, Wenige interne Abhängigkeiten],
    [Testbarkeit], [Logik isoliert von I/O und UI],
    [Deploybarkeit], [Unabhängiges Deployen von einzelnen Komponenten],
    [Performance], [Richtige Rendering-Strategie für den Inhalt],
    [Sicherheit], [Trust Boundaries und Validierungsschichten]
  )
]

#slide(align: horizon)[
  *Ökonomische Argumente:*
  - Architektur ist: Jetzt günstig, später teuer (ein Live-System umbauen kann 10-100x an Kosten verursachen)
  - Conway's Law: Architektur wird auch das Team widerspiegeln $arrow$ Entscheidungen für Architektur sind auch Teamweite Entscheidungen
  
  *Konkrete Beispiele:*
  - Netflix migrierte von Monolith zu Microservices
  - Amazon: "You build it, you run it"
  - Shopify: Bewusste Wahl eines modularen Monolithen
]

= Beispiele

== Netflix - Vom Monolith zu Microservices

#slide(align: horizon)[
  *Ausgangspunkt:* Netflix begann 1997 als DVD-by-mail Geschäft und nutzte eine monolithische Java App mit Oracle DBs

  *Auslöser:* 2008 ging der ganze Service down, weil Teile der Datenbank corrupted wurden. 
  Es dauerte 3 Tage, bis er wieder online kam. 
  Die monolithische Architektur wurde als _single-point-of-failure_ erkannt. 
  Neues Streamingbusiness verlangte außerdem Skalierungen, die monolithisch nicht möglich gewesen wären. 
]

== Die Migration

#slide(align: horizon)[
  - Eine 7-jährige Reise zu hunderten Microservices auf AWS
  - Monolith und Microservices liefen parallel für Jahre
  - Heute: 700+ Microservices, die 15+ milliarden API Aufrufe, verteilt auf 190+ Länder, täglich verwalten
  - Netflix baute eigene OSS Tools während dem Prozess:
    - Eureka (Service Discovery)
    - Hystrix (Circuit Breaker)
    - Zuul (Gateway)
    - Simian Army (Chaos Testing) 
]
