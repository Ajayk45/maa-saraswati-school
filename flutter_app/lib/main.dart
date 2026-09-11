import 'package:flutter/material.dart';
import 'pages/about_page.dart';
import 'theme.dart';
import 'pages/admin_faculty_page.dart';
import 'pages/home_page.dart';
import 'pages/admissions_page.dart';
import 'pages/contact_page.dart';
import 'pages/gallery_page.dart';
import 'pages/content_page.dart';

import 'pages/admin_login_page.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/admin_content_page.dart';
import 'pages/admin_admissions_page.dart';
import 'pages/admin_gallery_page.dart';
import 'pages/admin_inquiries_page.dart';
import 'pages/admin_messages_page.dart';

void main() {
  runApp(const MaaSaraswatiApp());
}

class MaaSaraswatiApp extends StatelessWidget {
  const MaaSaraswatiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maa Saraswati School',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',

      routes: {
        // ======================================================
        // PUBLIC PAGES
        // ======================================================

        '/': (context) => const HomePage(),

        '/admissions': (context) =>
            const AdmissionsPage(),

        '/contact': (context) =>
            const ContactPage(),

        '/gallery': (context) =>
            const GalleryPage(),

        '/content': (context) =>
            const ContentPage(),

        // ======================================================
        // ADMIN LOGIN
        // ======================================================

        '/admin-login': (context) =>
            const AdminLoginPage(),

        '/admin': (context) =>
            const AdminLoginPage(),

        // ======================================================
        // ADMIN DASHBOARD
        // ======================================================

        '/admin-dashboard': (context) =>
            const AdminDashboardPage(),

        // ======================================================
        // ADMIN CONTENT
        // ======================================================

        '/admin-content': (context) =>
            const AdminContentPage(),
'/admin-faculty': (context) =>
    const AdminFacultyPage(),
'/about': (context) => const AboutPage(),

        // ======================================================
        // ADMIN GALLERY
        // ======================================================

        '/admin-gallery': (context) =>
            const AdminGalleryPage(),

        // ======================================================
        // ADMIN ADMISSIONS
        // ======================================================

        '/admin-admissions': (context) =>
            const AdminAdmissionsPage(),

        // ======================================================
        // ADMIN INQUIRIES
        // ======================================================

        '/admin-inquiries': (context) =>
            const AdminInquiriesPage(),

        '/admin-messages': (context) =>
            const AdminMessagesPage(),
      },
    );
  }
}