import '../core/api_client/api_client.dart';
import '../models/diagnosis.dart';

class DiagnosisRepository {
  final ApiClient apiClient;

  DiagnosisRepository({required this.apiClient});

  Future<void> saveDiagnosis({
    required String condition,
    required double confidence,
    String? imagePath,
  }) async {
    try {
      await apiClient.postJson(
        endpoint: '/save-diagnosis',
        body: {
          'condition': condition,
          'confidence': confidence,
          'image_path': imagePath,
        },
      );
    } catch (e) {
      throw Exception('Failed to save diagnosis: $e');
    }
  }

  Future<List<Diagnosis>> getDiagnoses() async {
    try {
      final response = await apiClient.getJson(endpoint: '/diagnoses');
      final List<dynamic> data = response['data'];
      print('Raw JSON data: $data');
      return data.map((json) => Diagnosis.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch diagnoses, I do not know wha is happening: $e');
    }
  }

  Future<void> deleteDiagnosis(int diagnosisId) async {
    try {
      await apiClient.deleteJson(endpoint: '/diagnoses/$diagnosisId');
    } catch (e) {
      throw Exception('Failed to delete diagnosis: $e');
    }
  }
}