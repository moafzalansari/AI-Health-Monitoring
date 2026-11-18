import time
import random
import requests

API_URL = "http://127.0.0.1:8000/api/vitals/upload"

print("🚀 HealthNova Dynamic Anomaly & Vitals Simulator Started...")
print("Press Ctrl+C to stop simulation.")

counter = 0

while True:
    counter += 1
    
    # Normal Range
    heart_rate = random.randint(72, 88)
    spo2 = random.randint(96, 99)
    temperature = round(random.uniform(97.8, 99.2), 1)
    fall_status = "Stable"
    
    # Demo Anomaly Simulation (Every 10 counts -> High HR Spike / Fall Detection)
    if counter % 10 == 0:
        print("\n⚠️ [DEMO TRIGGER] Simulating Sudden Critical Heart Rate Spike!")
        heart_rate = random.randint(115, 135)
        spo2 = random.randint(91, 94)
    elif counter % 15 == 0:
        print("\n🚨 [DEMO TRIGGER] Simulating Patient Fall Detection Event!")
        fall_status = "FALL DETECTED!"
        heart_rate = random.randint(100, 120)

    payload = {
        "heart_rate": heart_rate,
        "spo2": spo2,
        "temperature": temperature,
        "fall_status": fall_status
    }
    
    try:
        response = requests.post(API_URL, json=payload)
        if response.status_code == 200:
            status_icon = "🚨" if fall_status != "Stable" or heart_rate > 100 else "✅"
            print(f"{status_icon} Vitals Pushed -> HR: {heart_rate} BPM | SpO2: {spo2}% | Temp: {temperature}°F | Fall: {fall_status}")
        else:
            print(f"⚠️ Failed to push vitals: {response.status_code}")
    except Exception as e:
        print(f"❌ Connection Error: {e}")
        
    time.sleep(3)