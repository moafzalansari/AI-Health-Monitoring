import 'dart:async';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  // Simulated live values (Jab hardware aayega toh yahan real BLE data aayega)
  int _heartRate = 78;
  int _spo2 = 98;
  double _temperature = 98.4;
  String _fallStatus = 'Normal';
  
  late Timer _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    
    // Heartbeat pulsing animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Timer to simulate real-time live vitals fluctuation
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _heartRate = 75 + (DateTime.now().second % 7); // Fluctuates between 75-81
        _spo2 = 97 + (DateTime.now().second % 3);      // Fluctuates between 97-99
        _temperature = 98.2 + ((DateTime.now().second % 5) * 0.1);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B19), // Deep futuristic space-dark
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.monitor_heart, color: Color(0xFF38BDF8), size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'VIP Health Command',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded, color: Color(0xFF38BDF8)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All Systems Nominal. No alerts detected.')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // VIP Live Status Banner with Glassmorphism effect
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 0.9, end: 1.1).animate(_pulseController),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.security_rounded, color: Colors.greenAccent, size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'IOT STREAM ACTIVE',
                          style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'All Vitals Stable & Secure',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            
            const Text(
              'Real-Time Sensor Telemetry',
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
            ),
            const SizedBox(height: 15),

            // Grid of Vitals Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                VitalsCard(
                  title: 'Heart Rate',
                  value: '$_heartRate',
                  unit: 'BPM',
                  icon: Icons.favorite_rounded,
                  color: Colors.redAccent,
                  isPulsing: true,
                  animationController: _pulseController,
                ),
                VitalsCard(
                  title: 'Blood Oxygen',
                  value: '$_spo2',
                  unit: '% SpO2',
                  icon: Icons.air_rounded,
                  color: const Color(0xFF38BDF8),
                ),
                VitalsCard(
                  title: 'Body Temperature',
                  value: _temperature.toStringAsFixed(1),
                  unit: '°F',
                  icon: Icons.thermostat_rounded,
                  color: Colors.orangeAccent,
                ),
                VitalsCard(
                  title: 'Fall Detection',
                  value: _fallStatus,
                  unit: 'MPU6050',
                  icon: Icons.shield_rounded,
                  color: Colors.greenAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Premium Vitals Card with Glow
class VitalsCard extends StatelessWidget {
  const VitalsCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.isPulsing = false,
    this.animationController,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final bool isPulsing;
  final AnimationController? animationController;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(icon, color: color, size: 26);
    
    if (isPulsing && animationController != null) {
      iconWidget = ScaleTransition(
        scale: Tween(begin: 0.85, end: 1.15).animate(animationController!),
        child: icon,
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: iconWidget,
              ),
              Text(
                unit,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}