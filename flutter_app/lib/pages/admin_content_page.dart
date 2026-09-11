import 'package:flutter/material.dart';

import 'admin_shell.dart';
import '../services/api_service.dart';

class AdminContentPage extends StatefulWidget {
  const AdminContentPage({super.key});

  @override
  State<AdminContentPage> createState() =>
      _AdminContentPageState();
}

class _AdminContentPageState
    extends State<AdminContentPage> {
  final ApiService _api = ApiService();

  final heroTitleController = TextEditingController();
  final heroTextController = TextEditingController();

  final aboutTitleController = TextEditingController();
  final aboutTextController = TextEditingController();

  final academicsTitleController =
      TextEditingController();
  final academicsTextController =
      TextEditingController();

  final studentLifeTitleController =
      TextEditingController();
  final studentLifeTextController =
      TextEditingController();

  final rulesTitleController =
      TextEditingController();
  final rulesTextController =
      TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadContent();
  }

  // ==========================================================
  // LOAD CONTENT
  // ==========================================================

  Future<void> loadContent() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await _api.adminContent();

      heroTitleController.text =
          data['heroTitle']?.toString() ?? '';

      heroTextController.text =
          data['heroText']?.toString() ?? '';

      aboutTitleController.text =
          data['aboutTitle']?.toString() ?? '';

      aboutTextController.text =
          data['aboutText']?.toString() ?? '';

      academicsTitleController.text =
          data['academicsTitle']?.toString() ?? '';

      academicsTextController.text =
          data['academicsText']?.toString() ?? '';

      studentLifeTitleController.text =
          data['studentLifeTitle']?.toString() ?? '';

      studentLifeTextController.text =
          data['studentLifeText']?.toString() ?? '';

      rulesTitleController.text =
          data['rulesTitle']?.toString() ?? '';

      rulesTextController.text =
          data['rulesText']?.toString() ?? '';
    } catch (error) {
      if (!mounted) return;

      showMessage(
        error
            .toString()
            .replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ==========================================================
  // SAVE CONTENT
  // ==========================================================

  Future<void> saveContent() async {
    if (heroTitleController.text.trim().isEmpty) {
      showMessage('Hero Title required hai');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await _api.saveContent({
        'heroTitle':
            heroTitleController.text.trim(),

        'heroText':
            heroTextController.text.trim(),

        'aboutTitle':
            aboutTitleController.text.trim(),

        'aboutText':
            aboutTextController.text.trim(),

        'academicsTitle':
            academicsTitleController.text.trim(),

        'academicsText':
            academicsTextController.text.trim(),

        'studentLifeTitle':
            studentLifeTitleController.text.trim(),

        'studentLifeText':
            studentLifeTextController.text.trim(),

        'rulesTitle':
            rulesTitleController.text.trim(),

        'rulesText':
            rulesTextController.text.trim(),
      });

      if (!mounted) return;

      showMessage(
        'Content successfully saved',
        success: true,
      );
    } catch (error) {
      if (!mounted) return;

      showMessage(
        error
            .toString()
            .replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void showMessage(
    String message, {
    bool success = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            success ? Colors.green : Colors.red,
      ),
    );
  }

  // ==========================================================
  // TEXT FIELD
  // ==========================================================

  Widget contentField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    heroTitleController.dispose();
    heroTextController.dispose();

    aboutTitleController.dispose();
    aboutTextController.dispose();

    academicsTitleController.dispose();
    academicsTextController.dispose();

    studentLifeTitleController.dispose();
    studentLifeTextController.dispose();

    rulesTitleController.dispose();
    rulesTextController.dispose();

    super.dispose();
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Edit School Content',
      currentRoute: '/admin-content',
      backgroundColor: const Color(0xfff4f7fb),

      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: isLoading ? null : loadContent,
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 900,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Website Content',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Yahan se website ka content edit aur save karein.',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ==================================================
                      // HERO
                      // ==================================================

                      _sectionTitle(
                        'Hero Section',
                        Icons.home,
                      ),

                      contentField(
                        label: 'Hero Title',
                        controller:
                            heroTitleController,
                      ),

                      contentField(
                        label: 'Hero Text',
                        controller:
                            heroTextController,
                        maxLines: 4,
                      ),

                      // ==================================================
                      // ABOUT
                      // ==================================================

                      _sectionTitle(
                        'About School',
                        Icons.school,
                      ),

                      contentField(
                        label: 'About Title',
                        controller:
                            aboutTitleController,
                      ),

                      contentField(
                        label: 'About Text',
                        controller:
                            aboutTextController,
                        maxLines: 5,
                      ),

                      // ==================================================
                      // ACADEMICS
                      // ==================================================

                      _sectionTitle(
                        'Academics',
                        Icons.menu_book,
                      ),

                      contentField(
                        label: 'Academics Title',
                        controller:
                            academicsTitleController,
                      ),

                      contentField(
                        label: 'Academics Text',
                        controller:
                            academicsTextController,
                        maxLines: 5,
                      ),

                      // ==================================================
                      // STUDENT LIFE
                      // ==================================================

                      _sectionTitle(
                        'Student Life',
                        Icons.groups,
                      ),

                      contentField(
                        label:
                            'Student Life Title',
                        controller:
                            studentLifeTitleController,
                      ),

                      contentField(
                        label:
                            'Student Life Text',
                        controller:
                            studentLifeTextController,
                        maxLines: 5,
                      ),

                      // ==================================================
                      // RULES
                      // ==================================================

                      _sectionTitle(
                        'Rules & Guidelines',
                        Icons.rule,
                      ),

                      contentField(
                        label: 'Rules Title',
                        controller:
                            rulesTitleController,
                      ),

                      contentField(
                        label: 'Rules Text',
                        controller:
                            rulesTextController,
                        maxLines: 5,
                      ),

                      const SizedBox(height: 10),

                      // ==================================================
                      // SAVE
                      // ==================================================

                      SizedBox(
                        width: double.infinity,
                        height: 52,

                        child: ElevatedButton.icon(
                          onPressed:
                              isSaving
                                  ? null
                                  : saveContent,

                          icon: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.save,
                                ),

                          label: Text(
                            isSaving
                                ? 'Saving...'
                                : 'SAVE CONTENT',
                          ),

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(
                              0xff1565c0,
                            ),
                            foregroundColor:
                                Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _sectionTitle(
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 15,
        bottom: 15,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xff1565c0),
          ),

          const SizedBox(width: 10),

          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}