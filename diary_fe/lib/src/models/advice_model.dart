class AdviceModel {
  final List<String> sentences;
  final List<String> emotions;
  final String? adviceContent;
  final Map<String, int> status;

  AdviceModel({
    required this.sentences,
    required this.emotions,
    this.adviceContent,
    required this.status,
  });

  factory AdviceModel.fromJson(Map<String, dynamic> json) {
    return AdviceModel(
      sentences: List<String>.from(json['sentence']),
      emotions: List<String>.from(json['emotion']),
      adviceContent: json['adviceContent'],
      status: (json['status'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as num).toInt())),
    );
  }
}
