// LTeX: enabled=true language=de-DE

#import "../../Template/hszg.typ": *

= Cross-Origin Resource Sharing (CORS)

== SOP entspannen

#slide(align: horizon)[
  - CORS: SOP Regeln entspannen, nicht ersetzen
  - SOP bleibt vollständig intakt
  - CORS ist eine Erlaubnis, spezifische Responses an spezifische Foreign Origins zu geben
  - Der Besitzer der Daten bleibt weiterhin in Kontrolle
  
  #textbox()[*SOP:* Es wird nie ein Cross-Origin Read geben (default deny)]
  #textbox()[*CORS:* ... außer Responses von `api.example.com`, die von `app.example.com` gelesen werden dürfen]
]

== Wer setzt die Regeln durch?

#slide(align: horizon)[
  #textbox()[
    CORS wird durch den Browser durchgesetzt und durch den Server konfiguriert.
  ]

  #pause

  - Der Server fügt nur Header an die Response an: Er weiß nicht, ob eine Request vom Browser, Script oder CURL kam. Er kann nicht das Erstellen einer Request blockieren.
  - Der Browser vergleicht `Origin` der Request-Seite mit `Access-Control-Allow-Origin` vom Server und schickt entweder die Daten oder gibt einen CORS-Error zurück
  #pause
  - *Konsequenzen:* CORS ist kein Sicherheitsfeature vom Server
    - Ein Client, der kein Browser ist, ignoriert CORS
    - Es existiert um den User und seine Credentials im Browser zu schützen 
]

== Zwei Arten von Requests

#let slide_start = [
  Cross-Origin Requests werden in zwei Flows aufgeteilt, je nachdem wie sicher sie sind:
]

#slide(align: horizon)[
  #slide_start
  1. *Einfache Requests:* Direkt gesendet, keine Erlaubnis im Voraus benötigt:
    - Methoden: `GET`, `HEAD`, `POST`
    - Nur einfache Header: `Accept`, `Accept-Language`, `Content-Type` (limitiert auf `text/plain`, `multipart/form-data`, `application/x-www-form-urlencoded`)
    - Request geht durch, Browser liest die Header nachdem sie angekommen ist
    - Wenn `Accept-Control-Allow-Origin` nicht übereinstimmt sieht das Script nie den Body
    - einfach $eq.not$ harmlos: CSRF existiert immer noch
]

#slide()[
  #slide_start
  2. *Preflighted Requests:* Alles was mehr ist brauch einen Handshake
    - Jede andere Methode: `PUT`, `DELETE`, `PATCH`
    - Custom Header: `Authorization`, `X-Api-Key`, `Content-Type: application/json` ...
    - Browser schickt zuerst eine `OPTIONS` Request mit seinen Intentionen
    - Die wirkliche Request folgt nur, wenn der Server zusagt
]

#slide(align: horizon)[
  #mermaid(
    read("../../Images/preflight_requests.mmd")
  )
]

#slide(align: horizon)[
  === Warum existiert Preflight?
  - Es gibt dem Server Vetorecht bevor Sideeffects auftauchen
  - Cross-Origin `DELETE` darf nicht fire-and-forget
  - Preflight konvertiert _ask forgiveness_ zu _ask permission_
]

// == Header Vokabular

// #slide(align: horizon)[
//   #table(
//     columns: (auto, auto, 1fr),
//     table.header(
//       [Header], [Direction], [Sinn],
//     ),
//     [`Origin`], [Request (automatisch vom Browser)], [Wer fragt?],
//     [`Access-Control-Allow-Origin`], [Response], [Welcher Single-Origin (oder `*`) darf lesen],
//     [`Access-Control-Allow-Methods`], [], [],
//     [], [], [],
//     [], [], [],
//     [], [], [],
//     [], [], [],
//     [], [], [],
//   )
// ]

== Wildcards vs. Explicit Origins

#slide(align: horizon)[
  - `Access-Control-Allow-Origin: *`: Beliebige Origins können diese Response lesen, *aber nur anonym*
  - Spec verbietet Kombination von `*` mit `Access-Control-Allow-Credentials: true`: Browser wird diese Response verbieten
  - Warum? Mit `*` sieht der Server nie, wer nachfragt. Aber Credential-Requests beinhalten User-Cookies $arrow$ Response ist Userspezifisch
  - Nicht jeder sollte die Erlaubnis haben private Daten zu lesen
  - Design zwingt den Server einen spezifischen Origin anzugeben

  ```
    Access-Control-Allow-Origin: https://app.example.com
    Access-Control-Allow-Credentials: true
  ```

  #textbox()[
    *Regel:* `*` ist für public-read-only, Credentials brauchen exakte Origins
  ]
]

== Server-Side Configuration

#slide(align: horizon)[
  ```javascript
    const cors = require("cors");
    // allowlist, not reflection:
    app.use(cors({
      origin: ["https://app.example.com", "https://admin.example.com"],
      credentials: true,
      methods: ["GET", "POST", "DELETE"],
      maxAge: 600 // cache preflight 10 min
    }));
  ```
]

// == Häufige Probleme

// #slide(align: horizon)[
//   - *Duplicate `Access-Control-Allow-Origin` Headers:* z.B. Backend schickt einen und Proxy noch einen $arrow$ Browser lehnt ab
//   - *Proxy antwortet falsch auf `OPTIONS`:* 404/405 bei preflight
//   - *Fehlendes `Vary: Origin`:* 
// ]

// == Alternativen

// #slide(align: horizon)[

// ]
