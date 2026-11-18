import numpy as np

class HealthAnomalyDetector:
    def __init__(self, window_size=20):
        self.window_size = window_size
        self.hr_history = []
        self.spo2_history = []

    def process_reading(self, heart_rate: float, spo2: float, body_temp: float):
        # 1. History maintain karo personalized baseline ke liye
        self.hr_history.append(heart_rate)
        self.spo2_history.append(spo2)

        if len(self.hr_history) > self.window_size:
            self.hr_history.pop(0)
        if len(self.spo2_history) > self.window_size:
            self.spo2_history.pop(0)

        # 2. Baseline calculation (Mean & Std Deviation)
        hr_baseline = np.mean(self.hr_history)
        hr_std = np.std(self.hr_history) if len(self.hr_history) > 1 else 5.0

        # 3. Anomaly Detection (Z-Score logic)
        # Agar current HR baseline se 2.5 standard deviation se zyada door hai
        hr_z_score = abs(heart_rate - hr_baseline) / (hr_std + 1e-5)
        
        is_anomaly = False
        risk_level = "Normal"
        explanation = "Vitals are within your normal personalized baseline."

        if hr_z_score > 2.5 or heart_rate > 115 or heart_rate < 50:
            is_anomaly = True
            risk_level = "High"
            explanation = f"Unusual Heart Rate detected ({heart_rate} BPM) compared to your baseline ({hr_baseline:.1f} BPM)."
        elif spo2 < 94:
            is_anomaly = True
            risk_level = "Moderate"
            explanation = f"Low SpO2 levels detected ({spo2}%)."

        return {
            "is_anomaly": is_anomaly,
            "risk_level": risk_level,
            "baseline_hr": round(hr_baseline, 1),
            "explanation": explanation
        }