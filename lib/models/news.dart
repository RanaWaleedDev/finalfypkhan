class News {
  String? id;
  String? title;
  String? description;
  String? photoUrl;
  String? category;
  int? date;

  News(
      {required this.id,
      required this.title,
      required this.description,
      required this.photoUrl,
      required this.category,
      required this.date});
  News.fromUIDAndDescription({required this.id, required this.title});
  factory News.fromMap(Map<dynamic, dynamic> map) {
    return News(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        photoUrl: map['photoUrl'],
        category: map['category'],
        date: map['date']);
  }

  Map toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photoUrl': photoUrl,
      'date': date,
    };
  }
}
