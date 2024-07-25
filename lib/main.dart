import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:fintrack/app/layout/navigation_sidebar.dart';
import 'package:fintrack/app/layout/tabs.dart';
import 'package:fintrack/app/onboarding/intro.page.dart';
import 'package:fintrack/core/database/services/app-data/app_data_service.dart';
import 'package:fintrack/core/database/services/user-setting/user_setting_service.dart';
import 'package:fintrack/core/presentation/responsive/breakpoints.dart';
import 'package:fintrack/core/presentation/theme.dart';
import 'package:fintrack/core/routes/root_navigator_observer.dart';
import 'package:fintrack/core/utils/scroll_behavior_override.dart';
import 'package:fintrack/i18n/translations.g.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FintrackAppEntryPoint());
}

final GlobalKey<TabsPageState> tabsPageKey = GlobalKey();
final GlobalKey<NavigationSidebarState> navigationSidebarKey = GlobalKey();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FintrackAppEntryPoint extends StatelessWidget {
  const FintrackAppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('------------------ APP ENTRY POINT ------------------');
    }

    return StreamBuilder(
      stream: UserSettingService.instance.getSettings((p0) =>
        p0.settingKey.equalsValue(SettingKey.appLanguage) |
        p0.settingKey.equalsValue(SettingKey.themeMode) |
        p0.settingKey.equalsValue(SettingKey.amoledMode) |
        p0.settingKey.equalsValue(SettingKey.accentColor),),
      builder: (context, snapshot) {
        if (kDebugMode) {
          print('Finding initial user settings...');
        }

        if (!snapshot.hasData) {
          return Container();
        }

        final userSettings = snapshot.data!;
        final lang = userSettings.firstWhere(
          (element) => element.settingKey == SettingKey.appLanguage).settingValue;

        if (lang != null) {
          if (kDebugMode) {
            print('App language found. Setting the locale to `$lang`...');
          }
          LocaleSettings.setLocaleRaw(lang);
        } else {
          if (kDebugMode) {
            print('App language not found. Setting the user device language...');
          }
          LocaleSettings.useDeviceLocale();
          UserSettingService.instance.setSetting(
            SettingKey.appLanguage,
            LocaleSettings.currentLocale.languageTag,
          ).then((value) => null);
        }

        return TranslationProvider(
          child: StreamBuilder(
            stream: AppDataService.instance.getAppDataItem(AppDataKey.introSeen).map((event) => event == '1'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              return MaterialAppContainer(
                introSeen: snapshot.data!,
                amoledMode: userSettings.firstWhere((element) => element.settingKey == SettingKey.amoledMode).settingValue! == '1',
                accentColor: userSettings.firstWhere((element) => element.settingKey == SettingKey.accentColor).settingValue!,
                themeMode: ThemeMode.values.byName(userSettings.firstWhere((element) => element.settingKey == SettingKey.themeMode).settingValue!),
              );
            }
          ),
        );
      }
    );
  }
}

int refresh = 1;

class MaterialAppContainer extends StatelessWidget {
  const MaterialAppContainer({
    super.key,
    required this.themeMode,
    required this.accentColor,
    required this.amoledMode,
    required this.introSeen,
  });

  final ThemeMode themeMode;
  final String accentColor;
  final bool amoledMode;
  final bool introSeen;

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = LocaleSettings.currentLocale.languageTag;

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'Fintrack',
          key: ValueKey(refresh),
          debugShowCheckedModeBanner: false,
          locale: TranslationProvider.of(context).flutterLocale,
          scrollBehavior: ScrollBehaviorOverride(),
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: getThemeData(context, isDark: false, amoledMode: amoledMode, lightDynamic: lightDynamic, darkDynamic: darkDynamic, accentColor: accentColor),
          darkTheme: getThemeData(context, isDark: true, amoledMode: amoledMode, lightDynamic: lightDynamic, darkDynamic: darkDynamic, accentColor: accentColor),
          themeMode: themeMode,
          navigatorKey: navigatorKey,
          navigatorObservers: [MainLayoutNavObserver()],
          builder: (context, child) {
            return Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => Stack(
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeInOutCubicEmphasized,
                            width: introSeen ? getNavigationSidebarWidth(context) : 0,
                            color: Theme.of(context).canvasColor,
                          ),
                          if (BreakPoint.of(context).isLargerThan(BreakpointID.sm))
                            Container(
                              width: 2,
                              height: MediaQuery.of(context).size.height,
                              color: Theme.of(context).dividerColor,
                            ),
                          Expanded(child: child ?? const SizedBox.shrink()),
                        ],
                      ),
                      if (introSeen) NavigationSidebar(key: navigationSidebarKey)
                    ],
                  ),
                ),
              ],
            );
          },
          home: introSeen ? const LockScreen() : const IntroPage(),
        );
      }
    );
  }
}

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   checkAndShowLockScreen();
  // }

  // Future<void> checkAndShowLockScreen() async {
  //   // final pin = await UserSettingService.instance.getSetting(SettingKey.appPin);
  //    String pin = '0000';
  //   if (pin == null) {
  //     // Show set PIN screen
  //     showSetPinScreen();
  //   } else {
  //     // Show lock screen
  //     showLockScreen(pin );
  //   }
  // }

  void showSetPinScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SetPinPage(onPinSet: (pin) {
          UserSettingService.instance.setSetting(SettingKey.appPin, pin);
          Navigator.of(context).pop();
          showLockScreen(pin);
        }),
      ),
    );
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
          Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) => const 
    ),
  );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: (){
      showLockScreen('0000');
    }, child: Text('UnLock'));
  }
}

class SetPinPage extends StatefulWidget {
  final ValueChanged<String> onPinSet;

  const SetPinPage({super.key, required this.onPinSet});

  @override
  _SetPinPageState createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
  
     return Scaffold(
      appBar: AppBar(title: Text('Set PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
           children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Enter PIN'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final pin = _pinController.text;
                if (pin.isNotEmpty) {
                  widget.onPinSet(pin);
                }
              },
              child: Text('Set PIN'),
            ),
          ],
        ),
      ),
    );
  
  
  
  }
}
