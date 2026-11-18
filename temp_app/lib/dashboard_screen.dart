import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeDashboardTab(),
    AnalyticsTab(),
    AIInsightsTab(),
    AlertsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070B),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B101D),
          border: Border(
            top: BorderSide(color: const Color(0xFF00F2FE).withOpacity(0.2), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF00F2FE),
          unselectedItemColor: Colors.white60,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Analytics'),
            BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), activeIcon: Icon(Icons.psychology), label: 'AI Insights'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Alerts'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 1. HOME TAB (API Integrated with Auto-Polling)
// ==========================================
class HomeDashboardTab extends StatefulWidget {
  const HomeDashboardTab({Key? key}) : super(key: key);

  @override
  _HomeDashboardTabState createState() => _HomeDashboardTabState();
}

class _HomeDashboardTabState extends State<HomeDashboardTab> {
  Map<String, dynamic> vitalsData = {
    "heart_rate": "--",
    "spo2": "--",
    "body_temp": "--",
    "fall_status": "Connecting..."
  };
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchVitals();
    // Har 3 seconds mein automatic background data fetch karega (Real-time IoT feel ke liye)
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) => fetchVitals());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Memory leak se bachne ke liye timer cancel karna zaroori hai
    super.dispose();
  }

  // FastAPI backend se data fetch karne ka function
  Future<void> fetchVitals() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/vitals/latest'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (mounted) {
          setState(() {
            vitalsData = jsonResponse['data'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          vitalsData["fall_status"] = "Server Error";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.monitor_heart, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              "HEALTHNOVA AI",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00F2FE)),
            onPressed: fetchVitals,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white60),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF00F2FE).withOpacity(0.15), const Color(0xFF131C31)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("PERSONAL HEALTH SCORE", style: TextStyle(color: Colors.white60, fontSize: 11, letterSpacing: 1.2)),
                      SizedBox(height: 6),
                      Text("94 / 100", style: TextStyle(color: Color(0xFF00F2FE), fontSize: 28, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("Status: Optimal & Stable", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.verified_user, color: Colors.greenAccent, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("CONNECTED IoT HARDWARE", style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 1.2)),
            const SizedBox(height: 10),
            const Row(
              children: [
                Expanded(child: IoTChipCard(name: "ESP32 MCU", status: "Online", icon: Icons.memory, color: Color(0xFF00F2FE))),
                SizedBox(width: 10),
                Expanded(child: IoTChipCard(name: "MAX30102", status: "Active", icon: Icons.favorite, color: Colors.redAccent)),
                SizedBox(width: 10),
                Expanded(child: IoTChipCard(name: "MPU6050", status: "Tracking", icon: Icons.explore, color: Colors.amberAccent)),
              ],
            ),
            const SizedBox(height: 25),
            const Text("LIVE BIOMETRIC VITALS (API CONNECTED)", style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 1.2)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                VitalCard(title: "HEART RATE", value: "${vitalsData['heart_rate']} BPM", subtitle: "Normal Range", icon: Icons.favorite, color: Colors.redAccent),
                VitalCard(title: "SPO2 LEVEL", value: "${vitalsData['spo2']} %", subtitle: "High Oxygen", icon: Icons.air, color: const Color(0xFF00F2FE)),
                VitalCard(title: "BODY TEMP", value: "${vitalsData['body_temp']} °F", subtitle: "Normal", icon: Icons.thermostat, color: Colors.orangeAccent),
                VitalCard(title: "FALL STATUS", value: "${vitalsData['fall_status']}", subtitle: "Sensor Status", icon: Icons.accessibility_new, color: Colors.greenAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. ANALYTICS TAB
// ==========================================
class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Health Analytics & Trends", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("24-HOUR HEART RATE TREND", style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0B101D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Avg: 75 BPM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("Peak: 92 BPM", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [40, 60, 50, 80, 70, 90, 65, 75, 85, 70].map((val) {
                      return Container(
                        width: 16,
                        height: val.toDouble() * 1.4,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)]),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  const Center(child: Text("Time intervals (00:00 to 24:00)", style: TextStyle(color: Colors.white38, fontSize: 10))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("DAILY SUMMARY & SLEEP QUALITY", style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0B101D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: const Column(
                children: [
                  SummaryRow(title: "Sleep Duration", value: "7 hrs 45 mins", icon: Icons.nightlight_round),
                  Divider(color: Colors.white12, height: 20),
                  SummaryRow(title: "Step Count", value: "8,432 steps", icon: Icons.directions_walk),
                  Divider(color: Colors.white12, height: 20),
                  SummaryRow(title: "Stress Index", value: "Low (Normal)", icon: Icons.mood),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. AI INSIGHTS TAB
// ==========================================
class AIInsightsTab extends StatelessWidget {
  const AIInsightsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Explainable AI Insights", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF00F2FE).withOpacity(0.1), const Color(0xFF0B101D)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Color(0xFF00F2FE)),
                      SizedBox(width: 8),
                      Text("Why did AI flag this?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "AI Diagnostics Engine evaluated recent sensor streams from MAX30102 and MPU6050. No irregular anomaly detected in past 12 hours.",
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("DIAGNOSTIC EXPLANATION TIMELINE", style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            const AIExplanationCard(time: "14:32 Today", title: "Heart Rate Spike Analysis", desc: "Slight elevation due to physical activity. Normal recovery curve observed."),
            const AIExplanationCard(time: "09:15 Today", title: "Fall Detection Sensor Check", desc: "MPU6050 accelerometer calibrated successfully. Zero impact shocks recorded."),
            const AIExplanationCard(time: "Yesterday", title: "SpO2 Baseline Assessment", desc: "Oxygen saturation maintained above 97% consistently throughout sleep cycle."),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. ALERTS TAB
// ==========================================
class AlertsTab extends StatelessWidget {
  const AlertsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Smart Alerts & Timeline", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          AlertTimelineCard(title: "System Armed & Secure", time: "08:00 AM", statusColor: Color(0xFF00F2FE), icon: Icons.security),
          AlertTimelineCard(title: "ESP32 Sensor Handshake OK", time: "08:02 AM", statusColor: Colors.greenAccent, icon: Icons.check_circle_outline),
          AlertTimelineCard(title: "Routine Vital Check Completed", time: "11:30 AM", statusColor: Colors.greenAccent, icon: Icons.favorite_border),
          AlertTimelineCard(title: "Low Battery Warning (MAX30102)", time: "02:15 PM", statusColor: Colors.orangeAccent, icon: Icons.battery_alert),
        ],
      ),
    );
  }
}

// ==========================================
// 5. PROFILE TAB
// ==========================================
class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("User Profile", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00F2FE), width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF0B101D),
                      child: Icon(Icons.person, size: 40, color: Color(0xFF00F2FE)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("HealthNova User", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("Standard Account | IoT Dashboard", style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0B101D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.email_outlined, color: Color(0xFF00F2FE)),
                    title: Text("Email", style: TextStyle(color: Colors.white60, fontSize: 12)),
                    subtitle: Text("user@email.com", style: TextStyle(color: Colors.white)),
                  ),
                  Divider(color: Colors.white12, height: 1),
                  ListTile(
                    leading: Icon(Icons.security, color: Color(0xFF00F2FE)),
                    title: Text("Account Security", style: TextStyle(color: Colors.white60, fontSize: 12)),
                    subtitle: Text("Encrypted OAuth Connected", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// REUSABLE HELPER WIDGETS
// ==========================================
class IoTChipCard extends StatelessWidget {
  final String name;
  final String status;
  final IconData icon;
  final Color color;

  const IoTChipCard({Key? key, required this.name, required this.status, required this.icon, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B101D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(status, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}

class VitalCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const VitalCard({Key? key, required this.title, required this.value, required this.subtitle, required this.icon, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B101D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1.0)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const SummaryRow({Key? key, required this.title, required this.value, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF00F2FE), size: 20),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

class AIExplanationCard extends StatelessWidget {
  final String time;
  final String title;
  final String desc;

  const AIExplanationCard({Key? key, required this.time, required this.title, required this.desc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B101D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(time, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.3)),
        ,
      ],
      ),
    );
  }
}

class AlertTimelineCard extends StatelessWidget {
  final String title;
  final String time;
  final Color statusColor;
  final IconData icon;

  const AlertTimelineCard({Key? key, required this.title, required this.time, required this.statusColor, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B101D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}