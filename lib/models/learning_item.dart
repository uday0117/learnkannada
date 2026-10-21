enum ItemType { word, sentence }

class LearningItem {
  final String id;
  final String kannada;
  final String transliteration;
  final String english;
  final String category;
  final ItemType type;

  const LearningItem({
    required this.id,
    required this.kannada,
    required this.transliteration,
    required this.english,
    required this.category,
    required this.type,
  });

  bool get isWord => type == ItemType.word;
  bool get isSentence => type == ItemType.sentence;

  Map<String, dynamic> toJson() => {
        'id': id,
        'kannada': kannada,
        'transliteration': transliteration,
        'english': english,
        'category': category,
        'type': type.name,
      };

  factory LearningItem.fromJson(Map<String, dynamic> json) => LearningItem(
        id: json['id'] as String,
        kannada: json['kannada'] as String,
        transliteration: json['transliteration'] as String,
        english: json['english'] as String,
        category: json['category'] as String,
        type: (json['type'] == 'sentence' || json['type'] == 'ItemType.sentence')
            ? ItemType.sentence
            : ItemType.word,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
