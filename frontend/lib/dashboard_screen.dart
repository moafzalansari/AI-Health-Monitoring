import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const AnalyticsTab(),
    const AiInsightsTab(),
    const AlertsTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0F172A),
          selectedItemColor: const Color(0xFF38BDF8),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Analytics'),
            BottomNavigationBarItem(icon: Icon(Icons.psychology_rounded), label: 'AI Insights'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// ==================== 1. HOME TAB (HealthNova AI Dashboard with Animations) ====================
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  int _heartRate = 78;
  int _spo2 = 98;
  double _temperature = 98.6;
  String _fallStatus = 'Stable';
  
  late Timer _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final String apiUrl = "http://127.0.0.1:8000/api/vitals/latest";

  @override
  void initState() {
    super.initState();
    
    // Heartbeat Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Hardware Badge Glowing Animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    fetchLatestVitals();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      fetchLatestVitals();
    });
  }

  Future<void> fetchLatestVitals() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _heartRate = data['heart_rate'] ?? 78;
            _spo2 = data['spo2'] ?? 98;
            _temperature = (data['temperature'] ?? 98.6).toDouble();
            _fallStatus = data['fall_status'] ?? 'Stable';
          });
        }
      }
    } catch (e) {
      print("Error fetching backend vitals: $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(_glowAnimation.value),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'HEALTHNOVA AI',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded, color: Color(0xFF38BDF8)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Health Score Card with Gradient Glow
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withOpacity(0.08),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('PERSONAL HEALTH SCORE', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      SizedBox(height: 6),
                      Text('94 / 100', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Status: Optimal & Stable', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Connected Hardware Status
            const Text('CONNECTED IOT HARDWARE', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 10),
            Row(
              children: const [
                HardwareBadge(title: 'ESP32 MCU', subtitle: 'Online', color: Colors.greenAccent, icon: Icons.wifi),
                SizedBox(width: 8),
                HardwareBadge(title: 'MAX30102', subtitle: 'Active', color: Color(0xFF38BDF8), icon: Icons.favorite),
                SizedBox(width: 8),
                HardwareBadge(title: 'MPU6050', subtitle: 'Tracking', color: Colors.orangeAccent, icon: Icons.shield),
              ],
            ),
            const SizedBox(height: 20),

            // Live Biometric Vitals Header
            const Text('LIVE BIOMETRIC VITALS', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 10),

            // Vitals Grid with Animated Heart Rate
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                // Heart Rate Card with Pulsing Icon
                AnimatedVitalsCard(
                  title: 'HEART RATE',
                  value: '$_heartRate',
                  unit: 'BPM',
                  subText: 'Normal Range',
                  icon: Icons.favorite,
                  color: Colors.redAccent,
                  isPulsing: true,
                  pulseAnimation: _pulseAnimation,
                ),
                VitalsCard(title: 'SPO2 LEVEL', value: '$_spo2', unit: '%', subText: 'High Oxygen', icon: Icons.air, color: const Color(0xFF38BDF8)),
                VitalsCard(title: 'BODY TEMP', value: '$_temperature', unit: '°F', subText: 'Normal', icon: Icons.thermostat, color: Colors.orangeAccent),
                VitalsCard(title: 'FALL STATUS', value: _fallStatus, unit: '', subText: 'No Fall Detected', icon: Icons.security, color: Colors.greenAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HardwareBadge extends StatelessWidget {
  final String title, subtitle;
  final Color color;
  final IconData icon;
  const HardwareBadge({super.key, required this.title, required this.subtitle, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 6, spreadRadius: 1)
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            Text(subtitle, style: TextStyle(color: color, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class VitalsCard extends StatelessWidget {
  final String title, value, unit, subText;
  final IconData icon;
  final Color color;
  const VitalsCard({super.key, required this.title, required this.value, required this.unit, required this.subText, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(unit, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Text(subText, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}

class AnimatedVitalsCard extends StatelessWidget {
  final String title, value, unit, subText;
  final IconData icon;
  final Color color;
  final bool isPulsing;
  final Animation<double>? pulseAnimation;

  const AnimatedVitalsCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.subText,
    required this.icon,
    required this.color,
    this.isPulsing = false,
    this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              isPulsing && pulseAnimation != null
                  ? ScaleTransition(
                      scale: pulseAnimation!,
                      child: Icon(icon, color: color, size: 20),
                    )
                  : Icon(icon, color: color, size: 18),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(unit, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Text(subText, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}

// ==================== 2. ANALYTICS TAB (Live Graph Added) ====================
class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  List<FlSpot> analyticsSpots = [
    const FlSpot(0, 72),
    const FlSpot(1, 75),
    const FlSpot(2, 78),
    const FlSpot(3, 74),
    const FlSpot(4, 82),
    const FlSpot(5, 79),
    const FlSpot(6, 76),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Health Analytics & Trends', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('LIVE HEART RATE TREND', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Avg: 76 BPM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('Peak: 82 BPM', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Real Fl_Chart Line Graph
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: analyticsSpots,
                            isCurved: true,
                            color: const Color(0xFF38BDF8),
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFF38BDF8).withOpacity(0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('DAILY SUMMARY & SLEEP QUALITY', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
              child: Column(
                children: const [
                  ListTile(leading: Icon(Icons.nightlight_round, color: Color(0xFF38BDF8)), title: Text('Sleep Duration', style: TextStyle(color: Colors.white)), trailing: Text('7 hrs 45 mins', style: TextStyle(color: Colors.white70))),
                  Divider(color: Colors.white12),
                  ListTile(leading: Icon(Icons.directions_walk, color: Colors.greenAccent), title: Text('Step Count', style: TextStyle(color: Colors.white)), trailing: Text('8,432 steps', style: TextStyle(color: Colors.white70))),
                  Divider(color: Colors.white12),
                  ListTile(leading: Icon(Icons.psychology, color: Colors.orangeAccent), title: Text('Stress Index', style: TextStyle(color: Colors.white)), trailing: Text('Low (Normal)', style: TextStyle(color: Colors.greenAccent))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 3. AI INSIGHTS / CHATBOT TAB ====================
class AiInsightsTab extends StatefulWidget {
  const AiInsightsTab({super.key});

  @override
  State<AiInsightsTab> createState() => _AiInsightsTabState();
}

class _AiInsightsTabState extends State<AiInsightsTab> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      "sender": "ai",
      "text": "Hello! I am your HealthNova AI Assistant. Ask me anything about your current vitals, heart rate trends, or health recommendations."
    }
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    String userText = _messageController.text;
    setState(() {
      _messages.add({"sender": "user", "text": userText});
      _messageController.clear();
    });

    // Simulating smart AI Medical response based on queries
    Future.delayed(const Duration(milliseconds: 800), () {
      String aiResponse = "Based on your recent IoT telemetry, your vitals are stable. However, stay hydrated and maintain a regular resting schedule.";
      
      if (userText.toLowerCase().contains('heart rate') || userText.toLowerCase().contains('bpm')) {
        aiResponse = "Your current heart rate is within the normal operating range (72-82 BPM). Excellent cardiovascular rhythm observed!";
      } else if (userText.toLowerCase().contains('spo2') || userText.toLowerCase().contains('oxygen')) {
        aiResponse = "Your blood oxygen saturation (SpO2) is optimal at 98%. Cellular oxygenation is running perfectly.";
      } else if (userText.toLowerCase().contains('fall') || userText.toLowerCase().contains('emergency')) {
        aiResponse = "MPU6050 accelerometer status is secure. No sudden shocks or impact anomalies have been detected.";
      }

      if (mounted) {
        setState(() {
          _messages.add({"sender": "ai", "text": aiResponse});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Row(
          children: [
            Icon(Icons.psychology_rounded, color: Color(0xFF38BDF8), size: 20),
            SizedBox(width: 8),
            Text('AI Medical Insights & Chat', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUser = message["sender"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF38BDF8).withOpacity(0.2) : const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isUser ? const Color(0xFF38BDF8) : Colors.white12,
                      ),
                    ),
                    child: Text(
                      message["text"]!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Ask AI about your heart rate, SpO2...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF111827),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: Color(0xFF38BDF8)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ==================== 4. ALERTS TAB ====================
class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      appBar: AppBar(backgroundColor: const Color(0xFF0F172A), title: const Text('Smart Alerts & Timeline', style: TextStyle(color: Colors.white, fontSize: 16))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          AlertTile(title: 'System Armed & Secure', time: '08:00 AM', icon: Icons.security, color: Color(0xFF38BDF8)),
          AlertTile(title: 'ESP32 Sensor Handshake OK', time: '08:02 AM', icon: Icons.check_circle, color: Colors.greenAccent),
          AlertTile(title: 'Routine Vital Check Completed', time: '11:30 AM', icon: Icons.favorite, color: Colors.blueAccent),
          AlertTile(title: 'Low Battery Warning (MAX30102)', time: '02:15 PM', icon: Icons.battery_alert, color: Colors.orangeAccent),
        ],
      ),
    );
  }
}

class AlertTile extends StatelessWidget {
  final String title, time;
  final IconData icon;
  final Color color;
  const AlertTile({super.key, required this.title, required this.time, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 4. PROFILE & EMERGENCY CONTACTS TAB ====================
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final TextEditingController _nameController = TextEditingController(text: "Mo Afzal Ansari");
  final TextEditingController _ageController = TextEditingController(text: "22");
  final TextEditingController _bloodController = TextEditingController(text: "O+ve");
  final TextEditingController _contactController = TextEditingController(text: "+91 9876543210");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Patient Profile & Emergency', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Color(0xFF1E293B),
                child: Icon(Icons.person, size: 35, color: Color(0xFF38BDF8)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('PERSONAL & MEDICAL INFO', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // Full Name
            const Text('Full Name', style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 4),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF111827),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),

            // Age & Blood Group
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Age', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _ageController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF111827),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Blood Group', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _bloodController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF111827),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Emergency Contact
            const Text('Emergency Contact Number', style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 4),
            TextField(
              controller: _contactController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF111827),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile details updated successfully!')),
                  );
                },
                child: const Text('Save Details', style: TextStyle(color: Color(0xFF070B19), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}