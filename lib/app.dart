import 'package:flutter/material.dart';
import 'l10n/l10n.dart';
import 'navigator_key.dart';
import 'screens/home_screen.dart';
import 'services/locale_service.dart';

class LottFunApp extends StatelessWidget {
  final LocaleService localeService;

  const LottFunApp({super.key, required this.localeService});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: localeService,
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: globalNavigatorKey,
          locale: localeService.locale,
          onGenerateTitle: (context) => context.l10n.appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6A1B9A), // deep purple
              secondary: const Color(0xFFFFB300), // amber
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF6A1B9A),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
              ),
            ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
