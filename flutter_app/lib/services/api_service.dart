import 'dart:convert';

import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:5000/api',
  );

  // ==========================================================
  // PUBLIC CONTENT
  // ==========================================================

  Future<Map<String, dynamic>> publicContent() async {
    final response = await http.get(
      Uri.parse('$baseUrl/content'),
    );

    return _mapResponse(
      response,
      fallbackMessage: 'Unable to load website content',
    );
  }

  // ==========================================================
  // PUBLIC INQUIRY
  // ==========================================================

  Future<void> submitInquiry(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/inquiries'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }
  }

  // ==========================================================
  // PUBLIC CONTACT
  // ==========================================================

  Future<void> submitContact(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/contact'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }
  }

  // ==========================================================
  // ADMIN LOGIN
  // ==========================================================

  Future<String> adminLogin(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response));
    }

    final data =
        jsonDecode(response.body) as Map<String, dynamic>;

    final token = data['token']?.toString();

    if (token == null || token.isEmpty) {
      throw Exception('Login token nahi mila.');
    }

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      'admin_token',
      token,
    );

    return token;
  }

  // ==========================================================
  // ADMIN LOGOUT
  // ==========================================================

  Future<void> adminLogout() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('admin_token');
  }

  // ==========================================================
  // CHECK ADMIN LOGIN
  // ==========================================================

  Future<bool> isAdminLoggedIn() async {
    final token = await _token();

    return token.isNotEmpty;
  }

  // ==========================================================
  // ADMIN CONTENT - GET
  // ==========================================================

  Future<Map<String, dynamic>> adminContent() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/content'),
      headers: await _authHeaders(),
    );

    return _mapResponse(
      response,
      fallbackMessage: 'Unable to load CMS',
    );
  }

  // ==========================================================
  // ADMIN CONTENT - SAVE
  // ==========================================================

  Future<void> saveContent(
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/content'),
      headers: await _authHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response),
      );
    }
  }

  // ==========================================================
  // ADMIN INQUIRIES
  // ==========================================================

  Future<List<dynamic>> inquiries() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/inquiries'),
      headers: await _authHeaders(),
    );

    return _listResponse(
      response,
      fallbackMessage: 'Unable to load enquiries',
    );
  }

  // ==========================================================
  // DELETE INQUIRY
  // ==========================================================

  Future<void> deleteInquiry(
    int id,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/inquiries/$id'),
      headers: await _authHeaders(),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response),
      );
    }
  }

  // ==========================================================
  // ADMIN CONTACT MESSAGES
  // ==========================================================

  Future<List<dynamic>> messages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/contact'),
      headers: await _authHeaders(),
    );

    return _listResponse(
      response,
      fallbackMessage: 'Unable to load messages',
    );
  }
Future<void> deleteMessage(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/admin/contact/$id'),
    headers: await _authHeaders(),
  );

  if (response.statusCode < 200 ||
      response.statusCode >= 300) {
    throw Exception(_errorMessage(response));
  }
}
// ==========================================================
// MARK CONTACT MESSAGE AS READ
// ==========================================================

Future<void> markMessageAsRead(int id) async {
  final response = await http.patch(
    Uri.parse('$baseUrl/admin/contact/$id/read'),
    headers: await _authHeaders(),
  );

  if (response.statusCode < 200 ||
      response.statusCode >= 300) {
    throw Exception(_errorMessage(response));
  }
}
  // ==========================================================
  // ADMISSIONS - GET
  // ==========================================================

  Future<List<Map<String, dynamic>>>
      getAdmissions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admissions'),
      headers: await _authHeaders(),
    );

    final data = _listResponse(
      response,
      fallbackMessage: 'Unable to load admissions',
    );

    return data
        .map(
          (item) => Map<String, dynamic>.from(
            item as Map,
          ),
        )
        .toList();
  }

  // ==========================================================
  // ADMISSION - CREATE
  // ==========================================================

  Future<Map<String, dynamic>> createAdmission(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admissions'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return _mapResponse(
      response,
      fallbackMessage: 'Admission save nahi ho raha.',
    );
  }

  // ==========================================================
  // ADMISSION - UPDATE STATUS
  // ==========================================================

  Future<Map<String, dynamic>>
      updateAdmissionStatus(
    int id,
    String status,
  ) async {
    final response = await http.patch(
      Uri.parse(
        '$baseUrl/admissions/$id/status',
      ),
      headers: await _authHeaders(),
      body: jsonEncode({
        'status': status,
      }),
    );

    return _mapResponse(
      response,
      fallbackMessage:
          'Status update nahi ho raha.',
    );
  }

  // ==========================================================
  // ADMISSION - DELETE
  // ==========================================================

  Future<void> deleteAdmission(
    int id,
  ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/admissions/$id',
      ),
      headers: await _authHeaders(),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response),
      );
    }
  }

  // ==========================================================
  // GALLERY - GET
  // ==========================================================

  Future<List<Map<String, dynamic>>>
      getGallery() async {
    final response = await http.get(
      Uri.parse('$baseUrl/gallery'),
    );

    final data = _listResponse(
      response,
      fallbackMessage:
          'Unable to load gallery',
    );

    return data
        .map(
          (item) => Map<String, dynamic>.from(
            item as Map,
          ),
        )
        .toList();
  }

  // ==========================================================
  // GALLERY - UPLOAD IMAGE + CREATE POST
  // ==========================================================

  Future<Map<String, dynamic>> uploadGalleryPost({
    required String title,
    required String description,
    required XFile image,
  }) async {
    final token = await _token();

    if (token.isEmpty) {
      throw Exception('Admin login required.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/admin/gallery/upload'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    request.fields['description'] = description;

    final bytes = await image.readAsBytes();
    final filename = image.name.isEmpty ? 'gallery_image.jpg' : image.name;

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: filename,
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return _mapResponse(
      response,
      fallbackMessage: 'Unable to upload gallery image',
    );
  }

  // ==========================================================
  // GALLERY - DELETE
  // ==========================================================

  Future<void> deleteGalleryPost(
    int id,
  ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/admin/gallery/$id',
      ),
      headers: await _authHeaders(),
    );

    if (response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response),
      );
    }
  }

// ==========================================================
// FACULTY - GET
// ==========================================================

Future<List<Map<String, dynamic>>> getFaculty() async {
  final response = await http.get(
    Uri.parse('$baseUrl/faculty'),
  );

  final data = _listResponse(
    response,
    fallbackMessage: 'Unable to load faculty',
  );

  return data
      .map(
        (item) => Map<String, dynamic>.from(
          item as Map,
        ),
      )
      .toList();
}

// ==========================================================
// FACULTY - UPLOAD PHOTO
// ==========================================================

Future<Map<String, dynamic>> uploadFacultyImage({
  required XFile image,
}) async {
  final token = await _token();

  if (token.isEmpty) {
    throw Exception('Admin login required.');
  }

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/admin/faculty/upload'),
  );

  request.headers['Authorization'] =
      'Bearer $token';

  final bytes = await image.readAsBytes();

  final filename = image.name.isEmpty
      ? 'faculty_image.jpg'
      : image.name;

  request.files.add(
    http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: filename,
    ),
  );

  final streamed = await request.send();

  final response =
      await http.Response.fromStream(streamed);

  return _mapResponse(
    response,
    fallbackMessage:
        'Unable to upload faculty image',
  );
}

// ==========================================================
// FACULTY - ADD
// ==========================================================

Future<Map<String, dynamic>> addFaculty({
  required String name,
  required String designation,
  required String subject,
  required String description,
  required String imageUrl,
  required bool isPrincipal,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/admin/faculty'),
    headers: await _authHeaders(),
    body: jsonEncode({
      'name': name,
      'designation': designation,
      'subject': subject,
      'description': description,
      'image_url': imageUrl,
      'is_principal': isPrincipal,
    }),
  );

  return _mapResponse(
    response,
    fallbackMessage:
        'Unable to add faculty',
  );
}

// ==========================================================
// FACULTY - UPDATE
// ==========================================================

Future<Map<String, dynamic>> updateFaculty({
  required int id,
  required String name,
  required String designation,
  required String subject,
  required String description,
  required String imageUrl,
  required bool isPrincipal,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/admin/faculty/$id'),
    headers: await _authHeaders(),
    body: jsonEncode({
      'name': name,
      'designation': designation,
      'subject': subject,
      'description': description,
      'image_url': imageUrl,
      'is_principal': isPrincipal,
    }),
  );

  return _mapResponse(
    response,
    fallbackMessage:
        'Unable to update faculty',
  );
}

// ==========================================================
// FACULTY - DELETE
// ==========================================================

Future<void> deleteFaculty(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/admin/faculty/$id'),
    headers: await _authHeaders(),
  );

  if (response.statusCode < 200 ||
      response.statusCode >= 300) {
    throw Exception(
      _errorMessage(response),
    );
  }
}
  // ==========================================================
  // HEALTH CHECK
  // ==========================================================

  Future<Map<String, dynamic>> health() async {
    final response = await http.get(
      Uri.parse('$baseUrl/health'),
    );

    return _mapResponse(
      response,
      fallbackMessage:
          'Backend connection failed',
    );
  }

  // ==========================================================
  // AUTH HEADERS
  // ==========================================================

  Future<Map<String, String>>
      _authHeaders() async {
    final token = await _token();

    if (token.isEmpty) {
      throw Exception(
        'Admin login required.',
      );
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ==========================================================
  // GET TOKEN
  // ==========================================================

  Future<String> _token() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(
          'admin_token',
        ) ??
        '';
  }

  // ==========================================================
  // MAP RESPONSE
  // ==========================================================

  Map<String, dynamic> _mapResponse(
    http.Response response, {
    required String fallbackMessage,
  }) {
    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response),
      );
    }

    try {
      final decoded =
          jsonDecode(response.body);

      if (decoded
          is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}

    throw Exception(
      fallbackMessage,
    );
  }

  // ==========================================================
  // LIST RESPONSE
  // ==========================================================

  List<dynamic> _listResponse(
    http.Response response, {
    required String fallbackMessage,
  }) {
    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        _errorMessage(response),
      );
    }

    try {
      final decoded =
          jsonDecode(response.body);

      if (decoded is List) {
        return decoded;
      }
    } catch (_) {}

    throw Exception(
      fallbackMessage,
    );
  }

  // ==========================================================
  // ERROR MESSAGE
  // ==========================================================

  String _errorMessage(
    http.Response response,
  ) {
    try {
      final decoded =
          jsonDecode(response.body);

      if (decoded is Map) {
        final message =
            decoded['message'] ??
            decoded['error'];

        if (message != null) {
          return message.toString();
        }
      }
    } catch (_) {}

    if (response.statusCode == 401) {
      return 'Admin login required.';
    }

    if (response.statusCode == 403) {
      return 'Admin permission required.';
    }

    return 'Server error (${response.statusCode})';
  }
}