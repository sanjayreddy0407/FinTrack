import 'package:collection/collection.dart';
import 'package:fintrack/app/lockscreen/setpin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:fintrack/app/layout/tabs.dart';
import 'package:fintrack/core/database/services/app-data/app_data_service.dart';
import 'package:fintrack/core/database/services/currency/currency_service.dart';
import 'package:fintrack/core/database/services/user-setting/user_setting_service.dart';
import 'package:fintrack/core/presentation/widgets/currency_selector_modal.dart';
import 'package:fintrack/core/presentation/widgets/skeleton.dart';
import 'package:fintrack/core/routes/route_utils.dart';
import 'package:fintrack/i18n/translations.g.dart';
import 'package:fintrack/main.dart';

import '../../core/presentation/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentPage = 0;

  introFinished() {
    AppDataService.instance.setAppDataItem(AppDataKey.introSeen, '1').then(
      (value) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SetPinPage(onPinSet: (pin) {
          UserSettingService.instance.setSetting(SettingKey.appPin, pin);
            RouteUtils.pushRoute(
          context,
          TabsPage(key: tabsPageKey),
          withReplacement: true,
        );
          }),
      ),
    );
        refresh++;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    List items = [
      {
        'header': t.intro.sl1_title,
        'description': t.intro.sl1_descr,
        'image': 'assets/icons/app_onboarding/first.svg'
      },
      {
        'header': t.intro.sl2_title,
        'description': t.intro.sl2_descr,
        'description2': t.intro.sl2_descr2,
        'image': 'assets/icons/app_onboarding/security.svg'
      },
      {
        'header': t.intro.last_slide_title,
        'description': t.intro.last_slide_descr,
        'description2': t.intro.last_slide_descr2,
        'image': 'assets/icons/app_onboarding/wallet.svg'
      },
    ];

    List<PageViewModel> slides = items
        .mapIndexed((index, item) => PageViewModel(
            titleWidget: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Text(
                item['header'],
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
            ),
            useRowInLandscape: true,
            bodyWidget: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Column(children: [
                Text(
                  item['description'],
                  style: const TextStyle(
                      fontSize: 14.0, fontWeight: FontWeight.w300),
                  textAlign: TextAlign.justify,
                ),
                if (item['description2'] != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    item['description2'],
                    style: const TextStyle(
                        fontSize: 14.0, fontWeight: FontWeight.w300),
                    textAlign: TextAlign.justify,
                  ),
                ],
                if (index == 0) ...[
                  const SizedBox(height: 40),
                  StreamBuilder(
                      stream:
                          CurrencyService.instance.getUserPreferredCurrency(),
                      builder: (context, snapshot) {
                        final userCurrency = snapshot.data;

                        return ListTile(
                          tileColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.04),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.45),
                          ),
                          leading: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: userCurrency != null
                                ? userCurrency.displayFlagIcon(size: 42)
                                : const Skeleton(height: 42, width: 42),
                          ),
                          title: Text(t.intro.select_your_currency),
                          subtitle: userCurrency != null
                              ? Text(userCurrency.name)
                              : const Skeleton(height: 12, width: 50),
                          onTap: () {
                            if (userCurrency == null) return;

                            showCurrencySelectorModal(
                                context,
                                CurrencySelectorModal(
                                    preselectedCurrency: userCurrency,
                                    onCurrencySelected: (newCurrency) {
                                      UserSettingService.instance
                                          .setSetting(
                                              SettingKey.preferredCurrency,
                                              newCurrency.code)
                                          .then((value) => setState(() => {}));
                                    }));
                          },
                        );
                      }),
                ],
              ]),
            ),
            image: SvgPicture.asset(
              item['image'],
              fit: BoxFit.fitWidth,
              width: 240.0,
              alignment: Alignment.bottomCenter,
            )))
        .toList();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
        ),
        body: IntroductionScreen(
          pages: slides,
          showSkipButton: true,
          initialPage: currentPage,
          onChange: (value) {
            setState(() {
              currentPage = value;
            });
          },
          skip: Text(
            t.intro.skip,
            style: const TextStyle(fontWeight: FontWeight.w300),
          ),
          next: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t.intro.next),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward)
            ],
          ),
          done: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t.general.continue_text),
              const SizedBox(width: 4),
              const Icon(Icons.check)
            ],
          ),
          onDone: () => introFinished(),
          onSkip: () => introFinished(),
          dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(20.0, 10.0),
            activeColor: AppColors.of(context).primary,
            color: AppColors.of(context).primary.withOpacity(0.3),
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
          ),
        ));
  }
}
