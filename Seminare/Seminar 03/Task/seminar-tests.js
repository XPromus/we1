/* ============================================================
   Seminar 03 - Tests. Diese Datei NICHT verändern!
   Öffnet index.html - unten erscheint eine Liste mit
   grünen (bestanden) und roten (noch offen) Tests.
   Jeder Test läuft isoliert: Wirft eine Funktion noch einen
   Fehler (z. B. weil sie leer ist), wird nur ihr eigener
   Test rot - alle anderen zeigen weiterhin ihr Ergebnis.
   Die Karten-Sortierung (Aufgabe 6.2) und die Vorhersagen
   (Aufgabe 2 und Aufgabe 3.2) macht ihr direkt auf dieser
   Seite - beides wird live geprüft und erscheint nicht in
   der Liste unten: Grün/Rot steht direkt am Element bzw.
   unter den Karten.
   Eingaben und Karten-Sortierung werden in localStorage
   gespeichert und überstehen so ein Reload der Seite.
   ============================================================ */

/* ---------- Mini-Testframework ---------- */
const results = [];
let currentTask = "";

// Setzt die Aufgabe, zu der die folgenden Tests gehören -
// die Namen entsprechen den Aufgaben im Seminarblatt.
function task(name) {
  currentTask = name;
}

function record(passed, name, detail) {
  results.push({ task: currentTask, passed, name, detail: passed ? "" : detail });
}

function assertEqual(actual, expected, name) {
  const a = JSON.stringify(actual);
  const e = JSON.stringify(expected);
  const hint = a === undefined && e !== undefined ? " - Funktion noch nicht implementiert?" : "";
  // Bewusst OHNE erwarteten Wert: Die Vorhersagen sollt IHR treffen.
  record(a === e, name, `Noch nicht richtig - erhalten: ${a}${hint}`);
}

function assertTrue(value, name, detail = "Noch nicht erfüllt") {
  record(value === true, name, value === true ? "" : `${detail} - erhalten: ${String(value)}`);
}

function assertThrows(fn, name, expectedType = "RangeError") {
  try {
    fn();
    record(false, name, "Es wurde keine Exception ausgelöst.");
  } catch (err) {
    record(err.constructor.name === expectedType, name,
      `Noch nicht die richtige Fehlerart - erhalten: ${err.constructor.name}`);
  }
}

/* Führt einen Test isoliert aus: Exceptions durch noch leere
   oder fehlende Funktionen werden als rotes Ergebnis zu
   genau diesem Test vermerkt, statt alle folgenden Tests
   abbrechen zu lassen. */
function test(name, fn) {
  try {
    fn();
  } catch (err) {
    record(false, name, errorDetail(err));
  }
}

function testEq(name, actualFn, expected) {
  test(name, () => assertEqual(actualFn(), expected, name));
}

function errorDetail(err) {
  const missing = /is not a function|is not defined|Cannot read|Cannot convert/.test(err.message)
    ? " - Funktion noch nicht implementiert?"
    : "";
  return `${err.constructor.name}: ${err.message}${missing}`;
}

function render() {
  const output = document.getElementById("test-output");
  let passedCount = 0;
  let totalCount = 0;

  const rowHtml = (r) => {
    totalCount++;
    if (r.passed) passedCount++;
    return `<div class="test ${r.passed ? "pass" : "fail"}">
      <span class="mark">${r.passed ? "✔" : "✘"}</span>
      <strong>${r.name}</strong>
      ${r.detail ? `<div class="detail">${r.detail}</div>` : ""}
    </div>`;
  };

  // Ausgabe in der Reihenfolge des Seminarblatts:
  // Abschnitts-Überschrift → Aufgabe → ihre Tests
  let html = "";
  let lastSection = "";
  const shown = new Set();
  for (const t of TASKS) {
    if (t.section !== lastSection) {
      html += `<h3>${t.section}</h3>`;
      lastSection = t.section;
    }
    html += `<div class="task">Aufgabe ${t.pdf}: ${t.name}</div>`;
    const rows = results.filter((r) => r.task === t.name);
    for (const r of rows) {
      shown.add(r);
      html += rowHtml(r);
    }
    if (rows.length === 0 && t.note) {
      html += `<div class="task-note">${t.note}</div>`;
    }
  }
  // Falls Tests ohne bekannte Aufgabe existieren: nicht verstecken
  const rest = results.filter((r) => !shown.has(r));
  if (rest.length > 0) html += `<h3>Weitere Tests</h3>` + rest.map(rowHtml).join("");

  const allPass = passedCount === totalCount && totalCount > 0;
  output.innerHTML =
    `<h2>Ergebnis: ${passedCount} / ${totalCount} Tests bestanden ${allPass ? "🎉" : ""}</h2>` + html;
}

/* ---------- Konstanten ---------- */
const SERVER_GRADES = [82, 95, 58, 77, 90];

// Vorhersagen: Aufgabe 2 (Coercion) und Aufgabe 3.2 (Hoisting) werden im UI
// der Testseite beantwortet. type "bool" = Auswahl true/false,
// type "choice" = Auswahl aus choices, type "text" = freie Eingabe.
// answer() liefert die Realität - sie wird nie angezeigt, nur zum
// Prüfen benutzt. name ist der Testzeilen-Name, label der UI-Text.
const PREDICTION_ITEMS = [
  // Aufgabe 2: Typen und Coercion
  { container: "coercion-inputs", key: "stringPlus",            name: '"5" + 3',     label: '"5" + 3',                type: "text", answer: () => String("5" + 3) },
  { container: "coercion-inputs", key: "stringMinus",           name: '"5" - 3',     label: '"5" - 3',                type: "text", answer: () => String("5" - 3) },
  { container: "coercion-inputs", key: "strictEquals",          name: '5 === "5"',   label: '5 === "5"',              type: "bool", answer: () => String(5 === "5") },
  { container: "coercion-inputs", key: "looseEquals",           name: '5 == "5"',    label: '5 == "5"',               type: "bool", answer: () => String(5 == "5") },
  { container: "coercion-inputs", key: "zeroEqualsFalse",       name: "0 == false",  label: "0 == false",             type: "bool", answer: () => String(0 == false) },
  { container: "coercion-inputs", key: "emptyStringEqualsZero", name: '"" == 0',     label: '"" == 0',                type: "bool", answer: () => String("" == 0) },
  { container: "coercion-inputs", key: "arrayEqualsFalse",      name: "[] == false", label: "[] == false",            type: "bool", answer: () => String([] == false) },
  { container: "coercion-inputs", key: "nullEqualsZero",        name: "null == 0",   label: "null == 0",              type: "bool", answer: () => String(null == 0) },
  { container: "coercion-inputs", key: "nullGteZero",           name: "null >= 0",   label: "null >= 0",              type: "bool", answer: () => String(null >= 0) },
  { container: "coercion-inputs", key: "typeofNull",            name: "typeof null", label: "typeof null",            type: "text", answer: () => String(typeof null) },
  // Aufgabe 3.2: Hoisting-Vorhersage
  { container: "hoisting-inputs", key: "varLine",
    name: "Vorhersage: console.log(a) mit var a = 1", label: "console.log(a); var a = 1;",
    type: "choice", choices: ["undefined", "ReferenceError"], answer: () => "undefined" },
  { container: "hoisting-inputs", key: "letLine",
    name: "Vorhersage: console.log(b) mit let b = 2", label: "console.log(b); let b = 2;",
    type: "choice", choices: ["undefined", "ReferenceError"], answer: () => "ReferenceError" },
];

// Die Aufgaben wie im Seminarblatt - die Testliste folgt genau
// dieser Reihenfolge (Abschnitts-Überschrift → Aufgabe → ihre Tests).
// block und pdf entsprechen den Nummern im PDF (dort steht vor
// den inhaltlichen Abschnitten noch "1. Ablauf und Setup").
const TASKS = [
  { section: "2. Typen und Coercion", pdf: "2", name: "Vorhersagen eintragen",
    note: "Wird direkt oben an den Eingabefeldern geprüft - grün = richtig, rot = falsch." },
  { section: "3. Variablen und Hoisting", pdf: "3.1", name: "MAX_POINTS" },
  { section: "3. Variablen und Hoisting", pdf: "3.2", name: "Hoisting-Vorhersage",
    note: "Wird direkt oben an den Auswahlfeldern geprüft - grün = richtig, rot = falsch." },
  { section: "3. Variablen und Hoisting", pdf: "3.3", name: "Call Stack bis zum Anschlag" },
  { section: "4. Funktionen als First-Class Citizens", pdf: "4.1", name: "Prozente und Bestehen" },
  { section: "4. Funktionen als First-Class Citizens", pdf: "4.2", name: "Ohne Schleifen" },
  { section: "4. Funktionen als First-Class Citizens", pdf: "4.3", name: "Funktionen als Werte" },
  { section: "5. Objekte und Prototypen", pdf: "5.1", name: "Zwei Wege, ein Ziel" },
  { section: "5. Objekte und Prototypen", pdf: "5.2", name: "Prototypenkette nachweisen" },
  { section: "5. Objekte und Prototypen", pdf: "5.3", name: "Methoden im Nachhinein" },
  { section: "6. Event Loop und Asynchronität", pdf: "6.1", name: "Callbacks vs. Promises" },
  { section: "6. Event Loop und Asynchronität", pdf: "6.2", name: "Ausgabereihenfolge vorhersagen",
    note: "Wird direkt unter den Karten geprüft - grün = richtige Reihenfolge, rot = noch offen." },
  { section: "6. Event Loop und Asynchronität", pdf: "6.3", name: "Fehler bewusst erleben",
    note: "Kein automatischer Test - eure unbehandelte Rejection erscheint als Warnung in der Browser-Konsole (F12)." },
  { section: "6. Event Loop und Asynchronität", pdf: "6.4", name: "async/await" },
];

const ORDER_STATEMENTS = [
  { id: "S",     label: 'order.push("S")' },
  { id: "P",     label: '.then(() => order.push("P"))' },
  { id: "T",     label: 'setTimeout(() => order.push("T"), 0)' },
  { id: "Micro", label: '.then(() => order.push("Micro"))' },
  { id: "K",     label: 'order.push("K")' },
];
const EXPECTED_ORDER = ["S", "K", "P", "Micro", "T"];

// Die Slot-Elemente des Karten-Widgets - module-global, damit
// restoreState() Karten wieder einsortieren kann.
const orderSlotEls = [];

function firstFreeSlot() {
  return orderSlotEls.find((slot) => !slot.querySelector(".card"));
}

/* ---------- Speichern (localStorage) ----------
   Vorhersagen und Karten-Sortierung überstehen so ein Reload.
   Ist localStorage nicht verfügbar (z. B. privater Modus),
   läuft die Seite einfach ohne Speicherung weiter. */

const STORAGE_KEY = "seminar03-gradecalc";

function saveState() {
  try {
    const state = {
      predictions: {},
      order: Array.from(document.querySelectorAll("#order-slots .card"))
        .map((card) => card.dataset.id),
    };
    for (const item of PREDICTION_ITEMS) {
      state.predictions[item.key] = getPrediction(item.key);
    }
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch (err) {
    /* localStorage nicht verfügbar - ohne Speicherung weiter */
  }
}

function loadState() {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY));
  } catch (err) {
    return null;
  }
}

// Stellt den gespeicherten Stand in die Widgets zurück - direkt
// nach deren Aufbau, vor dem ersten Testlauf.
function restoreState() {
  const state = loadState();
  if (!state) return;

  if (state.predictions) {
    for (const item of PREDICTION_ITEMS) {
      const value = state.predictions[item.key];
      const input = predictionInputs.get(item.key);
      if (input && typeof value === "string") input.value = value;
    }
  }

  if (Array.isArray(state.order)) {
    for (const id of state.order) {
      const card = document.querySelector(`.card[data-id="${id}"]`);
      const free = firstFreeSlot();
      if (card && free) free.appendChild(card);
    }
  }
}

/* ---------- Vorhersage-Eingaben (Aufgabe 2 und 3.2) ----------
   Die Vorhersagen werden im UI der Testseite eingetragen und live
   geprüft - die erwarteten Werte werden nie verraten. */

const predictionInputs = new Map();

// Liest die Vorhersage zu einem Ausdruck ab - null, solange nichts eingetragen ist.
function getPrediction(key) {
  const input = predictionInputs.get(key);
  if (!input) return null;
  const value = String(input.value).trim();
  return value === "" ? null : value;
}

// Färbt die Eingabefelder live: grün = richtig, rot = falsch,
// ohne Farbe = noch offen. Die erwarteten Werte werden nie
// verraten. Die Vorhersagen erscheinen nicht in der Testliste -
// ihr Ergebnis steht direkt an den Feldern oben.
function refreshPredictions() {
  for (const item of PREDICTION_ITEMS) {
    const guess = getPrediction(item.key);
    const correct = guess !== null && guess === item.answer();
    const input = predictionInputs.get(item.key);
    if (input) {
      input.classList.remove("ok", "err");
      if (guess !== null) input.classList.add(correct ? "ok" : "err");
    }
  }
  saveState();
}

function initPredictionWidgets() {
  for (const item of PREDICTION_ITEMS) {
    const wrap = document.getElementById(item.container);
    if (!wrap) continue;

    const row = document.createElement("div");
    row.className = "predict-row";

    const label = document.createElement("code");
    label.className = "predict-expr";
    label.textContent = item.label;
    row.appendChild(label);

    let input;
    if (item.type === "text") {
      input = document.createElement("input");
      input.type = "text";
      input.placeholder = "euer Tipp";
    } else {
      input = document.createElement("select");
      const empty = document.createElement("option");
      empty.value = "";
      empty.textContent = "- Vorhersage -";
      input.appendChild(empty);
      const choices = item.type === "bool" ? ["true", "false"] : item.choices;
      for (const value of choices) {
        const option = document.createElement("option");
        option.value = value;
        option.textContent = value;
        input.appendChild(option);
      }
    }
    input.dataset.key = item.key;
    input.addEventListener("input", refreshPredictions);
    row.appendChild(input);

    predictionInputs.set(item.key, input);
    wrap.appendChild(row);
  }
}

/* ---------- Aufgabe 6.2: Karten-Widget für die Vorhersage ----------
   Die Vorhersage passiert als Karten-UI auf dieser Seite:
   Karten in die Slots ziehen (oder klicken), der Test prüft live. */

// Liest die aktuelle Sortierung ab - null, solange Karten fehlen.
function getPredictOrder() {
  const cards = document.querySelectorAll("#order-slots .card");
  if (cards.length < ORDER_STATEMENTS.length) return null;
  return Array.from(cards).map((card) => card.dataset.id);
}

// Prüft die Sortierung live: aktualisiert die Ergebniszeile in der
// Liste UND das Feedback unter den Karten - grün, sobald die
// Reihenfolge stimmt, ohne die Lösung zu verraten.
// Prüft die Sortierung live und zeigt das Ergebnis unter den
// Karten - ohne die Lösung zu verraten. Die Sortierung erscheint
// nicht in der Testliste unten, das Ergebnis steht direkt da.
function refreshPredictOrderResult() {
  const arranged = getPredictOrder();
  const correct = arranged !== null &&
    JSON.stringify(arranged) === JSON.stringify(EXPECTED_ORDER);

  const resultEl = document.getElementById("order-result");
  if (resultEl) {
    resultEl.textContent = arranged === null
      ? "Noch nicht alle fünf Karten sind einsortiert."
      : correct
        ? "Richtig! Die Reihenfolge stimmt."
        : "Noch nicht die richtige Reihenfolge.";
    resultEl.className = correct ? "ok" : "err";
  }

  saveState();
}

function initPredictOrderWidget() {
  const slotsEl = document.getElementById("order-slots");
  const poolEl = document.getElementById("order-pool");
  if (!slotsEl || !poolEl) return;

  const shuffle = (arr) => {
    for (let i = arr.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [arr[i], arr[j]] = [arr[j], arr[i]];
    }
    return arr;
  };

  for (let i = 0; i < ORDER_STATEMENTS.length; i++) {
    const li = document.createElement("li");
    li.className = "slot";
    li.addEventListener("dragover", (e) => { e.preventDefault(); li.classList.add("over"); });
    li.addEventListener("dragleave", () => li.classList.remove("over"));
    li.addEventListener("drop", (e) => {
      e.preventDefault();
      li.classList.remove("over");
      const id = e.dataTransfer.getData("text/plain");
      const dragged = document.querySelector(`.card[data-id="${id}"]`);
      if (!dragged) return;
      const existing = li.querySelector(".card");
      if (existing) {
        // Belegter Platz blockt nicht: Die alte Karte rutscht dorthin,
        // wo die gezogene herkam (Platz tauschen).
        dragged.parentElement.appendChild(existing);
      }
      li.appendChild(dragged);
      refreshPredictOrderResult();
    });
    orderSlotEls.push(li);
    slotsEl.appendChild(li);
  }

  const createCard = (stmt) => {
    const card = document.createElement("div");
    card.className = "card";
    card.draggable = true;
    card.dataset.id = stmt.id;
    card.textContent = stmt.label;
    card.addEventListener("dragstart", (e) => {
      e.dataTransfer.setData("text/plain", stmt.id);
      e.dataTransfer.effectAllowed = "move";
    });
    card.addEventListener("click", () => {
      if (card.parentElement.classList.contains("slot")) {
        poolEl.appendChild(card); // zurück in den Vorrat
      } else {
        const free = firstFreeSlot();
        if (free) free.appendChild(card); // in den nächsten freien Platz
      }
      refreshPredictOrderResult();
    });
    return card;
  };

  for (const stmt of shuffle([...ORDER_STATEMENTS])) {
    poolEl.appendChild(createCard(stmt));
  }
}

/* ---------- Synchrone Tests ---------- */
function runSyncTests() {
  /* ----- Aufgabe 3: Variablen und Hoisting ----- */
  task("MAX_POINTS");

  testEq("MAX_POINTS ist 100", () => MAX_POINTS, 100);
  test("MAX_POINTS ist nicht neu zuweisbar (const)", () => {
    assertThrows(() => { MAX_POINTS = 200; },
      "MAX_POINTS ist nicht neu zuweisbar (const)", "TypeError");
  });

  task("Call Stack bis zum Anschlag");

  test("stackOverflow() löst RangeError aus (Call Stack voll)", () => {
    assertThrows(stackOverflow, "stackOverflow() löst RangeError aus (Call Stack voll)");
  });

  /* ----- Aufgabe 4: Funktionen als First-Class Citizens ----- */
  task("Prozente und Bestehen");

  testEq("toPercent(50) - Skalierung mit MAX_POINTS", () => toPercent(50), 50);
  testEq("isPassing(50) ist true (Grenze)", () => isPassing(50), true);
  testEq("isPassing(49.9) ist false", () => isPassing(49.9), false);

  task("Ohne Schleifen");

  testEq("allPercents mit map", () => allPercents([50, 100]), [50, 100]);
  testEq("passedPercents mit filter", () => passedPercents([20, 50, 80]), [50, 80]);
  testEq("averagePercent mit reduce", () => averagePercent([50, 100]), 75);
  testEq("averagePercent über drei Werte", () => averagePercent([10, 20, 30]), 20);
  test("Array-Methoden statt Schleifen genutzt", () => {
    assertTrue([allPercents, passedPercents, averagePercent].every((f) =>
      f.toString().includes("map") || f.toString().includes("filter") ||
      f.toString().includes("reduce")), "Array-Methoden statt Schleifen genutzt");
  });

  task("Funktionen als Werte");

  testEq("applyToAll wendet fn an", () => applyToAll([1, 2, 3], (x) => x * 10), [10, 20, 30]);

  // Funktionen sind Werte - das Kernkonzept von First-Class Citizens:
  testEq("isPassing ist ein Wert vom Typ function", () => typeof isPassing, "function");
  testEq("applyToAll nimmt Funktionen als Argument", () => applyToAll([10, 20], isPassing), [false, false]);

  /* ----- Aufgabe 5: Objekte und Prototypen ----- */
  task("Zwei Wege, ein Ziel");

  test("class-Weg: getName() funktioniert", () => {
    const s1 = new Student("Alex");
    assertEqual(s1.getName(), "Alex", "class-Weg: getName() funktioniert");
  });

  test("Prototyp-Weg: getName() über Prototypenkette", () => {
    s2 = createStudent("Kim");
    assertEqual(s2.getName(), "Kim", "Prototyp-Weg: getName() über Prototypenkette");
  });
  test("createStudent nutzt Object.create(studentProto)", () => {
    assertTrue(Object.getPrototypeOf(s2) === studentProto,
      "createStudent nutzt Object.create(studentProto)");
  });

  task("Prototypenkette nachweisen");

  test("getName liegt NICHT auf dem Objekt selbst (Prototypenkette!)", () => {
    assertTrue(hasOwnGetName(s2) === false,
      "getName liegt NICHT auf dem Objekt selbst (Prototypenkette!)");
  });
  test("hasOwnGetName erkennt eigene Methoden", () => {
    assertTrue(hasOwnGetName({ getName() { return 1; } }) === true,
      "hasOwnGetName erkennt eigene Methoden");
  });

  task("Methoden im Nachhinein");

  test("greet() ist nachträglich für ALLE verfügbar", () => {
    addGreetToProto();
    assertEqual(s2.greet(), "Hallo, Kim", "greet() ist nachträglich für ALLE verfügbar");
  });

  /* ----- Aufgabe 6: Event Loop und Asynchronität (sync) -----
     6.2 wird nicht als Zeile getestet - das Ergebnis steht live
     unter den Karten. Aber der versprochene Code läuft hier
     wirklich (siehe index.html): */
  const actualOrder = [];
  (function recordOrder() {
    actualOrder.push("S");
    Promise.resolve().then(() => actualOrder.push("P")); // steht hier für loadGrades-then
    setTimeout(() => actualOrder.push("T"), 0);
    Promise.resolve().then(() => actualOrder.push("Micro"));
    actualOrder.push("K");
  })();
  // Hinweis: loadGrades() braucht 1s - hier messen wir mit sofortigen Promises.
}

let s2; // wird im Prototyp-Test erzeugt und danach weiterverwendet

/* ---------- Asynchrone Tests ---------- */

// Asynchrone Ergebnisse zusätzlich als Zeilen eintragen:
function assertSoft(actual, expected, name) {
  const ok = JSON.stringify(actual) === JSON.stringify(expected);
  const hint = !ok && actual === undefined ? " - Funktion noch nicht implementiert?" : "";
  record(ok, name, ok ? "" : `Noch nicht richtig - erhalten: ${JSON.stringify(actual)}${hint}`);
  return ok;
}

// Startet eine async-Funktion und prüft ihr Ergebnis - egal ob sie
// ein Promise zurückgibt, synchron einen Fehler wirft oder (noch)
// nichts tut. Liefert immer ein erfülltes Promise zurück, damit
// nachfolgende Tests unabhängig weiterlaufen.
function testAsync(name, taskName, fn) {
  let promise;
  try {
    promise = fn();
  } catch (err) {
    currentTask = taskName;
    record(false, name, errorDetail(err));
    return Promise.resolve();
  }
  return Promise.resolve(promise)
    .then((loaded) => {
      currentTask = taskName;
      assertSoft(loaded, SERVER_GRADES, name);
    })
    .catch((err) => {
      currentTask = taskName;
      record(false, name, `Promise wurde abgelehnt: ${errorDetail(err)}`);
    });
}

function runAsyncTests() {
  const callbackTask = "Callbacks vs. Promises";
  let callbackCalled = false;

  // a) Callback-Variante
  try {
    loadGradesCallback((loaded) => {
      callbackCalled = true;
      currentTask = callbackTask;
      assertSoft(loaded, SERVER_GRADES, "loadGradesCallback liefert Noten");
      render(); // Zwischenstand zeigen
    });
  } catch (err) {
    callbackCalled = true; // Aufruf selbst fehlgeschlagen - Timeout-Prüfung entfällt
    currentTask = callbackTask;
    record(false, "loadGradesCallback liefert Noten", errorDetail(err));
    render();
  }

  // Wurde der Callback nach 1,5 s nie aufgerufen, ist die Funktion leer.
  setTimeout(() => {
    if (!callbackCalled) {
      currentTask = callbackTask;
      record(false, "loadGradesCallback liefert Noten",
        "Der Callback wurde nach 1,5 s nie aufgerufen - Funktion noch nicht implementiert?");
    }
    render();

    // b) Promise-Variante
    testAsync("loadGrades() resolved mit Noten", callbackTask, loadGrades)
      .then(() => {
        // d) Bewusst NICHT returnen: Die Rejection bleibt unbehandelt
        //    und landet als Warnung in der Browser-Konsole.
        try { triggerUnhandledRejection(); } catch (err) { /* Demo, kein Test */ }
        // e) async/await-Variante
        return testAsync("loadGradesAsync liefert Noten", "async/await", loadGradesAsync);
      })
      .then(render); // finale Ausgabe nach den async Tests
  }, 1500);
}

/* ---------- Ein vollständiger Testlauf ---------- */
function runAllTests() {
  results.length = 0;
  runSyncTests();
  render(); // Zwischenstand - die async Tests folgen
  runAsyncTests();
}

/* ---------- Start ---------- */
initPredictionWidgets();
initPredictOrderWidget();
restoreState(); // gespeicherte Vorhersagen und Karten zurückholen
runAllTests();
refreshPredictions(); // gespeicherte Vorhersagen direkt einfärben
refreshPredictOrderResult(); // Erstzustand der Karten unter den Karten anzeigen
