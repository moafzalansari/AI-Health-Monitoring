from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional

app = FastAPI(title="HealthNova AI Vitals API")

# CORS Enable karna zaroori hai taaki Flutter Web/Mobile server se communicate kar sake
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Temporary in-memory data store (Yahan current vitals save rahenge)
latest_vitals_store = {
    "heart_rate": 78,
    "spo2": 98,
    "body_temp": 98.6,
    "fall_status": "Stable"
}

class VitalsModel(BaseModel):
    heart_rate: int
    spo2: int
    body_temp: float
    fall_status: str

# 1. Flutter app ke liye GET endpoint (Data fetch karne ke liye)
@app.get("/api/vitals/latest")
def get_latest_vitals():
    return {
        "status": "success",
        "data": latest_vitals_store
    }

# 2. ESP32 hardware ke liye POST endpoint (Data push karne ke liye)
@app.post("/api/vitals/update")
def update_vitals(vitals: VitalsModel):
    global latest_vitals_store
    latest_vitals_store = vitals.dict()
    return {"status": "updated", "data": latest_vitals_store}