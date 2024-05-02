class DiaryImage {
  int imageIndex;
  String imageName;
  String imageLink;

  DiaryImage({
    required this.imageIndex,
    required this.imageName,
    required this.imageLink,
  });

  factory DiaryImage.fromJson(Map<String, dynamic> json) {
    return DiaryImage(
      imageIndex: json['imageIndex'],
      imageName: json['imageName'],
      imageLink: json['imageLink'],
    );
  }
}
