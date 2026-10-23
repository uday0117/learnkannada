import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

/// Service to handle seamless in-app background updates via Google Play
class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  /// Global messenger key to display update prompts from background tasks
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  bool _isChecking = false;

  /// Checks for in-app updates in the background on Android.
  /// If an update is available:
  /// - Downloads it in the background silently (Flexible update)
  /// - Notifies the user with a restart prompt once ready
  Future<void> checkForBackgroundUpdate() async {
    // In-app updates are Android-specific via Google Play
    if (kIsWeb || !Platform.isAndroid) return;
    if (_isChecking) return;
    _isChecking = true;

    try {
      debugPrint('UpdateService: Checking for available updates on Google Play...');
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.flexibleUpdateAllowed) {
          debugPrint('UpdateService: Flexible update available. Starting background download...');

          // Listen for install/download state changes
          InAppUpdate.installUpdateListener.listen((InstallStatus status) {
            debugPrint('UpdateService: Install status -> $status');
            if (status == InstallStatus.downloaded) {
              _showUpdateReadyPrompt();
            }
          });

          // Start the flexible update download in background
          final result = await InAppUpdate.startFlexibleUpdate();
          if (result == AppUpdateResult.success) {
            _showUpdateReadyPrompt();
          }
        } else if (updateInfo.immediateUpdateAllowed) {
          // If only immediate update is allowed by Play Console
          debugPrint('UpdateService: Immediate update required by Play Console.');
          await InAppUpdate.performImmediateUpdate();
        }
      } else {
        debugPrint('UpdateService: App is up to date.');
      }
    } catch (e) {
      // Gracefully catch exceptions (expected when running local builds without Play Store signature)
      debugPrint('UpdateService check: $e');
    } finally {
      _isChecking = false;
    }
  }

  /// Displays a non-intrusive SnackBar allowing the user to restart and install the update
  void _showUpdateReadyPrompt() {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.system_update_rounded, color: Colors.amberAccent, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'New version downloaded! Restart to apply update.',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'RESTART',
          textColor: Colors.amberAccent,
          onPressed: () async {
            try {
              await InAppUpdate.completeFlexibleUpdate();
            } catch (e) {
              debugPrint('Error completing flexible update: $e');
            }
          },
        ),
        duration: const Duration(minutes: 5),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
