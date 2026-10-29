/* ============================================================
   Seminar 03 – JavaScript Grundkonzepte (GradeCalc)
   Diese Datei enthält NUR leere Funtionen. Implementiert alle Funktionen,
   bis alle Tests in seminar-tests.js grün sind.
   Regeln: MDN, Vorlesungsfolien und auch Gruppenarbeit erlaubt.
   ============================================================ */

/* ---------- Aufgabe 3: Variablen und Hoisting ---------- */

// a) Legt MAX_POINTS so an, dass Neuzuweisung einen Fehler wirft.
let MAX_POINTS = null; // TODO

// c) Schreibt eine Funktion, die absichtlich einen
//    "Maximum call stack size exceeded" (RangeError) auslöst.
function stackOverflow() {
  // TODO
}

/* ---------- Aufgabe 4: Funktionen als First-Class Citizens ----------
   WICHTIG: keine for-/while-Schleifen! Genau eine Array-Methode pro Wert. */

const grades = [82, 95, 58, 77, 90];

// Prozent aus Punkten
function toPercent(grade) {
  // TODO
}

// true ab 50 Prozent
function isPassing(percent) {
  // TODO
}

// Alle Noten als Prozentwerte – mit map
function allPercents(values) {
  // TODO
}

// Nur die bestandenen Prozente – mit filter
function passedPercents(values) {
  // TODO
}

// Prozent-Durchschnitt aller Noten – mit reduce (ohne Hilfsvariable außen)
function averagePercent(values) {
  // TODO
}

// Nimmt eine Funktion und gibt ein neues Array mit fn(value) zurück
function applyToAll(values, fn) {
  // TODO
}

/* ---------- Aufgabe 5: Objekte und Prototypen ---------- */

// a) Klassischer Weg
class Student {
  // TODO: constructor(name), getName()
}

// b) Prototypischer Weg – OHNE class
const studentProto = {
  // TODO: getName() { ... }
};

// Erzeugt einen Studenten über den Prototypen und setzt den Namen
function createStudent(name) {
  // TODO: Object.create(...) verwenden
}

// c) true, wenn getName NICHT auf dem Objekt selbst liegt (Stichwort: Object.hasOwn)
function hasOwnGetName(student) {
  // TODO
}

// d) Fügt ALLEN Studenten des prototypischen Wegs nachträglich greet() hinzu
function addGreetToProto() {
  // TODO: studentProto erweitern
}

/* ---------- Aufgabe 6: Event Loop und Asynchronität ---------- */

// a) Callback-Variante: ruft callback nach 1000ms mit dem Noten-Array auf
function loadGradesCallback(callback) {
  const gradesFromServer = [82, 95, 58, 77, 90];
  // TODO: setTimeout
}

// b) Promise-Variante: resolved nach 1000ms mit dem Noten-Array
function loadGrades() {
  const gradesFromServer = [82, 95, 58, 77, 90];
  // TODO: new Promise(...) mit setTimeout
  // Fehlschlagen soll die Funktion NICHT – die Fehlerfälle behandelt Aufgabe 6.4)
}

// d) Löst absichtlich einen unhandled rejection aus: gibt ein abgelehntes
//    Promise zurück, das NIRGENDS abgefangen wird.
function triggerUnhandledRejection() {
  // TODO: Promise.reject(...)
}

// e) async/await-Variante von loadGrades mit try/catch:
//    Bei Erfolg: das Noten-Array. Bei Fehler: leeres Array [].
async function loadGradesAsync() {
  // TODO
}
