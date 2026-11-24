#import "../../../Template/hszg.typ": *

== Konsequenzen des Splits

#slide(align: horizon)[
    - *CSRF existiert weil Schicken erlaubt ist:* Ein Angreifer kann Requests auslösen, die State verändern mit den User-Cookies. SOP hilft da nicht. Es werden CSRF Tokens und `SameSite` Cookies verwendet
    - *XSS kann SOP einfach umgehen:* Wenn böser Code in deinem Origin läuft, bringt SOP keinen Schutz (aus der Sicht des Codes bist du es)
    - *Informationen können auch ohne read leaken:* Error Nachrichten, (Miss)Erfolg des Ladens. Dafür gibt es CORP/CORB
]

== Warum der Browser?

#slide(align: horizon)[
    - SOP wird durch den User Agent durchgesetzt, nicht den Server
    - Server kann nicht zuverlässig sagen, wer eine Request ausgelöst hat (`Origin`/`Referer` können fehlen oder geändert werden)
    - Browser ist die einzige Komponente, die zuverlässig weiß, in welchem Origin ein Skript läuft
    - Server ist nur für opt-in zuständig: CORS Header $arrow$ "Ich erlaube Origin X, das zu lesen."
]

== Grundsatz

#slide(align: horizon)[
    SOP geht davon aus, dass jeder Origin feindlich zu jedem anderen Origin ist, blockiert das Lesen von cross-origin Daten und zwingt jeden, der Lesen möchte, es explizit zu erlauben.
]
