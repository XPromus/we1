package com.xpromus;

import java.net.InetSocketAddress;
import org.java_websocket.server.WebSocketServer;
import org.java_websocket.WebSocket;
import org.java_websocket.handshake.ClientHandshake;

/**
 * The simple WebSocket server: it sends a welcome message to each client
 * and prints every message it receives.
 *
 * Run it with: ./gradlew run -PmainClass=com.xpromus.SimpleServer
 */
public class SimpleServer {

    static class ChatServer extends WebSocketServer {

        public ChatServer(int port) {
            super(new InetSocketAddress(port));
        }

        @Override
        public void onOpen(WebSocket conn, ClientHandshake handshake) {
            System.out.println("Client connected: " + conn.getRemoteSocketAddress());
            conn.send("Welcome to the WebSocket server!");
        }

        @Override
        public void onClose(WebSocket conn, int code, String reason, boolean remote) {
            System.out.println("Client disconnected: " + conn.getRemoteSocketAddress());
        }

        @Override
        public void onMessage(WebSocket conn, String message) {
            System.out.println("Received: " + message);
            System.out.println("Raw message: \"" + message + "\" (" + message.length() + " characters)");
        }

        @Override
        public void onError(WebSocket conn, Exception ex) {
            System.err.println("Error: " + ex.getMessage());
        }

        @Override
        public void onStart() {
            System.out.println("WebSocket server started on port " + getPort());
        }
    }

    public static void main(String[] args) {
        int port = 8887;
        ChatServer server = new ChatServer(port);
        server.start();
    }
}
