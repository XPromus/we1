#import "Template/hszg.typ": *

#show: hszg-theme.with(
  course: "Web Engineering 1",
  course-number: "319300",
  lecturer: "M.Sc. Christopher-Manuel Hilgner",
  title: "Seminar 01",
  date: datetime(year: 2026, month: 10, day: 09),
  summary: [
    URL-Bestandteile, analysiere HTTP-Requests mit curl, theoretische HTTP-Konzepte in einem echten Browser-Werkzeug wiedererkennen und interpretieren.
  ]
)

#task(name: "URL-Zerlegung")[
  Benenne die einzelnen Bestandteile der folgenden URLs:

  ```
    https://www.studentenwerk-dresden.de/mensen/speiseplan/mio-mensa-im-osten.html
  ```

  ```
    https://de.wikipedia.org/wiki/Chomsky-Hierarchie#Nat%C3%BCrliche_Sprachen
  ```
]

#task(name: [Requests mit `curl`])[
  Senden einer HTTP-Request mit `curl` und Analyse der zurückgegebenen Response (wie aus Vorlesung 01)

  == Vorbereitung
  Teste ob `curl` installiert ist mit
  ```
    curl --version
  ```

  Als Test-API wird hier #link("https://jsonplaceholder.typicode.com") genutzt.

  == GET-Request senden und Response lesen

  Sende folgende Request mit der `-v` Flag:

  ```
    curl -v https://jsonplaceholder.typicode.com/posts/1
  ```

  *Analysiere die Ausgabe und beantworte:*
  1. Welche HTTP-Version wird verwendet?
  2. Welcher Status-Code kam zurück? Zu welcher Klasse gehört er?
  3. Welchen Wert hat der `Content-Type` Header?
  4. Wie viele Bytes groß ist der Response-Body?
  5. Welche Felder enthält der Response-Body?

  == Fehler provozieren

  Sende folgende Request:

  ```
    curl -v https://jsonplaceholder.typicode.com/posts/99999
  ```

  *Analysiere die Ausgabe und beantworte:*
  1. Welcher Status Code kommt zurück?
  2. Ist das Ergebnis trotzdem ein gültiges JSON? Was steht im Body?
  3. Warum ist das kein 500er-Fehler, obwohl die gewünschte Ressource nicht existiert?
]

#task(name: "DevTools im Browser")[
  - Navigiere zu #link("https://www.hszg.de/") und öffne die Browser DevTools mit `F12`
  - Navigiere zum `Network`-Tab und lade die Seite neu
  - Filtere nach Typ `Doc` bzw. `HTML` und öffne die erste Request (das HTML-Dokument der Seite)

  == Analysiere im `Headers`-Tab der Request folgende Aspekte und notiere
    - Status-Code (inkl. Bedeutung der Klasse, z.B. 2xx, 3xx)
    - HTTP Version
    - `content-type` Header der Response (MIME-Type der zurückgegebenen Daten)
    - `accept` Header der Request (welchen MIME-Type erwartet der Browser als Antwort?)
    - Inhalt der Response im `Preview`- oder `Response`-Tab (nur kurze Umschreibung, kein vollständiges Kopieren des HTML)

  == Erster Einblick in Timings
    - Lade die Seite neu (`F5`) und öffne den `Timing`-Tab der ersten Dokument-Request. Notiere die Dauer der einzelnen Phasen (z.B. Queueing, DNS Lookup, Initial Connection, SSL, Request sent, Waiting (TTFB), Content Download)
    - Ordne die sichtbaren Phasen den Schritten aus der Vorlesung zu
      (DNS-Auflösung, TCP-Handshake, TLS-Handshake, HTTP-Request, Verarbeitung,
      Response)
    - Aktualisiere die Seite anschließend mit `Ctrl + F5` (Laden ohne Cache) und vergleiche die Timings mit dem vorherigen Durchlauf. Welche Phasen fallen weg oder werden kürzer, und warum?
]
