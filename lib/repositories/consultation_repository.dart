import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/api_client/api_client.dart';
import '../models/consultation.dart';

class ConsultationRepository {
  final ApiClient apiClient;

  ConsultationRepository({required this.apiClient});

  Future<void> createConsultation({
    required String doctorId,
    required int diagnosisId,
    required String notes,
    required bool imageAuthorized,
    String? imagePath,
  }) async {
    try {
      final fields = {
        'doctor_id': doctorId,
        'diagnosis_id': diagnosisId.toString(), // Convert int to String
        'notes': notes,
        'image_authorized': imageAuthorized.toString(), // Convert bool to String
      };

      final files = <http.MultipartFile>[];
      if (imageAuthorized && imagePath != null) {
        files.add(await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      await apiClient.postMultipart(
        endpoint: '/consultations',
        fields: fields,
        files: files,
      );
    } catch (e) {
      throw Exception('Failed to create consultation: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDoctors() async {
    try {
      final response = await apiClient.getJson(endpoint: '/doctors');
      return List<Map<String, dynamic>>.from(response['data']);
    } catch (e) {
      throw Exception('Failed to fetch doctors: $e');
    }
  }

  Future<List<Consultation>> getConsultations() async {
    try {
      final response = await apiClient.getJson(endpoint: '/consultations');
      final List<dynamic> data = response['data'];
      return data.map((json) => Consultation.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch consultations: $e');
    }
  }
}