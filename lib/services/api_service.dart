import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/claim.dart';
import '../models/part.dart';
import '../models/assessment.dart';
import '../models/photo.dart';

class ApiService {
  // Use localhost for web, 10.0.2.2 for Android emulator
  static const String baseUrl = 'http://localhost:8001';

  static String? _token;
  static int? _userId;
  static String? _userName;
  static String? _userEmail;

  static void setToken(String token) => _token = token;
  static String? get token => _token;
  static int? get userId => _userId;
  static String? get userName => _userName;
  static String? get userEmail => _userEmail;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Auth ────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String surveyorLicense = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'surveyor_license': surveyorLicense,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Registration failed');
  }

  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];
      _userId = data['user_id'];
      _userName = data['name'];
      _userEmail = data['email'];
      return true;
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Login failed');
  }

  static void logout() {
    _token = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
  }

  // ── Claims ──────────────────────────────────────────────────────

  static Future<Claim> createClaim(Map<String, dynamic> claimData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/claims/create'),
      headers: _headers,
      body: jsonEncode(claimData),
    );
    if (response.statusCode == 200) {
      return Claim.fromJson(jsonDecode(response.body));
    }
    throw Exception(jsonDecode(response.body)['detail'] ?? 'Failed to create claim');
  }

  static Future<List<Claim>> listClaims() async {
    final response = await http.get(
      Uri.parse('$baseUrl/claims/list'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => Claim.fromJson(j)).toList();
    }
    throw Exception('Failed to load claims');
  }

  static Future<Map<String, dynamic>> getClaimDetail(int claimId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/claims/$claimId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load claim detail');
  }

  static Future<Claim> updateClaim(int claimId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/claims/$claimId'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return Claim.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update claim');
  }

  // ── Parts ───────────────────────────────────────────────────────

  static Future<List<PartItem>> saveParts(
      int claimId, List<PartItem> parts) async {
    final response = await http.post(
      Uri.parse('$baseUrl/claims/$claimId/parts'),
      headers: _headers,
      body: jsonEncode(parts.map((part) {
        final json = part.toJson();
        json.remove('id');
        json.remove('claim_id');
        return json;
      }).toList()),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => PartItem.fromJson(j)).toList();
    }
    throw Exception('Failed to save parts');
  }

  static Future<List<PartItem>> getParts(int claimId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/claims/$claimId/parts'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => PartItem.fromJson(j)).toList();
    }
    throw Exception('Failed to load parts');
  }

  // ── Photos ──────────────────────────────────────────────────────

  static Future<InspectionPhoto> addPhoto(
      int claimId, Map<String, dynamic> photoData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/claims/$claimId/photos'),
      headers: _headers,
      body: jsonEncode(photoData),
    );
    if (response.statusCode == 200) {
      return InspectionPhoto.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to add photo');
  }

  static Future<List<InspectionPhoto>> getPhotos(int claimId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/claims/$claimId/photos'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((j) => InspectionPhoto.fromJson(j)).toList();
    }
    throw Exception('Failed to load photos');
  }

  // ── Assessment ──────────────────────────────────────────────────

  static Future<Assessment> saveAssessment(
      int claimId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/claims/$claimId/assessment'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return Assessment.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to save assessment');
  }

  static Future<Assessment> getAssessment(int claimId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/claims/$claimId/assessment'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Assessment.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load assessment');
  }

  // ── Estimate Upload ─────────────────────────────────────────────

  static Future<Map<String, dynamic>> uploadEstimate(
    int claimId,
    Uint8List fileBytes,
    String fileName,
  ) async {
    final uri = Uri.parse('$baseUrl/estimate/$claimId/upload');
    final request = http.MultipartRequest('POST', uri);
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
    );
    final streamedResponse = await request.send();
    final body = await streamedResponse.stream.bytesToString();
    if (streamedResponse.statusCode == 200) {
      return jsonDecode(body);
    }
    throw Exception('Upload failed: $body');
  }

  // ── Report ──────────────────────────────────────────────────────

  static Future<Uint8List> generateReport(int claimId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/$claimId/generate'),
      headers: {
        if (_token != null) 'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('Failed to generate report');
  }
}
