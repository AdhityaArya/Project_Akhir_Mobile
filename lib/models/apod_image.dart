class ApodImage {
  final String title;
  final String explanation;
  final String url;
  final String hdurl;
  final String date;

  ApodImage({
    required this.title,
    required this.explanation,
    required this.url,
    required this.hdurl,
    required this.date,
  });

  factory ApodImage.fromJson(Map<String, dynamic> json) {
    return ApodImage(
      title: json['title'] ?? 'No title',
      explanation: json['explanation'] ?? 'No explanation',
      url: json['url'] ?? '',
      hdurl: json['hdurl'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
