import 'package:diary_fe/src/models/diary_image.dart';


class DiaryEntry {
  int diaryIndex;
  String diarySetDate;
  String diaryTitle;
  String diaryContent;
  int diaryHappiness, diarySadness, diaryFear, diaryAnger, diarySurprise;
  List<DiaryImage> imageList; // 변경된 부분
  List<String> hashtagList;

  DiaryEntry.fromJson(Map<String, dynamic> json)
      : diaryIndex = json['diaryIndex'],
        diarySetDate = json['diarySetDate'],
        diaryTitle = json['diaryTitle'],
        diaryContent = json['diaryContent'],
        diaryHappiness = json['diaryHappiness'],
        diarySadness = json['diarySadness'],
        diaryFear = json['diaryFear'],
        diaryAnger = json['diaryAnger'],
        diarySurprise = json['diarySurprise'],
        imageList = (json['imageList'] as List)
            .map((i) => DiaryImage.fromJson(i))
            .toList(), // 변경된 부분
        hashtagList = List<String>.from(json['hashtagList']);
}
