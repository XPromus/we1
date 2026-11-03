#import "../../Template/hszg.typ": *

= Web Sockets

== Technische Übersicht

#slide(align: horizon)[
  *Welches Problem wird gelöst?*

  #pause

  - Klassisches HTTP ist ein Request-Response-Protokoll
  - Nur der Client intialisiert Kommunikation
  - Für real-time Anwendungen (Chats, Live Dashboards, Multiplayer Spiele, ...) würde sonst Polling benötigt werden
  - Wiederholte HTTP Requests wären verschwenderisch und _laggy_
  
  #pause
  
  *Was ist eine WebSocket?*
  
  #pause
  - Eine einzelne persistente TCP Verbindung
  - Wird über HTTP ausgehandelt (Handshake)
  - Wird danach zu einer full-duplex bzw. einem bidirektionalem Kanal (definiert nach RFC 6455)
  - Beide Seiten können Nachrichten schicken mit minimalem Overhead
]

== Ablauf

/*
sequenceDiagram
    participant Client as Browser (WebSocket API)
    participant Server as Server (z.B. Node.js + ws)

    Note over Client,Server: 1. Handshake — noch normales HTTP
    Client->>Server: GET /chat HTTP/1.1<br/>Upgrade: websocket<br/>Sec-WebSocket-Key: ...
    Server->>Client: 101 Switching Protocols<br/>Sec-WebSocket-Accept: SHA-1(Key + GUID)

    Note over Client,Server: 2. Persistente TCP-Verbindung<br/>Vollduplex ab jetzt
    Client-->>Server: Frame (masked, UTF-8 Text)
    Server-->>Client: Frame (unmasked)
    Server-->>Client: Ping
    Client-->>Server: Pong
    Client-->>Server: Binär-Frame (z.B. Blob)

    Note over Client,Server: 3. Geordneter Abbau
    Client->>Server: Close-Frame (Code 1000)
    Server->>Client: Close-Frame (Echo)
    Client-->>Server: TCP FIN
*/

#slide(align: horizon)[
  #figure(
    image("../../Images/websocket_overview.svg")
  )
]

== Ablauf - Phase 1

#slide(align: horizon)[
  #figure(
    image("../../Images/websocket_overview_1.svg")
  )

  #speaker-note()[
    #set text(21pt)
    *Phase 1*
    - Die Verbindung beginnt als *ganz normale HTTP-Anfrage*: ein `GET` mit Sonderheadern:
      - `Upgrade: websocket` und `Connection: Upgrade`: Forderung nach Protokollwechsel
      - `Sec-WebSocket-Key: <Base64>`: zufälliger 16-Byte-Wert des Clients
      - `Sec-WebSocket-Versiom: 13`: aktuelle Protokollversion (RFC 6455)
    - Der Server antwortet mit `101 Switching Protocols` und `Sec-WebSocket-Accept`: der SHA-1-Hash aus `Key + festem GUID`, Base64-kodiert
    - *Zweck des Hashes:* Der Client prüft den Accept-Wert. Da ein HTTP-Server ohne WebSocket-Verständnis den Header nie korrekt berechnen kann, ist garantiert, dass Gegenüber wirklich ein WebSocket-Endpunkt ist (kein versehentlicher Proxy-Kontakt)
    - *Ab hier ist HTTP beendet*- Dieselbe TCP-Verbindung wird weiterverwendet, aber sie spricht im WebSocket-Frameprotokoll
  ]
]

== Ablauf - Phase 2

#slide(align: horizon)[
  #figure(
    image("../../Images/websocket_overview_2.svg")
  )

  #speaker-note()[
    #set text(size: 19pt)
    - *Ein TCP-Socket, beide Richtungen, jederzeit:* Weder Client noch Server müssen auf eine Anfrage warten. Der Server kann von sich aus Nachrichten pushen, der zentrale Unterschied zum Request-Response-Modell.
    - *Frames statt Header:* Jede Nachricht besteht aus Frames mit nur *maximal 14 Byte Overhead* (gegenüber ~500 Byte HTTP-Header pro Polling-Request). Geringe Latenz, geringer Overhead.
    - *Maskierung (nur Client → Server):* Jeder Client-Frame wird mit einem zufälligen *4-Byte-XOR-Schlüssel* maskiert. Grund: Schutz vor Middleware-Proxys, die maskierte Daten nicht als HTTP-Header missinterpretieren können (Cache-Poisoning-Abwehr aus der Geschichte des Protokolls). Server-Frames sind unmaskiert.
    - *Frame-Typen*
      - Text — UTF-8, typischer Fall für JSON-Nachrichten
      - Binary — Blobs, ArrayBuffer, z. B. Bilder oder Audio
      - Ping/Pong — Herzschlag: der Server (oder Client) sendet `Ping`, der Partner antwortet sofort mit `Pong`. Hält NAT-Timeouts und Proxys davon ab, die stille Verbindung abzubauen. Bleibt der Pong aus, gilt die Verbindung als tot und wird typischerweise nach ~30 s abgebaut..
    - *Fragmentation:* Große Nachrichten dürfen in mehrere Kontinuations-Frames zerlegt werden (relevant für Streaming großer Binärdaten).
  ]
]

== Ablauf - Phase 3

#slide(align: horizon)[
  #figure(
    image("../../Images/websocket_overview_3.svg")
  )

  #speaker-note()[
    - Ein Beteiligter sendet einen *Close-Frame*, meist mit Statuscode:
      - `1000`: normaler Abschluss ("Connection closed normally")
      - `1001`: Endpunkt geht offline
      - `1006`: abrupter Abbruch ohne Close-Frame (Netzwerkfehler), wichtig für die Reconnect-Logik
    - Der Partner *echo't* den Close-Frame, erst danach schließt der Initiator die TCP-Verbindung.
    - *Warum der Aufwand?* Beide Seiten wissen sicher, dass das Ende gewollt war, und können noch ausstehende Frames flushen. Ein fehlender Close-Frame signalisiert Fehlerfall $arrow$ Reconnect.
  ]
]

== HTTP vs. Web Sockets

/*
flowchart LR
    subgraph HTTP ["HTTP: Request–Response (halbduplex)"]
        A1[Client] -- "Request 1" --> B1[Server]
        B1 -- "Response 1" --> A1
        A1 -. "Request 2 (Polling)<br>Kopf-Overhead ~500 Byte" .-> B1
        B1 -. "Response 2" .-> A1
    end

    subgraph WS ["WebSocket: Vollduplex über eine Verbindung"]
        A2[Client] <== "Frames ~2–10 Byte<br>beide Richtungen jederzeit" ==> B2[Server]
    end
*/

#slide(align: horizon)[
  // #figure(
  //   image("../../Images/websocket_http_comp.png")
  // )
  
  // #fletcher.diagram(
  //   node-stroke: 0.8pt,
  //   node-fill: luma(245),
  //   spacing: (4em, 5em),
  //   edge-stroke: .8pt,

  //   node((1, 2.9), [HTTP: Request-Response (halbduplex)],
  //   shape: rect, fill: none, stroke: (paint: luma(120), dash: "dashed"), layer: -1),

  //   node((0, 2), [Client], name: <c1>),
  //   node((2, 2), [Server], name: <s1>),

  //   edge(<c1>, <s1>, "-|>", bend: 14deg,
  //     label: text(size: 8pt)[Request 1], label-side: left),
  //   edge(<s1>, <c1>, "-|>", bend: 14deg,
  //     label: text(size: 8pt)[Response 1], label-side: left),
  //   edge(<c1>, <s1>, "-|>", bend: 14deg, shift: (0, -1),
  //     stroke: (dash: "dashed"),
  //     label: text(size: 8pt)[Request 2 (Polling)\
  //       Kopf-Overhead ~500 Byte], label-side: left),
  //   edge(<s1>, <c1>, "-|>", bend: 14deg, shift: (0, -1),
  //     stroke: (dash: "dashed"),
  //     label: text(size: 8pt)[Response 2], label-side: left),

  //   node((5, 2.9), [WebSocket: Vollduplex über eine Verbindung], shape: rect, fill: none, stroke: (paint: luma(120), dash: "dashed"), layer: -1),

  //   node((4, 2), [Client], name: <c2>),
  //   node((6, 2), [Server], name: <s2>),

  //   edge(<c2>, <s2>, "-", stroke: 1.8pt,
  //     label: text(size: 8pt)[Frames ~2–10 Byte\
  //       beide Richtungen jederzeit], label-side: left),
  // )
  
  *HTTP*
  - Halbduplex: pro Kommunikation genau eine Richtung $arrow$ erst fragen, dann antworten
  - Nur der Client kann initiieren; der Server schweigt, bis Request kommt
  - Jede Nachricht kostet einen vollen Request-Zyklus (~500 Byte Header)
  - Für Neuigkeiten: Polling $arrow$ wiederholte, meist leere Anfrage

  *Web Sockets*
  - Eine einzige persistente Verbindung für die gesamte Sitzung
  - Beide Seiten senden jederzeit, ohne neuen Verbindungsaufbau
  - Jede Nachricht ist ein schlanker Frame (maximal 14 Byte Overhead)
  - Der Server pusht aktiv: keine Anfrage, keine Wartezeit

  #speaker-note()[
    *Kernaussage:* Beide Modelle laufen über TCP und können dieselben Daten transportieren. 
    Der Unterschied liegt in *Wer initiieren darf* und *was jede Nachricht kostet*.
    HTTP erzwingt ein Frager-Antwort-Spiel mit hohem Wiederholungsaufwand. 
    WebSocket zahlt einmalig für den Handshake und bekommt danach eine schlanke, in beiden Richungen offene, Leitung.
  ]
]


== Der Handshake

#slide(align: horizon)[
  Die Verbindung startet mit einer normalen HTTP GET Request mit einem `Upgrade` Header:
  ```
    GET /chat HTTP/1.1
    Host: exmaple.com
    Upgrade: websocket
    Connection: Upgrade
    Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
    Sec-WebSocket-Version: 13
  ```
  - Der Server antwortet mit `101 Switching Protocols` und einem `Sec-WebSocket-Accept` Value
  - Beweis dafür, dass der Server WebSockets benutzen kann
  - HTTP ist jetzt fertig $arrow$ TCP übernimmt mit dem *WebSocket framing protocol*

  #speaker-note()[
    Codebeispiel:
    `Upgrade: websocket` + `Connection: Upgrade`: Forderung nach Protokollwechsel
    - `Connection: Upgrade`: gehört grammatikalisch dazu, wird gern vergessen
    - Fehlende Header: Ablehnung `400 Bad Request`
    - `Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==`: Konstante aus RFC 6455
    - `Sec-WebSocket-Version: 13`: Versionsnummer, 1-12 waren experimentelle Phasen, 13 ist endgültig. Bei Versionunterschieden `426 Upgrade Required`
  ]
]

== Protokoll Komponenten

#slide(align: horizon)[
  - *Frames:* 
    - Client $arrow$ Server Frames müssen maskiert werden (4-byte XOR Key als Sicherheitsmaßnahme)
    - Server $arrow$ Client Frames werden nicht maskiert
  - *Frame types:* Text (UTF-8), Binary, Ping/Pong (keep-alive), Close
  - *Fragmentation:* Große Nachrichten können in mehrere Frames aufgeteilt werden
  - *Closing:* Handshake um die Verbindung ordentlich zu schließen (close frame + TCP FIN), Verbindung wird sonst einfach abgebrochen
]

== Aufbau eines Frames

#slide(align: horizon)[
  - Jede Nachricht nach dem Upgrade ist ein *Frame*
  - Frame-Format ist binär definiert: Header ist zwischen 2 und 14 Byte groß
  #fletcher.diagram(
    node-stroke: black,
    node-corner-radius: none,
    node-shape: rect,
    node((0, 0), [FIN \ 1 Bit]),
    edge(),
    node((1, 0), [RSV1-3 \ 3 Bit]),
    edge(),
    node((2, 0), [Opcode \ 4 Bit]),
    edge(),
    node((0, 1), [MASK \ 1 Bit]),
    edge(),
    node((1, 1), [Payload-Length \ 7/7+16 / 7+64 Bit]),
    edge(),
    node((2, 1), [Masking-Key \ 4 Byte (wenn MASK=1)]),
    edge(),
    node((0, 2), [Payload \ maximal 8 Exbibyte]),
  )

  #speaker-note()[
    - Diagram ist Bytereihenfolge von links nach rechts, wie sie beim Empfänger ankommt
    - Logik mit Fragen
      1. Was kommt? (FIN, Opcode)
      2. Wie viel kommt? (Länge)
      3. Wie entschlüsselt (Masking-Key)
    - Zentraler Gedanke: Empfänger kann Länge aus dem Header ableiten ohne Payload zu lesen
    - Auch bei Fragmentierung weiß Empfänger wo Frame endet und neuer beginnt
    - Reihenfolge ist wichtig für das Protokoll
  ]
]

== Komponenten

#slide(align: horizon)[
  *FIN (1 Bit):* Endfragment-Flag:
    - `1` = die Nachricht ist vollständig in diesem Frame
    - `0` = es folgen Kontinuations-Frames (Opcode `0`) bis ein Frame mit `FIN=1` kommt
  
  *RSV1-RSV3 (je 1 Bit):* reserviert, müssen `0` sein, *außer* eine Erweiterung ist ausgehandelt

  #speaker-note()[
    *FIN - Fragmentierungs-Flag*:
    - Entscheidet ob Nachricht sofort weitergeben werden kann `FIN=1` oder in einen Buffer kommt bis der Rest da ist `FIN=0`
    *RSV1-RSV3:* reserviert, müssen `0` sein, *außer* eine Erweiterung ist ausgehandelt
  ]
]

#slide(align: horizon)[
  *Opcode (4 Bit):* Typ des Frames
  #set text(size: 20pt)
  #table(
    columns: (1fr, 1fr, 1fr),
    table.header(
      [Opcode], [Frame], [Bedeutung]
    ),
    [`0x0`], [Continuation], [Fortsetzung einer fragmentierten Nachricht],
    [`0x1`], [Text], [UTF-8-Nachricht, als Grenzes dekodierbar],
    [`0x2`], [Binary], [beliebige Binärdaten (ArrayBuffer/Blob)],
    [`0x8`], [Close], [leitet den geordneten Abbau ein],
    [`0x9`], [Ping], [Herzschlag-Anfrage],
    [`0xA`], [Pong], [Herzschlag-Antwort],
    [`0x3-0x7, 0xB-0xF`], [reserviert], [ungültig im normalen Betrieb],
  )
]

#slide(align: horizon)[
  *MASK (1 Bit):* muss bei allen Client-Frames `1` sein und `0` bei Server-Frames. 
  Ein Server, der einen unmaskierten Client-Frame erhält (oder umgekehrt maskierte vom Server), trennt die Verbindung (Protokollfehler 1002).

  *Payload-Länge (7 Bit + optional):* drei Stufen:
  1. Länge `0-125`: passt direkt in die 7 Bit, kein Zusatzfeld
  2. Wert `126`: die nächsten *2 Byte* (16 Bit, bis 65.535) tragen die echte Länge
  3. Wert `127`: die nächsten *8 Byte* (64 Bit) tragen die echte Länge 
  // (bis ~16 Exbibyte). Der Wert muss in minimaler Form kodiert sein: Länge 100 mit 8-Byte-Kodierung ist ein Protokollverstoß.
]

#slide(align: horizon)[
  *Masking-Key (4 Byte, bei MASK=1):* ein zufälliger XOR-Schlüssel 
  - Payload wird byteweise mit `payload[i] XOR key[i mod 4]` maskiert 
  - Empfänger (Server) demaskiert identisch
  - *Beachte:* Der Frame-Header wird nie selbst maskiert
  - Maskierung basiert auf der Regel: `a XOR k XOR k = a`
  - *Ziel:* Proxy soll Bytes nicht als HTTP wahrnehmen
  - *Risiko:* Requests in den Proxy schmuggeln um andere Daten zu erhalten
  
  *Payload:* die eigentlichen Daten, 0 Byte bis zur 64-Bit-Grenze.

  // #speaker-note()[
  //   #set text(size: 20pt)
  //   - Grund historisch und betrifft Middleboxes, nicht Server 
  //   - Proxys und transparente Middlewares interpretieren eingehende Bytes als HTTP-Header 
  //   - Böswilliger Client könnte in einem WebSocket-Frame Bytes schicken die exakt wie HTTP-Anweisungen aussehen (z. B. GET /admin HTTP/1.1) - Ziel: Caching-Proxy zwischendurch speichert Antwort und vergiftet Cache (Cache-Poisoning)
  //   - Maskierung macht Byte vorhersagen mathematisch unmöglich
  //   - Ergebnis hängt vom passenden Schlüssel ab
  //   - Maskierung ist es dem Client mathematisch unmöglich vorherzusagen, welche Bytes auf der Leiste ankommen, selbst wenn er den gewünschten Klartext kennt, hängt das Ergebnis vom zufälligen Schlüssel ab, den er nicht selbst „passend“ wählen kann, ohne gleichzeitig den Schlüssel im selben Frame offenzulegen.
  //   Warum nur die Client-Richtung? Weil Server innerhalb des Rechenzentrums als vertrauenswürdig gelten. 
  //   Der Angreifer in diesem Szenario ist immer der kontrollierbare Browser-Client, nicht der eigene Server.

  //   MASK ist keine Verschlüsselung, sondern ein *Verfälschungsschutz*: Der Client darf bestimmen, was er sendet, aber die Maskierung nimmt ihm die Kontrolle darüber, welche Bytes der Proxy zu sehen bekommt - und genau diese Kontrolle bräuchte ein Cache-Poisoning-Angriff.
  // ]
]

== Konkretes Beispiel (Server $arrow$ Client)

#slide(align: horizon)[
  ```
    81 05 48 61 6C 6C 6F
  ```

  #set text(size: 20pt)
  #table(
    columns: (auto, auto, auto, 1fr),
    table.header(
      [Byte(s)], [Hex], [Binär], [Bedeutung]
    ),
    [1], [`81`], [`1000 0001`], [FIN=1 (eine komplette Nachricht), RSV=000, Opcode 0x1 = Text-Frame],
    [2], [`05`], [`0000 0101`], [MASK=0 (Server sendet nie maskiert), Payload-Länge = 5],
    [3-7], [`48 61 6C 6C 6F`], [], [Payload: "Hallo" in UTF-8],
  )
]

#slide(align: horizon)[
  *Im Browser:*
  - WebSocket-API des Browsers liest den Frame-Header
  - Erkennt Opcode `0x1` (Text)
  - Dekodiert den Payload als UTF-8
  - Übergibt Ergebnis dem Handler

  ```javascript
    socket.onmessage = (event) => {
      event.data; // "Hallo"
      event.origin; // "wss://example.com"
      event.lastEventId; // "" (nur bei SSE relevant)
      event.ports; // []
    }
  ```
]

== Beispiel für mehrere Frames (Fragmentierung)

#slide(align: horizon)[
  
  #grid(
    columns: (auto, 1fr, auto),
    inset: 5pt,
    [Frame 1], [`FIN=0, Opcode=0x1, Payload="Web "`], [`01 04 57 65 62 20`],
    [Frame 2], [`FIN=1, Opcode=0x0, Payload="Engineering"`], [`80 0B 45 6E …`]
  )

  - `MASK=0` wurde gesetzt, also Server $arrow$ Client
  - Erst mit dem zweiten Frame ist die Nachricht vollständig
  - Wichtig: Der Opcode (`0x1` Text) steht nur im ersten Frame
  - Alle Continuation-Frames tragen nur `0x0`
  - Ein anderer Opcode im Continuation-Frame wäre Protokollverstoß

  #speaker-note()[
    ```md
      0x01 = 0000 0001
             ||-| |--|
             ||   |- Opcode (4 Bit) = 0001 (Text)
             ||- RSV1-3 (3 Bit) = 000
             |- FIN (1 Bit) = 0
    ```
  ]
]

#let source = "01 04 57 65 62 20"

#slide(align: horizon)[
  *Frame 1*
  #codly.new(
    source,
    highlights: (
      (line: 1, start: 1, end: 2),
    ),
    header: [Hex]
  )
  
  #codly.new(
    ```
      0000 0001
      ||-| |--| Opcode = 0x1 -> Text
      || RSV = 000 -> Keine Erweiterung
      | FIN = 0 -> Nachricht noch nicht zu Ende
    ```,
    header: [Byte 1 in Binär]
  )
]

#slide(align: horizon)[
  *Frame 1*
  #codly.new(
    source,
    highlights: (
      (line: 1, start: 4, end: 5),
    ),
    header: [Hex]
  )
  
  #codly.new(
    ```
      0000 0100
      |--| |--| Payload-Länge = 4 -> Payload besteht aus 4 Bytes
      |MASK = 0 -> kein Masking-Key, kein XOR (Server ist Absender)
    ```,
    header: [Byte 2 in Binär]
  )
]

#slide(align: horizon)[
  *Frame 1*
  #codly.new(
    source,
    highlights: (
      (line: 1, start: 7, end: 17),
    ),
    header: [Hex]
  )

  - `0101 0111` $arrow$ `W`
  - `0110 0101` $arrow$ `e`
  - `0110 0010` $arrow$ `b`
  - `0010 0000` $arrow$ ` `
]

== Server & Client API

#slide(align: horizon)[
  #set text(size: 21pt)
  ```javascript
    const socket = new WebSocket(
      "wss://example.com/chat"
    );
    socket.onopen = () => socket.send("Hello");
    socket.onmessage = (event) => console.log(event.data);
    socket.onclose = (event) => console.log(event.code, event.reason);
    socket.onerror = (e) => console.error(e);
  ```
  ```javascript
    import { WebSocketServer } from "ws";
    const wss = new WebSocketServer({ port: 8080 });

    wss.on("connection", (ws) => {
      ws.on("message", (data) => wss.clients.forEach(c => c.send(data)));
    });
  ```
]

== Verbindungen zu vorherigen Themen

#slide(align: horizon)[
  *Event Loop:* `onmessage` Callbacks sind normale Tasks, Nachrichten die ankommen werden in die Queue gelegt und asynchron abgearbeitet (wie `setTimeout`/`Promise`) \

  *Promises/async-await:* Connection, Reconnection und send ackowledgements werden in den meisten Bibliotheken als Promises verpackt (auf Browser Ebene ereignisbasiert `onopen`/`onmessage`/`onclose`)
]

== Vergleich zu Alternativen

#slide(align: horizon)[
  #set text(size: 20pt)
  #table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr),
    table.header(
      [], [Polling], [Long Polling], [SSE], [WebSockets]
    ),
    [Richtung], [Client $arrow$ Server], [Client $arrow$ Server], [Server $arrow$ Client], [*Bidirektional*],
    [Latenz], [Hoch], [Mittel], [Niedrig], [*geringste*],
    [Overhead], [komplette HTTP Header], [komplette HTTP Header], [wenig], [max. 14 Byte],
    [Protokoll], [HTTP], [HTTP], [HTTP], [eigenes Protokoll],
  )

  *Fun-Fact:* Server-Sent Events (SSE) wurden wieder populär für AI Streaming (z.B. ChatGPT Token Streams)
]
