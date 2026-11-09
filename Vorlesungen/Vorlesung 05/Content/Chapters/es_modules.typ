#import "../../Template/hszg.typ": *

= ES Modules

== Warum?

#slide(align: horizon)[
  *Welches Problem wird gelöst?*
  - Bevor es Module gab, teilte sich jedes `<script>` einen globalen Namespace
  - Der einzige Weg für private Werte war: Code in IIFEs wrappen
  - "Dependency Management" war damals: Manuell `<script>`-Tags im HTML ordnen
  - Eine Datei konnte nicht deklarieren, welche Abhängigkeiten sie braucht

  #speaker-note()[

  ]
]

#slide(align: horizon)[
  *Statische, analysierbare Abhängigkeiten*

  - `import`/`export` sind syntaktische Deklarationen, keine runtime Funktionen (wie `require()`)
  - Tools können den ganzen Dependency-Graph lesen ohne Code auszuführen
  
  Ermöglicht folgende Features:
  - *Frühes Finden von Errors:* Ein fehlendes Modul wird bei _load time_ fehlschlagen, nicht wärend der Ausführung
  - *Tree-shaking:* Bundlers können unerreichbare Abhängigkeiten finden und löschen
  - *Optimiertes Laden:* Preloading (`modulepreload`), paralleles fetch, deferred execution 

  #speaker-note()[
    #set text(size: 20pt)
    *Deferred Execution:* 
    - Klassische `<script>`-Tags ohne Attribute werden synchron ausgeführt (HTML parsing stoppt)
    - Bei deferred:
      - Script Download passiert parallel
      - Script wird erst ausgeführt, wenn HTML geparst wurde
      - Ausgührungsreihenfolge von Scripts bleibt erhalten: anders als `async`, deferred Scripts werden in Document Reihenfolge ausgeführt
  ]
]

#slide(align: horizon)[
  *Isolation zwischen Modulen*
  
  - Jedes Modul hat seinen eigenen Scope
  - Keine globalen Variablen (weniger Fehlerpotential)
  - Keine Probleme zwischen unterschiedlichen Libraries
  - Top-Level Code wird genau einmal pro URL ausgeführt, egal wie viele Importers es gibt

  #speaker-note()[
    
  ]
]

#slide(align: horizon)[
  *Live Bindings mit direktionaler Mutation*

  - Imports bringen read-only Zugriff auf Variablen
  -  Nur das besitzende Modul kann Werte ändern
  - Änderungen am State propagieren nach Draußen $arrow$ Flow von Daten wird verfolgbar

  #speaker-note()[
    
  ]
]

#slide(align: horizon)[
  *Standard für die Sprache*

  #speaker-note()[
    
  ]
]

#slide(align: horizon)[
  *Robust*

  #speaker-note()[
    
  ]
]

== Ziele

#slide(align: horizon)[

]

== Pipeline

#slide(align: horizon)[
  1. *Construction:* `fetch` + `parse` für jedes Module (ohne Ausführung), Extrahierung von `import` Spezifikation, Rekursives Bauen eines Graphs, Errors tauchen früh auf. `<link rel="modulepreload">` erlaubt Browser parallele Discovery
  2. *Instantiation:* Zuerst auf Tiefe, Ein Memory-Slot pro exportiertem Binding, Jeder Import wird zu dem gleichen Slot verlinkt. Function wird hier inizialisiert (hoisting)
  3. *Evaluation:* Post-Order (Dependencies zuerst, danach Dependents), Jeder body wird einmal pro URL ausgeführt, danach dependents

  #speaker-note()[
    
  ]
]
