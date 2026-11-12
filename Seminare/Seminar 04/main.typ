#import "Template/hszg.typ": *

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

#show: codly-init.with()
#codly(languages: codly-languages)

#show: hszg-theme.with(
  course: "Web Engineering 1",
  course-number: "319300",
  lecturer: "M.Sc. Christopher-Manuel Hilgner",
  title: "Seminar 04",
  date: datetime(year: 2026, month: 11, day: 13),
  summary: [
    WebSockets implementieren für ein einfaches Multiplayer-Spiel.
  ]
)

#topicBlock(name: "WebSocket Game: Setup")[
  Der Starter ist ein lokales Spiel mit zwei Spielern, die auf einem Canvas angezeigt werden. 
  Daraus soll ein echtes Multiplayer-Spiel werden. 
  Der Node.js Server stellt dabei den zentralen Datenort dar. 
  Keiner der Clients soll seine Position selbst ausrechnen.

  *Setup, fünf Dateien:*
  - `index.html`: Startseite, lädt `styles.css` und `client.js`
  - `client.js`: der Client; *Schritt 1* (Starter ausführen, Game Loop verstehen) läuft sofort
  - `styles.css`: fertiges Styling (*nicht verändern*)
  - `server.js`: Stub mit TODOs; startet erst mit einer echten `WebSocketServer`-Instanz
  - `package.json`: `"type": "module"` und die Abhängigkeit `ws`

  1. Führt im Aufgabenordner `npm install` aus
  2. Startet den Server mit `npm start`, er läuft auf `ws://localhost:8080`
  3. Öffnet `index.html` in *zwei* Browser-Tabs, idealerweise nebeneinander

  *Das Nachrichtenprotokoll im Überblick:*
  #table(
    columns: (auto, auto, 1fr),
    [Nachricht], [Richtung], [Inhalt],
    [`welcome`], [Server → neuer Spieler], [eigene ID, Startposition und Farbe],
    [`state`], [Server → alle], [komplette Liste aller Spieler, bei jeder Änderung],
    [`move`], [Spieler → Server], [gewünschter Schritt: `dx`, `dy`],
    [`lobby-full`], [Server → dritter Spieler], [Lobby ist voll, Verbindung wird geschlossen],
    [`collision`], [Server → beide Spieler], [die zwei Spieler überlappen],
  )
]

#topicBlock(name: "Client: Verbindung und Bewegung")[
  #task(name: "Verbindung öffnen (TODO 1)")[
    Bekannt aus der Vorlesung: ein WebSocket verbindet genau einmal und bleibt offen.
    ```javascript
      const socket = new WebSocket("ws://localhost:8080");
    ```
    Aktualisiert `#status` bei `open`, `error` und `close`: zum Beispiel *nicht verbunden*, *verbunden* und *getrennt*.
  ]

  #task(name: "State empfangen (TODO 2)")[
    - Bei `welcome` merkt ihr euch eure `id`: nur so erkennt ihr später auf dem Canvas, welcher Spieler *ihr* seid.
    - Bei `state` ersetzt ihr `players` komplett durch die empfangene Liste. Der Game Loop zeichnet dann einfach weiter, nur dass die Positionen jetzt vom Server kommen.
    ```javascript
      socket.onmessage = (event) => {
          const msg = JSON.parse(event.data);
          // TODO: welcome → id speichern, state → players ersetzen
      };
    ```
  ]

  #task(name: "Bewegung senden (TODO 3)")[
    - Entfernt die lokale Steuerung von Player 2. Jeder Spieler sendet nur noch seine *eigenen* Bewegungen.
    - Sendet *genau eine* Nachricht pro Tastendruck (`keydown`), *nicht* pro Frame.
    ```javascript
      socket.send(JSON.stringify({ type: "move", dx, dy }));
    ```
  ]
]

#topicBlock(name: "Server: Spieler und State")[
  #task(name: "Server instanziieren")[
    Ersetzt das `null` durch eine echte Instanz. Erst dann startet der Server und das `connection`-Event feuert.
    ```javascript
      const wss = new WebSocketServer({ port: PORT });
    ```
  ]

  #task(name: "Spieler akzeptieren (TODO 2)")[
    - Es sind nur 2 Spieler erlaubt: ab dem dritten bekommt der neue Client `lobby-full`, dann schließt ihr die Verbindung.
    - Vergibt ID, Farbe und Startposition aus den vorhandenen Konstanten und speichert den Spieler in der Map.
    - `welcome` geht nur an den *neuen* Spieler. Danach einmal `state` an alle broadcasten.
  ]

  #task(name: "Bewegung verarbeiten (TODO 3)")[
    - Aktualisiert die Position des *Senders* und clamped sie an die Canvas-Grenzen — *inklusive Spielergröße*: 0..620 statt 0..640.
    - Broadcastet danach den Zustand ALLER Spieler an ALLE Clients. Achtung: Der `state` muss nach jeder Änderung auf dem neuesten Stand sein, sonst sehen die Clients Ghosts.
    - *Bonusfrage*: Warum sollte der Server `dx` und `dy` aus der Nachricht nicht ungeprüft übernehmen? Was könnte ein manipulierter Client sonst erreichen?
  ]

  #task(name: "Verbindungsende behandeln (TODO 5)")[
    Geht ein Spieler (Tab zu, Browser zu), entfernt ihn aus der Map und broadcastet den aktualisierten `state` — die Übrigen sollen den Abgang sofort sehen.
  ]
]

#topicBlock(name: "Server: Kollision (optional)", breakable: false)[
  #task(name: "TODO 4: Treffer")[
    Wenn die beiden Spieler (je 20 x 20 Pixel) überlappen, sendet `collision` an beide. Tipp: Überlappung heißt *in x und in y* gleichzeitig.
    ```javascript
      Math.abs(a.x - b.x) < SIZE && Math.abs(a.y - b.y) < SIZE
    ```
  ]
]

#topicBlock(name: "Debugging und Ressourcen")[
  *Fehlersuche:*
  - In den Browser-DevTools (F12) gibt es unter *Network* einen WS-Filter: dort seht ihr jeden Frame in beide Richtungen live mit.
  - Server-Änderungen brauchen einen Neustart (`Ctrl+C`, dann erneut `npm start`) — der Client reicht einen Browser-Reload.
  - Steht im `#status` dauerhaft *nicht verbunden*: läuft der Server wirklich? Wurde `npm install` ausgeführt?

  *Zum Nachschlagen:*
  - #link("https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API/Writing_WebSocket_client_applications")[MDN: WebSocket-Client]: Events, `send()`, `readyState`
  - #link("https://github.com/websockets/ws#usage-examples")[ws-README]: serverseitige Beispiele, fast 1:1 für TODO 2 und 3 nutzbar
  - #link("https://javascript.info/websocket")[javascript.info]: kompakte Einführung
  - #link("https://developer.mozilla.org/en-US/docs/Web/API/UI_Events/Keyboard_event_key_values")[MDN: Tastenwerte]: warum Pfeiltasten `"arrowup"` heißen
]
