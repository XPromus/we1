// =========================================================================
// Starter: Beide Spieler werden lokal über einen Canvas kontrolliert.
// Schritt 1: Führe es aus, verstehe den Game Loop und wie der State aufgebaut ist
// Schritt 2: Ersetzte den lokalen Spieler 2 mit den Daten, die über die WebSocket ankommen
// =========================================================================

const canvas = document.getElementById("game");
const ctx = canvas.getContext("2d");

const statusEl = document.getElementById("status");

const canvasWidth = canvas.width; 
const canvasHeight = canvas.height;

const SPEED = 5, SIZE = 20;

// Lokaler State für die Anfangsversion
const players = {
    p1: { x: 100, y: 100, color: "#e74c3c" },
    p2: { x: 500, y: 300, color: "#3498db" },
};

// -------------------------------------------------------------------------
// TODO 1: Öffne die Verbindung
// - const socket = new WebSocket("ws://localhost:8080");
// - Update "#status" wenn "open", "error" und "close" kommen
// -------------------------------------------------------------------------

// -------------------------------------------------------------------------
// TODO 2: Erhalte den State
// socket.onmessage = (event) => { ... }
// - Parse das JSON. Speichere deine id bei { type: "welcome", ... }
// - Wenn { type: "state", players: [...] } ankommt, ersetze `players` mit der erhaltenen Liste an Spielern und lass den game loop sie zeichnen
// -------------------------------------------------------------------------

// Tastatursteuerung mit WASD und Pfeiltasten als lokale Version
const keys = {};
window.addEventListener("keydown", (e) => { keys[e.key.toLowerCase()] = true; e.preventDefault(); });
window.addEventListener("keyup",   (e) => { keys[e.key.toLowerCase()] = false; });

// -------------------------------------------------------------------------
// TODO 3: Entferne lokale Steuerung & Schicke die Bewegung
// - Entferne die Steuerung von Player 2
// - Berechne dx/dy von den betätigen Tasten (nur Spieler 1) und Sende eine Nachricht an den Server:
// - socket.send(JSON.stringify({ type: "move", dx, dy }));
// - Sende eine Nachricht pro Tastendruck (keydown), nicht pro Frame
// -------------------------------------------------------------------------

function step() {
    if (keys["w"]) players.p1.y -= SPEED;
    if (keys["s"]) players.p1.y += SPEED;
    if (keys["a"]) players.p1.x -= SPEED;
    if (keys["d"]) players.p1.x += SPEED;

    if (keys["arrowup"])    players.p2.y -= SPEED;
    if (keys["arrowdown"])  players.p2.y += SPEED;
    if (keys["arrowleft"])  players.p2.x -= SPEED;
    if (keys["arrowright"]) players.p2.x += SPEED;

    for (const p of Object.values(players)) {
        p.x = Math.max(0, Math.min(canvasWidth - SIZE, p.x));
        p.y = Math.max(0, Math.min(canvasHeight - SIZE, p.y));
    }

    draw();
    requestAnimationFrame(step);
}

function draw() {
    ctx.clearRect(0, 0, canvasWidth, canvasHeight);
    
    for (const p of Object.values(players)) {
        ctx.fillStyle = p.color;
        ctx.fillRect(p.x, p.y, SIZE, SIZE);
    }
}

step();