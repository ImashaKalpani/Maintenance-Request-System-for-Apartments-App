import 'package:flutter/material.dart';
import 'login_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(254, 255, 255, 1),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (top-right)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0A5CFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Center image
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      "assets/images/apartment.png",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 400, // ↓ Podda kala
                    ),
                  ),
                ),
              ),
            ),

            // Bottom content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Text(
                    "Quick & Reliable\nMaintenance",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26, // ↓ Podda kala (32 → 26)
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D2A47),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "From leaky faucets to electrical fixes, our team is just a tap away — ensuring your home stays safe and functional.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16, // ↓ Podda kala (18 → 16)
                      height: 1.45,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Get Started Button (Smaller)
                  SizedBox(
                    width: double.infinity,
                    height: 52, // ↓ Podda kala (60 → 52)
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00A8C6), Color(0xFF0A5CFF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0A5CFF).withOpacity(0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Get Started",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16, // ↓ Podda kala
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 22, // ↓ Podda kala
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
