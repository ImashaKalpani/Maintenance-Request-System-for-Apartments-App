import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscure = true;
  final _email = TextEditingController();
  final _password = TextEditingController();

  // Validation states
  String? _emailError;
  String? _passwordError;

  void _login() {
    final email = _email.text.trim();
    final pass = _password.text.trim();

    // Reset errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validate email
    if (email.isEmpty) {
      setState(() {
        _emailError = "Required";
      });
    } else if (!_validEmail(email)) {
      setState(() {
        _emailError = "Invalid email";
      });
    }

    // Validate password
    if (pass.isEmpty) {
      setState(() {
        _passwordError = "Required";
      });
    } else if (pass.length < 6) {
      setState(() {
        _passwordError = "Min 6 characters";
      });
    }

    // Check if any errors exist
    if (_emailError != null || _passwordError != null) {
      return;
    }

    _showSnack('Login successful!');

    Future.delayed(const Duration(milliseconds: 700), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  bool _validEmail(String email) {
    return RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF00A8C6),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 30, left: 18, right: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  void _gotoSignup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignupPage()),
    );
  }

  void _forgotPassword() {
    _showSnack("Password reset link sent to email");
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              SizedBox(
                width: 150,
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Apartment FixMate",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D3E72),
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Apartment Maintenance System",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 32),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Email Address",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 6),

              _input(
                controller: _email,
                hint: "Enter your email",
                icon: Icons.email_outlined,
                errorText: _emailError,
                onChanged: (value) {
                  if (_emailError != null) {
                    setState(() {
                      _emailError = null;
                    });
                  }
                },
              ),

              const SizedBox(height: 14),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Password",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 6),

              _input(
                controller: _password,
                hint: "Enter your password",
                icon: Icons.lock_outline,
                obscure: _obscure,
                errorText: _passwordError,
                onChanged: (value) {
                  if (_passwordError != null) {
                    setState(() {
                      _passwordError = null;
                    });
                  }
                },
                suffix: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _forgotPassword,
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color(0xFF1D3E72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              GestureDetector(
                onTap: _login,
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A8C6), Color(0xFF0A5CFF)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _gotoSignup,
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1D3E72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _input({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  bool obscure = false,
  String? errorText,
  Widget? suffix,
  ValueChanged<String>? onChanged,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        errorText: errorText,
        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
