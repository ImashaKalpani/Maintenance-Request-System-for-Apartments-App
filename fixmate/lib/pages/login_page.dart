import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'main_container.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscure = true;
  final _email = TextEditingController();
  final _password = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  final _auth = AuthService();
  final _firestore = FirestoreService();

  Future<void> _login() async {
    final email = _email.text.trim();
    final pass = _password.text.trim();

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (email.isEmpty) {
      setState(() => _emailError = "Required");
    } else if (!_validEmail(email)) {
      setState(() => _emailError = "Invalid email");
    }

    if (pass.isEmpty) {
      setState(() => _passwordError = "Required");
    } else if (pass.length < 6) {
      setState(() => _passwordError = "Min 6 characters");
    }

    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);

    try {
      final user = await _auth.signIn(email, pass);

      if (user != null) {
        final data = await _firestore.getUser(user.uid);
        debugPrint("USER DATA: $data");

        _showSuccessSnack("Login successful!");

        Future.delayed(const Duration(milliseconds: 600), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainContainer()),
          );
        });
      } else {
        _showErrorSnack(
          "Invalid email or password. Please check your credentials.",
        );
      }
    } catch (e) {
      String errorMessage = "Login failed";

      if (e.toString().contains("invalid-credential")) {
        errorMessage =
            "Invalid email or password. Please check your credentials.";
      } else if (e.toString().contains("user-not-found")) {
        errorMessage =
            "No account found with this email. Please sign up first.";
      } else if (e.toString().contains("wrong-password")) {
        errorMessage = "Incorrect password. Please try again.";
      } else if (e.toString().contains("network-request-failed")) {
        errorMessage = "Network error. Please check your internet connection.";
      } else {
        errorMessage = "Login failed: ${e.toString()}";
      }

      _showErrorSnack(errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validEmail(String email) {
    return RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }

  void _forgotPassword() {
    final email = _email.text.trim();

    if (email.isEmpty || !_validEmail(email)) {
      _showForgotPasswordErrorSnack();
      return;
    }

    _showInfoSnack("Password reset link sent to $email");
    // TODO: Implement actual password reset functionality
    // await _auth.resetPassword(email);
  }

  void _showForgotPasswordErrorSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Please enter a valid email address to reset password",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 4000),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccessSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 4000),
        action: SnackBarAction(
          label: 'Sign Up',
          textColor: Colors.white,
          onPressed: () {
            _gotoSignup();
          },
        ),
      ),
    );
  }

  void _showInfoSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF00A8C6),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  void _gotoSignup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignupPage()),
    );
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
            crossAxisAlignment: CrossAxisAlignment.center,
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

              const SizedBox(height: 6),
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
                onChanged: (v) {
                  if (_emailError != null) setState(() => _emailError = null);
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
                suffix: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                onChanged: (v) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _forgotPassword,
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D3E72),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: _isLoading ? null : _login,
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: _isLoading
                        ? const LinearGradient(
                            colors: [Colors.grey, Colors.grey],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF00A8C6), Color(0xFF0A5CFF)],
                          ),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
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

              // Helper message for new users
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "New to Apartment FixMate? Create an account to get started.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _gotoSignup,
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Color(0xFF1D3E72),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
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
  return TextField(
    controller: controller,
    obscureText: obscure,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      suffixIcon: suffix,
      errorText: errorText,
      errorStyle: const TextStyle(height: 0.9),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF00A8C6), width: 2),
      ),
    ),
  );
}
