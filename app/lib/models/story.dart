final class Story {
  final String id;
  final String title;
  final String content;

  Story({required this.id, required this.title, required this.content});

  Story.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        content = map['content'];
}
