import 'package:flutter/material.dart';
import '../core/services/ad_service.dart';
import '../core/services/tts_service.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/responsive.dart';
import '../data/content_repository.dart';
import '../models/quiz_question.dart';

class QuizScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const QuizScreen({super.key, this.onBackToHome});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ContentRepository _repository = ContentRepository();
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  int _score = 0;
  bool _isQuizFinished = false;

  @override
  void initState() {
    super.initState();
    _startQuiz();
  }

  void _startQuiz() {
    // Preload interstitial so it's ready upon quiz completion
    AdService().loadQuizInterstitial();

    setState(() {
      _questions = _repository.generateQuiz(questionCount: 10);
      _currentIndex = 0;
      _selectedIndex = null;
      _answered = false;
      _score = 0;
      _isQuizFinished = false;
    });
  }

  void _selectOption(int index) {
    if (_answered) return;

    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (index == _questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
      });
    } else {
      // Show Interstitial Ad (learn_kannada_quiz_interstitial) on quiz completion
      AdService().showQuizInterstitial(
        onDismissed: () {
          if (mounted) {
            setState(() {
              _isQuizFinished = true;
            });
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isQuizFinished) {
      return _buildScoreSummary();
    }

    final currentQuestion = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Quiz'),
        leading: widget.onBackToHome != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBackToHome,
              )
            : null,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscapeMode = constraints.maxWidth > constraints.maxHeight &&
                constraints.maxHeight < 560;

            final progressBar = Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: isDark
                          ? AppColors.darkBorder
                          : AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? AppColors.accentGreen : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  '${_currentIndex + 1}/${_questions.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                ),
              ],
            );

            if (isLandscapeMode) {
              // 2-column landscape mode: Question on left, options on right
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    progressBar,
                    const SizedBox(height: 12),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 5,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: _buildQuestionCard(currentQuestion, isDark),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 6,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (int i = 0; i < currentQuestion.options.length; i++) ...[
                                    _buildOptionTile(
                                      currentQuestion: currentQuestion,
                                      optionText: currentQuestion.options[i],
                                      optionIndex: i,
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  const SizedBox(height: 4),
                                  _buildNextButton(isDark),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Standard portrait layout with responsive width & safe scrolling
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ResponsiveContentWrapper(
                    maxWidth: 620,
                    child: progressBar,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ResponsiveContentWrapper(
                        maxWidth: 620,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildQuestionCard(currentQuestion, isDark),
                            const SizedBox(height: 18),
                            for (int i = 0; i < currentQuestion.options.length; i++) ...[
                              _buildOptionTile(
                                currentQuestion: currentQuestion,
                                optionText: currentQuestion.options[i],
                                optionIndex: i,
                              ),
                              const SizedBox(height: 12),
                            ],
                            const SizedBox(height: 10),
                            _buildNextButton(isDark),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion currentQuestion, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSide(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'What is the meaning of',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.subtext(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            currentQuestion.kannada,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NotoSansKannada',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.accentGreen : AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '(${currentQuestion.transliteration})',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.subtext(context),
            ),
          ),
          const SizedBox(height: 16),
          // Pronounce button (Unmute / Mute Toggle)
          ValueListenableBuilder<String?>(
            valueListenable: TtsService().currentlyPlayingId,
            builder: (context, playingId, _) {
              final isPlaying = playingId == 'quiz_${currentQuestion.id}';
              return IconButton.filledTonal(
                onPressed: () {
                  TtsService().toggleSpeak(
                    id: 'quiz_${currentQuestion.id}',
                    text: currentQuestion.kannada,
                  );
                },
                tooltip: isPlaying
                    ? 'Mute / Stop audio'
                    : 'Unmute / Hear pronunciation',
                style: IconButton.styleFrom(
                  backgroundColor: isPlaying
                      ? (isDark
                          ? AppColors.accentGreen.withValues(alpha: 0.3)
                          : AppColors.primary.withValues(alpha: 0.2))
                      : (isDark
                          ? AppColors.darkGreenTint
                          : AppColors.greenTint),
                  foregroundColor: isPlaying
                      ? (isDark ? AppColors.goldVibrant : AppColors.primary)
                      : (isDark ? AppColors.accentGreen : AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isPlaying
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    key: ValueKey<bool>(isPlaying),
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(bool isDark) {
    return FilledButton(
      onPressed: _answered ? _nextQuestion : null,
      style: FilledButton.styleFrom(
        backgroundColor:
            isDark ? AppColors.accentGreen : AppColors.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
        disabledBackgroundColor:
            isDark ? AppColors.darkBorder : AppColors.border,
        disabledForegroundColor: AppColors.textMuted,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        _currentIndex == _questions.length - 1 ? 'Finish' : 'Next',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required QuizQuestion currentQuestion,
    required String optionText,
    required int optionIndex,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color cardColor = AppColors.surface(context);
    Color borderColor = AppColors.borderSide(context);
    Color textColor = AppColors.text(context);
    Widget trailingIcon = Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1.5,
        ),
      ),
    );

    if (_answered) {
      final isCorrect = optionIndex == currentQuestion.correctIndex;
      final isSelected = optionIndex == _selectedIndex;

      if (isCorrect) {
        cardColor = isDark ? AppColors.darkCorrectBg : AppColors.correctBg;
        borderColor = AppColors.correctGreen;
        textColor = isDark ? const Color(0xFF4ADE80) : AppColors.correctGreen;
        trailingIcon = const Icon(
          Icons.check_circle_rounded,
          color: AppColors.correctGreen,
          size: 24,
        );
      } else if (isSelected) {
        cardColor = isDark ? AppColors.darkIncorrectBg : AppColors.incorrectBg;
        borderColor = AppColors.incorrectRed;
        textColor = isDark ? const Color(0xFFF87171) : AppColors.incorrectRed;
        trailingIcon = const Icon(
          Icons.cancel_rounded,
          color: AppColors.incorrectRed,
          size: 24,
        );
      }
    }

    return InkWell(
      onTap: _answered ? null : () => _selectOption(optionIndex),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: _answered ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            trailingIcon,
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSummary() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = ((_score / _questions.length) * 100).round();
    final isPass = percentage >= 60;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ResponsiveContentWrapper(
              maxWidth: 500,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trophy / Medal Badge
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isPass
                          ? (isDark ? const Color(0xFF382C10) : AppColors.goldLight)
                          : (isDark ? AppColors.darkIncorrectBg : AppColors.incorrectBg),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPass ? Icons.emoji_events_rounded : Icons.refresh_rounded,
                      size: 52,
                      color: isPass
                          ? (isDark ? AppColors.goldVibrant : AppColors.goldDark)
                          : (isDark ? const Color(0xFFF87171) : AppColors.incorrectRed),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    isPass ? 'Outstanding Effort!' : 'Keep Practicing!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.accentGreen : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPass
                        ? 'You did great on this Kannada quiz.'
                        : 'Review the words and sentences to boost your score.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.subtext(context),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Score Box
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderSide(context)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'YOUR SCORE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.subtext(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$_score / ${_questions.length}',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.accentGreen
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$percentage% accuracy',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isPass
                                ? AppColors.correctGreen
                                : AppColors.incorrectRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Restart Quiz Button
                  FilledButton.icon(
                    onPressed: _startQuiz,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Try Another Quiz'),
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.accentGreen
                          : AppColors.primary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Return Home
                  if (widget.onBackToHome != null)
                    OutlinedButton(
                      onPressed: widget.onBackToHome,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text(context),
                        side: BorderSide(color: AppColors.borderSide(context)),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
