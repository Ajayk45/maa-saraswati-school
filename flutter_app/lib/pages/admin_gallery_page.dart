import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'admin_shell.dart';
import '../services/api_service.dart';

class AdminGalleryPage extends StatefulWidget {
  const AdminGalleryPage({super.key});

  @override
  State<AdminGalleryPage> createState() => _AdminGalleryPageState();
}

class _AdminGalleryPageState extends State<AdminGalleryPage> {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> gallery = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadGallery();
  }

  Future<void> loadGallery() async {
    setState(() => isLoading = true);
    try {
      final data = await _api.getGallery();
      if (!mounted) return;
      setState(() {
        gallery = data;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<XFile?> _pickImage() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1800,
      );
    } catch (error) {
      if (mounted) showMessage('Image select nahi ho paayi: $error');
      return null;
    }
  }

  Future<void> addGalleryPost() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    XFile? selectedImage;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> chooseImage() async {
              final image = await _pickImage();
              if (image != null) {
                setDialogState(() => selectedImage = image);
              }
            }

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.cloud_upload),
                  SizedBox(width: 10),
                  Text('Add Gallery Photo'),
                ],
              ),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Event / Post Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      InkWell(
                        onTap: saving ? null : chooseImage,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 190),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                            color: Colors.grey.shade50,
                          ),
                          child: selectedImage == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, size: 55),
                                    SizedBox(height: 10),
                                    Text(
                                      'Browse / Choose Photo',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text('Phone ya laptop se image select karein'),
                                  ],
                                )
                              : FutureBuilder<List<int>>(
                                  future: selectedImage!.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        Uint8List.fromList(snapshot.data!),
                                        height: 230,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                      if (selectedImage != null) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            selectedImage!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton.icon(
                          onPressed: saving ? null : chooseImage,
                          icon: const Icon(Icons.change_circle),
                          label: const Text('Change Photo'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton.icon(
                  onPressed: saving
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          final description = descriptionController.text.trim();

                          if (title.isEmpty) {
                            showMessage('Title required hai');
                            return;
                          }
                          if (selectedImage == null) {
                            showMessage('Pehle photo select karein');
                            return;
                          }

                          setDialogState(() => saving = true);
                          try {
                            await _api.uploadGalleryPost(
                              title: title,
                              description: description,
                              image: selectedImage!,
                            );

                            if (!mounted) return;
                            Navigator.pop(dialogContext, true);
                            showMessage('Photo uploaded successfully', success: true);
                            await loadGallery();
                          } catch (error) {
                            setDialogState(() => saving = false);
                            showMessage(error.toString().replaceFirst('Exception: ', ''));
                          }
                        },
                  icon: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload),
                  label: Text(saving ? 'UPLOADING...' : 'UPLOAD'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    if (result == true && mounted) await loadGallery();
  }

  Future<void> deletePost(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Gallery Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _api.deleteGalleryPost(id);
      if (!mounted) return;
      showMessage('Gallery photo deleted', success: true);
      await loadGallery();
    } catch (error) {
      if (mounted) showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Gallery Management',
      currentRoute: '/admin-gallery',
      backgroundColor: const Color(0xfff4f7fb),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: isLoading ? null : loadGallery,
          icon: const Icon(Icons.refresh),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addGalleryPost,
        backgroundColor: const Color(0xff1565c0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Add Photo'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : gallery.isEmpty
              ? const Center(
                  child: Text(
                    'No gallery photos yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadGallery,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 380,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: gallery.length,
                    itemBuilder: (context, index) {
                      final item = gallery[index];
                      final imageUrl = item['image_url']?.toString() ?? '';
                      final title = item['title']?.toString() ?? '';
                      final description = item['description']?.toString() ?? '';
                      final id = int.tryParse(item['id'].toString()) ?? 0;

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey.shade700),
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      tooltip: 'Delete',
                                      onPressed: id == 0 ? null : () => deletePost(id),
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
