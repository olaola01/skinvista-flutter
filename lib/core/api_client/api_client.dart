import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final String baseUrl;
  final http.Client client;

  ApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> postMultipart({
    required String endpoint,
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      var request = http.MultipartRequest('POST', uri)
        ..fields.addAll(fields)
        ..files.addAll(files);

      request.headers['Accept'] = 'application/json';
      if (endpoint != '/get/token') {
        final token = await _getToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      final response = await client.send(request);
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return jsonDecode(responseData);
      } else {
        final responseBody = await response.stream.bytesToString();
        final errorData = jsonDecode(responseBody);
        final errorMessage = errorData['message'] ?? 'Unknown error';
        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          responseBody: responseBody,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e');
    }
  }

  Future<Map<String, dynamic>> postJson({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (endpoint != '/api/get/token') {
        final token = await _getToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final response = await client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw ApiException(
            message: 'Invalid response format: Expected JSON',
            statusCode: response.statusCode,
            responseBody: response.body,
          );
        }
      } else {
        final responseBody = response.body;
        try {
          final errorData = jsonDecode(responseBody);
          final errorMessage = errorData['message'] ?? 'Unknown error';
          throw ApiException(
            message: errorMessage,
            statusCode: response.statusCode,
            responseBody: responseBody,
          );
        } catch (e) {
          throw ApiException(
            message: 'Error: ${response.statusCode}',
            statusCode: response.statusCode,
            responseBody: responseBody,
          );
        }
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getJson({
    required String endpoint,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = {
        'Accept': 'application/json',
      };

      if (endpoint != '/api/get/token') {
        final token = await _getToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final response = await client.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw ApiException(
            message: 'Invalid response format: Expected JSON',
            statusCode: response.statusCode,
            responseBody: response.body,
          );
        }
      } else {
        final responseBody = response.body;
        try {
          final errorData = jsonDecode(responseBody);
          final errorMessage = errorData['message'] ?? 'Unknown error';
          throw ApiException(
            message: errorMessage,
            statusCode: response.statusCode,
            responseBody: responseBody,
          );
        } catch (e) {
          throw ApiException(
            message: 'Error: ${response.statusCode}',
            statusCode: response.statusCode,
            responseBody: responseBody,
          );
        }
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e');
    }
  }

  Future<Map<String, dynamic>> deleteJson({
    required String endpoint,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = {
        'Accept': 'application/json',
      };

      if (endpoint != '/api/get/token') {
        final token = await _getToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final response = await client.delete(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw ApiException(
            message: 'Invalid response format: Expected JSON',
            statusCode: response.statusCode,
            responseBody: response.body,
          );
        }
      } else {
        final responseBody = response.body;
        try {
          final errorData = jsonDecode(responseBody);
          final errorMessage = errorData['message'] ?? 'Unknown error';
          throw ApiException(
            message: errorMessage,
            statusCode: response.statusCode,
            responseBody: responseBody,
          );
        } catch (e) {
          throw ApiException(
            message: 'Error: ${response.statusCode}',
            statusCode: response.statusCode,
            responseBody: responseBody,
          );
        }
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e');
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  ApiException({required this.message, this.statusCode, this.responseBody});

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}${responseBody != null ? ' (Body: $responseBody)' : ''}';
}