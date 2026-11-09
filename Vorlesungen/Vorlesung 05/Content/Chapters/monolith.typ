#import "../../Template/hszg.typ": *

= Monolith
<monolith>

== Definition

#slide(align: horizon)[
  #textbox()[
    Ein System, dessen kompletter Funktionsumfang in einer Codebase entwickelt wurde, als ein Artefakt gebaut wird und als eine Einheit deployed wird. 

    Modularität wird intern festgelegt. 
    Verteilung ist extern
  ]

  #table(
    columns: (auto, 1fr, 1fr),
    table.header(
      [], [Intern: verzweigt], [Intern: modular]
    ),
    [Extern: einzelnes Deployment], [Großer Haufen an Software], [Modularer Monolith],
    [Extern: verteilt], [verteilter Monolith (das schlimmste)], [Microservices]
  )
]

== Stärken und Schwächen

#slide(align: horizon)[
  *Stärken*
  - Eine Build/Deploy/Test Pipeline
  - Wenige Netzwerkanfragen
  - Einfaches Refactoring über Module hinaus 
  - Einfaches lokales Entwickeln

  *Schwächen*
  - Skalierung ist _alles oder nichts_ (ein großes neues Feature skaliert ganzes System)
  - Ein Crash zerlegt das ganze System
  - Teams können sich an einer Codebase in die Quere kommen

  #textbox()[
    Monolithen sind in den meisten Fällen die richtige Wahl.
  ]
]
