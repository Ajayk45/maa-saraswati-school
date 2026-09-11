import 'package:flutter/material.dart';

import '../services/api_service.dart';

class SchoolShell extends StatelessWidget {
  final Widget child;

  const SchoolShell({
    super.key,
    required this.child,
  });

  void goTo(BuildContext context, String route) {
    Navigator.pushReplacementNamed(
      context,
      route,
    );
  }

  Future<void> _logout(BuildContext context) async {
    await ApiService().adminLogout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  bool _isAdminPage(BuildContext context) {
    final route =
        ModalRoute.of(context)?.settings.name;

    return route == '/admin-dashboard' ||
        route == '/admin-content' ||
        route == '/admin-gallery' ||
        route == '/admin-admissions' ||
        route == '/admin-inquiries';
  }

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.of(context).size.width;

    final isDesktop = width >= 850;
    final isAdmin = _isAdminPage(context);

    // ========================================================
    // ADMIN AREA
    // ========================================================

    if (isAdmin) {
      return Scaffold(
        backgroundColor:
            const Color(0xfff4f7fb),

        drawer: isDesktop
            ? null
            : Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration:
                          const BoxDecoration(
                        color: Color(0xff1565c0),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            width: 60,
                            height: 70,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'SCHOOL ADMIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.dashboard,
                      ),
                      title:
                          const Text('Dashboard'),
                      onTap: () {
                        Navigator.pop(context);
                        goTo(
                          context,
                          '/admin-dashboard',
                        );
                      },
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.people,
                      ),
                      title:
                          const Text('Admissions'),
                      onTap: () {
                        Navigator.pop(context);
                        goTo(
                          context,
                          '/admin-admissions',
                        );
                      },
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.question_answer,
                      ),
                      title:
                          const Text('Inquiries'),
                      onTap: () {
                        Navigator.pop(context);
                        goTo(
                          context,
                          '/admin-inquiries',
                        );
                      },
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.photo_library,
                      ),
                      title:
                          const Text('Gallery'),
                      onTap: () {
                        Navigator.pop(context);
                        goTo(
                          context,
                          '/admin-gallery',
                        );
                      },
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.edit_document,
                      ),
                      title:
                          const Text('Edit Content'),
                      onTap: () {
                        Navigator.pop(context);
                        goTo(
                          context,
                          '/admin-content',
                        );
                      },
                    ),

                    const Divider(),

                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      onTap: () =>
                          _logout(context),
                    ),
                  ],
                ),
              ),

        appBar: AppBar(
          toolbarHeight: 78,
          backgroundColor:
              const Color(0xff1565c0),
          foregroundColor: Colors.white,

          titleSpacing: 16,

          leading: isDesktop
              ? null
              : Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(
                        Icons.menu,
                      ),
                      onPressed: () {
                        Scaffold.of(context)
                            .openDrawer();
                      },
                    );
                  },
                ),

          title: InkWell(
            onTap: () {
              goTo(
                context,
                '/admin-dashboard',
              );
            },
            borderRadius:
                BorderRadius.circular(8),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 52,
                  height: 62,
                  fit: BoxFit.contain,
                ),

                const SizedBox(width: 10),

                const Text(
                  'MAA SARASWATI\nPUBLIC SCHOOL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),

          actions: isDesktop
              ? [
                  TextButton.icon(
                    onPressed: () {
                      goTo(
                        context,
                        '/admin-dashboard',
                      );
                    },
                    icon: const Icon(
                      Icons.dashboard,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  TextButton.icon(
                    onPressed: () {
                      goTo(
                        context,
                        '/admin-admissions',
                      );
                    },
                    icon: const Icon(
                      Icons.people,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Admissions',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  TextButton.icon(
                    onPressed: () {
                      goTo(
                        context,
                        '/admin-inquiries',
                      );
                    },
                    icon: const Icon(
                      Icons.question_answer,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Inquiries',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  TextButton.icon(
                    onPressed: () {
                      goTo(
                        context,
                        '/admin-gallery',
                      );
                    },
                    icon: const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Gallery',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  TextButton.icon(
                    onPressed: () {
                      goTo(
                        context,
                        '/admin-content',
                      );
                    },
                    icon: const Icon(
                      Icons.edit_document,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Edit Content',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Padding(
                    padding:
                        const EdgeInsets.only(
                      right: 16,
                    ),
                    child:
                        ElevatedButton.icon(
                      onPressed: () =>
                          _logout(context),
                      icon: const Icon(
                        Icons.logout,
                        size: 18,
                      ),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.white,
                        foregroundColor:
                            const Color(
                          0xff1565c0,
                        ),
                      ),
                    ),
                  ),
                ]
              : null,
        ),

        body: Column(
          children: [
            Container(
              width: double.infinity,
              color:
                  const Color(0xff0d47a1),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
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
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Maa Saraswati Public School',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: child,
            ),
          ],
        ),
      );
    }

    // ========================================================
    // PUBLIC AREA
    // ========================================================

    return Scaffold(
      drawer: isDesktop
          ? null
          : Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration:
                        const BoxDecoration(
                      color: Color(0xff1565c0),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          width: 65,
                          height: 75,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'MAA SARASWATI\nPUBLIC SCHOOL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  ListTile(
                    leading:
                        const Icon(Icons.home),
                    title:
                        const Text('Home'),
                    onTap: () {
                      Navigator.pop(context);
                      goTo(context, '/');
                    },
                  ),
                  
                  ListTile(
                    leading:
                        const Icon(Icons.school),
                    title:
                        const Text('Admissions'),
                    onTap: () {
                      Navigator.pop(context);
                      goTo(
                        context,
                        '/admissions',
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.photo_library,
                    ),
                    title:
                        const Text('Gallery'),
                    onTap: () {
                      Navigator.pop(context);
                      goTo(
                        context,
                        '/gallery',
                      );
                    },
                  ),

                  ListTile(
                    leading:
                        const Icon(Icons.article),
                    title: const Text(
                      'Events & Guidelines',
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      goTo(
                        context,
                        '/content',
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.contact_phone,
                    ),
                    title:
                        const Text('Contact'),
                    onTap: () {
                      Navigator.pop(context);
                      goTo(
                        context,
                        '/contact',
                      );
                    },
                  ),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('About'),
                      onTap: () {
                        Navigator.pop(context);
                        goTo(context, '/about');
                      },
                    ),
                  const Divider(),

                  ListTile(
                    leading: const Icon(
                      Icons.admin_panel_settings,
                      color:
                          Color(0xff1565c0),
                    ),
                    title: const Text(
                      'Admin Login',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xff1565c0),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.pushNamed(
                        context,
                        '/admin-login',
                      );
                    },
                  ),
                ],
              ),
            ),

      appBar: AppBar(
        toolbarHeight: 78,
        titleSpacing: 16,

        title: InkWell(
          onTap: () {
            goTo(context, '/');
          },
          borderRadius:
              BorderRadius.circular(8),
          child: Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 52,
                height: 62,
                fit: BoxFit.contain,
              ),

              const SizedBox(width: 10),

              const Text(
                'MAA SARASWATI\nPUBLIC SCHOOL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),

        actions: isDesktop
            ? [
                TextButton(
                  onPressed: () {
                    goTo(context, '/');
                  },
                  child: const Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    goTo(
                      context,
                      '/admissions',
                    );
                  },
                  child: const Text(
                    'Admissions',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    goTo(
                      context,
                      '/gallery',
                    );
                  },
                  child: const Text(
                    'Gallery',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    goTo(
                      context,
                      '/content',
                    );
                  },
                  child: const Text(
                    'Events & Guidelines',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    goTo(
                      context,
                      '/contact',
                    );
                  },
                  child: const Text(
                    'Contact',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    goTo(context, '/about');
                  },
                  child: const Text(
                    'About',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                Padding(
                  padding:
                      const EdgeInsets.only(
                    right: 16,
                  ),
                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/admin-login',
                      );
                    },
                    icon: const Icon(
                      Icons
                          .admin_panel_settings,
                      size: 19,
                    ),
                    label: const Text(
                      'Admin Login',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.white,
                      foregroundColor:
                          const Color(
                        0xff1565c0,
                      ),
                      elevation: 2,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            color:
                const Color(0xff1565c0),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            child: const Wrap(
              alignment:
                  WrapAlignment.spaceBetween,
              spacing: 20,
              runSpacing: 5,
              children: [
                Text(
                  '📍 Near By Kisan Path, Juggour, Chinhat, Lucknow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '☎ 8090933790  |  8400040369',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}