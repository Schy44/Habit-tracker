class Quote {
  final String id;
  final String content;
  final String author;
  bool isFavorite;

  Quote({
    required this.id,
    required this.content,
    required this.author,
    this.isFavorite = false,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: (json['id'] ?? (json['q'] + json['a'])).toString(),
      content: json['content'] ?? json['quote'] ?? json['q'],
      author: json['author'] ?? json['a'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': author,
      'isFavorite': isFavorite,
    };
  }
}
