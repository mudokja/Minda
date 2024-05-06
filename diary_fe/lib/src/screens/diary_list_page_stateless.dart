// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:diary_fe/src/services/diary_provider.dart';
// import 'package:diary_fe/src/models/MoodEntry.dart'; // 필요에 따라 import 추가

// class DiaryListPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Consumer<DiaryProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (provider.entries.isEmpty) {
//             return Center(child: Text("No diary entries found"));
//           }
//           return ListView.builder(
//             itemCount: provider.entries.length,
//             itemBuilder: (context, index) {
//               final entry = provider.entries[index];
//               return ListTile(
//                 title: Text(entry.diary_happiness ?? 'No Title'),
//                 subtitle: Text(entry.diary_sadness ?? 'No Content'),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
