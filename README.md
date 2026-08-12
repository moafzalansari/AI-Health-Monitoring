# AI-Powered Context-Aware Personalized Health Monitoring and Physiological Anomaly Detection System

## 👥 Team Members & Work Division

| S. No. | Name | Role | Main Responsibility |
|--------|------|------|---------------------|
| 1 | **Mo Afzal Ansari** | AI + Research | ML, Personalized Baseline, Anomaly Detection, Research Paper |
| 2 | **Abhishek Chaurasia** | Hardware + IoT | ESP32, MAX30102, SpO₂/HR, Temperature, MPU6050 |
| 3 | **Vishal Mali** | Full-Stack Development | Flutter App, Backend/API, Database, Integration |
| 4 | **Kaushal Pandey** | Data + Testing | Dataset, Preprocessing Support, Testing, Evaluation, Documentation |

---

## 📌 About the Project

We are developing a low-cost AI-powered health monitoring system that collects physiological and activity-related data using wearable sensors and analyses the user's individual patterns.

The system will monitor:

- ❤️ Heart Rate
- 🫁 SpO₂
- 🌡️ Temperature
- 🏃 Physical Activity / Movement

Instead of relying only on fixed thresholds, the system will study the user's individual physiological baseline and activity context to identify unusual physiological patterns.

The detected patterns will be analysed using machine learning techniques and presented through a mobile application with understandable alerts, trends, and insights.

> **Note:** This project is an academic research prototype for physiological monitoring and anomaly detection. It is not intended to provide clinical diagnosis.

---

## 🎯 Project Objectives

- Collect physiological data using low-cost sensors.
- Develop a reliable sensor-data acquisition system.
- Perform data preprocessing and noise handling.
- Establish personalized physiological baselines.
- Incorporate activity context into physiological analysis.
- Develop a machine-learning based anomaly detection system.
- Generate understandable and explainable alerts.
- Provide health trends and historical data through a mobile application.
- Experimentally compare personalized monitoring with conventional threshold-based monitoring.

---

## ⚙️ Hardware Components

- **ESP32** — Main microcontroller and communication unit
- **MAX30102** — Heart Rate and SpO₂ sensing
- **Temperature Sensor** — Temperature monitoring
- **MPU6050** — Motion and activity sensing
- Battery and supporting electronic components

---

## 💻 Software Components

- **Flutter** — Mobile Application
- **Python** — AI/ML and data processing
- **Backend API** — Communication and data management
- **Database** — User and physiological data storage
- **Machine Learning** — Personalized anomaly detection

---

## 🧠 AI/ML Module

The AI module will include:

1. Data preprocessing
2. Noise and outlier handling
3. Feature extraction
4. Personalized baseline generation
5. Activity-context analysis
6. Machine-learning based anomaly detection
7. Anomaly scoring
8. Model evaluation

The final machine-learning approach will be selected after experimentation and comparison of suitable models.

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
             Mobile Application