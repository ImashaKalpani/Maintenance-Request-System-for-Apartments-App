import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixmate/pages/create_request_page.dart';
import 'package:fixmate/pages/request_details_page.dart';
import 'package:fixmate/services/auth_service.dart';
import 'package:fixmate/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'notification_page.dart';
import 'request_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  String _userName = "User";
  String? _uid;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final uid = _authService.getCurrentUserId();
    if (uid != null) {
      if (mounted) setState(() => _uid = uid);
      final userData = await _firestoreService.getUser(uid);
      if (userData != null && userData['name'] != null) {
        if (mounted) {
          setState(() {
            _userName = userData['name'].toString().split(' ')[0];
          });
        }
      }
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Just now";
    final date = timestamp.toDate();
    final months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'ASSIGNED':
        return Colors.deepPurple;
      case 'IN PROGRESS':
        return Colors.teal;
      case 'COMPLETED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Plumbing':
        return Icons.water_drop_outlined;
      case 'Electrical':
        return Icons.electrical_services_rounded;
      case 'HVAC':
        return Icons.ac_unit_rounded;
      case 'Appliance':
        return Icons.kitchen_rounded;
      case 'Pest Control':
        return Icons.pest_control_rounded;
      default:
        return Icons.handyman_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Gradient Mesh
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00A8C6).withOpacity(0.15),
                    const Color(0xFF00A8C6).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Fixed Top Section
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  color: const Color(0xFFF8FAFC),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Apartment FixMate",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1D3E72),
                              letterSpacing: -1,
                            ),
                          ),
                          Row(
                            children: [
                              _buildNotificationIcon(),
                              const SizedBox(width: 12),
                              _buildHeaderAvatar(),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildHeroGreeting(),
                      const SizedBox(height: 24),
                      _buildCreateRequestCard(),
                    ],
                  ),
                ),

                // Scrollable Section
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 1.4,
                              ),
                          delegate: SliverChildListDelegate([
                            _buildAdviceCard(
                              "Maintenance",
                              "Quick home tips",
                              Icons.build_circle_outlined,
                              Colors.blue,
                            ),
                            _buildAdviceCard(
                              "Safety Guide",
                              "Stay safe & secure",
                              Icons.security_outlined,
                              Colors.orange,
                            ),
                            _buildAdviceCard(
                              "Help Center",
                              "FAQ & Support",
                              Icons.help_outline_rounded,
                              Colors.teal,
                            ),
                            _buildAdviceCard(
                              "Rules",
                              "Community living",
                              Icons.gavel_rounded,
                              Colors.purple,
                            ),
                          ]),
                        ),
                      ),

                      // Recent Requests Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Recent Requests",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1D3E72),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Track your latest maintenance picks",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RequestsPage(),
                                  ),
                                ),
                                child: const Text(
                                  "See All",
                                  style: TextStyle(
                                    color: Color(0xFF00A8C6),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Request List Sliver
                      _uid == null
                          ? const SliverFillRemaining(
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : StreamBuilder<QuerySnapshot>(
                              stream: _firestoreService.getRequestsStream(
                                _uid!,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SliverToBoxAdapter(
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return SliverToBoxAdapter(
                                    child: _buildEmptyState(),
                                  );
                                }

                                final requests = snapshot.data!.docs;
                                requests.sort((a, b) {
                                  final aTime =
                                      (a['createdAt'] as Timestamp?)
                                          ?.toDate() ??
                                      DateTime.now();
                                  final bTime =
                                      (b['createdAt'] as Timestamp?)
                                          ?.toDate() ??
                                      DateTime.now();
                                  return bTime.compareTo(aTime);
                                });

                                return SliverPadding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        if (index >= 3)
                                          return null; // Only show top 3
                                        final doc = requests[index];
                                        final data =
                                            doc.data() as Map<String, dynamic>;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          child: _buildGlassRequestCard(
                                            doc.id,
                                            data,
                                          ),
                                        );
                                      },
                                      childCount: requests.length > 3
                                          ? 3
                                          : requests.length,
                                    ),
                                  ),
                                );
                              },
                            ),

                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationPage()),
      ),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF1D3E72),
              size: 24,
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00A8C6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hello,",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          _userName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1D3E72),
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF00A8C6), const Color(0xFF1D3E72)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A8C6).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCreateRequestCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1D3E72),
            const Color(0xFF1D3E72).withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D3E72).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.handyman_rounded,
              size: 120,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Need a Fix?",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Get professional maintenance help in minutes.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateRequestPage(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A8C6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Create Request",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassRequestCard(String docId, Map<String, dynamic> data) {
    final status = data['status'] ?? 'PENDING';
    final statusColor = _getStatusColor(status);
    final category = data['category'] ?? 'Other';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              RequestDetailsPage(requestData: data, requestId: docId),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF00A8C6).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: const Color(0xFF00A8C6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data['title'] ?? 'Untitled',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFF1D3E72),
                            ),
                          ),
                        ),
                        _buildStatusBadge(status.toUpperCase(), statusColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data['description'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(data['createdAt'] as Timestamp?),
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_mosaic_rounded,
            size: 60,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 16),
          Text(
            "Nothing to show yet",
            style: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Color(0xFF1D3E72),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
