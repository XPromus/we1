#import "../../Template/hszg.typ": *

= Zusammenfassung

== Zusammenfassung

#slide(align: horizon)[
  #set text(size: 20pt)
  *Polling:*
  - Der Client fragt in festen Intervallen an, ob neue Daten vorliegen
  - Meist kommt eine leere Antwort (Bringt Latenz und Verschwendung von Ressourcen)
  - Jede Request hat volle HTTP-Header
  *Long Polling:*
  - Client fragt an, der Server hält die Antwort offen bis ein Ergebnis vorliegt
  - Leerfahrten entfallen
  - Jede Nachricht kostet trotzdem einen kompletten HTTP-Zyklus
  *Server-Sent Events (SSE):*
  - Dauerhaft offene HTTP Verbindung
  - Server streamt Daten zum Client
  - Nur Server $arrow$ Client, Client muss weiterhin Requests stellen
  *WebSocket:*
  - Nach einmaligem HTTP-Upgrade besteht dauerhafte vollduplex Verbindung
  - Client und Server senden jederzeit Nachrichten ohne neuen Verbindungsaufbau
]
