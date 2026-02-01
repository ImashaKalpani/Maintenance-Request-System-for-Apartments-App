import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'create_request_page.dart';
import 'main_container.dart';

class RequestDetailsPage extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final String requestId;

  const RequestDetailsPage({
    super.key,
    required this.requestData,
    required this.requestId,
  });

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
        return Icons.build_circle_outlined;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Unknown Date";
    final date = (timestamp as dynamic).toDate();
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

  @override
  Widget build(BuildContext context) {
    final title = requestData['title'] ?? 'Untitled Request';
    final description =
        requestData['description'] ?? 'No description provided.';
    final category = requestData['category'] ?? 'General';
    final status = requestData['status'] ?? 'PENDING';
    final createdAt = requestData['createdAt'];
    final availableDate = requestData['availableDate'] ?? 'Not specified';
    final availableTime = requestData['availableTime'] ?? 'Not specified';

    final statusColor = _getStatusColor(status);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Details",
          style: TextStyle(
            color: Color(0xFF1D3E72),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainContainer()),
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
        actions: [
          IconButton(
            onPressed: () => _showDeleteConfirmation(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            _buildStatusHeader(status, statusColor, createdAt),

            const SizedBox(height: 32),

            // Availability Card
            _buildSection(
              title: "Technician Availability",
              icon: Icons.timer_rounded,
              child: Row(
                children: [
                  _buildAvailabilityBadge(
                    availableDate,
                    Icons.calendar_month_rounded,
                  ),
                  const SizedBox(width: 12),
                  _buildAvailabilityBadge(
                    availableTime,
                    Icons.access_time_filled_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Information Card
            _buildSection(
              title: "Information",
              icon: Icons.info_outline_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A8C6).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
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
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1D3E72),
                              ),
                            ),
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF00A8C6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D3E72).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Apartment: ${requestData['apartment'] ?? 'N/A'}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1D3E72),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_rounded,
                        size: 16,
                        color: const Color(0xFF1D3E72).withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Contact: ${requestData['phone'] ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D3E72),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D3E72),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Attached Image
                  if (requestData['imageUrl'] != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      "Attached Image",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D3E72),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        // show full image dialog
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(10),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    requestData['imageUrl'],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(requestData['imageUrl']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Bottom Actions
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToEdit(context),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF1D3E72).withOpacity(0.1),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Edit",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D3E72),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00A8C6), Color(0xFF0A5CFF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00A8C6).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Done",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(String status, Color color, dynamic timestamp) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2), width: 4),
            ),
            child: Icon(_getStatusIcon(status), size: 40, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            status,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Last updated on ${_formatDate(timestamp)}",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 4),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF1D3E72)),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D3E72),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildAvailabilityBadge(String text, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF00A8C6)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D3E72),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.hourglass_top_rounded;
      case 'ASSIGNED':
        return Icons.engineering_rounded;
      case 'IN PROGRESS':
        return Icons.build_circle_rounded;
      case 'COMPLETED':
        return Icons.verified_rounded;
      default:
        return Icons.info_outline;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Request"),
        content: const Text(
          "Are you sure you want to delete this maintenance request? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await FirestoreService().deleteRequest(requestId);
              if (context.mounted) {
                Navigator.pop(context); // Go back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Request deleted successfully"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateRequestPage(requestId: requestId, initialData: requestData),
      ),
    );
  }
}
