from datetime import datetime
import os
import sqlite3
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from google import genai
from app.ai_module import HealthAnomalyDetector

app = FastAPI(title="AI Health Monitoring API", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def init_db():
    conn = sqlite3.connect("healthnova.db")
    cursor = conn.cursor()
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT
        )
    """
    )
    cursor.execute(
        "INSERT OR IGNORE INTO users (email, password) VALUES ('admin@healthnova.com', 'admin123')"
    )
    conn.commit()
    conn.close()


init_db()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
client = genai.Client(api_key=GEMINI_API_KEY)
detector = HealthAnomalyDetector()

initial_analysis = {
    "is_anomaly": False,
    "risk_level": "Normal",
    "baseline_hr": 78.0,
    "explanation": "Vitals are within your normal personalized baseline.",
}

latest_vitals = {
    "heart_rate": 78,
    "spo2": 98,
    "temperature": 98.4,
    "fall_status": "Normal",
    "timestamp": str(datetime.now()),
    "analysis": initial_analysis,
}

vitals_history = [dict(latest_vitals)]


class VitalsData(BaseModel):
    heart_rate: int
    spo2: int
    temperature: float
    fall_status: str


class AIChatRequest(BaseModel):
    prompt: str
    current_vitals: dict = {}


class LoginRequest(BaseModel):
    email: str
    password: str


@app.get("/")
def read_root():
    return {"message": "AI Health Monitoring Backend with SQLite & Gemini AI is Running!"}


@app.post("/api/login")
def login_user(data: LoginRequest):
    conn = sqlite3.connect("healthnova.db")
    cursor = conn.cursor()

    cursor.execute(
        "SELECT * FROM users WHERE email = ? AND password = ?",
        (data.email, data.password),
    )
    user = cursor.fetchone()

    if user:
        conn.close()
        return {
            "status": "success",
            "message": "Login successful",
            "user": data.email.split("@")[0],
        }

    try:
        cursor.execute(
            "INSERT INTO users (email, password) VALUES (?, ?)",
            (data.email, data.password),
        )
        conn.commit()
        conn.close()
        return {
            "status": "success",
            "message": "Account created and logged in successfully",
            "user": data.email.split("@")[0],
        }
    except Exception:
        conn.close()
        return {"status": "error", "message": "Invalid email or password"}


@app.post("/api/vitals/upload")
def upload_vitals(data: VitalsData):
    global latest_vitals, vitals_history
    analysis = detector.process_reading(
        heart_rate=float(data.heart_rate),
        spo2=float(data.spo2),
        body_temp=data.temperature,
    )
    latest_vitals = {
        "heart_rate": data.heart_rate,
        "spo2": data.spo2,
        "temperature": data.temperature,
        "fall_status": data.fall_status,
        "timestamp": str(datetime.now()),
        "analysis": analysis,
    }
    vitals_history.append(dict(latest_vitals))
    if len(vitals_history) > 30:
        vitals_history.pop(0)

    return {
        "status": "success",
        "message": "Vitals updated successfully",
        "analysis": analysis,
    }


@app.get("/api/vitals/latest")
def get_latest_vitals():
    global latest_vitals
    return {"status": "success", "data": latest_vitals}


@app.get("/api/vitals/history")
def get_vitals_history():
    global vitals_history
    return {"status": "success", "history": vitals_history}


@app.post("/api/ai/chat")
def ai_health_chat(request: AIChatRequest):
    user_query = request.prompt
    vitals = request.current_vitals if request.current_vitals else latest_vitals
    anomaly_info = latest_vitals.get("analysis", {})

    system_prompt = f"""
    You are HealthNova, an advanced, empathetic Clinical AI Copilot integrated into a health monitoring app.
    You can fluently speak and understand English, Hindi, Hinglish, and Urdu (both Roman Urdu and Urdu script). Match the user's language style naturally.

    Current live vital signs of the user:
    - Heart Rate: {vitals.get('heart_rate', 78)} BPM
    - SpO2: {vitals.get('spo2', 98)}%
    - Temperature: {vitals.get('temperature', 98.4)} °F
    - Fall Status: {vitals.get('fall_status', 'Normal')}
    - Anomaly Detection: {anomaly_info}

    User query: "{user_query}"

    Instructions: Provide a natural, concise, intelligent, and contextual response based on the user's query, live vitals, and anomaly detection status.
    """

    models_to_try = ["gemini-3.5-flash-lite"]
    ai_reply = None
    last_error = None

    for model_name in models_to_try:
        try:
            response = client.models.generate_content(
                model=model_name,
                contents=system_prompt,
            )
            if response and response.text:
                ai_reply = response.text
                break
        except Exception as e:
            last_error = str(e)

    if not ai_reply:
        ai_reply = f"Bhai API error aa gayi: {last_error}"

    return {"status": "success", "response": ai_reply}