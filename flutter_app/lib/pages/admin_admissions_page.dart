import 'package:flutter/material.dart';

import 'admin_shell.dart';

import '../services/api_service.dart';

class AdminAdmissionsPage extends StatefulWidget {
  const AdminAdmissionsPage({super.key});

  @override
  State<AdminAdmissionsPage> createState() =>
      _AdminAdmissionsPageState();
}

class _AdminAdmissionsPageState extends State<AdminAdmissionsPage> {
  final ApiService _api = ApiService();
  final TextEditingController searchController = TextEditingController();

  String selectedStatus = 'All';
  bool isLoading = true;
  String? loadError;

  List<Map<String, dynamic>> admissions = [];

  @override
  void initState() {
    super.initState();
    loadAdmissions();
  }

  Future<void> loadAdmissions() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      final data = await _api.getAdmissions();

      if (!mounted) return;

      setState(() {
        admissions = data;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        loadError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<Map<String, dynamic>> get filteredAdmissions {
    final search = searchController.text.trim().toLowerCase();

    return admissions.where((admission) {
      final student =
          (admission['student_name'] ?? '').toString().toLowerCase();
      final father =
          (admission['father_name'] ?? '').toString().toLowerCase();
      final mobile = (admission['mobile'] ?? '').toString();

      final searchMatch = search.isEmpty ||
          student.contains(search) ||
          father.contains(search) ||
          mobile.contains(search);

      final status =
          (admission['status'] ?? 'Pending').toString();

      final statusMatch =
          selectedStatus == 'All' || status == selectedStatus;

      return searchMatch && statusMatch;
    }).toList();
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> openAdmissionForm() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const AdmissionFormDialog(),
    );

    if (created == true && mounted) {
      await loadAdmissions();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admission successfully added.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> updateStatus(
    Map<String, dynamic> admission,
    String status,
  ) async {
    final id = int.tryParse(admission['id'].toString());

    if (id == null) return;

    try {
      await _api.updateAdmissionStatus(id, status);
      await loadAdmissions();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Admission $status'),
          backgroundColor: statusColor(status),
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
    }
  }

  Future<void> deleteAdmission(
    Map<String, dynamic> admission,
  ) async {
    final id = int.tryParse(admission['id'].toString());

    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Admission'),
          content: Text(
            'Delete admission of ${admission['student_name']}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _api.deleteAdmission(id);
      await loadAdmissions();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admission deleted.'),
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
    }
  }

  void showAdmissionDetails(
    Map<String, dynamic> admission,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Admission Details'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detail(
                    'Student Name',
                    admission['student_name'],
                  ),
                  _detail(
                    'Father Name',
                    admission['father_name'],
                  ),
                  _detail(
                    'Mother Name',
                    admission['mother_name'],
                  ),
                  _detail(
                    'Date of Birth',
                    admission['dob'],
                  ),
                  _detail(
                    'Class',
                    admission['class_name'],
                  ),
                  _detail(
                    'Mobile',
                    admission['mobile'],
                  ),
                  _detail(
                    'Email',
                    admission['email'],
                  ),
                  _detail(
                    'Address',
                    admission['address'],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Status: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(
                          (admission['status'] ?? 'Pending')
                              .toString(),
                        ),
                        backgroundColor: statusColor(
                          (admission['status'] ?? 'Pending')
                              .toString(),
                        ).withOpacity(0.12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  Widget _detail(String title, dynamic value) {
    final text = value == null || value.toString().isEmpty
        ? '-'
        : value.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
          ),
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Admission Management',
      currentRoute: '/admin-admissions',
      backgroundColor: const Color(0xfff4f7fb),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: loadAdmissions,
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Admissions',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: openAdmissionForm,
                  icon: const Icon(Icons.add),
                  label: const Text('New Admission'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1565c0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText:
                              'Search student, father name or mobile...',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    DropdownButton<String>(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(
                          value: 'All',
                          child: Text('All'),
                        ),
                        DropdownMenuItem(
                          value: 'Pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'Approved',
                          child: Text('Approved'),
                        ),
                        DropdownMenuItem(
                          value: 'Rejected',
                          child: Text('Rejected'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 3,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off,
                size: 50,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              Text(
                loadError!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: loadAdmissions,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredAdmissions.isEmpty) {
      return const Center(
        child: Text(
          'No admissions found',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor:
              WidgetStateProperty.all(
            const Color(0xffe3f2fd),
          ),
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Student')),
            DataColumn(label: Text('Father')),
            DataColumn(label: Text('Class')),
            DataColumn(label: Text('Mobile')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: filteredAdmissions.map((admission) {
            final status =
                (admission['status'] ?? 'Pending').toString();

            return DataRow(
              cells: [
                DataCell(
                  Text(admission['id'].toString()),
                ),
                DataCell(
                  Text(
                    (admission['student_name'] ?? '').toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    (admission['father_name'] ?? '').toString(),
                  ),
                ),
                DataCell(
                  Text(
                    (admission['class_name'] ?? '').toString(),
                  ),
                ),
                DataCell(
                  Text(
                    (admission['mobile'] ?? '').toString(),
                  ),
                ),
                DataCell(
                  Chip(
                    label: Text(status),
                    labelStyle: TextStyle(
                      color: statusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor:
                        statusColor(status).withOpacity(0.12),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'View',
                        icon: const Icon(
                          Icons.visibility,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          showAdmissionDetails(admission);
                        },
                      ),
                      IconButton(
                        tooltip: 'Approve',
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          updateStatus(admission, 'Approved');
                        },
                      ),
                      IconButton(
                        tooltip: 'Reject',
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          updateStatus(admission, 'Rejected');
                        },
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          deleteAdmission(admission);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class AdmissionFormDialog extends StatefulWidget {
  const AdmissionFormDialog({super.key});

  @override
  State<AdmissionFormDialog> createState() =>
      _AdmissionFormDialogState();
}

class _AdmissionFormDialogState
    extends State<AdmissionFormDialog> {
  final ApiService _api = ApiService();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final studentNameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final motherNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  String selectedClass = 'Class 1';
  DateTime? selectedDob;
  bool isSubmitting = false;

  @override
  void dispose() {
    studentNameController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final today = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDob ?? DateTime(today.year - 8),
      firstDate: DateTime(1990),
      lastDate: today,
      helpText: 'Select Date of Birth',
    );

    if (picked != null && mounted) {
      setState(() {
        selectedDob = picked;
      });
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String formatDateForApi(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Date of Birth.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await _api.createAdmission({
        'student_name': studentNameController.text.trim(),
        'father_name': fatherNameController.text.trim(),
        'mother_name': motherNameController.text.trim(),
        'dob': formatDateForApi(selectedDob!),
        'class_name': selectedClass,
        'mobile': mobileController.text.trim(),
        'email': emailController.text.trim(),
        'address': addressController.text.trim(),
      });

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'New Admission',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 550,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: studentNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Student Name *',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';

                    if (text.isEmpty) {
                      return 'Student name is required';
                    }

                    if (text.length < 2) {
                      return 'Enter a valid student name';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: fatherNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Father Name *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if ((value?.trim() ?? '').isEmpty) {
                      return 'Father name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: motherNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Mother Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: isSubmitting ? null : selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth *',
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    child: Text(
                      selectedDob == null
                          ? 'Select date'
                          : formatDate(selectedDob!),
                      style: TextStyle(
                        color: selectedDob == null
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedClass,
                  decoration: const InputDecoration(
                    labelText: 'Class *',
                    prefixIcon: Icon(Icons.school),
                  ),
                  items: List.generate(
                    12,
                    (index) {
                      final value = 'Class ${index + 1}';

                      return DropdownMenuItem<String>(
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
                const SizedBox(height: 14),
                TextFormField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number *',
                    prefixIcon: Icon(Icons.phone),
                    counterText: '',
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';

                    if (text.isEmpty) {
                      return 'Mobile number is required';
                    }

                    if (!RegExp(r'^[0-9]{10}$').hasMatch(text)) {
                      return 'Enter valid 10-digit mobile number';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';

                    if (text.isEmpty) {
                      return null;
                    }

                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(text)) {
                      return 'Enter valid email address';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: addressController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting
              ? null
              : () => Navigator.pop(context, false),
          child: const Text('CANCEL'),
        ),
        ElevatedButton.icon(
          onPressed: isSubmitting ? null : submitForm,
          icon: isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check),
          label: Text(
            isSubmitting ? 'SAVING...' : 'SUBMIT',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff1565c0),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
