/*
 * Smart Home AI - ESP32 Configuration
 * ====================================
 * Edit this file with your network and sensor settings.
 *
 * MQTT Broker: Run the Dart MQTT broker from server/ directory:
 *   cd server && dart run bin/server.dart
 *
 * Set MQTT_SERVER to the IP of the machine running the broker.
 * TCP port 1883 is used by ESP32 (native MQTT).
 * WebSocket port 8083 is used by Flutter Web app.
 *
 * © 2026 Circuvent Technologies Pvt Ltd, Hyderabad
 */

#ifndef CONFIG_H
#define CONFIG_H

// ==================== NETWORK ====================
#define WIFI_SSID          "YOUR_WIFI_SSID"
#define WIFI_PASSWORD      "YOUR_WIFI_PASSWORD"

// MQTT Broker (IP of the machine running server/bin/server.dart)
#define MQTT_SERVER        "192.168.1.100"
#define MQTT_PORT          1883
#define MQTT_USER          "smarthome"
#define MQTT_PASSWORD      "smarthome_password"

// Device Identity
#define DEVICE_ID          "esp32_node_01"
#define DEVICE_NAME        "Living Room Node"
#define FIRMWARE_VERSION   "1.0.0"

// ==================== PIN MAP ====================
// Sensors
#define DHT_PIN            4
#define DHT_TYPE           DHT22
#define TRIG_PIN           5
#define ECHO_PIN           18
#define PZEM_RX_PIN        16
#define PZEM_TX_PIN        17
#define PIR_PIN            33
#define LDR_PIN            34
#define GAS_PIN            35

// Actuators
#define RELAY_1_PIN        25    // Light
#define RELAY_2_PIN        26    // Fan
#define RELAY_3_PIN        27    // AC
#define RELAY_4_PIN        14    // Water Pump
#define BUZZER_PIN         32
#define STATUS_LED_PIN     2

// ==================== THRESHOLDS ====================
#define TEMP_HIGH          40.0   // °C
#define TEMP_LOW           10.0   // °C
#define HUMIDITY_HIGH      80.0   // %
#define VOLTAGE_HIGH       250.0  // V
#define VOLTAGE_LOW        190.0  // V
#define CURRENT_HIGH       15.0   // A
#define WATER_LOW          15.0   // %
#define WATER_CRITICAL     5.0    // %
#define WATER_FULL         95.0   // %
#define GAS_THRESHOLD      2000   // ADC value

// ==================== TANK DIMENSIONS ====================
#define TANK_HEIGHT_CM     100.0
#define TANK_DIAMETER_CM   60.0
#define SENSOR_OFFSET_CM   5.0    // Distance from sensor to full-tank surface

// ==================== TIMING (ms) ====================
#define SENSOR_INTERVAL    2000
#define PUBLISH_INTERVAL   3000
#define HEARTBEAT_INTERVAL 30000
#define WIFI_RETRY_DELAY   5000

// ==================== FEATURES ====================
#define ENABLE_OTA         true
#define ENABLE_AUTO_PUMP   true
#define ENABLE_GAS_SAFETY  true   // Auto-off appliances on gas detection
#define ENABLE_MOTION_LOG  true
#define ENABLE_DEEP_SLEEP  false
#define DEEP_SLEEP_MINUTES 5

// ==================== NTP ====================
#define NTP_SERVER         "pool.ntp.org"
#define GMT_OFFSET_SEC     19800  // IST = UTC+5:30
#define DAYLIGHT_OFFSET    0

#endif // CONFIG_H
