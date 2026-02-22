# ESP32 Hardware Guide

This guide covers the ESP32 microcontroller firmware that serves as the IoT hardware bridge for SmartHome AI.

## Overview

The ESP32 node collects sensor data (temperature, humidity, power, water level, gas, motion, light) and controls actuators (relays for lights, fans, AC, water pump) via MQTT communication with the Flutter app.

## Hardware Requirements

### Core Board
| Component | Specification |
|---|---|
| **Microcontroller** | ESP32 DevKit v1 (ESP-WROOM-32) |
| **USB Driver** | CP2102 or CH340 (depends on board variant) |
| **Power** | 5V via USB or external supply |

### Sensors

| Sensor | Model | Purpose | Pin |
|---|---|---|---|
| Temperature & Humidity | DHT22 (AM2302) | Room climate | GPIO 4 |
| Power Monitor | PZEM-004T v3.0 | Voltage, current, power, energy | RX: GPIO 16, TX: GPIO 17 |
| Ultrasonic Distance | HC-SR04 | Water tank level | TRIG: GPIO 5, ECHO: GPIO 18 |
| Motion | PIR (HC-SR501) | Occupancy detection | GPIO 33 |
| Gas | MQ-2 | Smoke/LPG detection | GPIO 35 (ADC) |
| Light | LDR (GL5528) | Ambient light level | GPIO 34 (ADC) |

### Actuators

| Device | Type | Purpose | Pin |
|---|---|---|---|
| Relay 1 | 5V relay module | Light control | GPIO 25 |
| Relay 2 | 5V relay module | Fan control | GPIO 26 |
| Relay 3 | 5V relay module | AC control | GPIO 27 |
| Relay 4 | 5V relay module | Water pump | GPIO 14 |
| Buzzer | Active buzzer | Alarm/alert | GPIO 32 |
| Status LED | Built-in LED | Connection status | GPIO 2 |

## Wiring Diagram

```
                          ESP32 DevKit v1
                    ┌─────────────────────────┐
                    │                         │
    DHT22 ─────────┤ GPIO 4          GPIO 25 ├───── Relay 1 (Light)
    HC-SR04 TRIG ──┤ GPIO 5          GPIO 26 ├───── Relay 2 (Fan)
    HC-SR04 ECHO ──┤ GPIO 18         GPIO 27 ├───── Relay 3 (AC)
    PZEM RX ───────┤ GPIO 16         GPIO 14 ├───── Relay 4 (Pump)
    PZEM TX ───────┤ GPIO 17         GPIO 32 ├───── Buzzer
    PIR ───────────┤ GPIO 33         GPIO 2  ├───── Status LED
    LDR ───────────┤ GPIO 34 (ADC)           │
    MQ-2 ──────────┤ GPIO 35 (ADC)           │
                    │                         │
                    │    5V ──── VCC (sensors) │
                    │    GND ─── GND (sensors) │
                    └─────────────────────────┘
```

### DHT22 Wiring
```
DHT22 Pin 1 (VCC)  → 3.3V
DHT22 Pin 2 (Data) → GPIO 4 (with 10kΩ pull-up to 3.3V)
DHT22 Pin 3 (NC)   → Not connected
DHT22 Pin 4 (GND)  → GND
```

### HC-SR04 Wiring
```
HC-SR04 VCC  → 5V
HC-SR04 TRIG → GPIO 5
HC-SR04 ECHO → GPIO 18 (through voltage divider: 1kΩ + 2kΩ)
HC-SR04 GND  → GND
```

### PZEM-004T Wiring
```
PZEM TX → GPIO 16 (ESP32 RX)
PZEM RX → GPIO 17 (ESP32 TX)
PZEM VCC → 5V
PZEM GND → GND
(Connect AC load through PZEM current transformer)
```

## Firmware Setup

### Option 1: PlatformIO (Recommended)

1. Install [PlatformIO IDE](https://platformio.org/install/ide?install=vscode) extension for VS Code
2. Open the `esp32/` folder in VS Code
3. Edit `smart_home_esp32/config.h` with your settings
4. Click **Upload** (→) in the PlatformIO toolbar

```bash
# Or from command line:
cd esp32
pio run -t upload
pio device monitor    # View serial output
```

### Option 2: Arduino IDE

1. Install [ESP32 board support](https://docs.espressif.com/projects/arduino-esp32/en/latest/installing.html)
2. Install required libraries via Library Manager:
   - `PubSubClient` by Nick O'Leary
   - `ArduinoJson` by Benoit Blanchon
   - `DHT sensor library` by Adafruit
   - `Adafruit Unified Sensor`
   - `PZEM-004T-v30` by Mandula
3. Open `esp32/smart_home_esp32/smart_home_esp32.ino`
4. Select board: **ESP32 Dev Module**
5. Select port and click **Upload**

## Configuration

Edit `esp32/smart_home_esp32/config.h` before flashing:

### Network Settings
```c
#define WIFI_SSID          "YourWiFiName"
#define WIFI_PASSWORD      "YourWiFiPassword"
```

### MQTT Broker
```c
#define MQTT_SERVER        "192.168.1.100"    // Broker IP
#define MQTT_PORT          1883
#define MQTT_USER          "smarthome"
#define MQTT_PASSWORD      "smarthome_password"
```

### Device Identity
```c
#define DEVICE_ID          "esp32_node_01"
#define DEVICE_NAME        "Living Room Node"
#define FIRMWARE_VERSION   "1.0.0"
```

### Safety Thresholds
```c
#define TEMP_HIGH          40.0    // °C - high temp alert
#define TEMP_LOW           10.0    // °C - low temp alert
#define HUMIDITY_HIGH      80.0    // % - high humidity alert
#define VOLTAGE_HIGH       250.0   // V - overvoltage alert
#define VOLTAGE_LOW        190.0   // V - undervoltage alert
#define CURRENT_HIGH       15.0    // A - overcurrent alert
#define WATER_LOW          15.0    // % - low water alert
#define WATER_CRITICAL     5.0     // % - critical water level
#define WATER_FULL         95.0    // % - tank full
#define GAS_THRESHOLD      2000    // ADC - gas detection
```

### Water Tank Dimensions
```c
#define TANK_HEIGHT_CM     100.0   // Tank height in cm
#define TANK_DIAMETER_CM   60.0    // Tank diameter in cm
#define SENSOR_OFFSET_CM   5.0     // Sensor-to-full distance
```

### Feature Toggles
```c
#define ENABLE_OTA         true    // Over-the-air updates
#define ENABLE_AUTO_PUMP   true    // Auto water pump control
#define ENABLE_GAS_SAFETY  true    // Emergency shutoff on gas
#define ENABLE_MOTION_LOG  true    // Log motion events
#define ENABLE_DEEP_SLEEP  false   // Battery saving mode
```

## MQTT Topics

### Published by ESP32 (Sensor Data)

| Topic | Payload | Interval |
|---|---|---|
| `smarthome/{device_id}/sensors/temperature` | `{"value": 25.5, "unit": "°C"}` | 3s |
| `smarthome/{device_id}/sensors/humidity` | `{"value": 65.2, "unit": "%"}` | 3s |
| `smarthome/{device_id}/sensors/voltage` | `{"value": 228.5, "unit": "V"}` | 3s |
| `smarthome/{device_id}/sensors/current` | `{"value": 4.2, "unit": "A"}` | 3s |
| `smarthome/{device_id}/sensors/power` | `{"value": 957.0, "unit": "W"}` | 3s |
| `smarthome/{device_id}/sensors/water_level` | `{"value": 72.5, "unit": "%", "liters": 204.3}` | 3s |
| `smarthome/{device_id}/sensors/motion` | `{"detected": true}` | On event |
| `smarthome/{device_id}/sensors/gas` | `{"value": 350, "alert": false}` | 3s |
| `smarthome/{device_id}/sensors/light` | `{"value": 650, "unit": "lux"}` | 3s |
| `smarthome/{device_id}/status` | `{"online": true, "uptime": 3600, "ip": "..."}` | 30s |
| `smarthome/{device_id}/alert` | `{"type": "gas", "message": "..."}` | On event |

### Subscribed by ESP32 (Commands)

| Topic | Payload | Action |
|---|---|---|
| `smarthome/{device_id}/relay/1/set` | `"ON"` or `"OFF"` | Control light |
| `smarthome/{device_id}/relay/2/set` | `"ON"` or `"OFF"` | Control fan |
| `smarthome/{device_id}/relay/3/set` | `"ON"` or `"OFF"` | Control AC |
| `smarthome/{device_id}/relay/4/set` | `"ON"` or `"OFF"` | Control pump |
| `smarthome/{device_id}/buzzer/set` | `"ON"` or `"OFF"` | Control buzzer |
| `smarthome/{device_id}/config` | JSON config | Update settings |
| `smarthome/{device_id}/restart` | `"RESTART"` | Reboot ESP32 |

## MQTT Broker Setup

### Install Mosquitto

**Windows:**
```powershell
winget install EclipseFoundation.Mosquitto
```

**Linux/macOS:**
```bash
sudo apt install mosquitto mosquitto-clients    # Ubuntu/Debian
brew install mosquitto                           # macOS
```

### Configure Mosquitto
Create `/etc/mosquitto/conf.d/smarthome.conf`:
```
listener 1883
allow_anonymous false
password_file /etc/mosquitto/passwd
```

Add credentials:
```bash
mosquitto_passwd -c /etc/mosquitto/passwd smarthome
# Enter password when prompted
```

### Test MQTT

```bash
# Subscribe (terminal 1)
mosquitto_sub -h localhost -t "smarthome/#" -u smarthome -P password

# Publish a test command (terminal 2)
mosquitto_pub -h localhost -t "smarthome/esp32_node_01/relay/1/set" -m "ON" -u smarthome -P password
```

## OTA Updates

The firmware supports Over-the-Air updates when `ENABLE_OTA` is `true`:

1. ESP32 advertises as `SmartHome-ESP32.local` on the network
2. PlatformIO auto-discovers it:
   ```bash
   pio run -t upload --upload-port SmartHome-ESP32.local
   ```
3. Or specify IP directly:
   ```bash
   pio run -t upload --upload-port 192.168.1.x
   ```

## Safety Features

### Gas Detection
When `ENABLE_GAS_SAFETY` is enabled and gas level exceeds `GAS_THRESHOLD`:
1. All relays are turned OFF immediately
2. Buzzer is activated
3. Alert is published to MQTT
4. Status LED blinks rapidly

### Auto Water Pump
When `ENABLE_AUTO_PUMP` is enabled:
- Pump turns ON when water level drops below `WATER_LOW` (15%)
- Pump turns OFF when water level reaches `WATER_FULL` (95%)
- Pump is disabled on `WATER_CRITICAL` (5%) to prevent dry-run

## Serial Monitor Output

```
[INFO] SmartHome AI ESP32 Node
[INFO] Firmware: 1.0.0
[INFO] Connecting to WiFi: MyNetwork
[OK]   WiFi connected: 192.168.1.42
[INFO] Connecting to MQTT: 192.168.1.100:1883
[OK]   MQTT connected
[DATA] Temp: 25.5°C | Humidity: 65.2% | Voltage: 228V
[DATA] Water Level: 72.5% (204.3L) | Gas: 350 | Light: 650 lux
[DATA] Motion: No | Relay: [ON, OFF, OFF, ON]
```

## Troubleshooting

| Issue | Solution |
|---|---|
| Upload fails | Press & hold BOOT button during upload |
| WiFi won't connect | Verify SSID/password; ESP32 supports 2.4GHz only |
| MQTT connection refused | Check broker IP, port, credentials |
| DHT22 reads NaN | Check wiring and 10kΩ pull-up resistor |
| HC-SR04 reads 0 | Verify voltage divider on ECHO pin |
| PZEM no readings | Ensure AC load passes through current transformer |

---

*See [Setup](SETUP.md) for Flutter app configuration to connect with ESP32.*
