import { WebSocketServer } from "ws";

const PORT = 8080;

const players = new Map();

const COLORS = ["#e74c3c", "#3498db"];
const START_POSITIONS = [{ x: 100, y: 100 }, { x: 500, y: 300 }];
const MOVE_SPEED = 5;

const wss = null; // TODO: Ersetze mit einer richtigen WebSocketServer Instanz

wss.on("connection", (socket) => {
    // -----------------------------------------------------------------------
    // TODO 2: Akzeptiere den Spieler
    //   - Es sind nur 2 Spieler erlaubt. Schicke { type: "lobby-full" } und schließe die Verbindung
    //   - Setze eine ID, Farbe, Startposition und speichere den Spieler
    //   - Schicke dem neuen Spieler seine Daten: { type: "welcome", id, x, y, color }
    // -----------------------------------------------------------------------

    socket.on("message", (raw) => {
        const msg = JSON.parse(raw.toString());

        // -------------------------------------------------------------------
        // TODO 3: Handle movement
        // - Server erwartet Nachricht vom Client: { type: "move", dx, dy }
        // - Update die Position des Senders (clamp Position zu den Canvas Grenzen: 0..640 / 0 ..400 inkl. Größe des Spielers)
        // - Broadcaste den neuen Zustand zu allen Clients { type: "state", players: [{ id, x, y, color }, ...] }
        // -------------------------------------------------------------------

        // -------------------------------------------------------------------
        // TODO 4 (optional): collision / score
        // Wenn zwei Spieler überlappen, schicke { type: "collision" } zu beiden
        // -------------------------------------------------------------------
    });

    socket.on("close", () => {
        // -------------------------------------------------------------------
        // TODO 5: Handle disconnect
        // - Entferne den Spieler von der Karte
        // - Broadcaste den aktuellen State, damit die anderen Spieler es sehen können
        // -------------------------------------------------------------------
    });
})

function broadcast(data, exclude = null) {
    const payload = JSON.stringify(data);
    for (const client of players.keys()) {
        if (client !== exclude && client.readyState === 1 /* OPEN */) {
            client.send(payload);
        }
    }
}

console.log(`Stub server listening on ws://localhost:${PORT} — now make it work!`);
