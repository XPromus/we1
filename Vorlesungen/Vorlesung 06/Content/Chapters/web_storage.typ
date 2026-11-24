#import "../../Template/hszg.typ": *

= Web Storage

== Übersicht

#slide(align: horizon)[
  #set text(size: 20pt)

  *Was ist es?* Ein Key-Value Store innerhalb des Browsers, der auf den Origin gescoped ist \
  *Warum existiert es?* HTTP ist stateless und Cookies sind zu klein und werden bei jeder Request mitgegeben. Web Storage ist ein fester Ort für den Client Sachen zu speichern

  #table(
    columns: (auto, 1fr, 1fr),
    table.header(
      [], [localStorage], [sessionStorage],
    ),
    [Lifetime], [Ewig (bis es gelöscht wird)], [Bis Tab geschlossen wird],
    [Scope], [Alle Tabs mit dem gleichen Origin], [Nur ein Tab],
    [Usecase], [Preferences, Tokens], [Temp State],
  )

  #textbox()[
    *Regel:* 
    - Cookies für Server-side login Sessions
    - Web Storage für Client-side Memory
    - Niemals etwas speichern, dass nicht mit XSS erreichbar sein soll
  ]

  // #speaker-note()[
  //   #set text(size: 19pt)

  //   *Was ist Web Storage?*
  //   - Ein Key-Value Store, der im Browser selbst lebt — nicht auf dem Server
  //   - "Key-Value" bedeutet: Jeder Eintrag besteht aus einem Schlüssel (String) und einem Wert (String), z.B. `"theme" → "dark"`
  //   - Gescoped auf den Origin: `https://app.example.com` und `https://evil.com` haben komplett getrennte Storages
  //   - Wichtig: Web Storage ist *kein* Ersatz für eine Datenbank. Es lebt nur im Browser des Users

  //   *Warum existiert Web Storage überhaupt?*
  //   - HTTP ist per Design stateless: Jede Request ist unabhängig, der Server merkt sich nichts
  //   - Cookies lösen das für den Server (Session-Token), aber:
  //     - Cookies sind winzig (~4 KB pro Cookie, insgesamt limitiert)
  //     - Cookies werden bei *jeder* HTTP-Request automatisch mitgeschickt — auch an statische Assets wie Bilder oder CSS. Das ist Bandbreitenverschwendung
  //   - Web Storage löst das für den Client: Daten bleiben lokal im Browser, werden nie automatisch an den Server geschickt
  //   - Zugriff erfolgt nur per JavaScript — der Server merkt nichts davon (außer das JS schickt es explizit)

  //   *Der Unterschied in der Tabelle:*
  //   - `localStorage`: Überlebt alles — Browser-Neustart, Tab-Schließen, sogar das Ausschalten des Rechners. Wird nur gelöscht durch explizites `localStorage.clear()`, `removeItem()`, oder wenn der User die Browserdaten löscht
  //   - `sessionStorage`: Stirbt mit dem Tab. Jeder Tab hat seine eigene, unabhängige Kopie — auch wenn derselbe Origin in zwei Tabs offen ist, sehen sie sich nicht gegenseitig (außer über das `storage`-Event, dazu später)

  //   *Use Cases:*
  //   - `localStorage` für Preferences (Theme, Sprache), JWT/Bearer-Tokens, Caching von API-Responses
  //   - `sessionStorage` für temporären State, z.B. Formular-Zwischenstände beim Seitenwechsel innerhalb eines Wizards, oder "Ist der User gerade eingeloggt in diesem Tab"-Flags

  //   *Die Regel in der Textbox ist kritisch für die Sicherheit:*
  //   - Cookies mit `HttpOnly` sind vor XSS geschützt (JS kann sie nicht lesen)
  //   - Web Storage ist *immer* per JS lesbar — `localStorage.getItem("token")` funktioniert sofort
  //   - Wenn ein Angreifer per XSS Code in eure Seite einschleusen kann, kann er alles aus dem Web Storage klauen
  //   - Deshalb: Niemals Secrets (Passwörter, Session-Tokens ohne HttpOnly-Alternative) im Web Storage speichern, die ein XSS-Angriff nicht erreichen soll
  // ]
]

== `localStorage` & `sessionStorage`

#slide(align: horizon)[
  `localStorage`
  - *Persistent:* Überlebt Browser neustarten; wird erst entfernt, wenn JS oder User es löschen
  - *5-10MB pro Origin:* Größe variiert pro Browser (kann mit `navigator.storage.estimate()` ausgelesen werden)
  - *Nur Strings:* Objekte müssen mit `JSON.stringify`/`parse` überführt werden
  - *Synchrone, blockierende API:* lesen/schreiben auf dem main Thread
  - *Durch Origin definiert:* Kein Cross-Origin Zugriff, (kein Opt-in wie CORS verfügbar)

  `sessionStorage`
  - Gleiche API wie `localStorage`, gleiche String Limitierungen
  - Auf Tab gescoped: Jeder Tab hat seine eigenen Kopie, die beim Schließen entfernt wird

  // #speaker-note()[
  //   #set text(size: 19pt)

  //   *localStorage — die Details:*
  //   - *Persistent:* Daten bleiben über Browser-Neustarts, OS-Neustarts und Tab-Schließungen hinweg erhalten. Erst wenn JavaScript `localStorage.clear()` aufruft oder der User die Website-Daten in den Browser-Einstellungen löscht, wird es entfernt
  //   - *5–10 MB pro Origin:* Die genaue Grenze variiert je nach Browser (Chrome ~10 MB, Firefox ~10 MB, Safari ~5 MB). Mit `navigator.storage.estimate()` kann man `quota` und `usage` abfragen:
  //     ```javascript
  //     const { quota, usage } = await navigator.storage.estimate();
  //     console.log(`Verwendet: ${usage} von ${quota} Bytes`);
  //     ```
  //   - *Nur Strings:* Web Storage kann keine Objekte, Arrays, Dates oder Numbers speichern — nur Strings. Deshalb `JSON.stringify()` beim Schreiben und `JSON.parse()` beim Lesen. Vergesst man das, bekommt man `[object Object]`
  //   - *Synchrone, blockierende API:* `setItem` und `getItem` blockieren den Main Thread. Bei großen Datenmengen (nahe dem 5–10 MB Limit) kann die Seite einfrieren. Es gibt keine `await`-Version — für größere Daten ist IndexedDB die bessere Wahl (asynchron, eigene API)
  //   - *Origin-Scope:* `app.example.com` und `evil.com` teilen sich nichts. Es gibt kein "Opt-in" wie bei CORS — ein fremder Origin kann den Storage nicht lesen, egal welchen Header er mitsendet

  //   *sessionStorage — die Details:*
  //   - Gleiche API, gleiche Methoden (`setItem`, `getItem`, `removeItem`, `clear`, `key`, `length`), gleiche String-Limitierung
  //   - Aber: Jeder Tab bekommt seine eigene Kopie. Öffnet man `https://app.example.com` in zwei Tabs, hat jeder Tab ein unabhängiges `sessionStorage`
  //   - Wird der Tab geschlossen (nicht minimiert!), wird das `sessionStorage` gelöscht — auch bei Browser-Absturz ist es weg
  //   - Ein Reload des Tabs *innerhalb desselben Tabs* behält das `sessionStorage` bei — es lebt so lange wie der Tab-Prozess
  //   - *Praxisbeispiel:* Ein mehrstufiges Formular (Wizard). Zwischenschritte in `sessionStorage` speichern, damit ein versehentlicher Reload nicht alles löscht. Aber nach Tab-Schließen ist alles weg — gewollt, damit keine sensiblen Daten liegen bleiben

  //   *Vergleich Cookies vs. Web Storage:*
  //   #table(
  //     columns: (auto, 1fr, 1fr),
  //     table.header([Aspekt], [Cookies], [Web Storage]),
  //     [Kapazität], [~4 KB gesamt], [5–10 MB pro Origin],
  //     [Werden an Server geschickt?], [Ja, bei jeder Request], [Nein, nur per JS-Zugriff],
  //     [Lebensdauer], [Vom Server gesetzt (Max-Age/Expires)], [localStorage: ewig; sessionStorage: bis Tab zu],
  //     [Zugriff durch JS], [Nur wenn nicht `HttpOnly`], [Immer möglich],
  //     [Use Case], [Session-Tokens, Server-State], [Client-seitiges Caching, Preferences, Tokens],
  //   )
  // ]
]

== API Basics

#slide(align: horizon)[
  ```javascript
    localStorage.setItem("user", JSON.stringify({name: "Anna"}));
    const u = JSON.parse(localStorage.getItem("user"));
    localStorage.removeItem("user");
    localStorage.clear();            // whole origin's storage
    localStorage.key(0); localStorage.length;   // enumeration
  ```
  - `storage`-Event: Wird in anderen Tabs/Fenstern des gleichen Origin ausgelöst (Führt zu Effekten wie: Logout in anderen Tab)

  // #speaker-note()[
  //   #set text(size: 10pt)

  //   *Die API Schritt für Schritt:*
  //   - `localStorage.setItem("user", JSON.stringify({name: "Anna"}))` — Key und Value sind beide Strings. Das Objekt wird zuerst zu einem JSON-String serialisiert. Ohne `JSON.stringify` speichert man nur `"[object Object]"`
  //   - `JSON.parse(localStorage.getItem("user"))` — Beim Lesen wieder deserialisieren. `getItem` gibt `null` zurück, wenn der Key nicht existiert — `JSON.parse(null)` wirft einen Fehler! Deshalb immer prüfen:
  //     ```javascript
  //     const raw = localStorage.getItem("user");
  //     const u = raw ? JSON.parse(raw) : null;
  //     ```
  //   - `localStorage.removeItem("user")` — Löscht einen einzelnen Key. Gibt es den Key nicht, passiert nichts (kein Fehler)
  //   - `localStorage.clear()` — Löscht *alles* für diesen Origin. Vorsicht: Auch Daten, die andere Teile der App dort abgelegt haben. In einer Multi-App-Origin (z.B. mehrere Apps auf dem gleichen Host) kann das problematisch sein
  //   - `localStorage.key(0)` und `localStorage.length` — Ermöglichen die Enumeration aller Keys. `key(i)` gibt den i-ten Key (als String) zurück, `length` die Anzahl. Damit kann man über alle Einträge iterieren:
  //     ```javascript
  //     for (let i = 0; i < localStorage.length; i++) {
  //       const key = localStorage.key(i);
  //       console.log(key, localStorage.getItem(key));
  //     }
  //     ```

  //   *Das `storage`-Event — der interesting part:*
  //   - Wird auf `window` ausgelöst, wenn sich der Storage in einem *anderen* Tab/Fenster desselben Origins ändert
  //   - Der Tab, der die Änderung vorgenommen hat, bekommt das Event *nicht* — nur die anderen Tabs
  //   - Event-Objekt enthält: `key` (welcher Key), `oldValue`, `newValue`, `url` (welche Seite die Änderung gemacht hat), `storageArea` (localStorage oder sessionStorage)
  //   - *Praxisbeispiel Logout-Synchronisation:* User klickt in Tab A auf "Logout". Tab A löscht den Token aus `localStorage` und leitet zur Login-Seite weiter. Tab B (noch offen mit der App) bekommt das `storage`-Event, sieht `key === "token"` und `newValue === null`, und kann ebenfalls auf die Login-Seite weiterleiten — sonst würde Tab B mit einem ungültigen Token weiterlaufen
  //     ```javascript
  //     window.addEventListener("storage", (e) => {
  //       if (e.key === "token" && e.newValue === null) {
  //         window.location.href = "/login";
  //       }
  //     });
  //     ```
  //   - *Wichtig:* Das `storage`-Event funktioniert nur für `localStorage` über Tab-Grenzen hinweg. `sessionStorage` ist pro Tab isoliert — da feuert kein Event in anderen Tabs

  //   *Sicherheitshinweis:*
  //   - Alles im Web Storage ist Klartext. In den DevTools (Application → Storage) kann jeder User alles sehen und bearbeiten
  //   - Manipulation durch den User ist immer möglich — Web Storage Daten müssen wie jede Client-seitige Eingabe als unsicher behandelt werden. Niemals sicherheitskritische Entscheidungen allein auf Basis von Web-Storage-Daten treffen
  // ]
]
