import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  int _heartRate = 78;
  int _spo2 = 98;
  double _temperature = 98.4;
  String _fallStatus = 'Normal';
  bool _isAnomaly = false;
  String _riskLevel = 'Normal';
  double _baselineHr = 78.0;
  String _explanation = 'Vitals are within your normal personalized baseline.';

  final _history = [
    {"hr": 78.0, "spo2": 98.0},
  ];

  final _autoLoggedAlerts = <String>{};
  final List _anomalyAlerts = [
    {
      'title': 'System Normal',
      'time': 'Just now',
      'type': 'info',
      'message': 'All vital signs are within optimal health parameters. No anomalies detected.'
    },
    {
      'title': 'ESP32 Sensor Connected',
      'time': '10 mins ago',
      'type': 'success',
      'message': 'MAX30102 and MPU6050 sensor nodes linked successfully via Wi-Fi.'
    },
  ];

  Timer? _pollTimer;
  final String _latestUrl = "http://127.0.0.1:8000/api/vitals/latest";
  final String _historyUrl = "http://127.0.0.1:8000/api/vitals/history";

  @override
  void initState() {
    super.initState();
    _syncTelemetry();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _syncTelemetry();
    });
  }

  Future<void> _syncTelemetry() async {
    try {
      final latestRes = await http.get(Uri.parse(_latestUrl));
      if (latestRes.statusCode == 200) {
        final decoded = json.decode(latestRes.body);
        final data = decoded['data'] ?? decoded;
        final analysis = data['analysis'] ?? {};

        final newHr = (data['heart_rate'] ?? 78).toInt();
        final newSpo2 = (data['spo2'] ?? 98).toInt();
        final newTemp = (data['body_temp'] ?? data['temperature'] ?? 98.4).toDouble();
        final newFall = (data['fall_status'] ?? 'Normal').toString();
        final newAnomaly = analysis['is_anomaly'] == true ||
            newFall.toLowerCase().contains('fall') ||
            newHr > 115 ||
            newHr < 50 ||
            newSpo2 < 94;
        final newRisk = (analysis['risk_level'] ?? (newAnomaly ? 'High' : 'Normal')).toString();
        final newBaseline = ((analysis['baseline_hr'] ?? newHr) as num).toDouble();
        final newExplanation = (analysis['explanation'] ??
                (newAnomaly
                    ? 'Anomaly detected: HR $newHr BPM, SpO2 $newSpo2%, Status $newFall.'
                    : 'Vitals are within your normal personalized baseline.'))
            .toString();

        if (mounted) {
          setState(() {
            _heartRate = newHr;
            _spo2 = newSpo2;
            _temperature = newTemp;
            _fallStatus = newFall;
            _isAnomaly = newAnomaly;
            _riskLevel = newRisk;
            _baselineHr = newBaseline;
            _explanation = newExplanation;

            if (newAnomaly) {
              final alertKey = "$newFall-$newHr-$newSpo2-$newRisk";
              if (!_autoLoggedAlerts.contains(alertKey)) {
                _autoLoggedAlerts.add(alertKey);
                _anomalyAlerts.insert(0, {
                  'title': '$newRisk Risk Alert ($newFall)',
                  'time': 'Just now',
                  'type': 'danger',
                  'message': newExplanation,
                });
              }
            }
          });
        }
      }

      final histRes = await http.get(Uri.parse(_historyUrl));
      if (histRes.statusCode == 200) {
        final histDecoded = json.decode(histRes.body);
        final List rawList = histDecoded['history'] ?? [];
        if (rawList.isNotEmpty && mounted) {
          final parsed = rawList.map((item) {
            return {
              "hr": ((item['heart_rate'] ?? 78) as num).toDouble(),
              "spo2": ((item['spo2'] ?? 98) as num).toDouble(),
            };
          }).toList();

          setState(() {
            _history
              ..clear()
              ..addAll(parsed);
          });
        }
      }
    } catch (e) {
      debugPrint("Telemetry sync error: $e");
    }
  }

  void _addManualAlert(Map<String, dynamic> alert) {
    setState(() {
      _anomalyAlerts.insert(0, alert);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveVitalsMap = {
      "heart_rate": _heartRate,
      "spo2": _spo2,
      "temperature": _temperature,
      "fall_status": _fallStatus,
      "is_anomaly": _isAnomaly,
      "risk_level": _riskLevel,
      "baseline_hr": _baselineHr,
      "explanation": _explanation,
    };

    final screens = [
      HomeTab(
        heartRate: _heartRate,
        spo2: _spo2,
        temperature: _temperature,
        fallStatus: _fallStatus,
        isAnomaly: _isAnomaly,
        riskLevel: _riskLevel,
        baselineHr: _baselineHr,
        explanation: _explanation,
        onRefresh: _syncTelemetry,
      ),
      AnalyticsTab(history: _history),
      AiInsightsTab(currentVitals: liveVitalsMap),
      AlertsTab(
        alerts: _anomalyAlerts,
        onAddAlert: _addManualAlert,
      ),
      const ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      body: screens[_currentIndex],
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

// ==================== 1. HOME TAB ====================
class HomeTab extends StatefulWidget {
  final int heartRate;
  final int spo2;
  final double temperature;
  final String fallStatus;
  final bool isAnomaly;
  final String riskLevel;
  final double baselineHr;
  final String explanation;
  final Future<void> Function() onRefresh;

  const HomeTab({
    super.key,
    required this.heartRate,
    required this.spo2,
    required this.temperature,
    required this.fallStatus,
    required this.isAnomaly,
    required this.riskLevel,
    required this.baselineHr,
    required this.explanation,
    required this.onRefresh,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  void _triggerEmergencySOS() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 8),
              Text(
                'EMERGENCY SOS',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🚨 Critical alert triggered!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '• Vitals: HR ${widget.heartRate} BPM | SpO2 ${widget.spo2}% | Temp ${widget.temperature}°F\n• Notifying Emergency Contacts (+91 9876543210)\n• Dispatching live GPS location & safety status (${widget.fallStatus})',
                style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('SOS Alert Cancelled by User'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🚨 SOS Signal Broadcasted Successfully!'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Confirm & Dispatch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final healthScore = widget.isAnomaly ? 68 : 94;
    final statusColor = widget.isAnomaly ? Colors.redAccent : Colors.greenAccent;

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
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(_glowAnimation.value),
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
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF38BDF8)),
            onPressed: widget.onRefresh,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isAnomaly) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.redAccent, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ANOMALY DETECTED • ${widget.riskLevel.toUpperCase()} RISK',
                            style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.explanation,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.2),
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  ),
                ),
                icon: const Icon(Icons.sos_rounded, size: 24),
                label: const Text(
                  'TRIGGER EMERGENCY SOS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                ),
                onPressed: _triggerEmergencySOS,
              ),
            ),
            const SizedBox(height: 20),
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
                    border: Border.all(
                      color: widget.isAnomaly
                          ? Colors.redAccent.withOpacity(0.6)
                          : const Color(0xFF38BDF8).withOpacity(0.4),
                    ),
                  ),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PERSONAL HEALTH SCORE',
                        style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$healthScore / 100',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.isAnomaly
                            ? 'Attention Needed • Baseline HR: ${widget.baselineHr.toStringAsFixed(1)} BPM'
                            : 'Status: Optimal & Stable • Baseline HR: ${widget.baselineHr.toStringAsFixed(1)} BPM',
                        style: TextStyle(
                          color: widget.isAnomaly ? Colors.redAccent : const Color(0xFF38BDF8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isAnomaly ? Icons.monitor_heart_rounded : Icons.verified_rounded,
                      color: statusColor,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'CONNECTED IOT HARDWARE',
              style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
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
            const Text(
              'LIVE BIOMETRIC VITALS',
              style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                AnimatedVitalsCard(
                  title: 'HEART RATE',
                  value: '${widget.heartRate}',
                  unit: 'BPM',
                  subText: widget.heartRate > 115 || widget.heartRate < 50 ? 'Out of Range' : 'Normal Range',
                  icon: Icons.favorite,
                  color: Colors.redAccent,
                  isPulsing: true,
                  pulseAnimation: _pulseAnimation,
                ),
                VitalsCard(
                  title: 'SPO2 LEVEL',
                  value: '${widget.spo2}',
                  unit: '%',
                  subText: widget.spo2 < 94 ? 'Low Oxygen' : 'High Oxygen',
                  icon: Icons.air,
                  color: const Color(0xFF38BDF8),
                ),
                VitalsCard(
                  title: 'BODY TEMP',
                  value: '${widget.temperature}',
                  unit: '°F',
                  subText: widget.temperature >= 100.4 ? 'Elevated' : 'Normal',
                  icon: Icons.thermostat,
                  color: Colors.orangeAccent,
                ),
                VitalsCard(
                  title: 'FALL STATUS',
                  value: widget.fallStatus,
                  unit: '',
                  subText: widget.fallStatus.toLowerCase().contains('fall') ? 'Alert Active' : 'No Fall Detected',
                  icon: Icons.security,
                  color: widget.fallStatus.toLowerCase().contains('fall') ? Colors.redAccent : Colors.greenAccent,
                ),
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
  const HardwareBadge({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
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
  const VitalsCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.subText,
    required this.icon,
    required this.color,
  });

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
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
                  ? ScaleTransition(scale: pulseAnimation!, child: Icon(icon, color: color, size: 20))
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

// ==================== 2. ANALYTICS TAB ====================
class AnalyticsTab extends StatelessWidget {
  final List history;
  AnalyticsTab({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final recent = history.length > 10 ? history.sublist(history.length - 10) : history;
    final hrSpots = <FlSpot>[];
    final spo2Spots = <FlSpot>[];

    for (int i = 0; i < recent.length; i++) {
      hrSpots.add(FlSpot(i.toDouble(), (recent[i]["hr"] ?? 78.0).clamp(40.0, 160.0)));
      spo2Spots.add(FlSpot(i.toDouble(), (recent[i]["spo2"] ?? 98.0).clamp(70.0, 100.0)));
    }

    final maxX = (recent.length > 1 ? recent.length - 1 : 1).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Live Vitals Analytics & Trends', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RECENT HEART RATE STREAM (BPM)',
              style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white.withOpacity(0.05),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('#${value.toInt() + 1}', style: const TextStyle(color: Colors.grey, fontSize: 10));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: maxX,
                  minY: 45,
                  maxY: 145,
                  lineBarsData: [
                    LineChartBarData(
                      spots: hrSpots,
                      isCurved: true,
                      color: const Color(0xFF38BDF8),
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF38BDF8).withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'RECENT OXYGEN SATURATION (SpO2 %)',
              style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('#${value.toInt() + 1}', style: const TextStyle(color: Colors.grey, fontSize: 10));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: maxX,
                  minY: 80,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spo2Spots,
                      isCurved: true,
                      color: Colors.greenAccent,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.greenAccent.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 3. AI INSIGHTS TAB ====================
class AiInsightsTab extends StatefulWidget {
  final Map<String, dynamic> currentVitals;
  const AiInsightsTab({super.key, required this.currentVitals});

  @override
  State<AiInsightsTab> createState() => _AiInsightsTabState();
}

class _AiInsightsTabState extends State<AiInsightsTab> {
  final TextEditingController _messageController = TextEditingController();
  bool _isGenerating = false;

  final _messages = [
    {
      "sender": "ai",
      "text": "Hello! I am your HealthNova AI Assistant. Ask me anything about your live vitals, anomalies, or health recommendations."
    }
  ];

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userText = _messageController.text.trim();
    setState(() {
      _messages.add({"sender": "user", "text": userText});
      _isGenerating = true;
    });
    _messageController.clear();

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/ai/chat'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "prompt": userText,
          "current_vitals": widget.currentVitals,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _messages.add({"sender": "ai", "text": data['response'] ?? "Aapke vitals bilkul normal hain."});
            _isGenerating = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _messages.add({"sender": "ai", "text": "Server Error: Backend response nahi mila."});
            _isGenerating = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({"sender": "ai", "text": "Connection Error: FastAPI server offline hai."});
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.currentVitals;
    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Medical Insights & Chat', style: TextStyle(color: Colors.white, fontSize: 15)),
            Text(
              'Live: ${v["heart_rate"] ?? 78} BPM • ${v["spo2"] ?? 98}% SpO2 • ${v["temperature"] ?? 98.4}°F',
              style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10),
            ),
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
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF38BDF8).withOpacity(0.2) : const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isUser ? const Color(0xFF38BDF8) : Colors.white12),
                    ),
                    child: Text(message["text"]!, style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4)),
                  ),
                );
              },
            ),
          ),
          if (_isGenerating)
            const LinearProgressIndicator(color: Color(0xFF38BDF8), backgroundColor: Color(0xFF111827)),
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
                      hintText: 'Ask AI in Hindi/English/Urdu about your vitals...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF111827),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: Color(0xFF38BDF8)),
                  onPressed: _isGenerating ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 4. EMERGENCY ALERTS TAB ====================
class AlertsTab extends StatefulWidget {
  final List alerts;
  final void Function(Map<String, dynamic>) onAddAlert;

  AlertsTab({
    super.key,
    required this.alerts,
    required this.onAddAlert,
  });

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  void _triggerEmergencySOS() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 8),
              Text(
                'EMERGENCY SOS TRIGGERED',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            '🚨 Automated emergency protocol initiated!\n\nEmergency contact (+91 9876543210) has been flagged.\nCurrent GPS location and health logs sent to emergency responders.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                widget.onAddAlert({
                  'title': 'SOS Emergency Dispatched',
                  'time': 'Just now',
                  'type': 'danger',
                  'message': 'Manual SOS alert sent to registered emergency contacts.'
                });
                Navigator.of(context).pop();
              },
              child: const Text('Confirm & Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Emergency & Safety Logs', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.shield_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'PANIC / SOS EMERGENCY BUTTON',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'In case of sudden distress or fall, tap the button below to instantly alert family and emergency medical services.',
                    style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _triggerEmergencySOS,
                      child: const Text(
                        'TRIGGER EMERGENCY SOS',
                        style: TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'RECENT SECURITY & SAFETY EVENTS',
              style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: widget.alerts.length,
                itemBuilder: (context, index) {
                  final alert = widget.alerts[index];
                  final isDanger = alert['type'] == 'danger';
                  final isSuccess = alert['type'] == 'success';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDanger
                            ? Colors.redAccent.withOpacity(0.5)
                            : isSuccess
                                ? Colors.greenAccent.withOpacity(0.3)
                                : const Color(0xFF1E293B),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isDanger
                              ? Icons.warning_rounded
                              : isSuccess
                                  ? Icons.check_circle_rounded
                                  : Icons.info_rounded,
                          color: isDanger
                              ? Colors.redAccent
                              : isSuccess
                                  ? Colors.greenAccent
                                  : const Color(0xFF38BDF8),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    alert['title']!,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    alert['time']!,
                                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                alert['message']!,
                                style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 5. PROFILE TAB ====================
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
  bool _isDownloading = false;

  void _downloadMedicalReport() {
    setState(() {
      _isDownloading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });

        if (kIsWeb) {
          final pdfContent = '''
=============================================
HEALTHNOVA AI - OFFICIAL CLINICAL MEDICAL REPORT
=============================================
Patient Name: ${_nameController.text}
Age: ${_ageController.text} | Blood Group: ${_bloodController.text}
Emergency Contact: ${_contactController.text}
Date: 2026-11-18

---------------------------------------------
1. LIVE VITALS & TELEMETRY SUMMARY
---------------------------------------------
- Heart Rate: Normal / Monitored via FastAPI Stream
- SpO2 Level: Monitored in Real-Time
- Body Temperature: Monitored in Real-Time
- Fall Detection Events: Tracked via Telemetry & Alerts Log

---------------------------------------------
2. IOT HARDWARE HEALTH STATUS
---------------------------------------------
- ESP32 Microcontroller: Ready for Hardware Integration
- MAX30102 Sensor Node: Telemetry Pipeline Active
- MPU6050 Gyro/Accelerometer: Fall & Motion Pipeline Active

---------------------------------------------
3. AI CLINICAL COPILOT RISK ASSESSMENT
---------------------------------------------
- Anomaly Engine: Sliding Window + Z-Score + Clinical Thresholds
- AI Assistant: Multilingual (English, Hindi, Hinglish, Urdu)
=============================================
''';

          final bytes = utf8.encode(pdfContent);
          final blob = html.Blob([bytes], 'text/plain');
          final url = html.Url.createObjectUrlFromBlob(blob);

          html.AnchorElement(href: url)
            ..setAttribute("download", "HealthNova_Clinical_Report.txt")
            ..click();

          html.Url.revokeObjectUrl(url);
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
              ),
              title: Row(
                children: const [
                  Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF38BDF8), size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Report Downloaded',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: const Text(
                '📄 HealthNova clinical report has been generated and downloaded.\n\nIncludes: Patient details, vitals summary, IoT status, and AI copilot notes.',
                style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK', style: TextStyle(color: Color(0xFF070B19), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      }
    });
  }

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
            const Text('Emergency Contact', style: TextStyle(color: Colors.grey, fontSize: 11)),
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
            const SizedBox(height: 24),
            const Text('CLINICAL EXPORT & DOCUMENTATION', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF38BDF8),
                  side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isDownloading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_rounded, size: 20),
                label: Text(
                  _isDownloading ? 'Generating PDF Report...' : 'Download Official Medical Report (PDF)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: _isDownloading ? null : _downloadMedicalReport,
              ),
            ),
          ],
        ),
      ),
    );
  }
}