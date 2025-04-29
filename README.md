# 🧊 FridgeGuard

A smart mobile app to monitor fridge temperature and track food expiry 📱🥦  
Developed for the CASA0015 Final Assessment.

👉 [Landing Page](https://github.com/MCH0202/FridgeGuard/blob/main/landing_page/home.html)  
👉 [▶️ Watch on YouTube](https://youtube.com/shorts/ofdGUBysSow)

---

## 🔍 Overview

**FridgeGuard** helps users:
- Track food expiry dates with color-coded reminders
- Monitor real-time fridge temperature via MQTT
- Reduce food waste and promote sustainability

---

## 📸 Screenshots

### 🏠 Home Page – Temperature Display  
<img src="./landing_page/images/homepage.png" width="300"/>

### 📋 Food List – Expiry Status  
<img src="./landing_page/images/foodlist.png" width="300"/>

### ✍️ Write Page – Manual Entry  
<img src="./landing_page/images/writepage.png" width="300"/>

### 📷 Scan Page – Barcode Lookup  
<img src="./landing_page/images/scanpage.png" width="300"/>

### ⚙️ Settings  
<img src="./landing_page/images/settingpage.png" width="300"/>

---

## 🧪 Features in Action

### 👤 Register Demo  
<img src="./landing_page/images/register.gif" width="300"/>

### 🌡️ Temperature Log Page  
<img src="./landing_page/images/temperaturelog.png" width="300"/>

### 📦 Physical Prototype

<p align="center">
  <img src="./landing_page/images/physical_device1.jpg" width="250"/>
  <img src="./landing_page/images/physical_device2.jpg" width="250"/>
  <img src="./landing_page/images/physical_device3.jpg" width="250"/>
</p>

---

## 🛠️ Built With

- [Flutter](https://flutter.dev/) – Cross-platform development  
- [Firebase Authentication](https://firebase.google.com/docs/auth) – User login  
- [Cloud Firestore](https://firebase.google.com/docs/firestore) – Food data storage  
- [MQTT Protocol](https://pub.dev/packages/mqtt_client) – Real-time temperature feed  
- [OpenFoodFacts API](https://world.openfoodfacts.org/data) – Barcode lookup  

---

## 🎬 Demo Video

> 📺 Watch the full app demonstration in the presentation video:  
> [Link to demo in presentation](https://github.com/MCH0202/FridgeGuard#demo-video)

---

## 🚀 Installation

You can either **run the app locally using Flutter**, or **directly download and install the APK file** from the Releases page.

---

### 📥 Option 1: Download APK (Recommended for Mobile Users)

- Go to the [Releases](https://github.com/MCH0202/FridgeGuard/releases) section.
- Download the latest version **FridgeGuard_v1.0.3.apk**.
- Transfer and install the APK on your Android device.

> ⚡ Make sure your device allows installation from unknown sources.

---

### 💻 Option 2: Run Locally with Flutter (For Developers)

#### Prerequisites:

- Flutter SDK >= 3.10.0 installed ([Flutter installation guide](https://docs.flutter.dev/get-started/install))
- Dart >= 3.1 installed
- Firebase CLI installed (`npm install -g firebase-tools`)
- Android Studio / Xcode with emulator or real device connected

#### Steps:

```bash
git clone https://github.com/MCH0202/FridgeGuard.git
cd FridgeGuard
flutter pub get
flutter run
