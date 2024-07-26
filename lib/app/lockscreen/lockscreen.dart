import 'package:fintrack/app/layout/tabs.dart';
import 'package:fintrack/core/database/services/user-setting/user_setting_service.dart';
import 'package:fintrack/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final Stream<String?> pin = UserSettingService.instance.getSetting(SettingKey.appPin);
  String newpin = '3432';

  @override
  void initState() {
    super.initState();
    pin.listen((pin) {
      newpin = pin!;
    });
    _checkLastUnlockTime();
  }

  Future<void> _checkLastUnlockTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastUnlockTime = prefs.getInt('lastUnlockTime');
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int twoHoursInMillis = 2 * 60 * 60 * 1000;

    if (lastUnlockTime == null || currentTime - lastUnlockTime >= twoHoursInMillis) {
      // Show lock screen if it's been more than 2 hours
      _showLockScreen(newpin);
    } else {
      // Directly go to the main screen if it's within 2 hours
      _navigateToMainScreen();
    }
  }

  void _showLockScreen(String correctPin) {
    screenLock(
      context: context,
      correctString: correctPin,
      maxRetries: 2,
      retryDelay: const Duration(seconds: 3),
      delayBuilder: (context, delay) => Text(
        'Cannot be entered for ${(delay.inMilliseconds / 1000).ceil()} seconds.',
      ),
      onUnlocked: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('lastUnlockTime', DateTime.now().millisecondsSinceEpoch);
        _navigateToMainScreen();
      },
    );
  }

  void _navigateToMainScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TabsPage(key: tabsPageKey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tap to unlock the app',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    _showLockScreen(newpin);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Unlock',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
