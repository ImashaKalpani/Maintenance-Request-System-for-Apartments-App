import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';
import 'main_container.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = AuthService();
  final _firestore = FirestoreService();

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _userEmail = '';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.getCurrentUser();
      if (user != null) {
        _userEmail = user.email ?? '';
        final data = await _firestore.getUser(user.uid);
        if (data != null) {
          setState(() {
            _userData = data;
            _userName = data['name'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _userName = 'User';
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showEditDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          userData: _userData,
          onProfileUpdated: () {
            _loadUserData();
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "Are you sure you want to delete your account? "
          "This action cannot be undone and all your data will be lost.\n\n"
          "For security, please enter your password to confirm.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => _showPasswordDialog(),
            child: const Text("Continue", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog() {
    Navigator.pop(context);

    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your password to delete your account:"),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => _deleteAccount(passwordController.text),
            child: const Text(
              "Delete Account",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(String password) async {
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = _auth.getCurrentUser();
      if (user != null) {
        final email = user.email ?? '';

        await _firestore.deleteUser(user.uid);
        await _auth.deleteAccount(email: email, password: password);

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(milliseconds: 00), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        });
      }
    } catch (e) {
      Navigator.pop(context);

      String errorMessage = "Failed to delete account";

      if (e.toString().contains("wrong-password")) {
        errorMessage = "Incorrect password. Please try again.";
      } else if (e.toString().contains("requires-recent-login")) {
        errorMessage = "Session expired. Please login again and try.";
      } else if (e.toString().contains("network")) {
        errorMessage = "Network error. Please check your internet connection.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Background decorative elements
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00A8C6).withOpacity(0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -80,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1D3E72).withOpacity(0.05),
                    ),
                  ),
                ),

                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: const Color(0xFFF8FAFC),
                      elevation: 0,
                      leading: IconButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            // If not pushable (e.g., from bottom nav), go to home tab
                            // This depends on MainContainer implementation, but a safe way is pushing MainContainer
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainContainer(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: Color(0xFF1D3E72),
                          ),
                        ),
                      ),
                      title: const Text(
                        "My Profile",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D3E72),
                        ),
                      ),
                      centerTitle: true,
                      pinned: true,
                      floating: true,
                      snap: true,
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Profile Avatar Section
                            Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF00A8C6),
                                    const Color(0xFF1D3E72).withOpacity(0.8),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00A8C6,
                                    ).withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Profile icon or initial
                                  Text(
                                    _userName.isNotEmpty
                                        ? _userName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),

                                  // Edit button on avatar
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _showEditDialog,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          border: Border.all(
                                            color: const Color(0xFF00A8C6),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.edit_rounded,
                                          size: 18,
                                          color: Color(0xFF00A8C6),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Name
                            Text(
                              _userName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1D3E72),
                                letterSpacing: -0.5,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Email
                            Text(
                              _userEmail,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Profile Info Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Section Title
                                  const Text(
                                    "Personal Information",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1D3E72),
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "Manage your account details",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Info Items
                                  _infoItem(
                                    icon: Icons.person_outline_rounded,
                                    title: "Full Name",
                                    value: _userData?['name'] ?? _userName,
                                  ),

                                  const SizedBox(height: 20),

                                  _infoItem(
                                    icon: Icons.email_outlined,
                                    title: "Email Address",
                                    value: _userEmail,
                                  ),

                                  const SizedBox(height: 20),

                                  _infoItem(
                                    icon: Icons.apartment_outlined,
                                    title: "Apartment Number",
                                    value:
                                        _userData?['apartment'] ??
                                        'Not specified',
                                  ),

                                  if (_userData?['phone'] != null) ...[
                                    const SizedBox(height: 20),
                                    _infoItem(
                                      icon: Icons.phone_outlined,
                                      title: "Phone Number",
                                      value: _userData?['phone'] ?? '',
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Action Buttons in Cards
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Edit Profile Button
                                  InkWell(
                                    onTap: _showEditDialog,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF00A8C6,
                                        ).withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF00A8C6,
                                          ).withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF00A8C6),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.edit_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Edit Profile",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF1D3E72),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Update your personal information",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: Colors.grey.shade400,
                                            size: 28,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Logout Button
                                  InkWell(
                                    onTap: _logout,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFFEE2E2,
                                        ).withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(
                                            0xFFFECACA,
                                          ).withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDC2626),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.logout_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Logout",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFFDC2626),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Sign out from your account",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: Colors.grey.shade400,
                                            size: 28,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Delete Account Button
                                  InkWell(
                                    onTap: _showDeleteConfirmation,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFFEF2F2,
                                        ).withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(
                                            0xFFFCA5A5,
                                          ).withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEF4444),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Delete Account",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFFDC2626),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Permanently remove your account",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: Colors.grey.shade400,
                                            size: 28,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF00A8C6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF00A8C6), size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
