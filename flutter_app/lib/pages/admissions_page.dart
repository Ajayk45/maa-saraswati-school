import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'school_shell.dart';

class AdmissionsPage extends StatefulWidget {
  const AdmissionsPage({super.key});

  @override
  State<AdmissionsPage> createState() => _AdmissionsPageState();
}

class _AdmissionsPageState extends State<AdmissionsPage> {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  final parentController = TextEditingController();
  final studentController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();

  String selectedClass = 'Class 1';
  bool isSubmitting = false;

  @override
  void dispose() {
    parentController.dispose();
    studentController.dispose();
    phoneController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> submitInquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      await _api.submitInquiry({
        'parentName': parentController.text.trim(),
        'mobile': phoneController.text.trim(),
        'studentName': studentController.text.trim(),
        'email': emailController.text.trim(),
        'className': selectedClass,
        'message': messageController.text.trim(),
      });

      if (!mounted) return;

      parentController.clear();
      studentController.clear();
      phoneController.clear();
      emailController.clear();
      messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Inquiry submitted successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SchoolShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admissions & Inquiry',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Fill in the form and our school team will contact you.',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: parentController,
                        decoration: const InputDecoration(
                          labelText: 'Parent Name *',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if ((value?.trim() ?? '').isEmpty) {
                            return 'Please enter parent name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: studentController,
                        decoration: const InputDecoration(
                          labelText: 'Student Name *',
                          prefixIcon: Icon(Icons.school),
                        ),
                        validator: (value) {
                          if ((value?.trim() ?? '').isEmpty) {
                            return 'Please enter student name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          prefixIcon: Icon(Icons.phone),
                          counterText: '',
                        ),
                        validator: (value) {
                          if (!RegExp(
                            r'^[0-9]{10}$',
                          ).hasMatch(value?.trim() ?? '')) {
                            return 'Enter valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        initialValue: selectedClass,
                        decoration: const InputDecoration(
                          labelText: 'Class',
                          prefixIcon: Icon(Icons.school),
                        ),
                        items: List.generate(
                          12,
                          (index) {
                            final value =
                                'Class ${index + 1}';

                            return DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            );
                          },
                        ),
                        onChanged: isSubmitting
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedClass = value;
                                  });
                                }
                              },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: messageController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Message / Inquiry',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.message),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              isSubmitting ? null : submitInquiry,
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                            isSubmitting
                                ? 'SUBMITTING...'
                                : 'SUBMIT INQUIRY',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
