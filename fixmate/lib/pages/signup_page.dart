import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _apartment = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  final _auth = AuthService();
  final _firestore = FirestoreService();

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      _showErrorSnack("Please agree to terms & conditions");
      return;
    }

    if (_password.text != _confirm.text) {
      _showErrorSnack("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _auth.signUp(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (user != null) {
        await _firestore.saveUser(
          uid: user.uid,
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          apartment: _apartment.text.trim(),
        );

        _showSuccessSnack("Account created successfully!");

        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        });
      }
    } catch (e) {
      String errorMessage = "Sign up failed";

      if (e.toString().contains("email-already-in-use")) {
        errorMessage =
            "This email is already registered. Please try to login instead.";
      } else if (e.toString().contains("weak-password")) {
        errorMessage = "Password is too weak. Please use a stronger password.";
      } else if (e.toString().contains("network-request-failed")) {
        errorMessage = "Network error. Please check your internet connection.";
      } else {
        errorMessage = "Failed: ${e.toString()}";
      }

      _showErrorSnack(errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 30, left: 18, right: 18),
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
        margin: const EdgeInsets.only(bottom: 30, left: 18, right: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 4000),
        action: msg.contains("already registered")
            ? SnackBarAction(
                label: 'Login',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5FAFF),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D3E72),
                    ),
                  ),
                  const SizedBox(height: 6),

                  const Text(
                    "Join Apartment FixMate",
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),

                  const SizedBox(height: 32),

                  _input(
                    "Full Name",
                    Icons.person_outline,
                    _name,
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 14),

                  _input(
                    "Email Address",
                    Icons.email_outlined,
                    _email,
                    keyboard: TextInputType.emailAddress,
                    validator: (v) =>
                        !RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(v!)
                        ? "Invalid email"
                        : null,
                  ),

                  const SizedBox(height: 14),

                  _input(
                    "Phone Number",
                    Icons.phone_outlined,
                    _phone,
                    keyboard: TextInputType.phone,
                    validator: (v) => v!.length < 10 ? "Invalid phone" : null,
                  ),

                  const SizedBox(height: 14),

                  _input(
                    "Apartment Number",
                    Icons.home_outlined,
                    _apartment,
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 14),

                  _passwordInput(
                    label: "Password",
                    controller: _password,
                    obscure: _obscurePassword,
                    toggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    validator: (v) => v!.length < 6 ? "Min 6 characters" : null,
                  ),

                  const SizedBox(height: 14),

                  _passwordInput(
                    label: "Confirm Password",
                    controller: _confirm,
                    obscure: _obscureConfirmPassword,
                    toggle: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                    validator: (v) =>
                        v != _password.text ? "Passwords do not match" : null,
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (v) => setState(() => _agreeToTerms = v!),
                        activeColor: const Color(0xFF00A8C6),
                      ),
                      const Expanded(
                        child: Text(
                          "I agree to terms and conditions",
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  GestureDetector(
                    onTap: _isLoading ? null : _signup,
                    child: Container(
                      height: 54,
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
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.black87, fontSize: 15),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
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
        ),
      ),
    );
  }
}

Widget _input(
  String label,
  IconData icon,
  TextEditingController controller, {
  TextInputType keyboard = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    ),
  );
}

Widget _passwordInput({
  required String label,
  required TextEditingController controller,
  required bool obscure,
  required VoidCallback toggle,
  String? Function(String?)? validator,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: toggle,
        ),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    ),
  );
}
