import 'package:flutter/material.dart';
import '../core/services/ad_service.dart';
import '../core/services/rating_service.dart';
import '../core/services/tts_service.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/responsive.dart';
import '../widgets/in_app_rating_dialog.dart';
import '../data/content_repository.dart';
import '../models/quiz_question.dart';

class QuizUserAnswer {
  final QuizQuestion question;
  final int selectedIndex;
  final bool isCorrect;

  const QuizUserAnswer({
    required this.question,
    required this.selectedIndex,
    required this.isCorrect,
  });
}

class QuizScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const QuizScreen({super.key, this.onBackToHome});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ContentRepository _repository = ContentRepository();
  List<QuizQuestion> _questions = [];
  final List<QuizUserAnswer> _userAnswers = [];
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  int _score = 0;
  bool _isQuizFinished = false;
  int _summaryFilter = 0; // 0 = All, 1 = Incorrect, 2 = Correct
  bool _showRatingBanner = true;

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
      _userAnswers.clear();
      _summaryFilter = 0;
      _currentIndex = 0;
      _selectedIndex = null;
      _answered = false;
      _score = 0;
      _isQuizFinished = false;
    });
  }

  void _selectOption(int index) {
    if (_answered) return;

    final currentQuestion = _questions[_currentIndex];
    final isCorrect = index == currentQuestion.correctIndex;

    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (isCorrect) {
        _score++;
      }
      _userAnswers.add(
        QuizUserAnswer(
          question: currentQuestion,
          selectedIndex: index,
          isCorrect: isCorrect,
        ),
      );
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
            RatingService().recordQuizCompletion();
            setState(() {
              _isQuizFinished = true;
            });
            final percentage = _questions.isNotEmpty
                ? ((_score / _questions.length) * 100).round()
                : 0;
            if (RatingService().shouldPromptAfterQuiz(percentage: percentage)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  showInAppRatingDialog(context, isMilestone: true);
                }
              });
            }
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
    final totalCount = _questions.length;
    final percentage = totalCount > 0 ? ((_score / totalCount) * 100).round() : 0;
    final isPass = percentage >= 60;
    final incorrectCount = totalCount - _score;

    final filteredAnswers = _userAnswers.where((answer) {
      if (_summaryFilter == 1) return !answer.isCorrect;
      if (_summaryFilter == 2) return answer.isCorrect;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Quiz Summary'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Center(
            child: ResponsiveContentWrapper(
              maxWidth: 640,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Celebration & Score Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderSide(context)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Trophy / Medal Badge
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: isPass
                                ? (isDark ? const Color(0xFF382C10) : AppColors.goldLight)
                                : (isDark ? AppColors.darkIncorrectBg : AppColors.incorrectBg),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPass ? Icons.emoji_events_rounded : Icons.psychology_rounded,
                            size: 46,
                            color: isPass
                                ? (isDark ? AppColors.goldVibrant : AppColors.goldDark)
                                : (isDark ? const Color(0xFFF87171) : AppColors.incorrectRed),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isPass ? 'Outstanding Effort!' : 'Keep Practicing!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.accentGreen : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isPass
                              ? 'You have a good grasp of these Kannada words!'
                              : 'Review the question summary below to boost your recall.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.subtext(context),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Stats Summary Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricTile(
                                label: 'SCORE',
                                value: '$_score / $totalCount',
                                color: isDark ? AppColors.accentGreen : AppColors.primary,
                                context: context,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildMetricTile(
                                label: 'ACCURACY',
                                value: '$percentage%',
                                color: isPass ? AppColors.correctGreen : AppColors.incorrectRed,
                                context: context,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildMetricTile(
                                label: 'MISTAKES',
                                value: '$incorrectCount',
                                color: incorrectCount == 0 ? AppColors.correctGreen : AppColors.incorrectRed,
                                context: context,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons (Try Another Quiz / Back to Home)
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _startQuiz,
                          icon: const Icon(Icons.restart_alt_rounded, size: 20),
                          label: const Text('Try Another Quiz'),
                          style: FilledButton.styleFrom(
                            backgroundColor: isDark ? AppColors.accentGreen : AppColors.primary,
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      if (widget.onBackToHome != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onBackToHome,
                            icon: const Icon(Icons.home_rounded, size: 20),
                            label: const Text('Home'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.text(context),
                              side: BorderSide(color: AppColors.borderSide(context)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // In-App Rating Card (Polite, dismissible, only if not already rated)
                  if (!RatingService().hasRated && _showRatingBanner) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2B220B) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF5A4412) : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.gold, size: 26),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enjoying Learn Kannada?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text(context),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Support us with a 5 ★ rating on Google Play',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.subtext(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => showInAppRatingDialog(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              backgroundColor: isDark ? AppColors.goldDark : AppColors.gold,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Rate 5 ★',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: AppColors.subtext(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            tooltip: 'Dismiss',
                            onPressed: () {
                              setState(() {
                                _showRatingBanner = false;
                              });
                              RatingService().recordDismissed();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),

                  // Summary Section Title & Filter Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Questions Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text(context),
                        ),
                      ),
                      Text(
                        '${_userAnswers.length} Questions',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.subtext(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips (All / Mistakes / Correct)
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text('All (${_userAnswers.length})'),
                        selected: _summaryFilter == 0,
                        onSelected: (_) => setState(() => _summaryFilter = 0),
                      ),
                      ChoiceChip(
                        label: Text('Mistakes ($incorrectCount)'),
                        selected: _summaryFilter == 1,
                        selectedColor: isDark ? AppColors.darkIncorrectBg : AppColors.incorrectBg,
                        onSelected: (_) => setState(() => _summaryFilter = 1),
                      ),
                      ChoiceChip(
                        label: Text('Correct ($_score)'),
                        selected: _summaryFilter == 2,
                        selectedColor: isDark ? AppColors.darkCorrectBg : AppColors.correctBg,
                        onSelected: (_) => setState(() => _summaryFilter = 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Questions Breakdown List
                  if (filteredAnswers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(28),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSide(context)),
                      ),
                      child: Text(
                        _summaryFilter == 1
                            ? '🎉 Perfect! You had zero mistakes on this quiz!'
                            : 'No questions in this filter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.subtext(context),
                        ),
                      ),
                    )
                  else
                    ...filteredAnswers.map((answer) {
                      final q = answer.question;
                      final isCorrect = answer.isCorrect;
                      final userOption = q.options[answer.selectedIndex];
                      final correctOption = q.options[q.correctIndex];
                      final questionIndex = _questions.indexOf(q) + 1;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCorrect
                                ? (isDark ? AppColors.darkBorder : AppColors.border)
                                : (isDark ? AppColors.incorrectRed.withValues(alpha: 0.4) : AppColors.incorrectRed.withValues(alpha: 0.3)),
                            width: isCorrect ? 1 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Question number, Result badge, Audio Button
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkSurface : AppColors.surfaceSoft,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.borderSide(context)),
                                  ),
                                  child: Text(
                                    'Q$questionIndex',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.subtext(context),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? (isDark ? AppColors.darkCorrectBg : AppColors.correctBg)
                                        : (isDark ? AppColors.darkIncorrectBg : AppColors.incorrectBg),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                        size: 14,
                                        color: isCorrect ? AppColors.correctGreen : AppColors.incorrectRed,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isCorrect ? 'Correct' : 'Incorrect',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isCorrect ? AppColors.correctGreen : AppColors.incorrectRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                // Pronunciation / Unmute Button for question
                                ValueListenableBuilder<String?>(
                                  valueListenable: TtsService().currentlyPlayingId,
                                  builder: (context, playingId, _) {
                                    final isPlaying = playingId == 'summary_${q.id}';
                                    return IconButton.filledTonal(
                                      onPressed: () {
                                        TtsService().toggleSpeak(
                                          id: 'summary_${q.id}',
                                          text: q.kannada,
                                        );
                                      },
                                      tooltip: isPlaying ? 'Mute / Stop audio' : 'Unmute / Listen pronunciation',
                                      style: IconButton.styleFrom(
                                        backgroundColor: isPlaying
                                            ? (isDark ? AppColors.accentGreen.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.2))
                                            : (isDark ? AppColors.darkGreenTint : AppColors.greenTint),
                                        foregroundColor: isPlaying
                                            ? (isDark ? AppColors.goldVibrant : AppColors.primary)
                                            : (isDark ? AppColors.accentGreen : AppColors.primary),
                                        padding: const EdgeInsets.all(8),
                                        minimumSize: const Size(36, 36),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      icon: Icon(
                                        isPlaying ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                        size: 18,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Kannada Text & Transliteration
                            Text(
                              q.kannada,
                              style: TextStyle(
                                fontFamily: 'NotoSansKannada',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.accentGreen : AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '(${q.transliteration})',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.subtext(context),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Answer Review Details
                            if (isCorrect) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCorrectBg : AppColors.correctBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.correctGreen.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_rounded, size: 16, color: AppColors.correctGreen),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Your Answer: $userOption',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? const Color(0xFF4ADE80) : AppColors.correctGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkIncorrectBg : AppColors.incorrectBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.incorrectRed.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.close_rounded, size: 16, color: AppColors.incorrectRed),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Your Answer: $userOption',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? const Color(0xFFF87171) : AppColors.incorrectRed,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCorrectBg : AppColors.correctBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.correctGreen.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_rounded, size: 16, color: AppColors.correctGreen),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Correct Answer: $correctOption',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? const Color(0xFF4ADE80) : AppColors.correctGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSide(context)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.subtext(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
