class QuizQuestion {
  final String id;
  final String kannada;
  final String transliteration;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.kannada,
    required this.transliteration,
    required this.options,
    required this.correctIndex,
    this.explanation = '',
  });

  String get correctAnswer => options[correctIndex];
}
