import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage("assets/images/user.png"),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    "My Home",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_none_rounded, size: 28),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Hi, Alex",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),

              const Text(
                "Everything is looking good with your apartment today.",
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),

              const SizedBox(height: 22),

              // CREATE REQUEST BUTTON (UPDATED GRADIENT)
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A8C6), Color(0xFF0A5CFF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Create New Request",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // RECENT REQUESTS HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Recent Requests",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "View History",
                    style: TextStyle(
                      color: Color(0xFF00A8C6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              _requestCard(
                title: "Kitchen Sink Leak",
                date: "Oct 24, 2023",
                status: "IN PROGRESS",
                statusColor: Colors.teal,
                subtitle: "Technician Marco is on the way",
                icon: Icons.build_rounded,
              ),

              _requestCard(
                title: "Broken AC Unit",
                date: "Oct 25, 2023",
                status: "PENDING",
                statusColor: Colors.orange,
                subtitle: "Awaiting administrator review",
                icon: Icons.access_time_rounded,
              ),

              _requestCard(
                title: "Replace Filter",
                date: "Oct 22, 2023",
                status: "ASSIGNED",
                statusColor: Colors.deepPurple,
                subtitle: "Assigned to Sarah J.",
                icon: Icons.person_rounded,
              ),

              _requestCard(
                title: "Balcony Light Out",
                date: "Oct 15, 2023",
                status: "COMPLETED",
                statusColor: Colors.green,
                subtitle: "Resolved on Oct 16",
                icon: Icons.check_circle_outline_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// REQUEST CARD COMPONENT
Widget _requestCard({
  required String title,
  required String date,
  required String status,
  required Color statusColor,
  required String subtitle,
  required IconData icon,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "Requested on $date",
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.black45),
            const SizedBox(width: 6),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ],
        ),
      ],
    ),
  );
}
