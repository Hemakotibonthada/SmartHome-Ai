# Features Guide

A comprehensive walkthrough of every feature module in SmartHome AI.

---

## 1. Authentication & Onboarding

### Splash Screen
- Animated logo with Lottie animation
- Auto-navigation to login or home based on auth state

### Login Screen
- Email/password authentication
- Demo mode for quick exploration
- Responsive layout (mobile card / web split-panel)
- Input validation and error feedback

### User Roles
| Role | Dashboard | Devices | Analytics | Admin Panel | Settings |
|---|---|---|---|---|---|
| Admin | ✅ | ✅ Full control | ✅ | ✅ | ✅ |
| User | ✅ | ✅ Full control | ✅ | ❌ | ✅ |
| Guest | ✅ View-only | ✅ View-only | ❌ | ❌ | Limited |

---

## 2. Landing Page

A marketing-style landing page with:
- **Hero section** — Animated headline, call-to-action buttons
- **Feature highlights** — 6 key features with icons
- **How it works** — 3-step setup guide
- **Pricing plans** — Free, Pro, Enterprise tiers
- **Testimonials** — Customer reviews carousel
- **Footer** — Links, social media, newsletter

---

## 3. Dashboard

The main control center with 5 widget cards:

### Sensor Summary Widget
- Real-time display of all sensor readings
- Color-coded status indicators (normal/warning/critical)
- Animated value transitions
- Sensors: Temperature, Humidity, Voltage, Current, Power, Water Level

### Water Tank Widget
- Custom wave animation (WavePainter)
- Fill percentage with color gradient (blue → red as level drops)
- Capacity in liters
- Auto-pump status indicator

### Energy Monitor Widget
- Live power consumption (watts)
- Daily/monthly cost tracker
- Usage trend sparkline chart
- Cost comparison with previous period

### Quick Actions Widget
- Toggle grid for frequently used devices
- One-tap on/off for lights, fan, AC, pump
- Animated switch states
- Device status badges

### AI Insights Widget
- Latest AI-generated recommendations
- Confidence scores per insight
- Categories: Energy, Comfort, Security, Maintenance
- Tap to view detailed analysis

---

## 4. Device Management

### Devices Screen
- Grid and list view toggle
- Filter by room and device type
- Online/offline status indicators
- Quick toggle from the device card
- Pull-to-refresh

### Device Detail (3-Tab View)

**Controls Tab:**
- Power toggle
- Value slider (brightness/speed/temperature)
- Schedule quick-add
- Device properties

**History Tab:**
- Usage timeline chart
- Daily on/off patterns
- Energy consumption history

**Settings Tab:**
- Rename device
- Change room assignment
- Set automation rules
- Firmware version info

### Device Hub (12 Device Categories)

| Category | Controls |
|---|---|
| **Lights** | On/off, brightness, color temperature |
| **Fans** | On/off, speed (1-5) |
| **Air Conditioning** | On/off, temperature, mode (cool/heat/auto) |
| **Thermostats** | Target temp, schedule, mode |
| **Security Cameras** | Live feed, recording, motion zones |
| **Smart Locks** | Lock/unlock, access log, guest codes |
| **Sensors** | View readings, set thresholds, alerts |
| **Water Pump** | On/off, auto mode, schedule |
| **Smart Plugs** | On/off, energy monitoring |
| **Speakers** | Volume, playback, announcements |
| **Smart TVs** | Power, volume, input selection |
| **Smart Blinds** | Position (0-100%), tilt, sun tracking |

---

## 5. Sensor Monitoring

### Sensor Screen
- **Radial gauges** (Syncfusion) for each sensor type
- **Real-time charts** (fl_chart) with historical data
- **Statistics panel** — min, max, average, trend
- **Alert thresholds** — visual indicators when exceeded
- Time range selector (1H, 6H, 24H, 7D, 30D)

### Monitored Sensors

| Sensor | Unit | Range | Source |
|---|---|---|---|
| Temperature | °C | 10–50 | DHT22 |
| Humidity | % | 0–100 | DHT22 |
| Voltage | V | 0–300 | PZEM-004T |
| Current | A | 0–30 | PZEM-004T |
| Power | W | 0–5000 | PZEM-004T |
| Water Level | % | 0–100 | HC-SR04 |
| Motion | boolean | — | PIR HC-SR501 |
| Gas Level | ADC | 0–5000 | MQ-2 |
| Light Level | lux | 0–1000 | LDR |

---

## 6. Analytics & AI

### Analytics Screen
- Energy consumption trends (hourly/daily/monthly)
- Cost analytics with bill projection
- Device usage rankings
- Carbon footprint estimation
- Exportable reports

### AI Hub
- **Pattern Recognition** — Identifies usage patterns across devices
- **Anomaly Detection** — Flags unusual readings or behavior
- **Predictive Insights** — Forecasts energy use and costs
- **Smart Suggestions** — 20 AI-generated optimization tips
- **Comfort Index** — Overall home comfort score (0-100)
- **Energy Score** — Efficiency rating with improvement tips

### Lifestyle Hub
- Sleep quality tracking and scoring
- Weather-based automation status
- Plant care monitoring
- Wellness metrics

### Security Dashboard
- Camera feed overview
- Recent security events
- Perimeter zone status
- Face recognition log
- Package tracking

### System Management
- System health overview (CPU, RAM, storage)
- Connected device count
- Network status
- Firmware update status
- Error log viewer

---

## 7. Advanced Home Devices

### Robot Vacuum
- Current status (idle, cleaning, charging, returning)
- Battery percentage
- Cleaned area (m²)
- Zone selection and scheduling
- Cleaning history

### Smart Kitchen
- Oven: temperature, timer, preheat status
- Coffee Maker: schedule, brew strength, auto-start
- Fridge: temperature, door alerts, inventory

### EV Charger
- Current charge level (%)
- Charging rate (kW)
- Estimated completion time
- Cost of current session
- Scheduled charging windows

### Pool Management
- Water temperature
- pH level with target range
- Chlorine level
- Pump and heater control
- Filter status

### Baby Monitor
- Audio level meter
- Room temperature & humidity
- Night vision status
- Alert sensitivity settings

### Pet Feeder
- Feeding schedule (up to 6 meals)
- Portion size control
- Food level indicator
- Feeding history log

---

## 8. Scenes & Automation

### Scenes (Preset Configurations)
| Scene | Actions |
|---|---|
| **Good Morning** | Blinds open, lights on 70%, coffee start |
| **Movie Night** | Lights dim 20%, TV on, blinds closed |
| **Away Mode** | All lights off, security armed, cameras active |
| **Good Night** | Lights off, doors locked, thermostat 22°C |
| **Party** | Lights colorful, speakers on, blinds open |
| **Focus** | Lights cool white, notifications muted |

### Routines
- Time-triggered (e.g., 7:00 AM weekdays)
- Sensor-triggered (e.g., motion detected → lights on)
- Location-triggered (e.g., arrive home → unlock door)
- Chain multiple device actions

### Schedules
- Calendar-based device programming
- Recurring schedules (daily, weekly, custom)
- Sunrise/sunset relative timing
- Holiday schedules

---

## 9. Safety & Emergency

### Emergency Panel
- **Panic Button** — One-tap emergency alert
- All doors auto-lock
- All lights flash
- Loud alarm on buzzer
- Emergency contacts notified

### Door/Window Monitoring
- Open/closed status per entry point
- Lock/unlock control
- Activity history

### Safety Modes
| Mode | Behavior |
|---|---|
| **Home** | Normal operation, motion lights active |
| **Away** | Security armed, lights simulated, cameras alert |
| **Night** | Doors locked, perimeter sensors active, lights off |
| **Vacation** | Extended away mode, random light simulation |

### Air Quality Monitoring
- Indoor AQI score
- PM2.5, CO2, VOC levels
- Auto-purifier activation
- Ventilation recommendations

### Geofencing
- Auto-detect arrival/departure
- Configurable radius
- Trigger scenes on enter/exit

---

## 10. Room Management

### Room Screen
- **Temperature Heatmap** — Visual color map across rooms
- **Occupancy Status** — People detected per room
- **Comfort Index** — Per-room comfort score
- **Adaptive Thresholds** — Auto-adjust based on preferences

---

## 11. Energy Analytics

### Energy Screen
- Real-time power draw meter
- Cost breakdown by device
- Solar generation tracking
- Monthly bill estimation
- Water consumption charts
- Community leaderboard
- Appliance fingerprinting (per-device identification)
- Device health scores

---

## 12. Notifications

### Notification Center
- **Filterable** by type (alert, info, warning, success, emergency)
- **Dismissible** cards with swipe
- Timestamp and priority badges
- Tap to navigate to relevant screen
- Mark all as read

---

## 13. Admin Panel (Admin Role Only)

### Admin Overview
- Total users, devices, sensors count
- System uptime and health
- Quick-action tiles

### User Management
- User list with role badges
- Add/edit/delete users
- Role assignment
- Last activity tracking

### AI Model Management
- Model status (active, training, idle)
- Accuracy metrics
- Training data volume
- Model version history

### Security Logs
- Authentication events
- Access violations
- API call log
- IP address tracking

### System Logs
- Application error log
- Performance metrics
- Database operations
- Third-party service status

---

## 14. Settings

- **Profile** — Edit name, email, avatar
- **Theme** — Dark/Light mode toggle
- **Notifications** — Enable/disable push notifications
- **Temperature Unit** — Celsius/Fahrenheit
- **Language** — Localization preference
- **About** — App version, license, credits
- **Logout** — Sign out with confirmation

---

## 15. Data Export

### Export Screen
- Select data type (sensors, devices, energy, all)
- Select format (CSV, JSON, PDF)
- Select time period (24h, 7d, 30d, custom)
- Automated report scheduling
- Download or share

---

## 16. Maintenance Tracking

### Maintenance Screen
- **Overdue** tasks with urgency indicator
- **Upcoming** scheduled maintenance
- **Completed** task history
- Task details: device, description, due date, priority

---

## 17. AI Suggestions

- 20 context-aware AI suggestions
- Categories: Energy, Comfort, Security, Automation, Maintenance
- Confidence score per suggestion
- One-tap **Apply** or **Dismiss**
- Applied suggestions tracker

---

## 18. Activity Log

- System-wide event timeline
- Category filters (security, device, energy, system)
- Timestamp and severity
- Expandable event details

---

## Responsive Design

All features adapt across three form factors:

| Breakpoint | Layout | Navigation |
|---|---|---|
| **Mobile** (< 600px) | Single column, cards | Bottom navigation bar |
| **Tablet** (600–1200px) | 2-column grid | Collapsible sidebar |
| **Desktop** (> 1200px) | Multi-column, data tables | Fixed sidebar + top bar |

---

*See [API Reference](API_REFERENCE.md) for the service layer that powers these features.*
