import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'school_shell.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> faculty = [];

  bool isLoadingFaculty = true;

  @override
  void initState() {
    super.initState();
    loadFaculty();
  }

  // ==========================================================
  // LOAD FACULTY
  // ==========================================================

  Future<void> loadFaculty() async {
    try {
      final data = await _api.getFaculty();

      if (!mounted) return;

      setState(() {
        faculty = data;
        isLoadingFaculty = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoadingFaculty = false;
      });
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

    final base = ApiService.baseUrl.replaceFirst(
      '/api',
      '',
    );

    return '$base$value';
  }

  @override
  Widget build(BuildContext context) {
    final principal = faculty
        .where(
          (item) => item['is_principal'] == true,
        )
        .toList();

    final teachers = faculty
        .where(
          (item) => item['is_principal'] != true,
        )
        .toList();

    return SchoolShell(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ==================================================
            // HERO
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 60,
                horizontal: 25,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff1565C0),
                    Color(0xff42A5F5),
                  ],
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 70,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'About Maa Saraswati Public School',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Education with Knowledge, Discipline & Values',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // ==================================================
            // ABOUT SCHOOL
            // ==================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
              ),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Our School',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1565C0),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Maa Saraswati Public School is committed to providing quality education in a caring and disciplined environment. We focus on academic excellence, moral values, creativity, sports and personality development so that every child becomes a responsible citizen of society.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            // ==================================================
            // PRINCIPAL
            // ==================================================

            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Principal's Message",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1565C0),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (isLoadingFaculty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )
            else if (principal.isEmpty)
              _emptyFacultyCard(
                'Principal information will be available soon.',
              )
            else
              _principalCard(principal.first),

            const SizedBox(height: 35),

            // ==================================================
            // TEACHERS
            // ==================================================

            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Our Teachers',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1565C0),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (isLoadingFaculty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )
            else if (teachers.isEmpty)
              _emptyFacultyCard(
                'Teacher information will be available soon.',
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double cardWidth;

                    if (constraints.maxWidth >= 1100) {
                      cardWidth = 250;
                    } else if (constraints.maxWidth >= 700) {
                      cardWidth = 220;
                    } else {
                      cardWidth = constraints.maxWidth;
                    }

                    return Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      alignment: WrapAlignment.center,
                      children: teachers.map(
                        (teacher) {
                          return SizedBox(
                            width: cardWidth,
                            child: _teacherCard(
                              teacher,
                            ),
                          );
                        },
                      ).toList(),
                    );
                  },
                ),
              ),

            const SizedBox(height: 35),

            // ==================================================
            // VISION / MISSION
            // ==================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _infoCard(
                    Icons.visibility,
                    'Our Vision',
                    'To inspire students to become lifelong learners, responsible citizens and future leaders through quality education.',
                  ),
                  _infoCard(
                    Icons.flag,
                    'Our Mission',
                    'To provide academic excellence, discipline, creativity and moral values in a safe learning environment.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // ==================================================
            // FACILITIES
            // ==================================================

            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Why Choose Our School?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1565C0),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                children: const [
                  _Facility(
                    Icons.menu_book,
                    'Smart Learning',
                  ),
                  _Facility(
                    Icons.computer,
                    'Computer Lab',
                  ),
                  _Facility(
                    Icons.sports_cricket,
                    'Sports Activities',
                  ),
                  _Facility(
                    Icons.science,
                    'Science Lab',
                  ),
                  _Facility(
                    Icons.music_note,
                    'Cultural Activities',
                  ),
                  _Facility(
                    Icons.directions_bus,
                    'Transport Facility',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // ==================================================
            // FOOTER
            // ==================================================
            const _WebsiteFooter(),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PRINCIPAL CARD
  // ==========================================================

  Widget _principalCard(
    Map<String, dynamic> person,
  ) {
    final name =
        person['name']?.toString() ?? '';

    final designation =
        person['designation']?.toString() ??
            'Principal';

    final description =
        person['description']?.toString() ?? '';

    final image =
        person['image_url']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mobile =
                constraints.maxWidth < 700;

            final photo = _facultyPhoto(
              image,
              radius: mobile ? 65 : 75,
              iconSize: mobile ? 70 : 80,
            );

            final details = Column(
              crossAxisAlignment:
                  mobile
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  textAlign:
                      mobile
                          ? TextAlign.center
                          : TextAlign.left,
                  style: TextStyle(
                    fontSize: mobile ? 22 : 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  designation,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Text(
                    description,
                    textAlign:
                        mobile
                            ? TextAlign.center
                            : TextAlign.left,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.7,
                    ),
                  ),
                ],
              ],
            );

            if (mobile) {
              return Column(
                children: [
                  photo,
                  const SizedBox(height: 20),
                  details,
                ],
              );
            }

            return Row(
              children: [
                photo,
                const SizedBox(width: 25),
                Expanded(
                  child: details,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // TEACHER CARD
  // ==========================================================

  Widget _teacherCard(
    Map<String, dynamic> teacher,
  ) {
    final name =
        teacher['name']?.toString() ?? '';

    final designation =
        teacher['designation']?.toString() ??
            '';

    final subject =
        teacher['subject']?.toString() ?? '';

    final description =
        teacher['description']?.toString() ?? '';

    final image =
        teacher['image_url']?.toString() ?? '';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _facultyPhoto(
              image,
              radius: 50,
              iconSize: 50,
            ),

            const SizedBox(height: 12),

            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              designation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),

            if (subject.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                subject,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ],

            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // FACULTY PHOTO
  // ==========================================================

  Widget _facultyPhoto(
    String image, {
    required double radius,
    required double iconSize,
  }) {
    if (image.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        child: Icon(
          Icons.person,
          size: iconSize,
          color: Colors.grey,
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: NetworkImage(
        _imageUrl(image),
      ),
      onBackgroundImageError: (_, __) {},
    );
  }

  // ==========================================================
  // EMPTY FACULTY
  // ==========================================================

  Widget _emptyFacultyCard(String message) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.groups_outlined,
                size: 55,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // INFO CARD
  // ==========================================================

  static Widget _infoCard(
    IconData icon,
    String title,
    String text,
  ) {
    return SizedBox(
      width: 400,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Icon(
                    icon,
                    color: const Color(0xff1565C0),
                    size: 45,
                    ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ==========================================================
// WEBSITE FOOTER
// ==========================================================

class _WebsiteFooter extends StatelessWidget {
  const _WebsiteFooter();

  void _go(BuildContext context, String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  Widget _link(
    BuildContext context,
    String title,
    String route,
  ) {
    return InkWell(
      onTap: () => _go(context, route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _section(
    String title,
    List<Widget> links,
  ) {
    return SizedBox(
      width: 190,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...links,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xff12385f),
      padding: const EdgeInsets.fromLTRB(25, 45, 25, 20),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 35,
                runSpacing: 30,
                alignment: WrapAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 280,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Maa Saraswati Public School',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Education with Knowledge, Discipline & Values',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.75),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _section(
                    'Quick Links',
                    [
                      _link(context, 'Home', '/'),
                      _link(context, 'About Us', '/about'),
                      _link(context, 'Admissions', '/admissions'),
                      _link(context, 'Gallery', '/gallery'),
                    ],
                  ),

                  _section(
                    'Explore',
                    [
                        _link(context, 'Admissions', '/admissions'),
                      _link(context, 'content', '/content'), 
                      _link(context, 'Contact Us', '/contact'),
                    ],
                  ),

                  SizedBox(
                    width: 240,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Developer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Website developed by',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Ajay Kumar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '✉  Ajaykumar4505786@gmail.com',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 35),
          Divider(
            color: Colors.white.withOpacity(.18),
            height: 1,
          ),
          const SizedBox(height: 18),

          const Text(
            '© 2026 Maa Saraswati Public School. All Rights Reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _Facility extends StatelessWidget {
  final IconData icon;
  final String title;

  const _Facility(
    this.icon,
    this.title,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Icon(
                icon,
                size: 38,
                color: const Color(0xff1565C0),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}