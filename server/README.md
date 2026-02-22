# Smart Home AI — MQTT Broker Server

A lightweight, self-hosted **MQTT v3.1.1** broker written in pure Dart.  
Part of the Smart Home AI platform by **Circuvent Technologies Pvt Ltd**.

## Features

- **TCP transport** (port 1883) — for ESP32, mobile apps, native clients
- **WebSocket transport** (port 8083) — for Flutter Web & browsers
- **Username/password authentication** (SHA-256 hashed)
- **QoS 0 & 1** support
- **Retained messages** — persistent across sessions
- **Topic wildcards** — `+` (single-level) and `#` (multi-level)
- **REST API** — `/status` and `/publish` endpoints
- **Graceful shutdown** — on SIGINT

## Quick Start

```bash
cd server
dart pub get
dart run bin/server.dart
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MQTT_TCP_PORT` | `1883` | TCP listener port |
| `MQTT_WS_PORT` | `8083` | WebSocket listener port |
| `MQTT_USER` | `smarthome` | Broker username |
| `MQTT_PASSWORD` | `smarthome_password` | Broker password |

## MQTT Topics (Smart Home)

| Topic | Direction | Description |
|-------|-----------|-------------|
| `smarthome/sensors/data` | ESP32 → App | Sensor telemetry (every 3s) |
| `smarthome/devices/status` | ESP32 → App | Relay/device states (retained) |
| `smarthome/devices/control` | App → ESP32 | Device commands |
| `smarthome/devices/+/set` | App → ESP32 | Per-device commands |
| `smarthome/alerts` | ESP32 → App | Alert events |
| `smarthome/system` | ESP32 → App | Heartbeat/status (retained) |

## REST API

```bash
# Broker status
curl http://localhost:8083/status

# Publish a message via REST
curl -X POST http://localhost:8083/publish \
  -H "Content-Type: application/json" \
  -d '{"topic": "smarthome/alerts", "payload": {"type": "test"}, "retain": false}'
```

## Connecting from Flutter

The Flutter app connects via WebSocket on web and TCP on mobile:
- **Web**: `ws://your-server:8083/mqtt`
- **Mobile/Desktop**: `tcp://your-server:1883`

## Architecture

```
ESP32 Node(s)  ──TCP──►  MQTT Broker (Dart)  ◄──WS──  Flutter Web App
                              │                         Flutter Mobile App
                              │
                         REST API (/status, /publish)
```
