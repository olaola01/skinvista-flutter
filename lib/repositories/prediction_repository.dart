import 'dart:io';
import 'package:http/http.dart' as http;

import '../core/api_client/api_client.dart';
import '../responses/prediction_response.dart';


class PredictionRepository {
  final ApiClient apiClient;

  PredictionRepository({required this.apiClient});

  Future<PredictionResponse> getPrediction(String imagePath) async {
    try {
      final files = [
        await http.MultipartFile.fromPath('image', imagePath),
      ];
      final response = await apiClient.postMultipart(
        endpoint: '/predict',
        fields: {},
        files: files,
      );
      return PredictionResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get prediction: $e');
    }
  }
}