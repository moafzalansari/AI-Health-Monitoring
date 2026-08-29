import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Animation controller for button scale effect
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Navigate to Dashboard with smooth transition
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Icon with glowing shadow
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.monitor_heart_rounded,
                  color: Color(0xFF38BDF8),
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'AI Health Monitor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Real-time IoT Vitals Tracking',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 40),

              // Email Input Field
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_rounded, color: Color(0xFF38BDF8), size: 20),
                  hintText: 'Email Address',
                  hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF111827),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Input Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFF38BDF8), size: 20),
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF111827),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Animated Login Button with Press Effect
              GestureDetector(
                onTapDown: (_) => _animController.forward(),
                onTapUp: (_) {
                  _animController.reverse();
                  _handleLogin();
                },
                onTapCancel: () => _animController.reverse(),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 0.96).animate(_animController),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFF070B19),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Divider (Or connect with)
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ),
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                ],
              ),
              const SizedBox(height: 20),

              // Sign in with Google Button
              GestureDetector(
                onTap: () {
                  _handleLogin();
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google colored icon representation
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          'G',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}