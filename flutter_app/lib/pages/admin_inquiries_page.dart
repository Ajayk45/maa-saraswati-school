import 'package:flutter/material.dart';

import 'admin_shell.dart';

import '../services/api_service.dart';

class AdminInquiriesPage extends StatefulWidget {
  const AdminInquiriesPage({super.key});

  @override
  State<AdminInquiriesPage> createState() =>
      _AdminInquiriesPageState();
}

class _AdminInquiriesPageState
    extends State<AdminInquiriesPage> {
  final ApiService _api = ApiService();

  List<dynamic> _inquiries = [];
  List<dynamic> _filtered = [];

  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadInquiries();
  }

  Future<void> _loadInquiries() async {
    setState(() {
      _loading = true;
    });

    try {
      final data = await _api.inquiries();

      if (!mounted) return;

      setState(() {
        _inquiries = data;
        _applySearch();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  void _applySearch() {
    final query = _search.trim().toLowerCase();

    if (query.isEmpty) {
      _filtered = List<dynamic>.from(_inquiries);
      return;
    }

    _filtered = _inquiries.where((item) {
      final inquiry =
          Map<String, dynamic>.from(item as Map);

      final parent =
          '${inquiry['parent_name'] ?? ''}'.toLowerCase();

      final student =
          '${inquiry['student_name'] ?? ''}'.toLowerCase();

      final mobile =
          '${inquiry['mobile'] ?? ''}'.toLowerCase();

      final className =
          '${inquiry['class_name'] ?? ''}'.toLowerCase();

      return parent.contains(query) ||
          student.contains(query) ||
          mobile.contains(query) ||
          className.contains(query);
    }).toList();
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';

    try {
      final date =
          DateTime.parse(value.toString());

      final day =
          date.day.toString().padLeft(2, '0');

      final month =
          date.month.toString().padLeft(2, '0');

      final year =
          date.year.toString();

      return '$day/$month/$year';
    } catch (_) {
      return value.toString();
    }
  }

  // ==========================================================
  // DELETE INQUIRY
  // ==========================================================

  Future<void> _deleteInquiry(
    Map<String, dynamic> inquiry,
  ) async {
    final id = int.tryParse(
      '${inquiry['id'] ?? ''}',
    );

    if (id == null) return;

    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Inquiry?',
          ),
          content: Text(
            'Are you sure you want to delete '
            'the inquiry from '
            '${inquiry['parent_name'] ?? 'this parent'}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _api.deleteInquiry(id);

      if (!mounted) return;

      setState(() {
        _inquiries.removeWhere(
          (item) =>
              '${(item as Map)['id']}' == '$id',
        );

        _applySearch();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Inquiry deleted successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  // ==========================================================
  // VIEW INQUIRY DETAILS
  // ==========================================================

  void _showDetails(
    Map<String, dynamic> inquiry,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Inquiry Details',
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _detail(
                    'Parent Name',
                    inquiry['parent_name'],
                  ),
                  _detail(
                    'Student Name',
                    inquiry['student_name'],
                  ),
                  _detail(
                    'Mobile',
                    inquiry['mobile'],
                  ),
                  _detail(
                    'Email',
                    inquiry['email'],
                  ),
                  _detail(
                    'Class',
                    inquiry['class_name'],
                  ),
                  _detail(
                    'Message',
                    inquiry['message'],
                  ),
                  _detail(
                    'Date',
                    _formatDate(
                      inquiry['created_at'],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detail(
    String label,
    dynamic value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value ?? '-'}',
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> _logout() async {
    await _api.adminLogout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  // ==========================================================
  // ADMIN NAVIGATION
  // ==========================================================

  void _go(String route) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (route) => false,
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Inquiries',
      currentRoute: '/admin-inquiries',
      backgroundColor:
          const Color(0xfff4f7fb),

      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: _loading ? null : _loadInquiries,
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xff0d47a1),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            child: const Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Text(
                  '🔐 Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Inquiry Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // PAGE CONTENT
          // ==================================================

          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Inquiries',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: _loading
                            ? null
                            : _loadInquiries,
                        icon: const Icon(
                          Icons.refresh,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'View and manage parent/student inquiries.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SEARCH
                  TextField(
                    decoration:
                        InputDecoration(
                      hintText:
                          'Search parent, student, mobile or class...',
                      prefixIcon:
                          const Icon(
                        Icons.search,
                      ),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _search = value;
                        _applySearch();
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  Text(
                    '${_filtered.length} '
                    '${_filtered.length == 1 ? 'Inquiry' : 'Inquiries'}',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: _loading
                        ? const Center(
                            child:
                                CircularProgressIndicator(),
                          )
                        : _filtered.isEmpty
                            ? Center(
                                child:
                                    Column(
                                  mainAxisSize:
                                      MainAxisSize
                                          .min,
                                  children: [
                                    const Icon(
                                      Icons
                                          .inbox_outlined,
                                      size: 60,
                                      color:
                                          Colors.grey,
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Text(
                                      _inquiries
                                              .isEmpty
                                          ? 'No inquiries yet.'
                                          : 'No matching inquiries.',
                                    ),
                                  ],
                                ),
                              )
                            : ListView
                                .separated(
                                itemCount:
                                    _filtered
                                        .length,
                                separatorBuilder:
                                    (_, __) =>
                                        const SizedBox(
                                  height: 10,
                                ),
                                itemBuilder:
                                    (
                                  context,
                                  index,
                                ) {
                                  final inquiry =
                                      Map<String,
                                          dynamic>.from(
                                    _filtered[
                                            index]
                                        as Map,
                                  );

                                  return Card(
                                    elevation: 1,
                                    child:
                                        ListTile(
                                      contentPadding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal:
                                            18,
                                        vertical: 8,
                                      ),

                                      leading:
                                          CircleAvatar(
                                        child:
                                            Text(
                                          '${index + 1}',
                                        ),
                                      ),

                                      title:
                                          Text(
                                        '${inquiry['student_name'] ?? '-'}',
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),

                                      subtitle:
                                          Padding(
                                        padding:
                                            const EdgeInsets
                                                .only(
                                          top: 6,
                                        ),
                                        child:
                                            Text(
                                          'Parent: ${inquiry['parent_name'] ?? '-'}\n'
                                          'Mobile: ${inquiry['mobile'] ?? '-'}\n'
                                          'Class: ${inquiry['class_name'] ?? '-'}\n'
                                          'Date: ${_formatDate(inquiry['created_at'])}',
                                        ),
                                      ),

                                      isThreeLine:
                                          true,

                                      onTap: () =>
                                          _showDetails(
                                        inquiry,
                                      ),

                                      trailing:
                                          IconButton(
                                        tooltip:
                                            'Delete',
                                        onPressed: () =>
                                            _deleteInquiry(
                                          inquiry,
                                        ),
                                        icon:
                                            const Icon(
                                          Icons
                                              .delete_outline,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}