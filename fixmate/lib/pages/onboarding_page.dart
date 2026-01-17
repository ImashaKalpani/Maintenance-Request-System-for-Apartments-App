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
                children: const [
                  Text(
                    "Skip",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00A8C6),
                    ),
                  ),
                ],
              ),
            ),

            // Centered Image Section - SMALLER
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      "assets/images/apartment.png",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height:
                          400, // <-- 450 ගෙන් 350 ක් දක්වා අඩු කළා (100 කින් අඩු)
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Content Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Title
                  const Text(
                    "Quick & Reliable\nMaintenance",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D2A47),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Subtitle
                  const Text(
                    "From leaky faucets to electrical fixes, our team is just a tap away — ensuring your home stays safe and functional.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.45,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // GET STARTED BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A8C6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 5,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Get Started",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
