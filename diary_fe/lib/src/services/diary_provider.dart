import 'package:dio/dio.dart'; // Dio 패키지를 정확하게 import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary_fe/src/models/MoodEntry.dart';
import 'package:diary_fe/src/models/DiaryEntry.dart';
import 'package:diary_fe/src/services/diary_api_service.dart';

// class DiaryProvider with ChangeNotifier {
//   List<MoodEntry> _entries = [];
//   bool _isLoading = false;

//   List<MoodEntry> get entries => _entries;
//   bool get isLoading => _isLoading;

//   final DiaryApiService _apiService;

//   DiaryProvider(this._apiService);

//   Future<void> loadDiaryEntries() async {
//     _isLoading = true;
//     notifyListeners();
//     _entries = await _apiService.fetchDiaryEntries();
//     _isLoading = false;
//     notifyListeners();
//   }
// }
class DiaryProvider with ChangeNotifier {
  List<DiaryEntry> _entries = [];
  bool _isLoading = false;

  final DiaryApiService _apiService; // API 서비스에 대한 참조

  List<DiaryEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  DiaryProvider(this._apiService) {
    fetchDiaryEntries();
  }

//   Future<void> fetchDiaryEntries() async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       _entries = await _apiService.fetchDiaryEntries();
//     } catch (e) {
//       print('Error fetching diary entries: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }
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
}