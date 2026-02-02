import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = _authService.getCurrentUserId();
  }

  String _formatNotifTime(Timestamp? timestamp) {
    if (timestamp == null) return "Just now";
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return DateFormat('MMM d').format(date);
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'request':
        return Icons.handyman_rounded;
      case 'update':
        return Icons.system_update_alt_rounded;
      case 'notice':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Map<String, List<QueryDocumentSnapshot>> _groupNotifs(
    List<QueryDocumentSnapshot> docs,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<QueryDocumentSnapshot>>{
      'Today': [],
      'Yesterday': [],
      'Earlier': [],
    };

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['createdAt'] as Timestamp?;
      if (timestamp == null) {
        groups['Today']!.add(doc);
        continue;
      }

      final date = timestamp.toDate();
      final compareDate = DateTime(date.year, date.month, date.day);

      if (compareDate == today) {
        groups['Today']!.add(doc);
      } else if (compareDate == yesterday) {
        groups['Yesterday']!.add(doc);
      } else {
        groups['Earlier']!.add(doc);
      }
    }

    return groups;
  }

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
            child: _uid == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestoreService.getNotificationsStream(_uid!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildEmptyState();
                      }

                      final docs = snapshot.data!.docs;
                      // Sort by creation time descending
                      docs.sort((a, b) {
                        final aT =
                            (a['createdAt'] as Timestamp?)?.toDate() ??
                            DateTime.now();
                        final bT =
                            (b['createdAt'] as Timestamp?)?.toDate() ??
                            DateTime.now();
                        return bT.compareTo(aT);
                      });

                      final grouped = _groupNotifs(docs);

                      // Flatten the groups for the builder
                      final flatList = <dynamic>[];
                      grouped.forEach((key, list) {
                        if (list.isNotEmpty) {
                          flatList.add(key);
                          flatList.addAll(list);
                          flatList.add(const SizedBox(height: 16));
                        }
                      });

                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          _buildAppBar(context),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                if (index >= flatList.length) return null;

                                final item = flatList[index];
                                if (item is String) {
                                  return _buildDayHeader(item);
                                } else if (item is QueryDocumentSnapshot) {
                                  final data =
                                      item.data() as Map<String, dynamic>;
                                  return Dismissible(
                                    key: Key(item.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red.shade400,
                                      ),
                                    ),
                                    onDismissed: (_) => _firestoreService
                                        .deleteNotification(item.id),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (!(data['isRead'] ?? false)) {
                                          _firestoreService
                                              .markNotificationAsRead(item.id);
                                        }
                                      },
                                      child: _ModernNotifItem(
                                        title: data['title'] ?? 'Notice',
                                        subtitle: data['subtitle'] ?? '',
                                        icon: _getIconForType(
                                          data['type'] ?? 'notice',
                                        ),
                                        time: _formatNotifTime(
                                          data['createdAt'],
                                        ),
                                        isNew: !(data['isRead'] ?? false),
                                      ),
                                    ),
                                  );
                                } else {
                                  return item as Widget;
                                }
                              }, childCount: flatList.length),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      surfaceTintColor: const Color(0xFFF8FAFC),
      elevation: 0,
      pinned: true,
      scrolledUnderElevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 80,
              color: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Notifications Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D3E72),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You'll see updates about your requests here.",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
