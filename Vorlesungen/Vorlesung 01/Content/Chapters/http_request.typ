#import "../../Template/hszg.typ": *

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

= HTTP Request

== Request-Response-Zyklus

#slide(align: horizon)[
  #figure(
    diagram(
      node-stroke: 1pt,
      node-inset: 10pt,
      defaultNode(x: 5, y: 0, shape: rect, name: <Frontend>)[Frontend],
      defaultNode(x: 0, y: 0, shape: rect, name: <Backend>)[Backend],
      edge(<Frontend>, "-|>", <Backend>, bend: -30deg)[1. HTTP Request],
      edge(<Backend>, "-|>", <Frontend>, bend: -30deg)[2. HTTP Response],
    ),
    caption: [
      Der Request-Response-Zyklus
    ]
  )
]

#slide(align: horizon)[
  #figure(
    diagram(
      node-stroke: 1pt,
      node-inset: 10pt,
      defaultNode(x: 5, y: 0, shape: rect, name: <Frontend>)[Frontend],
      defaultNode(x: 0, y: 0, shape: rect, name: <Backend>)[Backend],
      edge(<Frontend>, "-|>", <Backend>, bend: -30deg, stroke: red)[#text(fill: red, weight: "bold")[1. HTTP Request]],
      edge(<Backend>, "-|>", <Frontend>, bend: -30deg)[2. HTTP Response],
    ),
    caption: [
      Der Request-Response-Zyklus
    ]
  )
]

#let httpRequestExample = {
  ```
    POST http://localhost:8080/todos HTTP/1.1
    Accept: */*
    Content-Type: application/json

    {
      "name": "todoItemName",
      "description": "newDescription",
      "done": true,
      "created": "2025-10-23T15:06:08.738Z"
    }
  ```
}

== Bestandteile

#slide(align: horizon)[
  - *Request Line* mit folgenden Bestandteilen:
    - Ein *HTTP Verb*, das die Art der Operation definiert
    - Einen *Pfad* zu einer Ressource
    - *HTTP-Version*
  - Einen *Header*, der Informationen über die Request enthält
  - Einen optionalen *Body*, der weitere Daten enthält
]

== Beispiel

#slide(align: horizon + center)[
  #httpRequestExample
]

#slide(align: horizon + center)[
  #codly(
    highlights: (
      (line: 1, start: 3, end: 6, fill: red),
      (line: 3, start: 17, end: none, fill: green),
    ),
    annotations: (
      (
        start: 1, end: 1,
        content: block(
          width: 2em,
          rotate(-90deg, reflow: true, align(center)[Request Line])
        )
      ),
      (
        start: 2, end: 3,
        content: block(
          width: 2em,
          rotate(-90deg, reflow: true, align(center)[Headers])
        )
      ),
      (
        start: 5, end: 10,
        content: block(
          width: 2em,
          rotate(-90deg, reflow: true, align(center)[JSON Body])
        )
      ),
    )
  )
  #httpRequestExample
]

== Request Line

#slide(align: horizon)[
  ```
    POST http://localhost:8080/todos HTTP/1.1
  ```

  - `POST`: Gibt die genutzte HTTP-Methode an
  - `http://localhost:8080/todos`: Request-Target gibt an, an welche Ressource die Anfrage gerichtet ist
  - `HTTP/1.1`: HTTP Version gibt an, welche Version des HTTP-Protokolls genutzt wird

  #rect(stroke: hszg-green + 2pt, fill: background, inset: 15pt)[
    *Hinweis:* Bei HTTP/1.1 ist normalerweise nur der Pfad enthalten:
    
    #codly(
      fill: gray.lighten(80%)
    )
    ```
      POST /todos HTTP/1.1
      Host: localhost:8080
    ```

    Volle URL wird meist von Tools wie curl, Postman oder Browser-Entwicklertools angezeigt. 
  ]
]

== Pfad

#slide(align: horizon)[
  - Definiert, auf welcher Ressource die Operation ausgeführt werden soll
  - Erster Teil sollte die Pluralform der Ressource sein
  *Beispiel*: `store.com/customers/223/orders/12`
  #guideline[Lesbarkeit der Pfade][
    Jeder API Pfad sollte auch ohne Kenntnisse über das System dahinter klar machen, was bei der Request passieren wird.
  ]
]

== Header

#slide(align: horizon)[  

  ```
    Accept: */*
    Content-Type: application/json  
  ```

  - `Accept`: Welche Formate der Client akzeptiert
  - `Content-Type`: Welches Format besitzen die Daten, die der Client schickt
  - Art der Ressource über MIME Types
  *MIME Type*:
  ```
    type/subtype;parameter=value
  ```
  - `parameter` ist optional
  - *Beispiele*: `image/png`, `audio/wav`, `application/json`
]

= HTTP Response

== Übersicht

#slide(align: horizon)[
  #figure(
    diagram(
      node-stroke: 1pt,
      node-inset: 10pt,
      defaultNode(x: 5, y: 0, shape: rect, name: <Frontend>)[Frontend],
      defaultNode(x: 0, y: 0, shape: rect, name: <Backend>)[Backend],
      edge(<Frontend>, "-|>", <Backend>, bend: -30deg)[1. HTTP Request],
      edge(<Backend>, "-|>", <Frontend>, bend: -30deg, stroke: red)[#text(fill: red, weight: "bold")[2. HTTP Response]],
    ),
    caption: [
      Der Request-Response-Zyklus
    ]
  )

  #v(1em)

  - Datentyp angeben wenn Daten zurückgegeben werden sollen
  - Content-Type im Header wie bei Request
  - Status Code anhängen für Informationen über Ausgang der Request
]

#let httpResponseExample = {
  ```
    HTTP/1.1 200 OK
    Connection: keep-alive
    Content-Type: application/json
    Date: Thu, 23 Oct 2025 16:45:09 GMT
    Keep-Alive: timeout=60
    Transfer-Encoding: chunked

    [
      {
        "id": 0,
        // Mehr Daten
      }
    ]
  ```
}

== Beispiel

#slide(align: horizon)[
  #httpResponseExample
]

#slide(align: horizon)[
  #codly(
    highlights: (
      (line: 1, start: 12, end: 17, fill: red),
      (line: 3, start: 17, end: none, fill: green),
    ),
    annotations: (
      (
        start: 1, end: 1,
        content: block(
          width: 2em,
          rotate(-90deg, reflow: true, align(center)[Code])
        )
      ),
      (
        start: 2, end: 6,
        content: block(
          width: 2em,
          rotate(-90deg, reflow: true, align(center)[Header])
        )
      ),
      (
        start: 7, end: 13,
        content: block(
          width: 2em,
          rotate(-90deg, reflow: true, align(center)[JSON Body])
        )
      ),
    )
  )
  #httpResponseExample
]
