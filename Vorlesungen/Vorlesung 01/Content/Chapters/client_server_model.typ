#import "../../Template/template.typ": *

#let defaultNode(
  x: int,
  y: int,
  shape: fletcher.shapes,
  name: label,
  content
) = {
  node(
    (x, y),
    name: name,
    fill: gray.lighten(90%),
    stroke: black,
    shape: shape,
  )[
    #content
  ]
}

= Client-Server-Modell

== Client vs Server

#slide(align: horizon)[
  #figure(
    image("../../Images/network.png", fit: "contain", height: 80%),
    caption: [
      Server-basiertes Netzwerk
    ]
  )
]

#slide(align: horizon)[
  - Verteilung von Aufgaben innerhalb eines Netzwerks
  - Unterteilung der Computer in Clients und Server
  - Client fordert Services vom Server an
  - Server beantwortet Request
]

#slide(align: horizon)[
  #figure(
    image("../../Images/client_server_model.png", height: 85%),
    caption: [Unterschiedliche Clients verbinden sich über das Internet mit einem Server]
  )
]

#slide(align: horizon)[
  === Server
  - Ein Programm, das mit dem Client kommuniziert
  - Server bietet Zugang zu einem Dienst für den Client
  - Server ist eine Rolle
  - Definierbar auf
    - Geräteebene (Server-Host)
    - Softwareebene (Server-Applikation)
  - Host kann sowohl Client als auch Server sein
]

#slide(align: horizon)[
  === Client
  - Client fordert Service vom Server an
  - Programm, das eine Request initialisiert
  - Im Web-Kontext: Ein Browser
  - Auch Apps, andere Server oder Tools wie `curl`
]

== Request-Response-Zyklus

#slide(align: horizon)[
  Jede Interaktion folgt der gleichen Abfolge
  - Der Client schickt eine Request
  - Der Server schickt genau eine Response
  - Wenn der Client neue Daten braucht, muss eine neue Request geschickt werden

  #figure(
    diagram(
      node-stroke: 1pt,
      node-inset: 10pt,
      defaultNode(x: 5, y: 0, shape: rect, name: <Frontend>)[Frontend],
      defaultNode(x: 0, y: 0, shape: rect, name: <Backend>)[Backend],
      edge(<Frontend>, "-|>", <Backend>, bend: -30deg)[1. HTTP-Request],
      edge(<Backend>, "-|>", <Frontend>, bend: -30deg)[2. HTTP-Response],
    ),
    caption: [
      Der Request-Response-Zyklus
    ]
  )
]

== HTTP Statelessness

#slide(align: horizon)[
  - Jede Request wird vom Server behandelt, als hätte der Server keine Erinnerungen an alte Requests
  - Zwei Requests vom gleichen Browser sind für HTTP komplett unzusammenhängend
  - *Ziel:* Einfacher Aufbau einer Request und Skalierbarkeit
  
  #v(2em)

  Wie kann eine Website sich merken, dass ein User eingeloggt ist? \
  #alert([Nutzung von Cookies, Sessions und JSON Web Tokens, um Kontext zu halten.])
]
