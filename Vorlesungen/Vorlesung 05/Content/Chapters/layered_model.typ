#import "../../Template/hszg.typ": *

= Layered Model

== Warum?

#slide(align: horizon)[
 - Jedes spätere Paradigma baut auf dem Layered Model auf
 - Entweder Variation, Anpassung oder Ablehnung des Modells
 
 #textbox()[
  *Kernidee:* Layers werden genutzt, um Verantwortlichkeiten zu teilen, damit jeder Teil des Systems, gemessen an seinen Aufgaben, geändert werden und wachsen kann. 
 ]
]

== Aufgaben

#slide(align: horizon)[
  Drei Aufgaben, die jede Application erfüllen muss:
  #set enum(numbering: "1.")
  1. *Darstellung:* Output rendern und User Interkation verwalten (HTML, CSS, JS, ...)
  2. *Business Logic:* Die tatsächlichen Regeln der Domain (Ein Kunde kann eine Bestellung innerhalb von 30 Tagen)
  3. *Datenzugriff:* State erhalten und behalten (SQL, ORM, Cache, externe APIs)
]

== Klassisches 3-Tier-Model

#slide(align: horizon)[
  #fletcher.diagram(
    node-stroke: hszg-green + 2pt,
    node-inset: 15pt,
    node-fill: background,
    node((0, 0), [*Tier 1:* Presentation]),
    edge(),
    node((0, 1), [*Tier 2:* Application (Business Logic)]),
    edge(),
    node((0, 2), [*Tier 3:* Daten]),

    node((1, 0), [Browser bzw. Client]),
    node((1, 1), [Web bzw. App Server mit Logik]),
    node((1, 2), [Datenbank]),

    edge((0, 0), "--", (1, 0)),
    edge((0, 1), "--", (1, 1)),
    edge((0, 2), "--", (1, 2)),
  )
]

== Tier vs. Layer

#slide(align: horizon)[
  *Layers*
  - Logische Gruppen aus Code (Präsetation, Logik, Daten)
  - Sie können alle in einem Prozess laufen

  *Tiers*
  - Physische deployment Einheiten
  - Jeder Tier läuft auf seiner eigenen Maschine oder seinem eigenen Prozess

  - Eine 3-Schichten App kann auf einem Tier oder drei deployed werden
  - Geschichte des Aufbaus (1970er - 90er)
    - 1-tier (mainframe, alles in einer Box)
    - 2-tier (Client/Server, Clients interagieren direkt mit der Datenbank)
    - 3-tier (der heute Web-Standard)
]

#slide(align: horizon)[
  *Die goldene(n) Regel(n): *
  - Die Präsentationsschicht darf die Business-Schicht aufrufen
  - Die Business-Schicht darf die Daten-Schicht aufrufen
  - Niemals in die andere Richtung
  - Tiefere Schichten müssen nicht wissen, wer sie aufruft
  - Business-Schicht sollte niemals SQL Strings enthalten
  - Daten-Schicht sollte niemals HTML enthalten
]

// == Varianten

// #slide(align: horizon)[
//   - *Zwei Sichten ("smart UI"):* UI - Logik vermischt (klassisches PHP)
//   - *Vier/Fünf-Schichten:* Service-Schicht zwischen Präsentation und Domain und Infrastruktur-Schicht für technische Anforderungen
//   - Domain-Zentrierte Varianten: 
// ]

== Beispiel

#slide(align: horizon)[
  #set text(size: 20pt)

  ```java
    @PostMapping("/checkout")
    String checkout(@ModelAttribute CartForm form, Model model) {}
  ```

  ```java
    public class CheckoutService {
      public Order placeOrder(Cart cart) {
        if (cart.isEmpty()) throw new EmptyCartException();
        if (!cart.customerHasSufficientCredit()) throw new PaymentException();
        return new Order(cart.items(), applyVat(cart.subtotal()));
      }
    }
  ```

  ```java
    public interface OrderRepository {
      void save(Order order);
      Optional<Order> findById(long id);
    }
  ```
]
