// import 'package:dio/dio.dart'; // Dio 패키지를 정확하게 import
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:diary_fe/src/models/MoodEntry.dart';
// import 'package:diary_fe/src/models/DiaryEntry.dart';
// import 'package:diary_fe/src/services/diary_api_service.dart';
// import 'package:diary_fe/src/services/api_services.dart';

// class DiaryProvider with ChangeNotifier {
//   List<DiaryEntry> _entries = [];
//   bool _isLoading = false;

//   final DiaryApiService _apiService; // API 서비스에 대한 참조
//   final ApiService apiService = ApiService();

//   List<DiaryEntry> get entries => _entries;
//   bool get isLoading => _isLoading;

//   DiaryProvider(this._apiService) {
//     fetchDiaryEntries();
//   }

//   Future<void> fetchDiaryEntries() async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       _entries = await _apiService.fetchDiaryEntries();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<DiaryEntry?> fetchDiaryEntry(int diaryIndex) async {
//     try {
//       final response = await apiService.get('/api/diary?diaryIndex=$diaryIndex');
//       return DiaryEntry.fromJson(response.data);
//     } catch (e) {
//       print('Error fetching diary entry: $e');
//       return null;
//     }
//   }
// }

import 'package:dio/dio.dart'; // Dio 패키지를 정확하게 import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary_fe/src/models/DiaryEntry.dart';
import 'package:diary_fe/src/services/diary_api_service.dart';
import 'package:diary_fe/src/services/api_services.dart';

class DiaryProvider with ChangeNotifier {
  List<DiaryEntry> _entries = [];
  DiaryEntry? _selectedDiaryEntry;
  bool _isLoading = false;

  final DiaryApiService _apiService; // API 서비스에 대한 참조
  final ApiService apiService = ApiService();

  List<DiaryEntry> get entries => _entries;
  DiaryEntry? get selectedDiaryEntry => _selectedDiaryEntry;
  bool get isLoading => _isLoading;

  DiaryProvider(this._apiService) {
    fetchDiaryEntries();
  }

  Future<void> fetchDiaryEntries() async {
    _isLoading = true;
    notifyListeners();
    try {
      _entries = await _apiService.fetchDiaryEntries();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDiaryEntry(int diaryIndex) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await apiService.get('/api/diary?diaryIndex=$diaryIndex');
      _selectedDiaryEntry = DiaryEntry.fromJson(response.data);
    } catch (e) {
      print('Error fetching diary entry: $e');
      _selectedDiaryEntry = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
