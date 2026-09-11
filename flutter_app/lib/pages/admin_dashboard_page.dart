import 'package:flutter/material.dart';

import 'admin_shell.dart';

import '../services/api_service.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await ApiService().adminLogout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'School Admin Dashboard',
      currentRoute: '/admin-dashboard',
      backgroundColor: const Color(0xfff4f7fb),

      // ======================================================
      // DASHBOARD BODY
      // ======================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Admin 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xff172033),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Manage your school information from one place.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            LayoutBuilder(
              builder: (context, constraints) {
                final columns =
                    constraints.maxWidth > 1000
                        ? 4
                        : constraints.maxWidth > 650
                            ? 2
                            : 1;

                return GridView.count(
                  crossAxisCount: columns,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 2.5,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),

                  children: [
                    // ADMISSIONS
                    _DashboardCard(
                      title: 'Admissions',
                      value: 'Manage',
                      icon: Icons.people,
                      iconColor: Colors.blue,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/admin-admissions',
                        );
                      },
                    ),

                    // INQUIRIES
                    _DashboardCard(
                      title: 'Inquiries',
                      value: 'View',
                      icon: Icons.question_answer,
                      iconColor: Colors.teal,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/admin-inquiries',
                        );
                      },
                    ),

                    // GALLERY
                    _DashboardCard(
                      title: 'Gallery',
                      value: 'Manage',
                      icon: Icons.photo_library,
                      iconColor: Colors.purple,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/admin-gallery',
                        );
                      },
                    ),

                    // CONTENT
                    _DashboardCard(
                      title: 'Content',
                      value: 'Edit',
                      icon: Icons.edit_document,
                      iconColor: Colors.orange,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/admin-content',
                        );
                      },
                    ),

                    // MESSAGES
                    _DashboardCard(
                      title: 'Messages',
                      value: 'View',
                      icon: Icons.mail,
                      iconColor: Colors.green,
                      onTap: () {
                        Navigator.pushNamed(context, '/admin-messages');
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            // ==================================================
            // QUICK ACTIONS
            // ==================================================

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: [
                        // NEW ADMISSION
                        _ActionButton(
                          icon: Icons.person_add,
                          title: 'New Admission',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/admin-admissions',
                            );
                          },
                        ),

                        // INQUIRIES
                        _ActionButton(
                          icon: Icons.question_answer,
                          title: 'View Inquiries',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/admin-inquiries',
                            );
                          },
                        ),

                        // GALLERY
                        _ActionButton(
                          icon: Icons.photo_library,
                          title: 'Manage Gallery',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/admin-gallery',
                            );
                          },
                        ),

                        // CONTENT
                        _ActionButton(
                          icon: Icons.edit_document,
                          title: 'Edit Content',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/admin-content',
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// DASHBOARD CARD
// ==========================================================

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: iconColor.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
}

// ==========================================================
// ACTION BUTTON
// ==========================================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xff1565c0),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}