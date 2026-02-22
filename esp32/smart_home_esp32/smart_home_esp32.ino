/*
 * Smart Home AI - ESP32 Main Controller Firmware
 * ================================================
 * Features:
 *   - DHT22 Temperature & Humidity sensor
 *   - PZEM-004T Voltage/Current/Power monitoring
 *   - HC-SR04 Ultrasonic sensor for water tank level
 *   - Relay control for appliances (4 channels)
 *   - Buzzer alarm system
 *   - WiFi + MQTT communication
 *   - OTA firmware updates
 *   - JSON data publishing
 *   - Deep sleep power management
 *
 * Hardware Connections:
 *   DHT22       -> GPIO 4
 *   HC-SR04 TRIG -> GPIO 5
 *   HC-SR04 ECHO -> GPIO 18
 *   PZEM TX     -> GPIO 16 (Serial2 RX)
 *   PZEM RX     -> GPIO 17 (Serial2 TX)
 *   Relay 1     -> GPIO 25 (Light)
 *   Relay 2     -> GPIO 26 (Fan)
 *   Relay 3     -> GPIO 27 (AC)
 *   Relay 4     -> GPIO 14 (Water Pump)
 *   Buzzer      -> GPIO 32
 *   Status LED  -> GPIO 2 (Built-in)
 *   Motion PIR  -> GPIO 33
 *   LDR (Light) -> GPIO 34 (ADC)
 *   Gas Sensor  -> GPIO 35 (ADC)
 */

#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <DHT.h>
#include <PZEM004Tv30.h>
#include <ArduinoOTA.h>
#include <Preferences.h>
#include <time.h>

// ==================== CONFIGURATION ====================

// WiFi Configuration
const char* WIFI_SSID = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

// MQTT Configuration
const char* MQTT_SERVER = "YOUR_MQTT_BROKER_IP";
const int MQTT_PORT = 1883;
const char* MQTT_USER = "smarthome";
const char* MQTT_PASSWORD = "smarthome_password";
const char* DEVICE_ID = "esp32_node_01";

// MQTT Topics
#define TOPIC_SENSOR_DATA    "smarthome/sensors/data"
#define TOPIC_DEVICE_STATUS  "smarthome/devices/status"
#define TOPIC_DEVICE_CONTROL "smarthome/devices/control"
#define TOPIC_ALERTS         "smarthome/alerts"
#define TOPIC_SYSTEM         "smarthome/system"
#define TOPIC_OTA            "smarthome/ota"

// Pin Definitions
#define DHT_PIN        4
#define DHT_TYPE       DHT22
#define TRIG_PIN       5
#define ECHO_PIN       18
#define PZEM_RX        16
#define PZEM_TX        17
#define RELAY_1        25   // Light
#define RELAY_2        26   // Fan
#define RELAY_3        27   // AC
#define RELAY_4        14   // Water Pump
#define BUZZER_PIN     32
#define STATUS_LED     2
#define PIR_PIN        33
#define LDR_PIN        34
#define GAS_PIN        35

// Thresholds
#define TEMP_HIGH_THRESHOLD     40.0
#define TEMP_LOW_THRESHOLD      10.0
#define HUMIDITY_HIGH_THRESHOLD 80.0
#define VOLTAGE_HIGH_THRESHOLD  250.0
#define VOLTAGE_LOW_THRESHOLD   190.0
#define CURRENT_HIGH_THRESHOLD  15.0
#define WATER_LOW_THRESHOLD     15.0   // percentage
#define WATER_CRITICAL_THRESHOLD 5.0
#define WATER_FULL_THRESHOLD    95.0
#define GAS_THRESHOLD           2000

// Tank dimensions (cm)
#define TANK_HEIGHT    100.0
#define TANK_DIAMETER  60.0
#define SENSOR_OFFSET  5.0     // distance from sensor to full tank

// Timing
#define SENSOR_READ_INTERVAL   2000    // 2 seconds
#define MQTT_PUBLISH_INTERVAL  3000    // 3 seconds
#define WIFI_RETRY_INTERVAL    5000    // 5 seconds
#define HEARTBEAT_INTERVAL     30000   // 30 seconds
#define WATCHDOG_TIMEOUT       60000   // 60 seconds

// ==================== OBJECTS ====================

DHT dht(DHT_PIN, DHT_TYPE);
HardwareSerial PZEMSerial(2);
PZEM004Tv30 pzem(PZEMSerial, PZEM_RX, PZEM_TX);
WiFiClient espClient;
PubSubClient mqtt(espClient);
Preferences preferences;

// ==================== DATA STRUCTURES ====================

struct SensorData {
  float temperature;
  float humidity;
  float voltage;
  float current;
  float power;
  float energy;
  float powerFactor;
  float frequency;
  float waterLevel;       // percentage
  float waterDistance;     // cm
  float waterVolume;      // liters
  int lightLevel;         // 0-4095
  int gasLevel;           // 0-4095
  bool motionDetected;
  bool isValid;
};

struct DeviceState {
  bool relay1;    // Light
  bool relay2;    // Fan
  bool relay3;    // AC
  bool relay4;    // Water Pump
  bool buzzer;
  int fanSpeed;   // 0-255 PWM
  int brightness; // 0-255 PWM
};

struct AlertState {
  bool tempHigh;
  bool tempLow;
  bool humidityHigh;
  bool voltageHigh;
  bool voltageLow;
  bool currentHigh;
  bool waterLow;
  bool waterCritical;
  bool gasDetected;
  bool motionAlert;
};

// ==================== GLOBAL VARIABLES ====================

SensorData sensorData;
DeviceState deviceState;
AlertState alertState;

unsigned long lastSensorRead = 0;
unsigned long lastMqttPublish = 0;
unsigned long lastHeartbeat = 0;
unsigned long lastWifiRetry = 0;
unsigned long lastWatchdog = 0;

bool wifiConnected = false;
bool mqttConnected = false;
int reconnectCount = 0;
unsigned long uptimeStart = 0;

// Ultrasonic averaging
#define US_SAMPLES 5
float usReadings[US_SAMPLES];
int usIndex = 0;

// ==================== SETUP ====================

void setup() {
  Serial.begin(115200);
  Serial.println("\n========================================");
  Serial.println("  Smart Home AI - ESP32 Controller v1.0");
  Serial.println("========================================\n");

  // Initialize pins
  setupPins();

  // Initialize sensors
  dht.begin();

  // Initialize NVS preferences
  preferences.begin("smarthome", false);
  loadDeviceState();

  // Initialize WiFi
  setupWiFi();

  // Initialize MQTT
  mqtt.setServer(MQTT_SERVER, MQTT_PORT);
  mqtt.setCallback(mqttCallback);
  mqtt.setBufferSize(1024);

  // Initialize OTA
  setupOTA();

  // Initialize time
  configTime(19800, 0, "pool.ntp.org", "time.nist.gov"); // IST (UTC+5:30)

  uptimeStart = millis();

  // Status LED blink to indicate ready
  for (int i = 0; i < 3; i++) {
    digitalWrite(STATUS_LED, HIGH);
    delay(100);
    digitalWrite(STATUS_LED, LOW);
    delay(100);
  }

  Serial.println("[SETUP] Initialization complete!\n");
}

// ==================== MAIN LOOP ====================

void loop() {
  unsigned long currentMillis = millis();

  // Handle WiFi reconnection
  if (WiFi.status() != WL_CONNECTED) {
    wifiConnected = false;
    if (currentMillis - lastWifiRetry >= WIFI_RETRY_INTERVAL) {
      lastWifiRetry = currentMillis;
      reconnectWiFi();
    }
  } else {
    wifiConnected = true;
  }

  // Handle MQTT
  if (wifiConnected) {
    if (!mqtt.connected()) {
      mqttConnected = false;
      reconnectMQTT();
    }
    mqtt.loop();
  }

  // Read sensors
  if (currentMillis - lastSensorRead >= SENSOR_READ_INTERVAL) {
    lastSensorRead = currentMillis;
    readAllSensors();
    checkAlerts();
  }

  // Publish data
  if (currentMillis - lastMqttPublish >= MQTT_PUBLISH_INTERVAL) {
    lastMqttPublish = currentMillis;
    publishSensorData();
    publishDeviceStatus();
  }

  // Heartbeat
  if (currentMillis - lastHeartbeat >= HEARTBEAT_INTERVAL) {
    lastHeartbeat = currentMillis;
    publishHeartbeat();
  }

  // Auto water pump control
  autoWaterPumpControl();

  // Handle OTA
  ArduinoOTA.handle();

  // Status LED indicator
  updateStatusLED();
}

// ==================== PIN SETUP ====================

void setupPins() {
  // Relay outputs (active LOW)
  pinMode(RELAY_1, OUTPUT);
  pinMode(RELAY_2, OUTPUT);
  pinMode(RELAY_3, OUTPUT);
  pinMode(RELAY_4, OUTPUT);
  digitalWrite(RELAY_1, HIGH);
  digitalWrite(RELAY_2, HIGH);
  digitalWrite(RELAY_3, HIGH);
  digitalWrite(RELAY_4, HIGH);

  // Buzzer
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);

  // Status LED
  pinMode(STATUS_LED, OUTPUT);
  digitalWrite(STATUS_LED, LOW);

  // Ultrasonic
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  // PIR Motion
  pinMode(PIR_PIN, INPUT);

  // ADC
  analogReadResolution(12);

  Serial.println("[PINS] All pins configured.");
}

// ==================== WIFI ====================

void setupWiFi() {
  Serial.printf("[WIFI] Connecting to %s", WIFI_SSID);
  WiFi.mode(WIFI_STA);
  WiFi.setHostname("SmartHome-ESP32");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    wifiConnected = true;
    Serial.println("\n[WIFI] Connected!");
    Serial.printf("[WIFI] IP: %s\n", WiFi.localIP().toString().c_str());
    Serial.printf("[WIFI] RSSI: %d dBm\n", WiFi.RSSI());
  } else {
    Serial.println("\n[WIFI] Connection failed. Will retry in loop.");
  }
}

void reconnectWiFi() {
  Serial.println("[WIFI] Reconnecting...");
  WiFi.disconnect();
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
}

// ==================== MQTT ====================

void reconnectMQTT() {
  if (!mqtt.connected()) {
    Serial.println("[MQTT] Connecting...");

    String clientId = "SmartHome-";
    clientId += String(DEVICE_ID);

    if (mqtt.connect(clientId.c_str(), MQTT_USER, MQTT_PASSWORD)) {
      mqttConnected = true;
      reconnectCount = 0;
      Serial.println("[MQTT] Connected!");

      // Subscribe to control topics
      mqtt.subscribe(TOPIC_DEVICE_CONTROL);
      mqtt.subscribe(TOPIC_OTA);
      mqtt.subscribe("smarthome/devices/+/set");

      // Publish online status
      StaticJsonDocument<128> doc;
      doc["device_id"] = DEVICE_ID;
      doc["status"] = "online";
      doc["ip"] = WiFi.localIP().toString();
      char buffer[128];
      serializeJson(doc, buffer);
      mqtt.publish(TOPIC_SYSTEM, buffer, true);

    } else {
      reconnectCount++;
      Serial.printf("[MQTT] Failed, rc=%d. Retry #%d\n", mqtt.state(), reconnectCount);
    }
  }
}

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  char message[length + 1];
  memcpy(message, payload, length);
  message[length] = '\0';

  Serial.printf("[MQTT] Topic: %s\n", topic);
  Serial.printf("[MQTT] Message: %s\n", message);

  StaticJsonDocument<512> doc;
  DeserializationError error = deserializeJson(doc, message);
  if (error) {
    Serial.printf("[MQTT] JSON parse error: %s\n", error.c_str());
    return;
  }

  String topicStr = String(topic);

  // Device control commands
  if (topicStr == TOPIC_DEVICE_CONTROL || topicStr.startsWith("smarthome/devices/")) {
    handleDeviceControl(doc);
  }

  // OTA command
  if (topicStr == TOPIC_OTA) {
    if (doc["command"] == "restart") {
      Serial.println("[OTA] Restart command received.");
      ESP.restart();
    }
  }
}

void handleDeviceControl(StaticJsonDocument<512>& doc) {
  const char* device = doc["device"];
  const char* action = doc["action"];
  int value = doc["value"] | -1;

  if (!device || !action) return;

  String dev = String(device);
  String act = String(action);

  if (dev == "relay1" || dev == "light") {
    if (act == "on") setRelay(1, true);
    else if (act == "off") setRelay(1, false);
    else if (act == "toggle") setRelay(1, !deviceState.relay1);
    if (value >= 0 && value <= 255) {
      deviceState.brightness = value;
      // PWM dimming could be implemented with MOSFET
    }
  }
  else if (dev == "relay2" || dev == "fan") {
    if (act == "on") setRelay(2, true);
    else if (act == "off") setRelay(2, false);
    else if (act == "toggle") setRelay(2, !deviceState.relay2);
    if (value >= 0 && value <= 255) {
      deviceState.fanSpeed = value;
    }
  }
  else if (dev == "relay3" || dev == "ac") {
    if (act == "on") setRelay(3, true);
    else if (act == "off") setRelay(3, false);
    else if (act == "toggle") setRelay(3, !deviceState.relay3);
  }
  else if (dev == "relay4" || dev == "pump" || dev == "water_pump") {
    if (act == "on") setRelay(4, true);
    else if (act == "off") setRelay(4, false);
    else if (act == "toggle") setRelay(4, !deviceState.relay4);
  }
  else if (dev == "buzzer") {
    if (act == "on") setBuzzer(true);
    else if (act == "off") setBuzzer(false);
    else if (act == "beep") {
      int count = doc["count"] | 3;
      int duration = doc["duration"] | 200;
      buzzerBeep(count, duration);
    }
    else if (act == "alarm") {
      buzzerAlarm();
    }
  }
  else if (dev == "all") {
    if (act == "off") {
      setRelay(1, false);
      setRelay(2, false);
      setRelay(3, false);
      setRelay(4, false);
      setBuzzer(false);
    }
  }

  // Save state to NVS
  saveDeviceState();

  // Publish updated status
  publishDeviceStatus();
}

// ==================== RELAY CONTROL ====================

void setRelay(int relay, bool state) {
  // Relays are active LOW
  int pin;
  switch (relay) {
    case 1: pin = RELAY_1; deviceState.relay1 = state; break;
    case 2: pin = RELAY_2; deviceState.relay2 = state; break;
    case 3: pin = RELAY_3; deviceState.relay3 = state; break;
    case 4: pin = RELAY_4; deviceState.relay4 = state; break;
    default: return;
  }
  digitalWrite(pin, state ? LOW : HIGH);
  Serial.printf("[RELAY] Relay %d: %s\n", relay, state ? "ON" : "OFF");
}

void setBuzzer(bool state) {
  deviceState.buzzer = state;
  if (state) {
    tone(BUZZER_PIN, 2000);
  } else {
    noTone(BUZZER_PIN);
  }
  Serial.printf("[BUZZER] %s\n", state ? "ON" : "OFF");
}

void buzzerBeep(int count, int duration) {
  for (int i = 0; i < count; i++) {
    tone(BUZZER_PIN, 2000);
    delay(duration);
    noTone(BUZZER_PIN);
    delay(duration / 2);
  }
}

void buzzerAlarm() {
  for (int freq = 500; freq <= 3000; freq += 100) {
    tone(BUZZER_PIN, freq);
    delay(20);
  }
  for (int freq = 3000; freq >= 500; freq -= 100) {
    tone(BUZZER_PIN, freq);
    delay(20);
  }
  noTone(BUZZER_PIN);
}

// ==================== SENSOR READING ====================

void readAllSensors() {
  sensorData.isValid = true;

  // Read DHT22
  readDHT();

  // Read PZEM
  readPZEM();

  // Read Ultrasonic
  readUltrasonic();

  // Read ADC sensors
  readAnalogSensors();

  // Read motion
  sensorData.motionDetected = digitalRead(PIR_PIN) == HIGH;

  // Print readings
  printSensorData();
}

void readDHT() {
  float t = dht.readTemperature();
  float h = dht.readHumidity();

  if (!isnan(t) && !isnan(h)) {
    sensorData.temperature = t;
    sensorData.humidity = h;
  } else {
    Serial.println("[DHT] Read error!");
  }
}

void readPZEM() {
  float v = pzem.voltage();
  float c = pzem.current();
  float p = pzem.power();
  float e = pzem.energy();
  float pf = pzem.pf();
  float f = pzem.frequency();

  if (!isnan(v)) sensorData.voltage = v;
  if (!isnan(c)) sensorData.current = c;
  if (!isnan(p)) sensorData.power = p;
  if (!isnan(e)) sensorData.energy = e;
  if (!isnan(pf)) sensorData.powerFactor = pf;
  if (!isnan(f)) sensorData.frequency = f;
}

void readUltrasonic() {
  // Send trigger pulse
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  // Read echo
  long duration = pulseIn(ECHO_PIN, HIGH, 30000); // 30ms timeout
  float distance = duration * 0.034 / 2.0;

  // Validate reading
  if (distance > 0 && distance < TANK_HEIGHT + SENSOR_OFFSET + 10) {
    // Moving average filter
    usReadings[usIndex] = distance;
    usIndex = (usIndex + 1) % US_SAMPLES;

    float avgDistance = 0;
    for (int i = 0; i < US_SAMPLES; i++) {
      avgDistance += usReadings[i];
    }
    avgDistance /= US_SAMPLES;

    sensorData.waterDistance = avgDistance;

    // Calculate water level percentage
    float waterHeight = TANK_HEIGHT - (avgDistance - SENSOR_OFFSET);
    if (waterHeight < 0) waterHeight = 0;
    if (waterHeight > TANK_HEIGHT) waterHeight = TANK_HEIGHT;

    sensorData.waterLevel = (waterHeight / TANK_HEIGHT) * 100.0;

    // Calculate volume (cylindrical tank in liters)
    float radius = TANK_DIAMETER / 2.0;
    float volumeCm3 = 3.14159 * radius * radius * waterHeight;
    sensorData.waterVolume = volumeCm3 / 1000.0; // cm³ to liters
  }
}

void readAnalogSensors() {
  // LDR - Light level (0-4095)
  sensorData.lightLevel = analogRead(LDR_PIN);

  // Gas sensor (MQ-2/MQ-5) - (0-4095)
  sensorData.gasLevel = analogRead(GAS_PIN);
}

void printSensorData() {
  Serial.println("--- Sensor Readings ---");
  Serial.printf("  Temp: %.1f°C  Humidity: %.1f%%\n",
                sensorData.temperature, sensorData.humidity);
  Serial.printf("  Voltage: %.1fV  Current: %.2fA  Power: %.1fW\n",
                sensorData.voltage, sensorData.current, sensorData.power);
  Serial.printf("  Water: %.1f%%  Distance: %.1fcm  Volume: %.1fL\n",
                sensorData.waterLevel, sensorData.waterDistance, sensorData.waterVolume);
  Serial.printf("  Light: %d  Gas: %d  Motion: %s\n",
                sensorData.lightLevel, sensorData.gasLevel,
                sensorData.motionDetected ? "YES" : "no");
  Serial.println("-----------------------");
}

// ==================== ALERT CHECKING ====================

void checkAlerts() {
  bool alertTriggered = false;

  // Temperature alerts
  if (sensorData.temperature > TEMP_HIGH_THRESHOLD && !alertState.tempHigh) {
    alertState.tempHigh = true;
    publishAlert("temperature_high", "High temperature detected!",
                 String(sensorData.temperature, 1) + "°C exceeds threshold");
    alertTriggered = true;
  } else if (sensorData.temperature <= TEMP_HIGH_THRESHOLD - 2) {
    alertState.tempHigh = false;
  }

  if (sensorData.temperature < TEMP_LOW_THRESHOLD && !alertState.tempLow) {
    alertState.tempLow = true;
    publishAlert("temperature_low", "Low temperature detected!",
                 String(sensorData.temperature, 1) + "°C below threshold");
    alertTriggered = true;
  } else if (sensorData.temperature >= TEMP_LOW_THRESHOLD + 2) {
    alertState.tempLow = false;
  }

  // Humidity alert
  if (sensorData.humidity > HUMIDITY_HIGH_THRESHOLD && !alertState.humidityHigh) {
    alertState.humidityHigh = true;
    publishAlert("humidity_high", "High humidity!",
                 String(sensorData.humidity, 1) + "% exceeds threshold");
    alertTriggered = true;
  } else if (sensorData.humidity <= HUMIDITY_HIGH_THRESHOLD - 5) {
    alertState.humidityHigh = false;
  }

  // Voltage alerts
  if (sensorData.voltage > VOLTAGE_HIGH_THRESHOLD && !alertState.voltageHigh) {
    alertState.voltageHigh = true;
    publishAlert("voltage_high", "High voltage alert!",
                 String(sensorData.voltage, 1) + "V - Risk of damage!");
    alertTriggered = true;
  } else if (sensorData.voltage <= VOLTAGE_HIGH_THRESHOLD - 5) {
    alertState.voltageHigh = false;
  }

  if (sensorData.voltage < VOLTAGE_LOW_THRESHOLD && sensorData.voltage > 0 && !alertState.voltageLow) {
    alertState.voltageLow = true;
    publishAlert("voltage_low", "Low voltage alert!",
                 String(sensorData.voltage, 1) + "V - Undervoltage condition");
    alertTriggered = true;
  } else if (sensorData.voltage >= VOLTAGE_LOW_THRESHOLD + 5) {
    alertState.voltageLow = false;
  }

  // Current alert
  if (sensorData.current > CURRENT_HIGH_THRESHOLD && !alertState.currentHigh) {
    alertState.currentHigh = true;
    publishAlert("current_high", "High current draw!",
                 String(sensorData.current, 2) + "A - Possible overload!");
    buzzerBeep(5, 100);
    alertTriggered = true;
  } else if (sensorData.current <= CURRENT_HIGH_THRESHOLD - 2) {
    alertState.currentHigh = false;
  }

  // Water level alerts
  if (sensorData.waterLevel < WATER_CRITICAL_THRESHOLD && !alertState.waterCritical) {
    alertState.waterCritical = true;
    publishAlert("water_critical", "CRITICAL: Water tank almost empty!",
                 String(sensorData.waterLevel, 1) + "% - Immediate action required");
    buzzerAlarm();
    alertTriggered = true;
  } else if (sensorData.waterLevel >= WATER_CRITICAL_THRESHOLD + 5) {
    alertState.waterCritical = false;
  }

  if (sensorData.waterLevel < WATER_LOW_THRESHOLD && !alertState.waterLow) {
    alertState.waterLow = true;
    publishAlert("water_low", "Water tank level low!",
                 String(sensorData.waterLevel, 1) + "% remaining");
    alertTriggered = true;
  } else if (sensorData.waterLevel >= WATER_LOW_THRESHOLD + 10) {
    alertState.waterLow = false;
  }

  // Gas alert
  if (sensorData.gasLevel > GAS_THRESHOLD && !alertState.gasDetected) {
    alertState.gasDetected = true;
    publishAlert("gas_detected", "GAS LEAK DETECTED!",
                 "Gas level: " + String(sensorData.gasLevel) + " - Evacuate immediately!");
    buzzerAlarm();
    // Auto turn off appliances for safety
    setRelay(1, false);
    setRelay(2, false);
    setRelay(3, false);
    alertTriggered = true;
  } else if (sensorData.gasLevel <= GAS_THRESHOLD - 500) {
    alertState.gasDetected = false;
  }

  // Motion alert (if armed)
  if (sensorData.motionDetected && !alertState.motionAlert) {
    alertState.motionAlert = true;
    publishAlert("motion", "Motion detected!", "Movement in monitored area");
  } else if (!sensorData.motionDetected) {
    alertState.motionAlert = false;
  }

  if (alertTriggered) {
    digitalWrite(STATUS_LED, HIGH);
  }
}

// ==================== AUTO WATER PUMP ====================

void autoWaterPumpControl() {
  // Auto-fill when water level is critically low
  if (sensorData.waterLevel < WATER_LOW_THRESHOLD && !deviceState.relay4) {
    Serial.println("[AUTO] Water pump ON - Level low");
    setRelay(4, true);
    publishAlert("pump_auto_on", "Water pump auto-activated",
                 "Water level at " + String(sensorData.waterLevel, 1) + "%");
  }

  // Auto-stop when tank is full
  if (sensorData.waterLevel >= WATER_FULL_THRESHOLD && deviceState.relay4) {
    Serial.println("[AUTO] Water pump OFF - Tank full");
    setRelay(4, false);
    publishAlert("pump_auto_off", "Water pump auto-stopped",
                 "Tank is full at " + String(sensorData.waterLevel, 1) + "%");
  }
}

// ==================== MQTT PUBLISHING ====================

void publishSensorData() {
  if (!mqttConnected) return;

  StaticJsonDocument<768> doc;

  doc["device_id"] = DEVICE_ID;
  doc["timestamp"] = getTimestamp();

  JsonObject sensors = doc.createNestedObject("sensors");

  JsonObject temp = sensors.createNestedObject("temperature");
  temp["value"] = round2(sensorData.temperature);
  temp["unit"] = "°C";

  JsonObject hum = sensors.createNestedObject("humidity");
  hum["value"] = round2(sensorData.humidity);
  hum["unit"] = "%";

  JsonObject volt = sensors.createNestedObject("voltage");
  volt["value"] = round2(sensorData.voltage);
  volt["unit"] = "V";

  JsonObject curr = sensors.createNestedObject("current");
  curr["value"] = round2(sensorData.current);
  curr["unit"] = "A";

  JsonObject pwr = sensors.createNestedObject("power");
  pwr["value"] = round2(sensorData.power);
  pwr["unit"] = "W";

  JsonObject engy = sensors.createNestedObject("energy");
  engy["value"] = round2(sensorData.energy);
  engy["unit"] = "kWh";

  JsonObject pf = sensors.createNestedObject("power_factor");
  pf["value"] = round2(sensorData.powerFactor);

  JsonObject freq = sensors.createNestedObject("frequency");
  freq["value"] = round2(sensorData.frequency);
  freq["unit"] = "Hz";

  JsonObject water = sensors.createNestedObject("water");
  water["level"] = round2(sensorData.waterLevel);
  water["distance"] = round2(sensorData.waterDistance);
  water["volume"] = round2(sensorData.waterVolume);
  water["unit"] = "%";

  sensors["light"] = sensorData.lightLevel;
  sensors["gas"] = sensorData.gasLevel;
  sensors["motion"] = sensorData.motionDetected;

  char buffer[768];
  serializeJson(doc, buffer);
  mqtt.publish(TOPIC_SENSOR_DATA, buffer);
}

void publishDeviceStatus() {
  if (!mqttConnected) return;

  StaticJsonDocument<384> doc;

  doc["device_id"] = DEVICE_ID;
  doc["timestamp"] = getTimestamp();

  JsonObject devices = doc.createNestedObject("devices");

  JsonObject light = devices.createNestedObject("light");
  light["state"] = deviceState.relay1;
  light["brightness"] = deviceState.brightness;

  JsonObject fan = devices.createNestedObject("fan");
  fan["state"] = deviceState.relay2;
  fan["speed"] = deviceState.fanSpeed;

  JsonObject ac = devices.createNestedObject("ac");
  ac["state"] = deviceState.relay3;

  JsonObject pump = devices.createNestedObject("water_pump");
  pump["state"] = deviceState.relay4;

  JsonObject buzz = devices.createNestedObject("buzzer");
  buzz["state"] = deviceState.buzzer;

  char buffer[384];
  serializeJson(doc, buffer);
  mqtt.publish(TOPIC_DEVICE_STATUS, buffer, true);
}

void publishAlert(const char* type, const char* title, String message) {
  if (!mqttConnected) return;

  StaticJsonDocument<384> doc;
  doc["device_id"] = DEVICE_ID;
  doc["type"] = type;
  doc["title"] = title;
  doc["message"] = message;
  doc["timestamp"] = getTimestamp();
  doc["severity"] = getSeverity(type);

  char buffer[384];
  serializeJson(doc, buffer);
  mqtt.publish(TOPIC_ALERTS, buffer);

  Serial.printf("[ALERT] %s: %s - %s\n", type, title, message.c_str());
}

void publishHeartbeat() {
  if (!mqttConnected) return;

  StaticJsonDocument<256> doc;
  doc["device_id"] = DEVICE_ID;
  doc["status"] = "online";
  doc["uptime"] = (millis() - uptimeStart) / 1000;
  doc["rssi"] = WiFi.RSSI();
  doc["free_heap"] = ESP.getFreeHeap();
  doc["ip"] = WiFi.localIP().toString();
  doc["firmware"] = "1.0.0";
  doc["reconnects"] = reconnectCount;

  char buffer[256];
  serializeJson(doc, buffer);
  mqtt.publish(TOPIC_SYSTEM, buffer, true);
}

// ==================== OTA ====================

void setupOTA() {
  ArduinoOTA.setHostname("SmartHome-ESP32");
  ArduinoOTA.setPassword("smarthome_ota");

  ArduinoOTA.onStart([]() {
    Serial.println("[OTA] Update starting...");
    // Turn off all relays during update
    setRelay(1, false);
    setRelay(2, false);
    setRelay(3, false);
    setRelay(4, false);
    setBuzzer(false);
  });

  ArduinoOTA.onEnd([]() {
    Serial.println("\n[OTA] Update complete!");
  });

  ArduinoOTA.onProgress([](unsigned int progress, unsigned int total) {
    Serial.printf("[OTA] Progress: %u%%\r", (progress / (total / 100)));
  });

  ArduinoOTA.onError([](ota_error_t error) {
    Serial.printf("[OTA] Error[%u]: ", error);
    if (error == OTA_AUTH_ERROR) Serial.println("Auth Failed");
    else if (error == OTA_BEGIN_ERROR) Serial.println("Begin Failed");
    else if (error == OTA_CONNECT_ERROR) Serial.println("Connect Failed");
    else if (error == OTA_RECEIVE_ERROR) Serial.println("Receive Failed");
    else if (error == OTA_END_ERROR) Serial.println("End Failed");
  });

  ArduinoOTA.begin();
  Serial.println("[OTA] Ready");
}

// ==================== NVS PERSISTENCE ====================

void saveDeviceState() {
  preferences.putBool("relay1", deviceState.relay1);
  preferences.putBool("relay2", deviceState.relay2);
  preferences.putBool("relay3", deviceState.relay3);
  preferences.putBool("relay4", deviceState.relay4);
  preferences.putInt("brightness", deviceState.brightness);
  preferences.putInt("fanSpeed", deviceState.fanSpeed);
}

void loadDeviceState() {
  deviceState.relay1 = preferences.getBool("relay1", false);
  deviceState.relay2 = preferences.getBool("relay2", false);
  deviceState.relay3 = preferences.getBool("relay3", false);
  deviceState.relay4 = preferences.getBool("relay4", false);
  deviceState.brightness = preferences.getInt("brightness", 255);
  deviceState.fanSpeed = preferences.getInt("fanSpeed", 255);
  deviceState.buzzer = false;

  // Apply saved state to relays
  digitalWrite(RELAY_1, deviceState.relay1 ? LOW : HIGH);
  digitalWrite(RELAY_2, deviceState.relay2 ? LOW : HIGH);
  digitalWrite(RELAY_3, deviceState.relay3 ? LOW : HIGH);
  digitalWrite(RELAY_4, deviceState.relay4 ? LOW : HIGH);

  Serial.println("[NVS] Device state loaded.");
}

// ==================== STATUS LED ====================

void updateStatusLED() {
  static unsigned long lastBlink = 0;
  static bool ledState = false;

  if (!wifiConnected) {
    // Fast blink - no WiFi
    if (millis() - lastBlink >= 200) {
      lastBlink = millis();
      ledState = !ledState;
      digitalWrite(STATUS_LED, ledState);
    }
  } else if (!mqttConnected) {
    // Slow blink - no MQTT
    if (millis() - lastBlink >= 1000) {
      lastBlink = millis();
      ledState = !ledState;
      digitalWrite(STATUS_LED, ledState);
    }
  } else {
    // Solid dim - all connected
    digitalWrite(STATUS_LED, HIGH);
  }
}

// ==================== UTILITIES ====================

float round2(float val) {
  return round(val * 100.0) / 100.0;
}

String getTimestamp() {
  time_t now;
  time(&now);
  char buf[25];
  strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%S", localtime(&now));
  return String(buf);
}

const char* getSeverity(const char* alertType) {
  String type = String(alertType);
  if (type.indexOf("critical") >= 0 || type.indexOf("gas") >= 0) return "critical";
  if (type.indexOf("high") >= 0 || type.indexOf("low") >= 0) return "warning";
  return "info";
}
