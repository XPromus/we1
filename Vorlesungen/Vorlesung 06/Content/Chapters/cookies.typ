#import "../../Template/hszg.typ": *

= Cookies

== In einer Nussschale

#slide(align: horizon)[
  #text()[Oder eher Cookies mit Nüssen #emoji.face.think]
  #pause
  #textbox()[
    *Was sind Cookies:* Ein Key-Value String (`session=abc123`) die der Browser zum Server schickt mit dem `Set-Cookie` Header. 
    Der Browser schickt sie bei jeder folgenden Request mit.
  ]
  #pause
  #textbox()[
    *Was machen Cookies:* Sie geben stateless HTTP ein _Gedächtnis_.
    Der Server speichert ein kleines Token um zu wissen wer die Anfrage stellt. 
  ]
  #pause
  *Warum werden Cookies genutzt?*
    - *Sessions bzw. Login State:* Ohne Cookies muss nach jedem Page-Reload neu eingelogged werden
    - *Personalisierung:* Preferenzen, Sprache, Theme
    - *Tracking & Analytics:* User erkennen über mehrere Seitenbesuche
]

#slide(align: horizon)[
  *Essentielle Mechanik:*
  - Cookies selbst sind trivial
  - Macht kommt von der Garantie des Browsers sie an jede passende Request anzuhängen
  - Automatisches Hinzufügen ist zugleich Feature und Sicherheitsproblem
  - Deshalb existiert Attributsystem `HttpOnly`, `Secure`, `SameSite`

  #textbox[
    *Kernaussage:* Cookies sind ein, vom Browser verwaltetes, Token, welches anonyme HTTP Requests in eine durchgehende Beziehung zu einem spezifischen Server umwandelt. 
  ]
]

== Header

#slide(align: horizon)[
  ```
  Set-Cookie: 
    session=abc123; Path=/; Domain=example.com; Max-Age=3600;
    Secure; HttpOnly; SameSite=Lax
  ```

  - Format: `name=value` zuerst; danach `;`-separierte Attribute
  - Geschickt durch den Server, wird echoed durch den Browser als `Cookie: session=abc123`
  - Attribute kontrollieren den Scope, Lifetime und Security
  - Mehrere Cookies werden durch mehrere `Set-Cookie` Header erzeugt 
]
