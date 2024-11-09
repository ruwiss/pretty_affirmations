import 'package:flutter/material.dart';
import 'package:hayiqu/hayiqu.dart';
import 'package:pretty_affirmations/app/router.dart';
import 'package:pretty_affirmations/app/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator(() {});
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppTheme()),
      ],
      child: Consumer<AppTheme>(
        builder: (context, value, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
            theme: value.lightTheme,
          );
        },
      ),
    );
  }
}
