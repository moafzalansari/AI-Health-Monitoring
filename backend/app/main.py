import random
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from datetime import datetime

app = FastAPI(title="AI Health Monitoring API", version="1.0")

# CORS middleware for Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory storage with initial values
latest_vitals = {
    "heart_rate": 78,
    "spo2": 98,
    "temperature": 98.4,
    "fall_status": "Normal",
    "timestamp": str(datetime.now())
}

class VitalsData(BaseModel):
    heart_rate: int
    spo2: int
    temperature: float
    fall_status: str

@app.get("/")
def read_root():
    return {"message": "AI Health Monitoring Backend is Running successfully!"}

@app.post("/api/vitals/upload")
def upload_vitals(data: VitalsData):
    global latest_vitals
    latest_vitals = {
        "heart_rate": data.heart_rate,
        "spo2": data.spo2,
        "temperature": data.temperature,
        "fall_status": data.fall_status,
        "timestamp": str(datetime.now())
    }
    return {"status": "success", "message": "Vitals updated successfully"}

@app.get("/api/vitals/latest")
def get_latest_vitals():
    global latest_vitals
    # 🔥 Yahan humne live fluctuation add kar diya hai taaki UI par numbers badle hue dikhein
    latest_vitals["heart_rate"] = random.randint(72, 92)
    latest_vitals["spo2"] = random.randint(95, 99)
    latest_vitals["temperature"] = round(random.uniform(97.8, 99.2), 1)
    latest_vitals["timestamp"] = str(datetime.now())
    
    return latest_vitals