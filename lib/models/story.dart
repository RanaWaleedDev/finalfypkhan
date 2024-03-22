class Story {
  String? id;
  String? channelName;
  String? channelLogoUrl;
  String? storyPhotoUrl;
  int? date;

  Story(
      {required this.id,
      required this.channelName,
      required this.channelLogoUrl,
      required this.storyPhotoUrl,
      required this.date});
  Story.fromUIDAndDescription({required this.id, required this.channelName});
  factory Story.fromMap(Map<dynamic, dynamic> map) {
    return Story(
        id: map['id'],
        channelName: map['channelName'],
        channelLogoUrl: map['channelLogoUrl'],
        storyPhotoUrl: map["storyPhotoUrl"],
        date: map['date']);
  }

  Map toJson() {
    return {
      'id': id,
      'channelName': channelName,
      'channelLogoUrl': channelLogoUrl,
      "storyPhotoUrl": storyPhotoUrl,
      'date': date,
    };
  }
}
