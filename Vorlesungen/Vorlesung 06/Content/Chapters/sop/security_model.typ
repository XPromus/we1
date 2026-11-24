#import "../../../Template/hszg.typ": *

== SOP als Security Modell

#slide(align: horizon)[
    *Kernaussage:* Das primäre Ziel von SOP ist es nicht Requests zu verhindern. 
    Es ist das Lesen der Antworten zu verhindern.

    *Was sagt SOP aus?*
    Ein Skript, welches im Context eines Origins A läuft darf nicht Daten lesen, die zum Origin B gehören. 

    Es werden drei Bereiche abgesichert:
    1. *Cross-window/iframe DOM Zugriff:* `iframe.contentDocument` ist `null` außer der Frame ist same-origin. Kein lesen, schreiben oder Event abfangen in dem Dokument
    2. *Network Responses:* `fetch()` oder XHR kann zu jeder URL geschickt werden. Aber die Response wird JS vorenthalten, solange der Server nicht per CORS zustimmt.
    3. *Storage und Cookies:* `localStorage`/`sessionStorage`/IndexedDB werden durch Origin verschlossen. Eine Seite von `evil.com` kann den Storage von `bank.com` nicht öffnen.
]
