# HealthNova AI — AI Pipeline

## Objective

HealthNova AI will analyze physiological data collected from
multiple sensors and identify unusual patterns compared with
the user's personal baseline.

## Input Data

- Heart Rate
- SpO2
- Temperature
- Activity
- HRV (if available)

## AI Pipeline

Sensor Data
    ↓
Data Cleaning
    ↓
Feature Engineering
    ↓
Personal Baseline
    ↓
Anomaly Detection
    ↓
Risk Score
    ↓
Explainable Result

## Planned ML Approaches

- Isolation Forest for anomaly detection
- Random Forest / XGBoost for risk classification
- Time-series analysis for continuous health patterns

## Important Limitation

The system is intended for preliminary health monitoring
and anomaly detection. It is not a medical diagnosis system.