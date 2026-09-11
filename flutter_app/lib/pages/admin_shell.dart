import 'package:flutter/material.dart';

import '../services/admin_auth.dart';

class AdminShell extends StatelessWidget {
  final String title;
  final String currentRoute;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Color backgroundColor;

  const AdminShell({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.backgroundColor = const Color(0xfff4f7fb),
  });

  static const Color adminBlue = Color(0xff1565c0);

  void _go(BuildContext context, String route) {
    if (route == currentRoute) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _logout(BuildContext context) async {
    await AdminAuth.logout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: adminBlue,
        foregroundColor: Colors.white,
        titleSpacing: 14,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 44,
              height: 54,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.school, size: 36),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ...?actions,
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            tooltip: 'Admin Controls',
            icon: const Icon(Icons.admin_panel_settings),
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              } else {
                _go(context, value);
              }
            },
            itemBuilder: (context) => [
              _menuItem(
                '/admin-dashboard',
                Icons.dashboard,
                'Dashboard',
              ),
              _menuItem(
                '/admin-admissions',
                Icons.people,
                'Admissions',
              ),
              _menuItem(
                '/admin-inquiries',
                Icons.question_answer,
                'Inquiries',
              ),
              _menuItem(
                '/admin-gallery',
                Icons.photo_library,
                'Gallery',
              ),
              _menuItem(
                '/admin-faculty',
                Icons.groups,
                'Principal & Teachers',
              ),
              _menuItem(
                '/admin-content',
                Icons.edit_document,
                'Content',
              ),
              _menuItem(
                '/admin-messages',
                Icons.message,
                'Messages',
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _AdminDrawer(
        currentRoute: currentRoute,
        onNavigate: (route) => _go(context, route),
        onLogout: () => _logout(context),
      ),
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }

  PopupMenuItem<String> _menuItem(
    String route,
    IconData icon,
    String label,
  ) {
    final active = route == currentRoute;

    return PopupMenuItem<String>(
      value: route,
      enabled: !active,
      child: Row(
        children: [
          Icon(
            icon,
            color: active ? adminBlue : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight:
                    active ? FontWeight.bold : FontWeight.normal,
                color: active ? adminBlue : null,
              ),
            ),
          ),
          if (active)
            const Icon(
              Icons.check_circle,
              size: 18,
              color: adminBlue,
            ),
        ],
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;
  final VoidCallback onLogout;

  const _AdminDrawer({
    required this.currentRoute,
    required this.onNavigate,
    required this.onLogout,
  });

  static const Color adminBlue = Color(0xff1565c0);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 175,
            padding: const EdgeInsets.all(18),
            color: adminBlue,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 58,
                  height: 68,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'School Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(
            context,
            '/admin-dashboard',
            Icons.dashboard,
            'Dashboard',
          ),
          _drawerItem(
            context,
            '/admin-admissions',
            Icons.people,
            'Admissions',
          ),
          _drawerItem(
            context,
            '/admin-inquiries',
            Icons.question_answer,
            'Inquiries',
          ),
           _drawerItem(
  context,
  '/admin-gallery',
  Icons.photo_library,
  'Gallery',
),
_drawerItem(
  context,
  '/admin-faculty',
  Icons.groups,
  'Principal & Teachers',
),
_drawerItem(
  context,
  '/admin-content',
  Icons.edit_document,
  'Content',
),
          _drawerItem(
            context,
            '/admin-messages',
            Icons.message,
            'Messages',
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    String route,
    IconData icon,
    String label,
  ) {
    final active = route == currentRoute;

    return ListTile(
      selected: active,
      selectedTileColor: adminBlue.withValues(alpha: 0.10),
      selectedColor: adminBlue,
      leading: Icon(icon),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: active
          ? const Icon(Icons.check_circle, size: 18)
          : null,
      onTap: () {
        Navigator.pop(context);

        if (!active) {
          onNavigate(route);
        }
      },
    );
  }
}
