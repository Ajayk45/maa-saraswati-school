import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'school_shell.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  final ApiService _api = ApiService();

  bool isLoading = true;
  String? errorMessage;

  String heroTitle = '';
  String heroText = '';

  String aboutTitle = '';
  String aboutText = '';

  String academicsTitle = '';
  String academicsText = '';

  String studentLifeTitle = '';
  String studentLifeText = '';

  String rulesTitle = '';
  String rulesText = '';

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
        heroTitle = data['heroTitle']?.toString() ?? '';
        heroText = data['heroText']?.toString() ?? '';

        aboutTitle =
            data['aboutTitle']?.toString() ?? '';
        aboutText =
            data['aboutText']?.toString() ?? '';

        academicsTitle =
            data['academicsTitle']?.toString() ?? '';
        academicsText =
            data['academicsText']?.toString() ?? '';

        studentLifeTitle =
            data['studentLifeTitle']?.toString() ?? '';
        studentLifeText =
            data['studentLifeText']?.toString() ?? '';

        rulesTitle =
            data['rulesTitle']?.toString() ?? '';
        rulesText =
            data['rulesText']?.toString() ?? '';

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
              ? Center(
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
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: loadContent,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadContent,
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(
                          maxWidth: 1000,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // ==========================================
                            // HERO
                            // ==========================================

                            _HeroCard(
                              title: heroTitle,
                              text: heroText,
                            ),

                            const SizedBox(height: 35),

                            // ==========================================
                            // ABOUT SCHOOL
                            // ==========================================

                            _ContentSection(
                              icon: Icons.school,
                              title: aboutTitle.isEmpty
                                  ? 'About Our School'
                                  : aboutTitle,
                              text: aboutText,
                            ),

                            const SizedBox(height: 25),

                            // ==========================================
                            // ACADEMICS
                            // ==========================================

                            _ContentSection(
                              icon: Icons.menu_book,
                              title: academicsTitle.isEmpty
                                  ? 'Academics'
                                  : academicsTitle,
                              text: academicsText,
                            ),

                            const SizedBox(height: 25),

                            // ==========================================
                            // STUDENT LIFE
                            // ==========================================

                            _ContentSection(
                              icon: Icons.groups,
                              title: studentLifeTitle.isEmpty
                                  ? 'Student Life'
                                  : studentLifeTitle,
                              text: studentLifeText,
                            ),

                            const SizedBox(height: 25),

                            // ==========================================
                            // RULES & GUIDELINES
                            // ==========================================

                            _ContentSection(
                              icon: Icons.rule,
                              title: rulesTitle.isEmpty
                                  ? 'Rules & Guidelines'
                                  : rulesTitle,
                              text: rulesText,
                            ),

                            const SizedBox(height: 40),

                            // ==========================================
                            // INFO
                            // ==========================================

                            Card(
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(24),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      size: 35,
                                      color:
                                          Color(0xFF174EA6),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Text(
                                        'School information and '
                                        'guidelines are managed '
                                        'from the Admin Panel.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors
                                              .grey.shade700,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}

// ================================================================
// HERO CARD
// ================================================================

class _HeroCard extends StatelessWidget {
  final String title;
  final String text;

  const _HeroCard({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff174EA6),
            Color(0xff4285F4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title.isEmpty
                ? 'Welcome to Maa Saraswati School'
                : title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text.isEmpty
                ? 'School information and updates.'
                : text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// CONTENT SECTION
// ================================================================

class _ContentSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _ContentSection({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: const Color(0xff174EA6),
                size: 30,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    text.isEmpty
                        ? 'No information available.'
                        : text,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}