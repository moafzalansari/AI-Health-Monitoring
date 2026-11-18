import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIInsightsTab extends StatefulWidget {
  @override
  _AIInsightsTabState createState() => _AIInsightsTabState();
}

class _AIInsightsTabState extends State<AIInsightsTab> {
  bool _isLoading = false;
  String _aiResponse = "Tap the button below to analyze current patient vitals using Google Gemini AI.";

  Future<void> _fetchAIInsights() async {
    setState(() {
      _isLoading = true;
      _aiResponse = "Analyzing vitals and generating clinical insights...";
    });

    try {
      // FastAPI backend endpoint (ensure your FastAPI server is running on port 8000)
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/ai-insights'), 
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _aiResponse = data['insight'] ?? "Patient vitals look stable. No immediate anomalies detected.";
        });
      } else {
        setState(() {
          _aiResponse = "Error: Failed to fetch AI insights from backend server.";
        });
      }
    } catch (e) {
      setState(() {
        _aiResponse = "Connection Error: Make sure FastAPI backend is running.\nDetails: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.psychology, size: 50, color: Colors.blueAccent),
                  SizedBox(height: 10),
                  Text(
                    "HealthNova AI Clinical Copilot",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _aiResponse,
                      style: TextStyle(fontSize: 15, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _fetchAIInsights,
            icon: _isLoading 
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Icon(Icons.refresh),
            label: Text(_isLoading ? "Analyzing..." : "Get AI Vitals Analysis"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}