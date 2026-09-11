import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'school_shell.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _api = ApiService();

  bool isLoading = true;
  String? errorMessage;

  String heroTitle = 'Maa Saraswati School';
  String heroText =
      'A place where education, discipline and values come together to build a better future.';

  String aboutTitle = 'About Our School';
  String aboutText =
      'Maa Saraswati School provides quality education for students up to Class 12. Our focus is on academic excellence, discipline, creativity and overall development.';

  String academicsTitle = 'Academics';
  String academicsText =
      'Strong academic foundation and quality education for every student.';

  String studentLifeTitle = 'Student Life';
  String studentLifeText =
      'Focus on overall development through sports, cultural activities and student participation.';

  String rulesTitle = 'Rules & Guidelines';
  String rulesText =
      'Students and parents should follow all school rules and guidelines.';

  @override
  void initState() {
    super.initState();
    loadContent();
  }

  Future<void> loadContent() async {
    try {
      final data = await _api.publicContent();

      if (!mounted) return;

      setState(() {
        heroTitle =
            data['heroTitle']?.toString().trim().isNotEmpty == true
                ? data['heroTitle'].toString()
                : heroTitle;

        heroText =
            data['heroText']?.toString().trim().isNotEmpty == true
                ? data['heroText'].toString()
                : heroText;

        aboutTitle =
            data['aboutTitle']?.toString().trim().isNotEmpty == true
                ? data['aboutTitle'].toString()
                : aboutTitle;

        aboutText =
            data['aboutText']?.toString().trim().isNotEmpty == true
                ? data['aboutText'].toString()
                : aboutText;

        academicsTitle =
            data['academicsTitle']?.toString().trim().isNotEmpty == true
                ? data['academicsTitle'].toString()
                : academicsTitle;

        academicsText =
            data['academicsText']?.toString().trim().isNotEmpty == true
                ? data['academicsText'].toString()
                : academicsText;

        studentLifeTitle =
            data['studentLifeTitle']?.toString().trim().isNotEmpty == true
                ? data['studentLifeTitle'].toString()
                : studentLifeTitle;

        studentLifeText =
            data['studentLifeText']?.toString().trim().isNotEmpty == true
                ? data['studentLifeText'].toString()
                : studentLifeText;

        rulesTitle =
            data['rulesTitle']?.toString().trim().isNotEmpty == true
                ? data['rulesTitle'].toString()
                : rulesTitle;

        rulesText =
            data['rulesText']?.toString().trim().isNotEmpty == true
                ? data['rulesText'].toString()
                : rulesText;

        isLoading = false;
        errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SchoolShell(
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? _ErrorView(
                  message: errorMessage!,
                  onRetry: loadContent,
                )
              : RefreshIndicator(
                  onRefresh: loadContent,
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // ==================================================
                        // HERO SECTION
                        // ==================================================

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 70,
                          ),
                          decoration:
                              const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF174EA6),
                                Color(0xFF4285F4),
                              ],
                            ),
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(
                                maxWidth: 1100,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Welcome to',
                                    style: TextStyle(
                                      color:
                                          Colors.white70,
                                      fontSize: 22,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    heroTitle,
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize: 42,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  Text(
                                    heroText,
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize: 18,
                                      height: 1.5,
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator
                                              .pushNamed(
                                            context,
                                            '/admissions',
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.school,
                                        ),
                                        label:
                                            const Text(
                                          'Admissions',
                                        ),
                                      ),

                                      OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator
                                              .pushNamed(
                                            context,
                                            '/contact',
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.phone,
                                          color:
                                              Colors.white,
                                        ),
                                        label:
                                            const Text(
                                          'Contact Us',
                                          style:
                                              TextStyle(
                                            color:
                                                Colors.white,
                                          ),
                                        ),
                                      ),

                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator
                                              .pushNamed(
                                            context,
                                            '/admin-login',
                                          );
                                        },
                                        icon: const Icon(
                                          Icons
                                              .admin_panel_settings,
                                        ),
                                        label:
                                            const Text(
                                          'Admin Login',
                                        ),
                                        style:
                                            ElevatedButton
                                                .styleFrom(
                                          backgroundColor:
                                              Colors.white,
                                          foregroundColor:
                                              const Color(
                                            0xFF174EA6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ==================================================
                        // MAIN CONTENT
                        // ==================================================

                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(
                              maxWidth: 1100,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // ================================
                                // ABOUT
                                // ================================

                                Text(
                                  aboutTitle,
                                  style:
                                      const TextStyle(
                                    fontSize: 30,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  aboutText,
                                  style: TextStyle(
                                    fontSize: 17,
                                    height: 1.6,
                                    color: Colors
                                        .grey.shade700,
                                  ),
                                ),

                                const SizedBox(height: 35),

                                // ================================
                                // INFO CARDS
                                // ================================

                                Wrap(
                                  spacing: 20,
                                  runSpacing: 20,
                                  children: [
                                    _InfoCard(
                                      icon:
                                          Icons.menu_book,
                                      title:
                                          academicsTitle,
                                      text:
                                          academicsText,
                                    ),
                                    _InfoCard(
                                      icon: Icons.groups,
                                      title:
                                          studentLifeTitle,
                                      text:
                                          studentLifeText,
                                    ),
                                    _InfoCard(
                                      icon:
                                          Icons.rule,
                                      title: rulesTitle,
                                      text: rulesText,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 50),

                                // ================================
                                // LATEST UPDATES
                                // ================================

                                const Text(
                                  'Latest Updates',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Card(
                                  child: ListTile(
                                    leading:
                                        const CircleAvatar(
                                      child: Icon(
                                        Icons.campaign,
                                      ),
                                    ),
                                    title: const Text(
                                      'School announcements and events',
                                    ),
                                    subtitle: Text(
                                      rulesText,
                                    ),
                                    trailing:
                                        TextButton(
                                      onPressed: () {
                                        Navigator
                                            .pushNamed(
                                          context,
                                          '/content',
                                        );
                                      },
                                      child:
                                          const Text(
                                        'View',
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 60),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// ================================================================
// INFO CARD
// ================================================================

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 40,
                color: const Color(0xFF174EA6),
              ),

              const SizedBox(height: 15),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                text,
                style: const TextStyle(
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// ERROR VIEW
// ================================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.red,
            ),

            const SizedBox(height: 12),

            Text(
              message,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}