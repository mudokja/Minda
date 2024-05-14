class DiaryImage {
  final int imageIndex;
  final int diaryIndex;
  final String imageName;
  final String imageLink;

  DiaryImage({
    required this.imageIndex,
    required this.diaryIndex,
    required this.imageName,
    required this.imageLink,
  });

  factory DiaryImage.fromJson(Map<String, dynamic> json) {
    return DiaryImage(
      imageIndex: json['imageIndex'] ?? 0,
      diaryIndex: json['diaryIndex'] ?? 0,
      imageName: json['imageName'] ?? 'No Name',
      imageLink: json['imageLink'] ?? '',
    );
  }
}
