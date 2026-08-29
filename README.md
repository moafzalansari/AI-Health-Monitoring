# 🏥 AI-Powered Context-Aware Personalized Health Monitoring and Physiological Anomaly Detection System

An advanced, low-cost health monitoring and anomaly detection research prototype built with **Flutter** (Frontend), **FastAPI** (Backend), **Python AI/ML pipeline**, and **IoT wearable sensors**.

---

## 👥 Team Members & Work Division

| S. No. | Name | Role | Main Responsibility |
|--------|------|------|---------------------|
| 1 | **Mo Afzal Ansari** | Full-Stack Development | Flutter App, Backend/API, Database, Integration |
| 2 | **Abhishek Chaurasia** | Hardware + IoT | ESP32, MAX30102, SpO₂/HR, Temperature, MPU6050 |
| 3 | **Vishal Mali** | AI + Research | ML, Personalized Baseline, Anomaly Detection, Research Paper |
| 4 | **Kaushal Pandey** | Data + Testing | Dataset, Preprocessing Support, Testing, Evaluation, Documentation |

---

## 📌 About the Project

We are developing a low-cost AI-powered health monitoring system that collects physiological and activity-related data using wearable sensors and analyses the user's individual patterns.

The system will monitor:
* ❤️ **Heart Rate**
* 🫁 **SpO₂ (Blood Oxygen)**
* 🌡️ **Temperature**
* 🏃 **Physical Activity / Movement**

Instead of relying only on fixed threshold limits, the system studies the user's individual physiological baseline and activity context to identify unusual physiological patterns. The detected patterns are analyzed using machine learning techniques and presented through an interactive mobile and web application with clear alerts, trends, and insights.

> **⚠️ Academic Disclaimer:** This project is an academic research prototype for physiological monitoring and anomaly detection. It is not intended to provide clinical diagnosis.

---

## 🎯 Project Objectives

* Collect physiological data using low-cost hardware components.
* Develop a reliable sensor-data acquisition and telemetry system.
* Perform data preprocessing and noise handling.
* Establish personalized physiological baselines.
* Incorporate activity context into physiological analysis.
* Develop a machine-learning based anomaly detection engine.
* Generate understandable and explainable alerts.
* Provide health trends and historical data through a cross-platform mobile/web application.
* Experimentally compare personalized monitoring with conventional threshold-based monitoring.

---

## ⚙️ Hardware Components

* **ESP32** — Main microcontroller and Wi-Fi communication unit
* **MAX30102** — Heart Rate and SpO₂ optical sensor
* **Temperature Sensor** — Continuous body temperature monitoring
* **MPU6050** — Motion and fall detection sensing
* **Power Source** — Rechargeable battery and supporting electronic components

---

## 💻 Software & Tech Stack

* **Frontend:** Flutter (Web/Mobile), Dart, Material Design, Google Fonts, `fl_chart`
* **Backend API:** Python, FastAPI, Uvicorn
* **AI / ML:** Python, Scikit-Learn / Custom Anomaly Detection Models
* **IoT Communication:** JSON Telemetry endpoints over HTTP/MQTT

---

## 🧠 AI/ML Module Pipeline

1. Data ingestion & cleaning
2. Noise and outlier handling
3. Feature extraction
4. Personalized baseline generation
5. Activity-context analysis
6. Machine-learning based anomaly scoring
7. Explainable alert generation

---

## 🔄 System Workflow

```text
Physiological & Activity Sensors
              ↓
            ESP32
              ↓
     Data Acquisition
              ↓
    Data Preprocessing
              ↓
  Personalized Baseline
              ↓
 Activity Context Analysis
              ↓
        AI / ML Model
              ↓
     Anomaly Detection
              ↓
   Anomaly / Risk Score
              ↓
   Explainable Alert
              ↓
    Flutter Application (Dashboard)