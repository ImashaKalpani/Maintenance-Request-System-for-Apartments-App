import 'package:flutter/material.dart';
import 'onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnim = Tween<double>(
      begin: 0.7,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Auto navigate after delay
    Future.delayed(const Duration(seconds: 8), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(254, 254, 254, 1),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Circle - LARGER SIZE
                Container(
                  width: 250, // <-- 180 ගෙන් 250 දක්වා වැඩි කළා
                  height: 250, // <-- 180 ගෙන් 250 දක්වා වැඩි කළා
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 250, // <-- 400 ගෙන් 250 දක්වා සුදුසු කළා
                      height: 250, // <-- 400 ගෙන් 250 දක්වා සුදුසු කළා
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                const Text(
                  "FixMate",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D3E72),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Streamlined Property Care",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 136, 136, 136),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
