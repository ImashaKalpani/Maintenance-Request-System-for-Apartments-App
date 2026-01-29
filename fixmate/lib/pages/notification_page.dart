import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Mesh Gradient
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00A8C6).withOpacity(0.1),
                    const Color(0xFF00A8C6).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF1D3E72),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  centerTitle: true,
                  title: const Text(
                    "Notifications",
                    style: TextStyle(
                      color: Color(0xFF1D3E72),
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildDayHeader("Today"),
                      const _ModernNotifItem(
                        title: "Kitchen Sink Leak Update",
                        subtitle:
                            "Technician Marco is arriving within 15 minutes. Please be available.",
                        icon: Icons.water_drop_rounded,
                        time: "2h ago",
                        isNew: true,
                      ),
                      const SizedBox(height: 16),
                      _buildDayHeader("Yesterday"),
                      const _ModernNotifItem(
                        title: "Maintenance Policy Updated",
                        subtitle:
                            "Weekend work hours have been adjusted for upcoming holidays.",
                        icon: Icons.article_rounded,
                        time: "1d ago",
                        isNew: false,
                      ),
                      const SizedBox(height: 16),
                      const _ModernNotifItem(
                        title: "Security Notice",
                        subtitle:
                            "Main gate entrance temporarily closed for paving. Use South gate.",
                        icon: Icons.shield_moon_rounded,
                        time: "2d ago",
                        isNew: false,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(String day) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        day.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Color(0xFF00A8C6),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _ModernNotifItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String time;
  final bool isNew;

  const _ModernNotifItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.time,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: isNew
            ? Border.all(
                color: const Color(0xFF00A8C6).withOpacity(0.15),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isNew
                  ? const Color(0xFF00A8C6).withOpacity(0.12)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isNew ? const Color(0xFF00A8C6) : const Color(0xFF1D3E72),
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
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF1D3E72),
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
