import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app_language.dart';
import 'lostly/pages/splash_page.dart';
import 'cubits/posts_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final appLanguage = AppLanguage();

  await appLanguage.loadLanguage();

  runApp(
    BlocProvider(
      create: (_) => PostsCubit(),
      child: LostlyApp(
        appLanguage: appLanguage,
      ),
    ),
  );
}

class LostlyApp extends StatelessWidget {
  const LostlyApp({
    super.key,
    required this.appLanguage,
  });

  final AppLanguage appLanguage;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appLanguage,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Lostly',
          locale: appLanguage.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: SplashPage(
            appLanguage: appLanguage,
          ),
        );
      },
    );
  }
}