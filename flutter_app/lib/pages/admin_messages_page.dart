import 'package:flutter/material.dart';
import 'admin_shell.dart';
import '../services/api_service.dart';

class AdminMessagesPage extends StatefulWidget {
  const AdminMessagesPage({super.key});

  @override
  State<AdminMessagesPage> createState() => _AdminMessagesPageState();
}

class _AdminMessagesPageState extends State<AdminMessagesPage> {
  final ApiService _api = ApiService();

  List<dynamic> messages = [];
  bool loading = true;
  String search = '';

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    setState(() => loading = true);

    try {
      final data = await _api.messages();

      if (!mounted) return;

      setState(() {
        messages = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

Future<void> _markAsRead(Map<String, dynamic> message) async {
  final id = int.tryParse(
    message['id']?.toString() ?? '',
  );

  if (id == null) return;

  final alreadyRead = message['is_read'] == true;

  if (alreadyRead) return;

  try {
    await _api.markMessageAsRead(id);

    if (!mounted) return;

    setState(() {
      message['is_read'] = true;
    });
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.toString().replaceFirst(
            'Exception: ',
            '',
          ),
        ),
      ),
    );
  }
}

  Future<void> _deleteMessage(Map<String, dynamic> message) async {
    final id = int.tryParse(message['id'].toString());

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid message ID.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final name = message['name']?.toString() ?? 'Unknown';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 10),
              Text('Delete Message'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete the message from "$name"?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _api.deleteMessage(id);

      if (!mounted) return;

      setState(() {
        messages.removeWhere((item) {
          final itemMap =
              Map<String, dynamic>.from(item as Map);

          return itemMap['id'].toString() == id.toString();
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<dynamic> get filteredMessages {
    final q = search.trim().toLowerCase();

    if (q.isEmpty) return messages;

    return messages.where((item) {
      final m = Map<String, dynamic>.from(item as Map);

      return [
        m['name'],
        m['mobile'],
        m['email'],
        m['message'],
      ]
          .map(
            (x) => x?.toString().toLowerCase() ?? '',
          )
          .any((x) => x.contains(q));
    }).toList();
  }

  String value(dynamic v) {
    return v?.toString() ?? '';
  }

  String formatDate(dynamic dateValue) {
    if (dateValue == null) return '-';

    try {
      final date =
          DateTime.parse(dateValue.toString()).toLocal();

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      final hour =
          date.hour % 12 == 0 ? 12 : date.hour % 12;

      final minute =
          date.minute.toString().padLeft(2, '0');

      final second =
          date.second.toString().padLeft(2, '0');

      final amPm = date.hour >= 12 ? 'PM' : 'AM';

      return '${date.day.toString().padLeft(2, '0')} '
          '${months[date.month - 1]} ${date.year}, '
          '$hour:$minute:$second $amPm';
    } catch (_) {
      return dateValue.toString();
    }
  }

  String shortDate(dynamic dateValue) {
    if (dateValue == null) return '-';

    try {
      final date =
          DateTime.parse(dateValue.toString()).toLocal();

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      final hour =
          date.hour % 12 == 0 ? 12 : date.hour % 12;

      final minute =
          date.minute.toString().padLeft(2, '0');

      final amPm = date.hour >= 12 ? 'PM' : 'AM';

      return '${date.day.toString().padLeft(2, '0')} '
          '${months[date.month - 1]} ${date.year}, '
          '$hour:$minute $amPm';
    } catch (_) {
      return dateValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Contact Messages',
      currentRoute: '/admin-messages',
      backgroundColor: const Color(0xfff4f7fc),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: loading ? null : loadMessages,
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < 700;

          return SingleChildScrollView(
            padding: EdgeInsets.all(mobile ? 14 : 28),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: mobile ? 54 : 66,
                            height: mobile ? 54 : 66,
                            decoration: BoxDecoration(
                              gradient:
                                  const LinearGradient(
                                colors: [
                                  Color(0xff1976d2),
                                  Color(0xff1565c0),
                                ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue
                                      .withOpacity(.18),
                                  blurRadius: 15,
                                  offset:
                                      const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.chat_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contact Messages',
                                  style: TextStyle(
                                    fontSize:
                                        mobile ? 25 : 32,
                                    fontWeight:
                                        FontWeight.w800,
                                    color:
                                        const Color(0xff101b41),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'View messages submitted from the Contact Us page.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color:
                                        Color(0xff60708f),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!mobile) ...[
                      const SizedBox(width: 20),
                      _totalMessagesCard(),
                    ],
                  ],
                ),

                if (mobile) ...[
                  const SizedBox(height: 18),
                  _totalMessagesCard(),
                ],

                const SizedBox(height: 24),

                // SEARCH
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(15),
                          border: Border.all(
                            color:
                                const Color(0xffdbe3f0),
                          ),
                        ),
                        child: TextField(
                          onChanged: (v) {
                            setState(() => search = v);
                          },
                          decoration:
                              const InputDecoration(
                            prefixIcon:
                                Icon(Icons.search),
                            hintText:
                                'Search by name, mobile, email or message...',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xff1976d2),
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                      child: IconButton(
                        onPressed:
                            loading ? null : loadMessages,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(60),
                    child: Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  )
                else if (filteredMessages.isEmpty)
                  _emptyState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount:
                        filteredMessages.length,
                    itemBuilder: (context, index) {
                      final m =
                          Map<String, dynamic>.from(
                        filteredMessages[index] as Map,
                      );

                      return _messageCard(
                        m,
                        mobile,
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _totalMessagesCard() {
    return Container(
      width: 245,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xffe8f2ff),
            Color(0xffdcecff),
          ],
        ),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.mail_rounded,
              color: Color(0xff1565c0),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Messages',
                style: TextStyle(
                  color: Color(0xff1565c0),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${messages.length}',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff102d65),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _messageCard(
    Map<String, dynamic> m,
    bool mobile,
  ) {
    final name =
        value(m['name']).trim().isEmpty
            ? 'Unknown'
            : value(m['name']).trim();

    final phone = value(m['mobile']);
    final email = value(m['email']);
    final message = value(m['message']);
    final date = m['created_at'];

    final initial =
        name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xffe1e7f0),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
            onExpansionChanged: (expanded) {
    if (expanded) {
      _markAsRead(m);
    }
  },
          tilePadding: EdgeInsets.symmetric(
            
            horizontal: mobile ? 16 : 28,
            vertical: 9,
          ),
          childrenPadding:
              EdgeInsets.fromLTRB(
            mobile ? 16 : 28,
            0,
            mobile ? 16 : 28,
            24,
          ),
          leading: Container(
            width: mobile ? 50 : 58,
            height: mobile ? 50 : 58,
            decoration:
                const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xffcfe0ff),
                  Color(0xffb9d1ff),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                fontSize: mobile ? 21 : 25,
                fontWeight: FontWeight.w800,
                color:
                    const Color(0xff1455b8),
              ),
            ),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  name,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize:
                        mobile ? 16 : 19,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        const Color(0xff101b41),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (m['is_read'] != true)
  Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 11,
      vertical: 5,
    ),
    decoration: BoxDecoration(
      color: const Color(0xffd9f8e8),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 4,
          backgroundColor: Color(0xff16a34a),
        ),
        SizedBox(width: 6),
        Text(
          'New',
          style: TextStyle(
            color: Color(0xff159447),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    ),
  ),
            ],
          ),
          subtitle: Padding(
            padding:
                const EdgeInsets.only(top: 5),
            child: Text(
              shortDate(date),
              style: const TextStyle(
                color: Color(0xff64748b),
                fontSize: 13,
              ),
            ),
          ),
          children: [
            const Divider(
              color: Color(0xffe7edf5),
              height: 1,
            ),

            const SizedBox(height: 20),

            if (mobile)
              Column(
                children: [
                  _infoBox(
                    Icons.phone_rounded,
                    'Mobile Number',
                    phone,
                    const Color(0xff16a34a),
                    const Color(0xffdcfce7),
                  ),
                  const SizedBox(height: 12),
                  _infoBox(
                    Icons.email_rounded,
                    'Email Address',
                    email.isEmpty
                        ? '-'
                        : email,
                    const Color(0xfff04438),
                    const Color(0xffffe4e1),
                  ),
                  const SizedBox(height: 12),
                  _infoBox(
                    Icons.calendar_month_rounded,
                    'Received On',
                    formatDate(date),
                    const Color(0xff7c3aed),
                    const Color(0xffeee7ff),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _infoBox(
                      Icons.phone_rounded,
                      'Mobile Number',
                      phone,
                      const Color(0xff16a34a),
                      const Color(0xffdcfce7),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _infoBox(
                      Icons.email_rounded,
                      'Email Address',
                      email.isEmpty
                          ? '-'
                          : email,
                      const Color(0xfff04438),
                      const Color(0xffffe4e1),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _infoBox(
                      Icons.calendar_month_rounded,
                      'Received On',
                      formatDate(date),
                      const Color(0xff7c3aed),
                      const Color(0xffeee7ff),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 18),

            // MESSAGE
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xffe5efff),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons
                        .chat_bubble_outline_rounded,
                    color:
                        Color(0xff1769e0),
                    size: 27,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Message',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              Color(0xff52678d),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(
                                18),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(0xfff0f6ff),
                          borderRadius:
                              BorderRadius.circular(
                                  14),
                        ),
                        child: Text(
                          message.isEmpty
                              ? '-'
                              : message,
                          style:
                              const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color:
                                Color(0xff172554),
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // DELETE BUTTON
            const SizedBox(height: 20),

            Align(
              alignment:
                  Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () =>
                    _deleteMessage(m),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
                label: const Text(
                  'Delete Message',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                style:
                    OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Colors.red,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(
    IconData icon,
    String title,
    String text,
    Color iconColor,
    Color iconBackground,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xfff8faff),
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xffe5ebf4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        Color(0xff64748b),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xff132452),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 70,
        horizontal: 30,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xffe1e7f0),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.mail_outline_rounded,
            size: 65,
            color: Color(0xff3977d4),
          ),
          SizedBox(height: 20),
          Text(
            'No contact messages found',
            style: TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.w700,
              color:
                  Color(0xff172554),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Messages submitted from the Contact Us page will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff64748b),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}