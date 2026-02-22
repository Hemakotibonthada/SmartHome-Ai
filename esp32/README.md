# Smart Home ESP32 - Arduino IDE Setup

## Required Libraries

Install these libraries via Arduino IDE Library Manager:

1. **PubSubClient** (by Nick O'Leary) - MQTT client
2. **ArduinoJson** (by Benoit Blanchon) v6.x - JSON serialization
3. **DHT sensor library** (by Adafruit) - DHT22 temperature/humidity
4. **Adafruit Unified Sensor** - Required by DHT library
5. **PZEM004Tv30** (by Jakub Mandula) - AC voltage/current sensor

## Board Setup

1. Open Arduino IDE → **File → Preferences**
2. Add this URL to "Additional Board Manager URLs":
   ```
   https://dl.espressif.com/dl/package_esp32_index.json
   ```
3. Go to **Tools → Board → Board Manager**, search "esp32" and install
4. Select **Tools → Board → ESP32 Dev Module**
5. Settings:
   - Upload Speed: 921600
   - CPU Frequency: 240MHz
   - Flash Size: 4MB
   - Partition Scheme: Default 4MB with spiffs

## Wiring Diagram

```
ESP32 Pin    →   Component
─────────────────────────────
GPIO 4       →   DHT22 DATA (with 10K pull-up to 3.3V)
GPIO 5       →   HC-SR04 TRIG
GPIO 18      →   HC-SR04 ECHO (voltage divider: 5V→3.3V)
GPIO 16      →   PZEM-004T TX
GPIO 17      →   PZEM-004T RX
GPIO 25      →   Relay 1 IN (Light)
GPIO 26      →   Relay 2 IN (Fan)
GPIO 27      →   Relay 3 IN (AC)
GPIO 14      →   Relay 4 IN (Water Pump)
GPIO 32      →   Buzzer (+)
GPIO 2       →   Built-in LED
GPIO 33      →   PIR Motion Sensor OUT
GPIO 34      →   LDR (Analog, voltage divider)
GPIO 35      →   Gas Sensor (MQ-2/MQ-5 Analog OUT)

VIN (5V)     →   HC-SR04 VCC, Relay Module VCC
3.3V         →   DHT22 VCC, PIR VCC
GND          →   All GND connections
```

## HC-SR04 Voltage Divider (5V Echo → 3.3V ESP32)

```
HC-SR04 ECHO ──┤
               R1 (1KΩ)
               ├── GPIO 18
               R2 (2KΩ)
               ├── GND
```

## MQTT Topics

| Topic | Direction | Description |
|-------|-----------|-------------|
| `smarthome/sensors/data` | ESP32 → App | Sensor readings (JSON) |
| `smarthome/devices/status` | ESP32 → App | Device ON/OFF states |
| `smarthome/devices/control` | App → ESP32 | Control commands |
| `smarthome/alerts` | ESP32 → App | Alert notifications |
| `smarthome/system` | ESP32 → App | Heartbeat & system info |

## Control Command Examples

### Turn on light:
```json
{
  "device": "light",
  "action": "on"
}
```

### Set fan speed:
```json
{
  "device": "fan",
  "action": "on",
  "value": 128
}
```

### Buzzer beep:
```json
{
  "device": "buzzer",
  "action": "beep",
  "count": 3,
  "duration": 200
}
```

### Emergency all off:
```json
{
  "device": "all",
  "action": "off"
}
```

## Sensor Data JSON Format

```json
{
  "device_id": "esp32_node_01",
  "timestamp": "2024-01-15T10:30:00",
  "sensors": {
    "temperature": { "value": 28.5, "unit": "°C" },
    "humidity": { "value": 65.2, "unit": "%" },
    "voltage": { "value": 230.5, "unit": "V" },
    "current": { "value": 2.35, "unit": "A" },
    "power": { "value": 541.7, "unit": "W" },
    "energy": { "value": 12.45, "unit": "kWh" },
    "power_factor": { "value": 0.98 },
    "frequency": { "value": 50.01, "unit": "Hz" },
    "water": { "level": 72.5, "distance": 32.5, "volume": 205.3 },
    "light": 2048,
    "gas": 350,
    "motion": false
  }
}
```

## Troubleshooting

- **DHT read errors**: Check 10K pull-up resistor on DATA pin
- **No PZEM readings**: Ensure correct TX/RX wiring (cross TX↔RX)
- **Ultrasonic erratic**: Add voltage divider for ECHO, ensure stable 5V
- **WiFi won't connect**: Check SSID/password in config.h
- **MQTT fails**: Verify broker IP, port, and firewall rules
- **Relays clicking randomly**: Add flyback diode, ensure separate power supply

## OTA Updates

Once connected to WiFi, you can update firmware over-the-air:
1. Arduino IDE → **Tools → Port** → select the network port
2. OTA Password: `smarthome_ota`
