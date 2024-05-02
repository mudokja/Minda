class AnalysisModel {
  final int diaryIndex;
  final DateTime diarySetDate;
  final String diaryTitle;
  final String diaryContent;
  final int diaryHappiness;
  final int diarySadness;
  final int diaryFear;
  final int diaryAnger;

  final int diarySurprise;
  final List<ImageDetail> imageList;
  final List<String> hashtagList;

  AnalysisModel({
    required this.diaryIndex,
    required this.diarySetDate,
    required this.diaryTitle,
    required this.diaryContent,
    required this.diaryHappiness,
    required this.diarySadness,
    required this.diaryFear,
    required this.diaryAnger,
    required this.diarySurprise,
    required this.imageList,
    required this.hashtagList,
  });

  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    try {
      return AnalysisModel(
        diaryIndex: json['diaryIndex'] ?? 0,
        diarySetDate:
            DateTime.tryParse(json['diarySetDate'] ?? '') ?? DateTime.now(),
        diaryTitle: json['diaryTitle'] ?? '',
        diaryContent: json['diaryContent'] ?? '',
        diaryHappiness: json['diaryHappiness'] ?? 0,
        diarySadness: json['diarySadness'] ?? 0,
        diaryFear: json['diaryFear'] ?? 0,
        diaryAnger: json['diaryAnger'] ?? 0,
        diarySurprise: json['diarySurprise'] ?? 0,
        imageList: (json['imageList'] as List<dynamic>? ?? [])
            .map((x) => ImageDetail.fromJson(x))
            .toList(),
        hashtagList:
            List<String>.from(json['hashtagList'] as List<dynamic>? ?? []),
      );
    } catch (e) {
      throw Exception('AnalysisModel 실패: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'diaryIndex': diaryIndex,
      'diarySetDate': diarySetDate.toIso8601String(),
      'diaryTitle': diaryTitle,
      'diaryContent': diaryContent,
      'diaryHappiness': diaryHappiness,
      'diarySadness': diarySadness,
      'diaryFear': diaryFear,
      'diaryAnger': diaryAnger,
      'diarySurprise': diarySurprise,
      'imageList': imageList.map((x) => x.toJson()).toList(),
      'hashtagList': hashtagList,
    };
  }
}

class ImageDetail {
  final int imageIndex;
  final String imageName;
  final String imageLink;

  ImageDetail({
    required this.imageIndex,
    required this.imageName,
    required this.imageLink,
  });

  factory ImageDetail.fromJson(Map<String, dynamic> json) {
    return ImageDetail(
      imageIndex: json['imageIndex'],
      imageName: json['imageName'],
      imageLink: json['imageLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageIndex': imageIndex,
      'imageName': imageName,
      'imageLink': imageLink,
    };
  }
}
