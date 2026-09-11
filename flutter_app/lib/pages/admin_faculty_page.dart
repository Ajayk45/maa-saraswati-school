import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import 'admin_shell.dart';

class AdminFacultyPage extends StatefulWidget {
  const AdminFacultyPage({super.key});

  @override
  State<AdminFacultyPage> createState() =>
      _AdminFacultyPageState();
}

class _AdminFacultyPageState
    extends State<AdminFacultyPage> {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> faculty = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFaculty();
  }

  // ==========================================================
  // LOAD FACULTY
  // ==========================================================

 Future<void> loadFaculty({
  bool showLoading = true,
}) async {
  if (showLoading && mounted) {
    setState(() {
      isLoading = true;
    });
  }

  try {
    final data = await _api.getFaculty();

    if (!mounted) return;

    setState(() {
      faculty = data;
      isLoading = false;
    });
  } catch (error) {
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    showMessage(
      error
          .toString()
          .replaceFirst('Exception: ', ''),
    );
  }
}
  // ==========================================================
  // ADD / EDIT DIALOG
  // ==========================================================

  Future<void> showFacultyDialog({
    Map<String, dynamic>? member,
  }) async {
    final nameController = TextEditingController(
      text: member?['name']?.toString() ?? '',
    );

    final designationController =
        TextEditingController(
      text:
          member?['designation']?.toString() ?? '',
    );

    final subjectController =
        TextEditingController(
      text: member?['subject']?.toString() ?? '',
    );

    final descriptionController =
        TextEditingController(
      text:
          member?['description']?.toString() ?? '',
    );

    XFile? selectedImage;

    String imageUrl =
        member?['image_url']?.toString() ?? '';

    bool isPrincipal =
        member?['is_principal'] == true ||
        member?['is_principal']?.toString() == 'true';

    Uint8List? previewBytes;

    // This belongs to THIS dialog only.
    // It must not survive after the dialog is closed.
    bool isSaving = false;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            Future<void> pickImage() async {
              try {
                final image =
                    await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                  maxWidth: 1600,
                );

                if (image == null) return;

                final bytes =
                    await image.readAsBytes();

                setDialogState(() {
                  selectedImage = image;
                  previewBytes = bytes;
                });
              } catch (error) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Image select failed: $error',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            Future<void> save() async {
              if (!formKey.currentState!
                  .validate()) {
                return;
              }

              setDialogState(() {
                isSaving = true;
              });

              try {
                // ------------------------------------------------
                // UPLOAD NEW IMAGE
                // ------------------------------------------------

                if (selectedImage != null) {
                  final uploaded =
                      await _api
                          .uploadFacultyImage(
                            image: selectedImage!,
                          )
                          .timeout(
                            const Duration(seconds: 10),
                            onTimeout: () {
                              throw Exception(
                                'Photo upload timed out. Please check that the backend server is running and try again.',
                              );
                            },
                          );

                  imageUrl =
                      uploaded['image_url']
                              ?.toString() ??
                          '';

                  if (imageUrl.isEmpty) {
                    throw Exception(
                      'Photo upload failed. Server did not return an image URL.',
                    );
                  }
                }

                // ------------------------------------------------
                // ADD / UPDATE
                // ------------------------------------------------

                if (member == null) {
                  await _api
                      .addFaculty(
                        name: nameController.text.trim(),
                        designation:
                            designationController.text.trim(),
                        subject: subjectController.text.trim(),
                        description:
                            descriptionController.text.trim(),
                        imageUrl: imageUrl,
                        isPrincipal: isPrincipal,
                      )
                      .timeout(
                        const Duration(seconds: 30),
                        onTimeout: () {
                          throw Exception(
                            'Faculty save timed out. Please check the backend server and try again.',
                          );
                        },
                      );
                } else {
                  await _api
                      .updateFaculty(
                        id: int.parse(
                          member['id'].toString(),
                        ),
                        name: nameController.text.trim(),
                        designation:
                            designationController.text.trim(),
                        subject: subjectController.text.trim(),
                        description:
                            descriptionController.text.trim(),
                        imageUrl: imageUrl,
                        isPrincipal: isPrincipal,
                      )
                      .timeout(
                        const Duration(seconds: 30),
                        onTimeout: () {
                          throw Exception(
                            'Faculty update timed out. Please check the backend server and try again.',
                          );
                        },
                      );
                }

                if (!mounted) return;

                Navigator.of(dialogContext).pop();

                // Refresh the faculty list without showing the full-page loader.
                await loadFaculty(showLoading: false);

                if (!mounted) return;

                showMessage(
                  member == null
                      ? 'Faculty added successfully.'
                      : 'Faculty updated successfully.',
                  success: true,
                );
              } catch (error) {
                setDialogState(() {
                  isSaving = false;
                });

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      error
                          .toString()
                          .replaceFirst('Exception: ', ''),
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 6),
                  ),
                );
              }
            }

            return AlertDialog(
              title: Text(
                member == null
                    ? 'Add Principal / Teacher'
                    : 'Edit Faculty',
              ),

              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // =========================================
                        // PHOTO
                        // =========================================

                        const Text(
                          'Faculty Photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Center(
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration:
                                BoxDecoration(
                              borderRadius:
                                  BorderRadius
                                      .circular(18),
                              border: Border.all(
                                color: Colors
                                    .grey
                                    .shade300,
                              ),
                            ),
                            clipBehavior:
                                Clip.antiAlias,
                            child:
                                previewBytes !=
                                        null
                                    ? Image.memory(
                                        previewBytes!,
                                        fit: BoxFit
                                            .cover,
                                      )
                                    : imageUrl
                                            .isNotEmpty
                                        ? Image.network(
                                            _imageUrl(
                                                imageUrl),
                                            fit: BoxFit
                                                .cover,
                                            errorBuilder:
                                                (
                                              _,
                                              __,
                                              ___,
                                            ) {
                                              return const Icon(
                                                Icons
                                                    .person,
                                                size: 70,
                                              );
                                            },
                                          )
                                        : const Icon(
                                            Icons
                                                .person,
                                            size: 70,
                                            color:
                                                Colors.grey,
                                          ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton
                              .icon(
                            onPressed:
                                isSaving
                                    ? null
                                    : pickImage,
                            icon: const Icon(
                              Icons
                                  .photo_library_outlined,
                            ),
                            label: Text(
                              selectedImage ==
                                      null
                                  ? 'BROWSE PHOTO'
                                  : 'CHANGE PHOTO',
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // =========================================
                        // NAME
                        // =========================================

                        TextFormField(
                          controller:
                              nameController,
                          enabled: !isSaving,
                          decoration:
                              const InputDecoration(
                            labelText: 'Name *',
                            prefixIcon:
                                Icon(Icons.person),
                            border:
                                OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if ((value ?? '')
                                .trim()
                                .isEmpty) {
                              return 'Name is required';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // =========================================
                        // DESIGNATION
                        // =========================================

                        TextFormField(
                          controller:
                              designationController,
                          enabled: !isSaving,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Designation *',
                            prefixIcon: Icon(
                              Icons.badge_outlined,
                            ),
                            border:
                                OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if ((value ?? '')
                                .trim()
                                .isEmpty) {
                              return 'Designation is required';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // =========================================
                        // SUBJECT
                        // =========================================

                        TextFormField(
                          controller:
                              subjectController,
                          enabled: !isSaving,
                          decoration:
                              const InputDecoration(
                            labelText: 'Subject',
                            prefixIcon: Icon(
                              Icons
                                  .menu_book_outlined,
                            ),
                            border:
                                OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // =========================================
                        // DESCRIPTION
                        // =========================================

                        TextFormField(
                          controller:
                              descriptionController,
                          enabled: !isSaving,
                          maxLines: 4,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Description',
                            alignLabelWithHint:
                                true,
                            prefixIcon: Icon(
                              Icons
                                  .description_outlined,
                            ),
                            border:
                                OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // =========================================
                        // PRINCIPAL
                        // =========================================

                        CheckboxListTile(
                          contentPadding:
                              EdgeInsets.zero,
                          value: isPrincipal,
                          enabled: !isSaving,
                          onChanged: (value) {
                            setDialogState(() {
                              isPrincipal =
                                  value ?? false;
                            });
                          },
                          title: const Text(
                            'Set as Principal',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          subtitle:
                              const Text(
                            'Only one faculty member can be Principal.',
                          ),
                          secondary: const Icon(
                            Icons.star_outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () =>
                          Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),

                ElevatedButton.icon(
                  onPressed:
                      isSaving ? null : save,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    isSaving
                        ? 'SAVING...'
                        : 'SAVE',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    designationController.dispose();
    subjectController.dispose();
    descriptionController.dispose();
  }

  // ==========================================================
  // DELETE
  // ==========================================================

  Future<void> deleteFaculty(
    Map<String, dynamic> member,
  ) async {
    final id = int.parse(
      member['id'].toString(),
    );

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Faculty?',
          ),
          content: Text(
            'Are you sure you want to delete '
            '${member['name']}?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _api.deleteFaculty(id);

      if (!mounted) return;

      showMessage(
        'Faculty deleted successfully.',
        success: true,
      );

      await loadFaculty(showLoading: false);
    } catch (error) {
      if (!mounted) return;

      showMessage(
        error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  // ==========================================================
  // IMAGE URL
  // ==========================================================

  String _imageUrl(String value) {
    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    final base =
        ApiService.baseUrl.replaceFirst(
      '/api',
      '',
    );

    return '$base$value';
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void showMessage(
    String message, {
    bool success = false,
  }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            success ? Colors.green : Colors.red,
      ),
    );
  }

  // ==========================================================
  // FACULTY CARD
  // ==========================================================

  Widget facultyCard(
    Map<String, dynamic> member,
  ) {
    final name =
        member['name']?.toString() ?? '';

    final designation =
        member['designation']?.toString() ??
            '';

    final subject =
        member['subject']?.toString() ?? '';

    final imageUrl =
        member['image_url']?.toString() ?? '';

    final isPrincipal =
        member['is_principal'] == true;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // PHOTO
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(14),
              child: SizedBox(
                width: 90,
                height: 90,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        _imageUrl(imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) {
                          return Container(
                            color: Colors
                                .grey
                                .shade200,
                            child: const Icon(
                              Icons.person,
                              size: 42,
                              color:
                                  Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        color:
                            Colors.grey.shade200,
                        child: const Icon(
                          Icons.person,
                          size: 42,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 16),

            // DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      if (isPrincipal)
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration:
                              BoxDecoration(
                            color: const Color(
                              0xfffff3cd,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors
                                    .orange,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Principal',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    designation,
                    style: TextStyle(
                      color:
                          Colors.blue.shade700,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  if (subject.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subject,
                      style: TextStyle(
                        color: Colors
                            .grey
                            .shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ACTIONS
            IconButton(
              tooltip: 'Edit',
              onPressed: () =>
                  showFacultyDialog(
                member: member,
              ),
              icon: const Icon(
                Icons.edit_outlined,
              ),
            ),

            IconButton(
              tooltip: 'Delete',
              onPressed: () =>
                  deleteFaculty(member),
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Principal & Teachers',
      currentRoute: '/admin-faculty',
      backgroundColor:
          const Color(0xfff4f7fb),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed:
              isLoading ? null : loadFaculty,
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(24),
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
                      // HEADER
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  'Principal & Teachers',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  'Manage school principal and teaching staff.',
                                  style: TextStyle(
                                    color: Colors
                                        .grey
                                        .shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          ElevatedButton.icon(
                            onPressed: () =>
                                showFacultyDialog(),
                            icon: const Icon(
                              Icons.add,
                            ),
                            label: const Text(
                              'ADD FACULTY',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // STATS
                      Row(
                        children: [
                          _statCard(
                            'Total Faculty',
                            faculty.length
                                .toString(),
                            Icons.groups,
                          ),
                          const SizedBox(
                            width: 14,
                          ),
                          _statCard(
                            'Principal',
                            faculty
                                .where(
                                  (item) =>
                                      item[
                                          'is_principal'] ==
                                      true,
                                )
                                .length
                                .toString(),
                            Icons.star,
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      if (faculty.isEmpty)
                        Card(
                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons
                                        .groups_outlined,
                                    size: 60,
                                    color: Colors
                                        .grey
                                        .shade400,
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  const Text(
                                    'No faculty added yet.',
                                    style:
                                        TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  const Text(
                                    'Click "ADD FACULTY" to add Principal or Teachers.',
                                    textAlign:
                                        TextAlign
                                            .center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        ...faculty.map(
                          facultyCard,
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ==========================================================
  // STAT CARD
  // ==========================================================

  Widget _statCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding:
              const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                    BoxDecoration(
                  color: const Color(
                    0xffe8f0fe,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  color: const Color(
                    0xff1565c0,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors
                          .grey
                          .shade600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style:
                        const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}