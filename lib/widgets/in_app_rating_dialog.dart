import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_config.dart';
import '../core/services/rating_service.dart';
import '../core/theme/app_theme.dart';

/// Shows an engaging, interactive In-App Rating & Review Dialog
Future<void> showInAppRatingDialog(
  BuildContext context, {
  bool isMilestone = false,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => _InAppRatingDialog(isMilestone: isMilestone),
  );
}

class _InAppRatingDialog extends StatefulWidget {
  final bool isMilestone;

  const _InAppRatingDialog({this.isMilestone = false});

  @override
  State<_InAppRatingDialog> createState() => _InAppRatingDialogState();
}

class _InAppRatingDialogState extends State<_InAppRatingDialog> {
  int _selectedStars = 5;
  final TextEditingController _feedbackController = TextEditingController();
  bool _submitted = false;

  final List<String> _starLabels = [
    'Please select a rating',
    'Needs improvement 🙁',
    'Could be better 😐',
    'Good & helpful 🙂',
    'Very good! Loved it 😊',
    'Outstanding! Best App! 🌟🎉',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handlePrimaryAction() async {
    final ratingService = RatingService();
    final feedback = _feedbackController.text.trim();

    if (_selectedStars >= 4) {
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      if (feedback.isNotEmpty) {
        // Copy user's review to clipboard so they can effortlessly paste it on Google Play
        await Clipboard.setData(ClipboardData(text: feedback));
      }

      navigator.pop();
      await ratingService.requestInAppReview();

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  feedback.isNotEmpty
                      ? 'ಧನ್ಯವಾದಗಳು! Review copied to clipboard — paste it on Google Play!'
                      : 'ಧನ್ಯವಾದಗಳು! Thank you for supporting Learn Kannada!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      // For 1-3 stars, allow sending feedback
      if (feedback.isNotEmpty) {
        await ratingService.sendFeedbackEmail(
          rating: _selectedStars,
          comments: feedback,
        );
      }
      await ratingService.markAsRated();
      if (mounted) {
        setState(() {
          _submitted = true;
        });
        await Future.delayed(const Duration(milliseconds: 1400));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  void _handleDismiss() {
    RatingService().recordDismissed();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHighRating = _selectedStars >= 4;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderSide(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: _submitted
            ? _buildThankYouState(context)
            : _buildRatingContent(context, isDark, isHighRating),
      ),
    );
  }

  Widget _buildThankYouState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.correctGreen.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.correctGreen,
            size: 42,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'ಧನ್ಯವಾದಗಳು! (Thank You)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your feedback helps us make Learn Kannada better for everyone.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.subtext(context),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRatingContent(
    BuildContext context,
    bool isDark,
    bool isHighRating,
  ) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Badge Icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF4A3B10), const Color(0xFF2E240A)]
                    : [const Color(0xFFFFF7ED), const Color(0xFFFEF3C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.star_rounded,
              color: AppColors.gold,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            widget.isMilestone
                ? 'Great Job on the Quiz!'
                : 'Enjoying Learn Kannada?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.text(context),
            ),
          ),
          const SizedBox(height: 4),

          // Kannada subtitle
          Text(
            'ನಿಮ್ಮ ಅನಿಸಿಕೆ ನಮಗೆ ಮುಖ್ಯ',
            style: TextStyle(
              fontFamily: AppConfig.kannadaFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.accentGreen : AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'How would you rate your learning experience so far?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.subtext(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),

          // 5 Star Rating Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final isFilled = starValue <= _selectedStars;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStars = starValue;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: AnimatedScale(
                    scale: isFilled ? 1.15 : 0.95,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isFilled
                          ? AppColors.gold
                          : (isDark ? Colors.grey[700] : Colors.grey[400]),
                      size: 38,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),

          // Dynamic Star Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoftColor(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _starLabels[_selectedStars],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isHighRating
                    ? (isDark ? AppColors.goldVibrant : AppColors.goldDark)
                    : AppColors.subtext(context),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Feedback / Review Input box for ALL ratings (with dynamic hint and helper)
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceSoftColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSide(context)),
            ),
            child: TextField(
              controller: _feedbackController,
              maxLines: 3,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.text(context),
              ),
              decoration: InputDecoration(
                hintText: isHighRating
                    ? 'What did you like most? Write a review (optional)...'
                    : 'Tell us how we can improve (optional)...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: AppColors.subtext(context),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Helpful subtext explaining how the review/feedback is processed
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isHighRating ? Icons.info_outline_rounded : Icons.mail_outline_rounded,
                  size: 14,
                  color: AppColors.subtext(context),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isHighRating
                        ? 'Google Play will open to publish your review. If you write comments above, we\'ll copy them so you can paste easily!'
                        : 'Your comments will be sent directly to our developer team so we can make the app better.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.subtext(context),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Primary Action Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _handlePrimaryAction,
              icon: Icon(
                isHighRating
                    ? Icons.rate_review_rounded
                    : Icons.send_rounded,
                size: 20,
              ),
              label: Text(
                isHighRating ? 'Rate on Google Play' : 'Submit Feedback',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: isHighRating
                    ? (isDark ? AppColors.accentGreen : AppColors.primary)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFF475569)),
                foregroundColor: isHighRating && isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          // Remind me later & Don't Ask Again buttons
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              TextButton(
                onPressed: _handleDismiss,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.subtext(context),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                child: const Text(
                  'Maybe Later',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '•',
                style: TextStyle(
                  color: AppColors.subtext(context).withValues(alpha: 0.4),
                ),
              ),
              TextButton(
                onPressed: () {
                  RatingService().setNeverAskAgain();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.subtext(context),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                child: const Text(
                  "Don't Ask Again",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
