import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_template.dart';
import 'package:okay_life_app/data/auth_state.dart';
import 'package:okay_life_app/pages/login_page.dart';
import 'package:okay_life_app/pages/onboarding_page.dart';
import 'package:okay_life_app/pages/splash_page.dart';
import 'package:provider/provider.dart';

void main() {
  KakaoSdk.init(
    nativeAppKey: '8318983612332f29a372019cd65997a6',
    javaScriptAppKey: 'c85dd45dd6a8bc233775dd97496eeaad',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()), // AuthState 제공
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      title: 'Okay Life App',
      home: OnboardingPage(),
    );
  }
}
