import 'package:diary_fe/src/models/advice_model.dart';
import 'package:diary_fe/src/services/api_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AdviceService {
  final ApiService _apiService = ApiService();

  Future<AdviceModel?> fetchAdvice(
    DateTime date,
  ) async {
    String formDate = formatDate(date);
    try {
      var response = await _apiService.get('/api/advice/single?date=$formDate');

      if (response.statusCode == 200) {
        var jsonData = response.data;

        return AdviceModel.fromJson(jsonData);
      } else {
        debugPrint('Error occurred: ${response.statusCode}');
        debugPrint('Error message: ${response.data}');
        return null;
      }
    } on DioException catch (dioException) {
      debugPrint('DioException occurred: $dioException');
      debugPrint('HTTP status code: ${dioException.response?.statusCode}');
      debugPrint('Error message: ${dioException.response?.data}');
      return null;
    } catch (e) {
      debugPrint('Error occurred: $e');
      throw Exception('Failed to fetch advice data: $e');
    }
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
