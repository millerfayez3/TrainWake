# 🚆 TRAINWAKE

## Complete Production-Grade Flutter Android Application Specification

You are an expert Flutter/Dart engineer, Android engineer, GIS/geospatial engineer, UX/UI designer, and product engineer.

Your task is to BUILD the complete application described below.

This is NOT a prototype.

This is NOT a mockup.

This is NOT a demo.

This is NOT a collection of fake screens.

Build a real, production-quality Android application with working location tracking, railway route matching, ETA calculation, background execution, alarms, notifications, persistence, localization, RTL, offline functionality, and a polished youthful UI.

The application name is:

# TrainWake

Core concept:

> The user gets on a train, selects the station where they want to get off, starts the trip, locks their phone and sleeps. TrainWake continuously determines the train's position and progress and wakes the user shortly before their destination station.

Arabic brand concept:

> نام وإحنا نصحيك قبل محطتك.

English:

> Sleep. We’ll wake you.

---

# 1. PRODUCT GOAL

TrainWake solves one simple problem:

A passenger is traveling by train, wants to sleep, but is afraid of missing their destination station.

The app should allow the user to:

1. Select their destination station.
2. Select how many minutes before arrival they want to be awakened.
3. Start the trip.
4. Put the phone in their pocket and lock the screen.
5. The app continues monitoring the journey in the background.
6. The app determines the user's position relative to the railway route.
7. The app estimates the remaining time.
8. Shortly before the destination, the app prepares the alarm.
9. The alarm wakes the user.
10. The app detects arrival / possible missed station.
11. The trip is saved locally.

The core philosophy is:

> Reliability > correctness > battery efficiency > UX > visual polish > extra features.

---

# 2. CRITICAL PRODUCT PRINCIPLE

DO NOT build a system that simply calculates:

```text
straight-line GPS distance → destination

```

That is NOT sufficient.

A train travels on railway tracks.

Therefore:

```text
GPS position
        ↓
railway route matching
        ↓
railway route progress
        ↓
destination progress
        ↓
remaining railway distance
        ↓
ETA
        ↓
alarm

```

The application must understand the railway route whenever route data is available.

For example, if the user is physically 8 km away from a station as the crow flies but the railway track requires 14 km of travel, the app must use the railway distance, not the straight-line distance.

---

# 3. PLATFORM

Primary platform:

```text
Android

```

Technology:

```text
Flutter
Dart
Material 3

```

Build for real Android devices.

Do not optimize only for emulator behavior.

Test on physical Android devices.

The app must support modern Android versions compatible with the selected Flutter version and dependencies.

---

# 4. ARCHITECTURE

Use clean, maintainable architecture.

Recommended structure:

```text
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   ├── utils/
│   ├── theme/
│   ├── localization/
│   └── widgets/
│
├── data/
│   ├── models/
│   ├── repositories/
│   ├── datasources/
│   └── local/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
├── features/
│   ├── onboarding/
│   ├── home/
│   ├── station_search/
│   ├── trip_setup/
│   ├── active_trip/
│   ├── alarm/
│   ├── arrival/
│   ├── missed_station/
│   ├── history/
│   └── settings/
│
├── routing/
│   ├── railway_matcher.dart
│   ├── geometry.dart
│   ├── route_progress.dart
│   └── direction_detector.dart
│
├── services/
│   ├── location_service.dart
│   ├── background_tracking_service.dart
│   ├── alarm_service.dart
│   ├── notification_service.dart
│   ├── permission_service.dart
│   ├── battery_optimization_service.dart
│   ├── station_service.dart
│   ├── railway_route_service.dart
│   ├── map_service.dart
│   └── storage_service.dart
│
├── trip/
│   ├── trip_engine.dart
│   ├── eta_engine.dart
│   ├── trip_state_machine.dart
│   └── trip_recovery.dart
│
└── main.dart

```

Use:

- Riverpod or another robust dependency injection/state-management solution.
- Repository pattern.
- Immutable models where practical.
- Clear separation between UI, business logic, geospatial logic, and platform services.

Do NOT put business logic directly inside widgets.

---

# 5. REQUIRED CORE SERVICES

Implement real services for:

```text
LocationService
BackgroundTrackingService
AlarmService
NotificationService
PermissionService
BatteryOptimizationService
StationService
RailwayRouteService
MapService
StorageService
TripEngine
EtaEngine
RailwayMatcher
DirectionDetector

```

Do not create fake service classes that only return hard-coded values.

---

# 6. DATA MODELS

Create a Station model similar to:

```dart
class Station {
  final String id;
  final String nameAr;
  final String nameEn;
  final double latitude;
  final double longitude;
  final List<String> aliases;
  final List<String> routeIds;
  final Map<String, int> routeIndexes;
}

```

Add any additional fields required for a robust implementation.

For example:

```text
isActive
region
stationCode

```

if useful.

Do NOT invent real railway station coordinates.

---

# 7. RAILWAY ROUTE MODEL

Create a route model similar to:

```dart
class RailwayRoute {
  final String id;
  final String nameAr;
  final String nameEn;
  final List<String> stationIds;
  final List<GeoPoint> geometry;
}

```

The route must preserve railway order.

Example conceptual structure:

```text
Station A
   ↓
Station B
   ↓
Station C
   ↓
Station D

```

The geometry must follow the actual railway line.

---

# 8. REAL DATA REQUIREMENT

NEVER fabricate real Egyptian railway coordinates, station positions, or railway geometry.

If verified production data is not available yet:

- clearly mark sample data as development-only
- keep the architecture ready for real data
- do not pretend sample data is accurate
- do not silently substitute fake coordinates

The application should make it easy to replace the data source later.

---

# 9. DATA FILES

For offline-first operation, support local assets:

```text
assets/
└── data/
    ├── stations.json
    └── routes.json

```

Register them in `pubspec.yaml`.

The data loader should validate:

- station IDs
- route IDs
- coordinates
- route order
- missing references
- invalid geometry

Fail gracefully if data is corrupted.

---

# 10. OPENSTREETMAP — MAP SYSTEM

Do NOT use Google Maps.

The application should use:

```text
OpenStreetMap-compatible map data
+
flutter_map

```

Use `flutter_map` for Flutter map rendering.

IMPORTANT:

OpenStreetMap is map data, not an unlimited tile-hosting service.

Do NOT treat the public OpenStreetMap tile server as an unlimited production backend.

For development/testing, an appropriate OSM-compatible tile source may be used while respecting its usage policy.

For production, structure the app so the tile provider can be changed to:

- a compliant commercial tile provider
- self-hosted tiles
- another compatible provider

without rewriting the application.

Keep the tile provider configuration centralized.

---

# 11. MAP ARCHITECTURE

The map is a VISUALIZATION component.

The core trip/alarm engine MUST NOT depend on the map being loaded.

This is extremely important.

The application must still be able to:

```text
GPS
+
route matching
+
ETA
+
alarm
+
arrival detection

```

when:

```text
internet = OFF
map tiles = unavailable

```

The map may simply show an offline/unavailable state.

---

# 12. MAP SCREEN

The active trip map can show:

- current position
- destination station
- railway route geometry
- progress
- nearby stations
- route direction

Keep the map visually secondary.

The map must NOT dominate the entire UI.

The primary information is:

```text
destination
ETA
tracking status
progress

```

---

# 13. DO NOT USE MAP APIs FOR GPS TRACKING

Do not make network map/routing requests every few seconds.

GPS should provide:

```text
latitude
longitude
accuracy
speed
heading
timestamp

```

The local railway engine should perform route matching.

---

# 14. OPENSTREETMAP ATTRIBUTION

If OSM data/tiles are used, provide appropriate attribution according to the data/tile provider's licensing and usage requirements.

Do not remove required attribution.

Do not imply that OpenStreetMap itself provides unlimited hosted tiles.

---

# 15. GOOGLE MAPS REMOVAL

There must be NO dependency on:

```text
Google Maps SDK
Google Maps API key
Google Places
Google Routes API
Google Directions API

```

unless a future optional integration explicitly requires it.

The default implementation must not require Google Maps billing.

---

# 16. LOCATION SYSTEM

Use the phone's GPS/location sensors.

The location service must provide:

```text
latitude
longitude
accuracy
speed
heading
timestamp
altitude if useful

```

Do not rely on a single location sample.

---

# 17. GPS FILTERING

Reject or down-weight bad GPS samples.

Check:

```text
accuracy
timestamp
speed
position jump
impossible movement

```

Example:

If the previous position is 100 meters away and the next sample claims the user moved 15 km in 3 seconds, reject it.

Use a robust filtering/smoothing approach.

Possible approaches:

- median filter
- moving average
- exponential moving average
- Kalman filter

Use complexity only when justified.

---

# 18. DIRECTION DETECTION

Do not trust one compass heading.

Determine travel direction from multiple GPS samples.

Use a rolling window.

Compare movement bearing with railway segment bearing.

The system should determine which direction along a railway route the train is traveling.

This is critical because many routes can be traveled in both directions.

---

# 19. RAILWAY ROUTE MATCHING

Implement map/route matching.

Given:

```text
current GPS point

```

find the nearest valid railway segment.

Implement functions such as:

```text
distanceBetweenCoordinates()
bearingBetweenCoordinates()
projectPointOntoSegment()
distanceFromPointToSegment()
nearestPointOnPolyline()
progressAlongPolyline()
polylineLength()
bearingOfSegment()

```

The system must calculate the user's progress along the railway route.

---

# 20. ROUTE PROGRESS

Represent the user's location as a scalar:

```text
progressMeters

```

Represent the destination as:

```text
destinationProgressMeters

```

Then:

```text
remainingRailwayDistance =
destinationProgressMeters - progressMeters

```

depending on travel direction.

Do NOT use absolute latitude/longitude differences for this.

---

# 21. INTERMEDIATE STATIONS

The system must understand that the user can pass many stations before reaching the destination.

Passing an intermediate station must NOT trigger the alarm.

Only the selected destination should control the alarm.

---

# 22. ROUTE SELECTION

If a station belongs to multiple routes:

- determine possible routes
- use current location
- use movement direction
- use route continuity
- use station order
- use confidence scoring

Do not blindly choose the first route in a list.

---

# 23. CONFIDENCE SYSTEM

Implement confidence values such as:

```text
routeConfidence
movementConfidence
gpsConfidence
etaConfidence
alarmConfidence

```

Do not trigger a critical alarm based on one uncertain GPS sample.

Use multiple confirmations.

---

# 24. GPS LOSS

If GPS becomes unavailable:

DO NOT immediately cancel the trip.

Preserve:

```text
lastKnownPosition
lastKnownProgress
lastKnownSpeed
lastKnownTimestamp
alarm state
destination
route

```

When GPS returns:

- validate the new position
- reconcile progress
- reject impossible jumps
- continue tracking

---

# 25. ETA ENGINE

ETA should use:

```text
remaining railway distance
+
smoothed movement speed
+
realistic stop/slowdown compensation

```

Do not display fake precision.

Prefer:

```text
~17 min

```

over:

```text
16:43.27

```

ETA should adapt as new data arrives.

---

# 26. TRAIN STOP BEHAVIOR

Trains stop at stations.

Do not assume:

```text
speed = 0

```

means the user has arrived.

The user may be stopped at an intermediate station.

ETA must account for:

- temporary stops
- acceleration
- deceleration
- typical train speed
- route characteristics

when enough historical/runtime data is available.

---

# 27. ADAPTIVE GPS SAMPLING

Do not constantly run high-frequency GPS tracking if unnecessary.

Example conceptual behavior:

Far from destination:

```text
lower sampling frequency

```

Approaching destination:

```text
higher sampling frequency

```

Near alarm threshold:

```text
high reliability sampling

```

The goal is:

```text
accuracy + battery efficiency

```

---

# 28. TRIP STATE MACHINE

Implement an explicit state machine:

```text
idle
preparing
tracking
approaching
alarmArmed
alarmTriggered
gpsUncertain
arrived
missed
ended

```

Transitions must be explicit.

Do not control the entire application with random booleans such as:

```text
isTracking
isAlarm
isNear

```

Use a robust state model.

---

# 29. START TRIP FLOW

User flow:

```text
Home
 ↓
Select destination
 ↓
Select wake-up offset
 ↓
Permission preparation
 ↓
Start trip
 ↓
Tracking

```

Before starting:

- verify location permission
- verify notification permission where required
- verify background requirements
- verify battery restrictions where relevant
- verify destination exists
- verify route can be determined
- persist the active trip

---

# 30. ACTIVE TRIP PERSISTENCE

Persist the active trip.

If Android kills/restarts the process, the app must be able to recover the active trip where platform limitations permit.

Persist:

```text
tripId
destinationStationId
selectedRouteId
startTime
wakeOffset
state
lastKnownPosition
lastKnownProgress
alarm state

```

---

# 31. BACKGROUND EXECUTION

The app MUST support tracking while:

- screen is locked
- app is minimized
- user switches apps
- phone is in their pocket

Use an Android foreground service where required.

Show an ongoing notification during active tracking.

Follow current Android permission and foreground-service requirements.

---

# 32. ANDROID LOCATION PERMISSIONS

Handle appropriately:

```text
ACCESS_FINE_LOCATION
ACCESS_COARSE_LOCATION

```

and background location where required by the implementation/Android version.

Do not request every permission blindly on first launch.

Explain WHY permission is needed before the Android system dialog.

---

# 33. NOTIFICATION PERMISSION

For Android versions requiring notification permission:

request it appropriately.

Explain:

> TrainWake needs notifications to keep you informed while your trip is active and to help deliver the wake-up alert.

Do not silently fail if permission is denied.

---

# 34. BATTERY OPTIMIZATION

This is particularly important for devices with aggressive background management.

Support guidance for:

- Xiaomi
- MIUI
- HyperOS
- Samsung
- other Android manufacturers

Do not assume Android background behavior is identical across devices.

If battery optimization can interfere with the trip:

show clear instructions.

---

# 35. BATTERY SCREEN — ARABIC

Use natural Arabic such as:

```text
خلّي TrainWake شغال في الخلفية

بعض الموبايلات، خصوصًا اللي عندها توفير بطارية قوي، ممكن توقف التطبيق في الخلفية.

عشان المنبه يشتغل في وقته، اسمح لـTrainWake بالعمل في الخلفية أثناء الرحلة.

```

Button:

```text
فتح إعدادات البطارية

```

---

# 36. ACTIVE TRIP NOTIFICATION

During an active trip, show an ongoing notification.

Example Arabic:

```text
TrainWake بيتابع رحلتك

نازل في دمنهور • حوالي 18 دقيقة

```

English:

```text
TrainWake is monitoring your trip

Damanhur • about 18 min

```

Do not expose excessive technical information.

---

# 37. ALARM ENGINE

Default alarm:

```text
10 minutes before destination

```

Allow:

```text
5 minutes
10 minutes
15 minutes
custom

```

The system must calculate the alarm threshold based on railway progress/ETA.

---

# 38. TWO-STAGE ALERT

Prefer:

```text
early warning
+
main alarm

```

Example:

Early warning:

```text
محطتك قربت 👀

```

Main:

```text
اصحى!
دمنهور قربت.

```

Do not spam the user.

---

# 39. ALARM RELIABILITY

Alarm triggering must have:

- hysteresis
- consecutive confirmation
- persisted alarm state
- duplicate prevention

Once the main alarm is triggered:

```text
alarmTriggered = true

```

persist it.

Do not trigger the same alarm repeatedly because of GPS jitter.

---

# 40. ALARM SCREEN

The alarm screen must be visually distinct from the normal application.

Arabic:

```text
اصحى

دمنهور قربت.

جهّز نفسك للنزول.

```

Primary:

```text
أنا صاحي

```

Secondary:

```text
كمّل المتابعة

```

English:

```text
WAKE UP

Damanhur is approaching.

Get ready to get off.

```

Primary:

```text
I'm awake

```

Secondary:

```text
Keep monitoring

```

Use:

- loud alarm sound
- vibration
- high-priority notification
- full-screen intent/activity where legally/technically appropriate and allowed by Android

Do not rely exclusively on a normal notification.

---

# 41. ALARM SOUND

Provide a real alarm sound.

Allow the user to configure:

- volume behavior where possible
- vibration
- sound enabled/disabled

Respect Android restrictions.

Do not bypass Android security policies.

---

# 42. ARRIVAL DETECTION

Arrival should require multiple signals.

For example:

```text
route progress near destination
+
reasonable geographical proximity
+
direction consistency
+
consecutive samples

```

Do not mark arrival because the phone briefly passed near the station geographically.

---

# 43. ARRIVAL SCREEN

Arabic:

```text
وصلنا 🎉

دمنهور

رحلتك خلصت.

```

English:

```text
You're here 🎉

Damanhur

Your trip is complete.

```

Stop tracking when appropriate.

Save the trip.

---

# 44. MISSED STATION

If route progress clearly passes the destination without successful arrival confirmation:

show:

Arabic:

```text
ممكن تكون عديت دمنهور

نزلت؟

```

Buttons:

```text
أيوه، أنهِ الرحلة

```

```text
لأ، كمّل المتابعة

```

English:

```text
You may have passed Damanhur

Did you get off?

```

Buttons:

```text
Yes, end trip

```

```text
No, keep monitoring

```

---

# 45. HISTORY

Save completed trips locally.

Show:

- destination
- date
- approximate duration
- alarm offset
- completion status

Keep the history lightweight.

Do not build an unnecessary analytics dashboard.

---

# 46. OFFLINE-FIRST

The following must work without internet after required local data is installed:

```text
station search
GPS tracking
railway matching
route progress
ETA
alarm
notifications
trip state
trip history

```

Internet may be needed for:

```text
map tiles
future data updates

```

but NOT for the fundamental wake-up logic.

---

# 47. STATION SEARCH

Search locally.

Support:

- Arabic
- English
- aliases
- partial matching
- typo tolerance/fuzzy search where useful

Examples:

```text
دمنهور
دمنهورر
damanhur
Daman

```

should be handled intelligently.

Do not require an internet request for every search.

---

# 48. SEARCH PERFORMANCE

Station search should feel instant.

Use:

- normalized strings
- indexed search if necessary
- cached data

Normalize Arabic where appropriate while preserving the original display name.

---

# 49. ARABIC NORMALIZATION

Consider common Arabic input differences:

```text
أ
إ
آ
ا

```

and:

```text
ى
ي

```

and common user typing variations.

Do this only for SEARCH MATCHING.

Do not destroy the original station name.

---

# 50. UI / UX — CRITICAL DESIGN DIRECTION

The application MUST look:

```text
young
modern
minimal
premium
friendly
confident
practical
slightly playful

```

It must NOT look:

```text
AI-generated
generic Flutter
SaaS dashboard
corporate railway software
developer prototype

```

---

# 51. ABSOLUTELY AVOID AI-LOOKING DESIGN

DO NOT use:

- excessive gradients
- purple/blue AI gradients everywhere
- glowing borders
- excessive glassmorphism
- giant floating cards
- random decorative blobs
- excessive 3D illustrations
- robots
- AI sparkles
- excessive pills
- giant dashboard statistics
- unnecessary charts
- generic startup visuals
- excessive neon
- huge shadows
- every element inside a card
- every section inside a rounded rectangle

The app should look HUMAN-DESIGNED.

---

# 52. DESIGN PHILOSOPHY

Prefer:

```text
great typography
+
great spacing
+
strong hierarchy
+
small thoughtful details

```

over:

```text
visual effects
+
gradients
+
decorations

```

Every element must have a reason.

If something does not improve usability, hierarchy, feedback, trust, or delight:

REMOVE IT.

---

# 53. BRAND PERSONALITY

TrainWake should feel:

```text
Young
Helpful
Reliable
Calm
Smart
Friendly
Simple

```

Subtle personality is encouraged.

Do not make the application childish.

---

# 54. BRAND MESSAGE

Primary English:

```text
Sleep. We’ll wake you.

```

Arabic:

```text
نام وإحنا نصحيك قبل محطتك.

```

The user should feel:

> "آه، ده التطبيق اللي أقدر أنام في القطر وأنا مطمن."

---

# 55. TYPOGRAPHY

Typography is a major part of the identity.

Use a high-quality Arabic-compatible font such as:

```text
IBM Plex Sans Arabic
Noto Sans Arabic
Cairo

```

or another professional UI font.

Choose ONE primary font family and use it consistently.

It must support:

- Arabic
- English
- numerals
- readable small text
- dark mode
- accessibility scaling

---

# 56. DESIGN SYSTEM

Create reusable tokens:

```text
AppColors
AppTypography
AppSpacing
AppRadius
AppElevation
AppMotion

```

Do not scatter arbitrary values everywhere.

Example spacing system:

```text
4
8
12
16
20
24
32
40
48

```

Use a coherent system.

---

# 57. COLOR SYSTEM

Use:

```text
one strong primary brand color
one supporting accent
neutral surfaces
semantic colors

```

Semantic:

```text
primary
success
warning
error
info

```

Do NOT use seven bright colors.

Do NOT make everything neon.

Do NOT make every screen a gradient.

---

# 58. DARK MODE

Support:

```text
Light
Dark
System

```

Dark mode must feel intentionally designed.

Do not simply turn backgrounds black.

Use layered surfaces and proper contrast.

---

# 59. CORNERS

Use a small, consistent radius system.

For example:

```text
small
medium
large

```

Do not use random radius values.

Avoid making every component look like a giant bubble.

---

# 60. SHADOWS

Use subtle elevation.

Avoid huge blurry shadows.

The UI should remain clean.

---

# 61. ICONOGRAPHY

Use a consistent icon family.

Do not randomly mix:

```text
Material Icons
+
random SVGs
+
3D icons
+
emoji

```

Use emoji only for occasional personality/microcopy.

---

# 62. ANIMATIONS

Use subtle, purposeful animations:

- screen transitions
- station selection
- trip start
- progress changes
- approaching destination
- alarm transition
- arrival

Do NOT animate everything.

Do NOT create endless floating animations.

Do NOT make it look like a Dribbble concept.

---

# 63. SPLASH SCREEN

Simple.

Show:

```text
TrainWake

```

and:

```text
Sleep. We’ll wake you.

```

Arabic:

```text
نام وإحنا نصحيك قبل محطتك.

```

No unnecessary loading spinner unless actually loading something.

---

# 64. ONBOARDING

Maximum 3–4 screens.

Do not use giant marketing illustrations.

Use typography and subtle train/wake visual language.

Example Arabic flow:

```text
نام براحتك.

```

```text
اختار محطتك.

```

```text
سيب الباقي علينا.

```

```text
اصحى في الوقت الصح.

```

English:

```text
Sleep comfortably.

```

```text
Choose your station.

```

```text
Leave the rest to us.

```

```text
Wake up at the right time.

```

---

# 65. HOME SCREEN

The home screen must immediately communicate the purpose.

Arabic:

```text
رايح فين؟

اختار محطتك

```

Primary CTA:

```text
اختار المحطة

```

Recent:

```text
محطاتك الأخيرة

```

Active trip:

```text
رحلتك الحالية

```

English:

```text
Where are you getting off?

Choose your station

```

---

# 66. STATION SEARCH DESIGN

Arabic:

```text
إنت نازل فين؟

```

Placeholder:

```text
اكتب اسم المحطة...

```

English:

```text
Where are you getting off?

```

Placeholder:

```text
Search station...

```

Keep it fast.

Do not add unnecessary filters.

---

# 67. STATION ROW

Simple station result:

```text
دمنهور
Damanhur

```

or in English mode:

```text
Damanhur
دمنهور

```

Do not add ten badges and technical details.

---

# 68. DESTINATION CONFIRMATION

Arabic:

```text
هتصحى قبلها بكام؟

```

Options:

```text
5 دقايق
10 دقايق
15 دقيقة
مخصص

```

English:

```text
Wake me before my station

```

Options:

```text
5 min
10 min
15 min
Custom

```

---

# 69. START TRIP

Arabic:

```text
ابدأ الرحلة

```

English:

```text
Start trip

```

There should be one obvious primary CTA.

---

# 70. START CONFIRMATION

Use subtle personality:

```text
تمام 🚆

نام وإحنا نصحيك.

```

English:

```text
You're all set 🚆

Sleep. We’ll wake you.

```

---

# 71. ACTIVE TRIP SCREEN

This is the most important screen.

The user must immediately understand:

```text
Where am I going?
How long is left?
Is TrainWake working?

```

Arabic example:

```text
نازل فين؟

دمنهور

حوالي 18 دقيقة

إحنا بنتابع رحلتك

```

English:

```text
Getting off at

Damanhur

About 18 min

We're monitoring your trip

```

---

# 72. ACTIVE TRIP HIERARCHY

Priority:

```text
1. Destination
2. ETA
3. Tracking status
4. Progress
5. Map
6. Secondary information

```

The map must NOT overpower the destination/ETA.

---

# 73. GPS STATUS

Arabic:

```text
إشارة الـGPS كويسة

```

```text
إشارة الـGPS ضعيفة

```

```text
مستني إشارة GPS...

```

English:

```text
GPS signal is good

```

```text
GPS signal is weak

```

```text
Waiting for GPS...

```

Keep this calm and informative.

---

# 74. YOUTHFUL MICROCOPY

Use small moments:

```text
قربنا 👀

```

```text
اصحى! 🚆

```

```text
وصلنا 🎉

```

Do not put emojis everywhere.

---

# 75. ALARM SCREEN DESIGN

The alarm screen must be visually urgent but elegant.

Arabic:

```text
اصحى

دمنهور قربت.

جهّز نفسك للنزول.

```

English:

```text
WAKE UP

Damanhur is approaching.

Get ready to get off.

```

Do NOT use:

- flashing red screen
- excessive animations
- scary graphics
- huge warning icons

Goal:

```text
attention
+
clarity
+
trust

```

---

# 76. ARRIVAL SCREEN DESIGN

Arabic:

```text
وصلنا 🎉

دمنهور

رحلتك خلصت.

```

English:

```text
You're here 🎉

Damanhur

Your trip is complete.

```

---

# 77. MISSED STATION DESIGN

Keep it calm.

Arabic:

```text
ممكن تكون عديت دمنهور

نزلت؟

```

English:

```text
You may have passed Damanhur

Did you get off?

```

---

# 78. SETTINGS

Arabic:

```text
الإعدادات

اللغة
العربية

المظهر
النظام

التنبيه
10 دقايق قبل المحطة

الصوت والاهتزاز

إعدادات البطارية

الصلاحيات

الخصوصية

عن TrainWake

```

English:

```text
Settings

Language
English

Appearance
System

Alarm
10 min before station

Sound & vibration

Battery settings

Permissions

Privacy

About TrainWake

```

---

# 79. LANGUAGE SYSTEM

Support:

```text
العربية
English
System default

```

if appropriate.

Language switching should be clean.

Do not require reinstall.

---

# 80. FLUTTER LOCALIZATION

Use professional localization.

Recommended:

```text
lib/l10n/
├── app_ar.arb
└── app_en.arb

```

Never scatter strings throughout widgets.

Use semantic keys:

```text
home_choose_station
trip_destination
trip_eta
trip_start
trip_tracking
gps_weak
alarm_wake_up
arrival_completed
settings_language
settings_battery

```

NOT:

```text
text1
text2
button7

```

---

# 81. ARABIC MUST BE FIRST-CLASS

Do NOT simply machine-translate English.

Arabic should be natural and concise.

Avoid robotic wording.

The Arabic UI should feel designed for Arabic users.

---

# 82. RTL

Arabic must use real RTL layout.

Support RTL in:

- navigation
- buttons
- station lists
- settings
- dialogs
- onboarding
- active trip
- alarm
- progress
- search

Use Flutter's localization/Directionality correctly.

Do NOT manually reverse the entire UI with hacks.

---

# 83. IMPORTANT RTL RULE

UI direction and geographic direction are different concepts.

Arabic UI:

```text
RTL

```

Geographic direction:

```text
real-world north/east/west

```

must remain unchanged.

Do NOT mirror geographical coordinates, bearings, or railway geometry because Arabic is RTL.

---

# 84. ICON RTL

UI navigation icons can follow RTL.

Geographic icons must retain their real-world meaning.

Do not blindly mirror every icon.

---

# 85. ARABIC SEARCH

Support:

```text
دمنهور
دمنهورر
دمنهور
Damanhur
daman

```

Use aliases and normalization.

---

# 86. ACCESSIBILITY

Support:

- screen readers
- large text
- text scaling
- contrast
- large touch targets
- reduced motion

Arabic must remain usable under large text scaling.

---

# 87. RESPONSIVE DESIGN

Support:

- small phones
- large phones
- different aspect ratios
- different font scales

Do not hard-code screen sizes.

Prevent:

```text
overflow
clipping
text truncation

```

especially in Arabic.

---

# 88. ERROR HANDLING

Errors must be understandable.

Never show technical exceptions to users.

Bad:

```text
NullPointerException

```

Good Arabic:

```text
مش قادرين نحدد مكانك دلوقتي.

متابعة الرحلة ممكن تتأثر لو GPS فضل ضعيف.

```

Good English:

```text
We can't determine your location right now.

Trip monitoring may be affected if GPS remains weak.

```

---

# 89. OFFLINE UI

Arabic:

```text
مفيش إنترنت

متابعة الرحلة لسه شغالة.
الخريطة ممكن تكون غير متاحة.

```

English:

```text
You're offline

Trip monitoring is still active.
The map may be unavailable.

```

Only show this when relevant.

---

# 90. PERMISSION EXPLANATION

Before Android location permission dialog:

Arabic:

```text
محتاجين موقعك

عشان TrainWake يعرف إمتى محطتك قربت، لازم نتابع موقعك أثناء الرحلة.

المتابعة بتقف لما الرحلة تخلص.

```

Button:

```text
السماح بالموقع

```

English:

```text
We need your location

TrainWake uses your location during the trip to know when your destination is approaching.

Tracking stops when the trip ends.

```

---

# 91. PRIVACY

Do not continuously upload the user's location to a server.

Default design:

```text
GPS → local processing → local trip state

```

No unnecessary location analytics.

No unnecessary tracking.

No selling/sharing location.

History remains local unless a future explicit sync feature is added.

---

# 92. SECURITY

Do not hard-code:

- API keys
- secrets
- private credentials

If a tile provider requires an API key:

use environment/build configuration.

Example conceptual:

```text
--dart-define

```

or secure build configuration.

Do not commit secrets.

---

# 93. MAP PROVIDER ABSTRACTION

Create a configuration layer so production tile providers can be changed without changing UI/business logic.

Conceptually:

```dart
abstract class MapTileProvider {
  String get tileUrlTemplate;
  String get attribution;
}

```

Then configure the selected provider.

---

# 94. NO MAP DEPENDENCY FOR ALARM

This is NON-NEGOTIABLE.

If:

```text
map tiles fail

```

the alarm must still work.

If:

```text
internet fails

```

the alarm must still work.

If:

```text
map widget crashes

```

the core trip engine must not crash.

Keep map rendering isolated.

---

# 95. DEVELOPER MODE

Implement an optional developer/debug mode.

It can display:

```text
GPS Accuracy
Speed
Bearing
Matched Route
Route Confidence
Movement Confidence
Progress
Destination Progress
Remaining Distance
ETA
Trip State
Alarm State

```

Normal users should NEVER see this information.

---

# 96. GPS SIMULATOR

Build a debug simulation system.

Allow developers to simulate:

```text
route progress
speed
GPS loss
bad GPS
station stops
approaching destination
alarm trigger
arrival
missed station

```

Also support route replay.

This is essential for testing without riding a train every time.

---

# 97. TESTING

Create unit tests for:

```text
distanceBetweenCoordinates
bearingBetweenCoordinates
projectPointOntoSegment
distanceFromPointToSegment
nearestPointOnPolyline
progressAlongPolyline
polylineLength
direction detection
GPS filtering
route matching
ETA calculation
state transitions
alarm threshold
alarm hysteresis
arrival detection
missed station detection
GPS recovery

```

---

# 98. INTEGRATION TESTS

Test:

```text
start trip
→ lock screen
→ background tracking
→ route progress
→ approaching destination
→ alarm
→ arrival

```

Also test:

```text
GPS loss
internet loss
battery saver
process restart
notification permission denied
location permission denied

```

---

# 99. DEVICE TESTING

Prioritize real Android devices.

Especially test devices with aggressive battery management.

Include Xiaomi/MIUI/HyperOS behavior in testing.

Test:

```text
screen locked
screen off
app minimized
mobile data disabled
Wi-Fi disabled
battery saver enabled

```

---

# 100. STATE RECOVERY

If the process restarts:

1. load persisted active trip
2. restore destination
3. restore route
4. restore alarm state
5. reacquire location
6. reconcile route progress
7. resume tracking

Do not accidentally start a second trip.

---

# 101. DUPLICATE TRIP PROTECTION

There can only be one active trip unless a future product requirement explicitly changes this.

If the user tries to start another trip:

show an appropriate confirmation.

---

# 102. TRIP ENDING

Trip can end because:

```text
arrival
user manually ends trip
missed station and user confirms ending

```

When ended:

- stop background tracking
- cancel active notification
- persist final state
- save history

---

# 103. USER MANUAL END

Provide:

```text
إنهاء الرحلة

```

or:

```text
End trip

```

Require confirmation if accidental ending could cause the user to miss their station.

---

# 104. BATTERY OPTIMIZATION PRINCIPLES

Do not use high-frequency GPS all day.

Tracking exists only during active trips.

No background tracking when there is no active trip.

Use adaptive sampling.

Stop everything after trip completion.

---

# 105. PERFORMANCE

The application must:

- start quickly
- search stations instantly
- avoid unnecessary rebuilds
- avoid memory leaks
- avoid unnecessary location listeners
- avoid unnecessary map rebuilds
- keep background service lightweight

---

# 106. FAILURE RESILIENCE

The app should degrade gracefully.

Examples:

GPS bad:

```text
continue attempting recovery

```

Internet unavailable:

```text
core trip still works

```

Map unavailable:

```text
trip still works

```

Battery optimization:

```text
show actionable guidance

```

Route confidence low:

```text
do not make dangerous assumptions

```

---

# 107. ROUTE CONFIDENCE RULE

If the system cannot confidently determine the route:

Do NOT blindly trigger an alarm.

Instead:

- continue collecting samples
- display a calm GPS/route warning
- improve confidence
- use fallback logic only when sufficiently safe

The system should prefer a delayed warning over a confidently wrong warning.

---

# 108. DESTINATION DETECTION RULE

Destination detection must combine:

```text
route progress
+
geographic proximity
+
direction
+
multiple samples
+
confidence

```

Never trigger based on proximity alone.

---

# 109. MISSED-STATION DETECTION RULE

Only mark the station as potentially missed when:

```text
progress clearly exceeds destination progress
+
direction is consistent
+
multiple samples confirm passing

```

GPS noise must not create false missed-station alerts.

---

# 110. USER EXPERIENCE WHEN GPS IS UNCERTAIN

Do not bombard the user.

Example:

```text
GPS إشارته ضعيفة شوية.

إحنا لسه بنحاول نحدد مكانك.

```

English:

```text
GPS is a little weak.

We're still trying to determine your position.

```

---

# 111. HOME NAVIGATION

Keep navigation simple.

Possible primary sections:

```text
Home
Trips
Settings

```

Do not add five or six navigation tabs.

---

# 112. TRIPS SCREEN

Show:

```text
Recent trips

```

Clean list.

Example:

```text
دمنهور
الجمعة، 10:42 م

المنصورة
الثلاثاء، 7:15 ص

```

Keep it simple.

---

# 113. EMPTY STATE

Arabic:

```text
لسه مفيش رحلات.

اختار محطة وابدأ أول رحلة.

```

English:

```text
No trips yet.

Choose a station and start your first trip.

```

---

# 114. MICROCOPY RULE

All user-facing copy must be:

- short
- natural
- human
- understandable
- appropriate for someone who may be tired

Avoid corporate wording.

Avoid technical language.

---

# 115. DESIGN QUALITY GATE

Before considering a screen finished, ask:

```text
Does it look like a real consumer app?
Does it look human-designed?
Does it feel youthful?
Does it avoid generic AI aesthetics?
Can someone understand it while sleepy?
Does Arabic look equally polished?
Does RTL work correctly?
Is anything unnecessary?

```

If the answer to the last question is YES:

REMOVE IT.

---

# 116. FINAL VISUAL TARGET

The app should feel like:

```text
modern Egyptian train companion
+
smart alarm
+
clean navigation experience

```

NOT:

```text
AI dashboard

```

NOT:

```text
generic Flutter template

```

NOT:

```text
corporate railway software

```

NOT:

```text
developer prototype

```

---

# 117. CORE USER JOURNEY

The ideal experience is:

```text
Open TrainWake
        ↓
"رايح فين؟"
        ↓
Choose station
        ↓
"هتصحى قبلها بكام؟"
        ↓
10 دقايق
        ↓
"ابدأ الرحلة"
        ↓
"تمام 🚆
نام وإحنا نصحيك."
        ↓
Lock phone
        ↓
Sleep
        ↓
Background GPS tracking
        ↓
Railway route matching
        ↓
ETA updates
        ↓
"قربنا 👀"
        ↓
Main alarm
        ↓
"اصحى
دمنهور قربت.
جهّز نفسك للنزول."
        ↓
User wakes up
        ↓
Gets ready
        ↓
Arrives
        ↓
"وصلنا 🎉"
        ↓
Trip saved
        ↓
Tracking stopped

```

---

# 118. ENGINEERING PRIORITY

When making implementation decisions, use this order:

```text
1. Safety/reliability
2. Correct railway positioning
3. Correct destination detection
4. Reliable alarm
5. Background execution
6. Battery efficiency
7. Offline operation
8. Arabic/RTL quality
9. UX
10. Visual polish
11. Optional extras

```

Do not sacrifice alarm reliability for visual effects.

---

# 119. DO NOT FAKE FEATURES

Never implement fake versions of:

```text
GPS
ETA
railway matching
alarm
background tracking
route detection

```

If something cannot be completed because a required external dataset/API/configuration is missing:

- implement the architecture correctly
- clearly identify the missing production dependency
- provide a development fallback
- do NOT pretend the fallback is real

---

# 120. DEPENDENCY QUALITY

Use maintained Flutter packages compatible with the selected Flutter/Android versions.

Avoid unnecessary dependencies.

Before adding a package ask:

```text
Is this actually required?
Is it maintained?
Does it work on Android?
Does it support background behavior?
Does it introduce unnecessary complexity?

```

---

# 121. README

Create a professional README containing:

```text
Project overview
Features
Architecture
Setup
Flutter version
Android requirements
Permissions
Map setup
Tile provider configuration
Railway data format
Localization
Background service
Battery optimization
Debug simulation
Testing
Build instructions
Known limitations
Production checklist

```

---

# 122. SETUP DOCUMENTATION

Include commands such as:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --release

```

Add any required configuration steps.

Do not include fake API keys.

---

# 123. PRODUCTION CHECKLIST

Before declaring the application complete, verify:

### Functionality

- station search works
- Arabic works
- English works
- RTL works
- trip starts
- trip persists
- GPS works
- route matching works
- ETA works
- alarm arms
- alarm triggers
- arrival detection works
- missed station detection works
- history works
- trip ends correctly

### Background

- screen lock works
- app minimization works
- foreground service works
- notification works
- battery optimization guidance works
- process recovery works

### Offline

- station search works
- GPS works
- route matching works
- ETA works
- alarm works
- map gracefully degrades

### Design

- youthful
- minimal
- premium
- human-designed
- no AI-looking UI
- Arabic polished
- English polished
- dark mode polished
- responsive

---

# 124. FINAL REQUIREMENT — DO NOT STOP AT UI

I am NOT asking you to only generate screens.

The final project must be an actual functional Flutter application.

Implement:

```text
UI
+
state management
+
repositories
+
local data
+
GPS
+
background service
+
railway matching
+
ETA
+
alarm
+
notifications
+
persistence
+
localization
+
RTL
+
OpenStreetMap-compatible map
+
testing

```

---

# 125. FINAL REQUIREMENT — BUILD ITERATIVELY

Build in logical phases internally:

```text
Phase 1
Project setup + architecture

Phase 2
Design system + localization

Phase 3
Station data/search

Phase 4
Map integration

Phase 5
GPS service

Phase 6
Railway route engine

Phase 7
Trip state machine

Phase 8
ETA engine

Phase 9
Background tracking

Phase 10
Alarm + notifications

Phase 11
Arrival/missed station

Phase 12
History/settings

Phase 13
Testing

Phase 14
Performance/reliability

Phase 15
Final UI polish

```

Do not move forward while leaving broken foundational code behind.

---

# 126. FINAL DESIGN RULE

The app does NOT need to look complicated to look professional.

Professional means:

```text
intentional
consistent
fast
clear
reliable
beautiful

```

not:

```text
complicated
animated
gradient-heavy
card-heavy
AI-looking

```

---

# 127. FINAL PRODUCT STATEMENT

TrainWake should make the user feel:

> "أنا ممكن أنام في القطر ومش هخاف أفوّت محطتي."

Arabic:

> "أنام وأنا مطمن، TrainWake هيصحيني قبل محطتي."

English:

> "I can sleep on the train without worrying about missing my stop."

Build the entire product around delivering that promise reliably.

---

# 128. FINAL INSTRUCTION TO THE AGENT

Start by inspecting the existing project.

If the project already contains code:

- preserve useful existing work
- refactor where necessary
- do not blindly overwrite working functionality
- remove obsolete Google Maps dependencies if present
- migrate to the OpenStreetMap/flutter\_map architecture
- implement Arabic/English localization
- implement the new design system
- keep the core logic modular

If the project is empty:

create the full Flutter project architecture described above.

Do not ask unnecessary questions if a reasonable implementation decision can be made.

Make sensible engineering decisions yourself.

If production railway data is missing, clearly isolate the data dependency instead of inventing real-world data.

Do not finish by saying:

```text
The rest can be implemented later.

```

Implement as much as possible now.

Do not leave:

```text
TODO
Coming soon
Fake data pretending to be real
Fake GPS
Fake alarm
Placeholder business logic

```

in core functionality.

The final result should be a professional, maintainable, Android-first Flutter application called:

# TRAINWAKE 🚆

with:

```text
real GPS
real background tracking
real railway route matching
real ETA calculation
real alarm behavior
real persistence
real localization
real Arabic RTL
real offline-first core
OpenStreetMap-compatible maps
and a youthful, minimal, human-designed UI.

```

## END OF SPECIFICATION

---

# 129. RELIABILITY UPGRADE — REQUIRED ADDITIONS

The following requirements are mandatory additions to the existing TrainWake specification. They extend the previous sections and must be implemented as part of the same production system. Do NOT create a separate parallel architecture for these features.

## 129.1 PRE-TRIP READINESS CHECK

Before allowing the user to start a real trip, run a readiness check.

Verify, as applicable to the Android version/device:

```text
Destination selected
Railway route available
Railway dataset available
Location permission
Background location capability
Notification permission
Foreground-service capability
GPS availability
Alarm configuration
Active-trip persistence
Battery/background restrictions
```

Present this in a simple human-readable checklist.

Arabic example:

```text
جاهز؟ 🚆

✓ الموقع
✓ الإشعارات
✓ المتابعة في الخلفية
✓ طريق الرحلة متاح

أنت جاهز.
```

If something is missing, explain exactly what the user needs to fix before starting.

Do not expose technical diagnostics to normal users.

Do not start a real trip if a critical prerequisite is unavailable unless the system can safely operate without it.

---

## 129.2 SMART FALLBACK WHEN RAILWAY MATCHING FAILS

If railway matching temporarily becomes uncertain, do NOT immediately cancel the trip.

Preserve:

```text
lastReliableRoute
lastReliableProgress
lastReliablePosition
lastReliableSpeed
lastReliableTimestamp
```

Enter the appropriate uncertain state and continue attempting recovery.

A fallback may use:

```text
last reliable railway progress
GPS proximity
recent movement direction
recent speed
route continuity
```

However:

**NEVER trigger the critical destination alarm using only a weak fallback estimate.**

The system must distinguish between:

```text
safe recovery assistance
```

and:

```text
sufficient confidence for a critical wake-up decision
```

If confidence is insufficient, remain conservative and keep collecting evidence.

---

## 129.3 TRAIN SPEED PROFILE

ETA must not depend on one raw GPS speed sample.

Maintain a smoothed runtime speed profile using appropriate combinations of:

```text
recent speed samples
moving average / weighted average
acceleration
braking
station stops
slow sections
route characteristics
historical speed data when legitimately available
```

Recognize station-stop behavior.

Example:

```text
moving
↓
decelerating
↓
station stop
↓
accelerating
↓
moving
```

A temporary speed of zero must NOT automatically mean destination arrival.

Intermediate station stops must be treated as part of the journey.

---

## 129.4 ETA SAFETY MARGIN

ETA is an estimate and must never be treated as exact.

The alarm engine must account for uncertainty around the requested wake-up offset.

Consider:

```text
ETA confidence
GPS confidence
route confidence
current speed
recent acceleration/deceleration
station-stop behavior
GPS sampling interval
processing delay
alarm scheduling delay
```

The system should generally bias toward waking the user slightly early rather than too late when uncertainty is meaningful.

Do NOT compensate by waking the user excessively early under normal conditions.

The target is:

```text
reliable protection against missing the station
+
reasonable wake-up timing
```

Do not use a simplistic rule such as:

```text
if etaMinutes == wakeOffset then alarm
```

The decision should be based on robust thresholding, hysteresis, confidence, and safety margin.

---

## 129.5 MONOTONIC TIME + CLOCK/TIMEZONE HANDLING

Do not blindly use wall-clock time for elapsed-duration calculations.

Use monotonic elapsed time where appropriate for:

```text
time between GPS samples
durations
timeouts
speed calculations
stale-sample detection
simulation timing
```

Use wall-clock time for user-facing dates/times and persisted display timestamps.

Handle:

```text
system clock changes
timezone changes
time corrections
daylight-saving changes where applicable
process restart
```

After a restart, reconcile persisted wall-clock state with current monotonic/runtime state instead of assuming the clock never changed.

Never allow a manual clock change to create an obviously invalid trip duration or alarm schedule.

---

## 129.6 PROCESS, SERVICE, AND BOOT RECOVERY

The active trip must survive process/service recreation whenever Android permits.

Persist important state immediately when it changes.

Persist at minimum:

```text
tripId
destination
route
route direction
progress
last reliable GPS
last reliable speed
last reliable timestamp
trip state
wake offset
alarm state
alarm trigger timestamp
alarm acknowledgement state
railwayDataVersion
schemaVersion
```

After process recreation:

```text
load persisted trip
↓
validate persisted state
↓
restore destination/route
↓
restore alarm state
↓
restore last reliable progress
↓
reacquire GPS
↓
reconcile progress
↓
resume tracking
```

Where Android permits boot recovery, restore the active trip after device reboot.

Never create duplicate trips or duplicate alarms during recovery.

If the OS prevents automatic recovery, fail safely and document the limitation rather than pretending recovery is guaranteed.

---

## 129.7 ALARM ACKNOWLEDGEMENT + UNACKNOWLEDGED STATE

The user must be able to explicitly acknowledge the main alarm.

Provide:

```text
أنا صاحي
```

and:

```text
كمّل المتابعة
```

English:

```text
I'm awake
```

and:

```text
Keep monitoring
```

If the user does not acknowledge the alarm:

- do not silently treat it as acknowledged
- continue the configured alarm behavior
- preserve the alarm state
- allow the trip engine to continue toward arrival
- record that the alarm was unacknowledged

Use a persisted field/state equivalent to:

```text
alarmUnacknowledged
```

Do not allow activity recreation or process restart to erase this state.

---

## 129.8 EXPLICIT ALARM STATE MODEL

The alarm system should distinguish at least:

```text
notArmed
armed
earlyWarningTriggered
mainAlarmTriggered
acknowledged
unacknowledged
completed
cancelled
```

The exact Dart representation may be an enum/state object, but it must be explicit and persisted where required.

The alarm engine must be idempotent.

Repeated GPS updates, service restarts, process recreation, and duplicate callbacks must not trigger the same main alarm repeatedly.

---

## 129.9 FULL-JOURNEY SIMULATION MODE

The existing developer GPS simulator must be upgraded into a complete journey simulator.

It must be capable of simulating an entire train journey using the SAME production:

```text
RailwayMatcher
DirectionDetector
TripEngine
EtaEngine
AlarmEngine
state machine
persistence/recovery logic where practical
```

Do NOT create a fake simulation-only alarm implementation that bypasses the real production logic.

The simulation should support:

```text
start
acceleration
normal movement
speed changes
intermediate station stop
acceleration after stop
GPS noise
GPS loss
GPS recovery
slowdown
approaching destination
early warning
main alarm
arrival
```

Also support failure scenarios:

```text
wrong direction
impossible GPS jump
poor GPS accuracy
route ambiguity
process restart
service restart
internet loss
map unavailable
```

Simulation speed:

```text
1x
2x
5x
10x
20x
```

The complete simulated journey must be fast enough to test alarm behavior without riding a real train.

---

## 129.10 SIMULATION CONTROLS

Developer mode should provide:

```text
Start
Pause
Resume
Reset
1x
2x
5x
10x
20x
```

Allow the developer to:

```text
force GPS loss
force GPS recovery
inject GPS noise
inject impossible jump
change speed
simulate station stop
force route ambiguity
force alarm
force arrival
force missed station
restart trip engine
simulate process recovery
```

Clearly display:

```text
SIMULATION MODE
```

Never allow simulation state to be mistaken for real tracking.

---

## 129.11 NORMAL USER UNCERTAINTY RULE

Technical uncertainty belongs in Developer Mode only.

Normal users should never see raw values such as:

```text
routeConfidence = 0.42
etaConfidence = 0.31
match score = 0.56
```

Instead use natural language.

Examples:

```text
لسه بنحدد مكانك...
```

```text
إشارة الـGPS ضعيفة
```

```text
بنراجع مكان الرحلة...
```

English:

```text
We're still determining your position.
```

```text
GPS signal is weak.
```

```text
We're checking your trip position.
```

Keep the tone calm and avoid unnecessary alarm.

---

## 129.12 DEVELOPER DIAGNOSTICS

Developer Mode may expose the full technical state:

```text
GPS accuracy
latitude/longitude when useful for debugging
speed
bearing
matched route
route confidence
movement confidence
GPS confidence
ETA confidence
progress
destination progress
remaining railway distance
alarm threshold
safety margin
alarm confidence
alarm state
trip state
last reliable progress
last reliable timestamp
railwayDataVersion
schemaVersion
```

These diagnostics must not appear in normal user flows.

---

## 129.13 RAILWAY DATA VERSIONING

Every installed railway dataset must have explicit metadata.

Include:

```text
railwayDataVersion
schemaVersion
lastUpdated
```

Validate the dataset when loaded.

If a newer compatible dataset is introduced, the application must be able to replace/update it without rewriting the trip engine.

Persist the data version associated with an active trip when useful for debugging/recovery.

Never silently mix incompatible route geometry from different dataset versions inside one active trip.

---

## 129.14 DATA INTEGRITY

Validate railway data before using it for critical alarm decisions.

Validate:

```text
station IDs
route IDs
station references
route order
coordinates
geometry continuity
geometry validity
destination index
```

If data is invalid:

- do not fabricate a replacement
- do not silently use broken geometry
- report the issue in developer diagnostics
- fail safely

---

## 129.15 ALARM DECISION SAFETY

The critical alarm decision must consider the complete state, not one variable.

Conceptually:

```text
GPS quality
+
route confidence
+
movement confidence
+
route progress
+
remaining railway distance
+
ETA
+
ETA confidence
+
requested wake offset
+
uncertainty/safety margin
+
previous alarm state
```

Use hysteresis and consecutive confirmation.

Avoid oscillation around the alarm threshold.

Example failure to avoid:

```text
ETA 9.9 min → alarm
ETA 10.2 min → not alarm
ETA 9.8 min → alarm again
```

Once the main alarm has been triggered, it remains triggered until the explicit alarm lifecycle moves forward.

---

## 129.16 DESTINATION SAFETY BUFFER

Arrival detection and missed-station detection should have explicit tolerances.

Do not use a single exact coordinate or exact progress number.

Account for:

```text
GPS noise
track geometry accuracy
station geometry
sampling interval
train speed
braking distance
```

The implementation must use sensible configurable constants instead of scattered magic numbers.

Centralize relevant thresholds in configuration/constants.

---

## 129.17 PRE-TRIP FAILURE MESSAGES

If the readiness check fails, use short actionable messages.

Examples:

Arabic:

```text
محتاجين إذن الموقع
```

```text
فعّل الإشعارات عشان نقدر ننبهك.
```

```text
الرحلة دي مش متاحة حاليًا لأن طريق القطار مش موجود في بياناتنا.
```

```text
GPS مش متاح دلوقتي.
```

English:

```text
Location permission is required.
```

```text
Turn on notifications so we can alert you.
```

```text
This trip isn't available because the railway route is not in the installed dataset.
```

```text
GPS isn't available right now.
```

Do not expose exceptions or stack traces.

---

## 129.18 FINAL RELIABILITY PRINCIPLE

When there is a conflict between:

```text
visual simplicity
```

and:

```text
alarm reliability
```

choose alarm reliability.

When there is a conflict between:

```text
an aggressive guess
```

and:

```text
a conservative uncertainty state
```

choose the conservative state unless enough evidence exists to make the decision safely.

The application exists to prevent a passenger from missing a station.

Do not optimize for impressive demos at the expense of real-world reliability.

---

# 130. FINAL ACCEPTANCE CRITERIA — UPDATED

Do not declare TrainWake complete until the following are implemented or explicitly documented as platform/data limitations.

### Core

```text
[ ] station search
[ ] destination selection
[ ] wake-up offset
[ ] readiness check
[ ] trip persistence
[ ] GPS tracking
[ ] railway matching
[ ] route direction
[ ] route progress
[ ] smoothed speed
[ ] station-stop handling
[ ] ETA
[ ] ETA confidence
[ ] alarm safety margin
[ ] early warning
[ ] main alarm
[ ] alarm acknowledgement
[ ] unacknowledged alarm state
[ ] duplicate alarm prevention
[ ] arrival detection
[ ] missed station detection
[ ] trip history
```

### Recovery

```text
[ ] process recreation
[ ] service recreation
[ ] active trip restoration
[ ] alarm restoration
[ ] last reliable progress restoration
[ ] GPS recovery
[ ] duplicate-trip prevention
[ ] boot recovery where Android permits
```

### Offline

```text
[ ] local station search
[ ] local railway route data
[ ] local route matching
[ ] local ETA
[ ] local alarm logic
[ ] map graceful degradation
```

### Simulation

```text
[ ] complete journey simulation
[ ] intermediate station stops
[ ] speed changes
[ ] GPS noise
[ ] GPS loss
[ ] GPS recovery
[ ] wrong direction
[ ] impossible jump
[ ] early warning
[ ] main alarm
[ ] arrival
[ ] missed station
[ ] process/service recovery simulation
[ ] 1x
[ ] 2x
[ ] 5x
[ ] 10x
[ ] 20x
```

### User experience

```text
[ ] Arabic
[ ] English
[ ] RTL
[ ] Light mode
[ ] Dark mode
[ ] accessibility
[ ] responsive layout
[ ] human microcopy
[ ] no technical diagnostics for normal users
```

### Android

```text
[ ] foreground service
[ ] location permissions
[ ] notification permissions
[ ] background behavior
[ ] battery optimization guidance
[ ] screen-lock behavior
[ ] minimized-app behavior
[ ] physical-device testing
```

### Quality

```text
[ ] flutter analyze passes
[ ] flutter test passes
[ ] critical unit tests exist
[ ] widget tests exist
[ ] integration tests cover the trip lifecycle
[ ] no fake core features
[ ] no production TODO placeholders
[ ] no hard-coded secrets
[ ] README updated
[ ] production limitations documented
```

---

# 131. FINAL BUILD DIRECTIVE

Now combine ALL requirements in this specification into one coherent implementation.

Do not implement the new reliability requirements as disconnected patches.

Integrate them into the existing:

```text
architecture
state machine
TripEngine
RailwayMatcher
EtaEngine
AlarmService
BackgroundTrackingService
StorageService
Developer Mode
simulation system
UI
```

Preserve existing good work.

Refactor when necessary.

Do not duplicate services or state models when an existing implementation can be extended cleanly.

Before making large changes:

```text
inspect
plan
implement
analyze
run tests
fix
continue
```

The final TrainWake application must be technically serious underneath while remaining extremely simple for a normal passenger to use.

The user experience should ultimately feel like:

```text
اختار محطتك
↓
اختار ميعاد التنبيه
↓
اعمل readiness check
↓
ابدأ الرحلة
↓
اقفل الموبايل
↓
نام
↓
TrainWake يتابع الرحلة
↓
قربنا 👀
↓
اصحى 🚆
↓
جهّز نفسك للنزول
↓
وصلنا 🎉
```

Build the complete product now.

## END OF UPDATED SPECIFICATION
