import 'package:fintrack/app/layout/tabs.dart';
import 'package:fintrack/core/database/services/user-setting/user_setting_service.dart';
import 'package:fintrack/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final Stream<String?> pin =
      UserSettingService.instance.getSetting(SettingKey.appPin);
  String newpin = '3432';
  @override
  void initState() {
    super.initState();
    pin.listen((pin) {
      newpin = pin!;
    });
  }

  void showLockScreen(String correctPin) {
    screenLock(
      context: context,
      correctString: correctPin,
      maxRetries: 2,
      retryDelay: const Duration(seconds: 3),
      delayBuilder: (context, delay) => Text(
        'Cannot be entered for ${(delay.inMilliseconds / 1000).ceil()} seconds.',
      ),
      onUnlocked: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>  TabsPage(key: tabsPageKey),
            ),
            );

        
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(
            height: 300,
          ),
          const Text('Tap to unlock the app'),
          Center(
            child: ElevatedButton(
                onPressed: () {
                  showLockScreen(newpin);
                },
                child: const Text('UnLock')),
          ),
          const SizedBox(
            height: 300,
          ),
        ],
      ),
    );
  }
}
