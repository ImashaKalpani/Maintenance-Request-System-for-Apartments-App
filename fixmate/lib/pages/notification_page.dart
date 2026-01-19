import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: const Color(0xFFF4F7FA),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _notifItem(
            title: "Kitchen Sink Leak Update",
            subtitle: "Technician Marco is arriving soon.",
            icon: Icons.build,
          ),
          _notifItem(
            title: "Maintenance Policy Updated",
            subtitle: "Weekend work hours changed.",
            icon: Icons.policy,
          ),
          _notifItem(
            title: "Security Notice",
            subtitle: "Gate entrance temporarily closed.",
            icon: Icons.shield,
          ),
        ],
      ),
    );
  }
}

class _notifItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _notifItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.06), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0A5CFF), size: 26),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
