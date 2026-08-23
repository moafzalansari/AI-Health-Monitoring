from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware  # <-- 1. Yeh import add karo
from pydantic import BaseModel
from datetime import datetime

app = FastAPI(title="AI Health Monitoring API", version="1.0")

# <-- 2. Yeh CORS middleware add karo taaki Flutter Web data le sake
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Sabhi origins allow hain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Temporary in-memory storage (Aage hum isko Database se connect karenge)
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
    return latest_vitals