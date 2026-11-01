package com.xpromus;

import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.util.List;
import org.java_websocket.WebSocketAdapter;
import org.java_websocket.WebSocketImpl;
import org.java_websocket.WebSocketServerFactory;
import org.java_websocket.drafts.Draft;
import org.java_websocket.handshake.ClientHandshake;
import org.java_websocket.server.WebSocketServer;
import org.java_websocket.WebSocket;

public class Main {

    // A WebSocket that prints the raw RFC 6455 frame before it gets decoded
    static class RawFrameWebSocket extends WebSocketImpl {

        public RawFrameWebSocket(WebSocketAdapter listener, Draft draft) {
            super(listener, draft);
        }

        public RawFrameWebSocket(WebSocketAdapter listener, List<Draft> drafts) {
            super(listener, drafts);
        }

        @Override
        public void decode(ByteBuffer socketBuffer) {
            // Only print frames after the handshake is done, otherwise the
            // buffer contains the HTTP upgrade request, not a WebSocket frame
            if (isOpen()) {
                printRawFrames(socketBuffer.asReadOnlyBuffer());
            }
            super.decode(socketBuffer);
        }

        private void printRawFrames(ByteBuffer buf) {
            while (buf.remaining() >= 2) {
                int frameStart = buf.position();

                int b0 = buf.get() & 0xFF;
                int b1 = buf.get() & 0xFF;

                boolean fin = (b0 & 0x80) != 0;
                int rsv = (b0 & 0x70) >> 4;
                int opcode = b0 & 0x0F;
                boolean masked = (b1 & 0x80) != 0;
                long payloadLength = b1 & 0x7F;

                if (payloadLength == 126) { // 16-bit extended length
                    if (buf.remaining() < 2) { buf.position(frameStart); return; }
                    payloadLength = ((buf.get() & 0xFF) << 8) | (buf.get() & 0xFF);
                } else if (payloadLength == 127) { // 64-bit extended length
                    if (buf.remaining() < 8) { buf.position(frameStart); return; }
                    payloadLength = 0;
                    for (int i = 0; i < 8; i++) {
                        payloadLength = (payloadLength << 8) | (buf.get() & 0xFF);
                    }
                }

                byte[] maskKey = null;
                if (masked) {
                    if (buf.remaining() < 4) { buf.position(frameStart); return; }
                    maskKey = new byte[4];
                    buf.get(maskKey);
                }

                // Frame not fully received in this read: let the library
                // buffer it and decode once the rest arrives
                if (buf.remaining() < payloadLength) { buf.position(frameStart); return; }

                byte[] payload = new byte[(int) payloadLength];
                buf.get(payload);

                System.out.println("---- Raw frame (RFC 6455) ----");
                System.out.printf("FIN=%d RSV=%d Opcode=0x%X (%s)%n",
                        fin ? 1 : 0, rsv, opcode, opcodeName(opcode));
                System.out.println("Masked=" + masked
                        + (masked ? String.format(" Masking key=%02X %02X %02X %02X",
                                maskKey[0], maskKey[1], maskKey[2], maskKey[3]) : ""));
                System.out.println("Payload length=" + payloadLength);
                System.out.println("Payload (hex, as sent on the wire): " + toHex(payload));
            }
        }

        private static String opcodeName(int opcode) {
            switch (opcode) {
                case 0:  return "CONTINUATION";
                case 1:  return "TEXT";
                case 2:  return "BINARY";
                case 8:  return "CLOSE";
                case 9:  return "PING";
                case 10: return "PONG";
                default: return "UNKNOWN";
            }
        }

        private static String toHex(byte[] bytes) {
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02X ", b));
            }
            return sb.toString().trim();
        }
    }

    static class ChatServer extends WebSocketServer {

        public ChatServer(int port) {
            super(new InetSocketAddress(port));
            // Plug in our own WebSocket implementation that prints raw frames
            setWebSocketFactory(new WebSocketServerFactory() {
                @Override
                public WebSocketImpl createWebSocket(WebSocketAdapter listener, Draft draft) {
                    return new RawFrameWebSocket(listener, draft);
                }

                @Override
                public WebSocketImpl createWebSocket(WebSocketAdapter listener, List<Draft> drafts) {
                    return new RawFrameWebSocket(listener, drafts);
                }

                @Override
                public java.nio.channels.ByteChannel wrapChannel(java.nio.channels.SocketChannel channel, java.nio.channels.SelectionKey key) {
                    return channel; // same as the default factory: use the channel as-is
                }

                @Override
                public void close() {
                    // nothing to clean up
                }
            });
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
