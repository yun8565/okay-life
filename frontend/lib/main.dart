import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_template.dart';
import 'package:okay_life_app/data/auth_state.dart';
import 'package:okay_life_app/pages/createGalaxy_page.dart';
import 'package:okay_life_app/pages/dashboard_page.dart';
import 'package:okay_life_app/pages/galaxy_dex_page.dart';
import 'package:okay_life_app/pages/galaxy_page.dart';
import 'package:okay_life_app/pages/galaxy_tutorial_page.dart';
import 'package:okay_life_app/pages/login_page.dart';
import 'package:okay_life_app/pages/onboarding_page.dart';
import 'package:okay_life_app/pages/overview_plan_page.dart';
import 'package:okay_life_app/pages/planet_page.dart';
import 'package:okay_life_app/pages/splash_page.dart';
import 'package:okay_life_app/pages/start_page.dart';
import 'package:okay_life_app/pages/test_page.dart';
import 'package:okay_life_app/pages/tutorial_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', '');
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
        home: GalaxyPage(
          galaxyData: _dummyGalaxyData(),
        ));
  }
}

// 더미 데이터 생성 함수
Map<String, dynamic> _dummyGalaxyData() {
  return {
    "title": "My Galaxy Adventure",
    "planetThemeIdRepresenting": 1,
    "planets": [
      {
        "planetId": 1,
        "title": "Start Planet",
        "status": "ACQUIRABLE",
        "planetThemeName": "Exploration Theme",
        "startDate": "2024-11-20",
        "endDate": "2024-11-28",
        "missions": [
          {
            "missionId": 1,
            "content": "Complete task 1",
            "date": "2024-11-28",
            "status": "ON_PROGRESS"
          },
          {
            "missionId": 2,
            "content": "Complete task 2",
            "date": "2024-11-29",
            "status": "ON_PROGRESS"
          },
        ],
      },
      {
        "planetId": 2,
        "title": "Second Planet",
        "status": "SOON",
        "planetThemeName": "Preparation Theme",
        "startDate": "2024-12-01",
        "endDate": "2024-12-10",
        "missions": [
          {
            "missionId": 3,
            "content": "Gather resources",
            "date": "2024-12-02",
            "status": "SOON"
          },
          {
            "missionId": 4,
            "content": "Prepare for next journey",
            "date": "2024-12-04",
            "status": "SOON"
          },
        ],
      },
      {
        "planetId": 3,
        "title": "Final Destination",
        "status": "FAILED",
        "planetThemeName": "Challenge Theme",
        "startDate": "2024-12-11",
        "endDate": "2024-12-20",
        "missions": [
          {
            "missionId": 5,
            "content": "Overcome obstacle",
            "date": "2024-12-13",
            "status": "FAILED"
          },
          {
            "missionId": 6,
            "content": "Conquer final challenge",
            "date": "2024-12-18",
            "status": "FAILED"
          },
        ],
      },
    ],
    "startDate": "2024-11-20",
    "endDate": "2024-12-31",
  };
}
