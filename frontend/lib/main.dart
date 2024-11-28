import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_template.dart';
import 'package:okay_life_app/api/api_client.dart';
import 'package:okay_life_app/data/auth_state.dart';
import 'package:okay_life_app/pages/createGalaxy_page.dart';
import 'package:okay_life_app/pages/dashboard_page.dart';
import 'package:okay_life_app/pages/galaxy_page.dart';
import 'package:okay_life_app/pages/setting_page.dart';
import 'package:okay_life_app/pages/splash_page.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local notifications
  await LocalPushNotifications.init();

  // Check if app launched via a notification
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  String initialRoute = '/';
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    // 알림에서 앱이 실행된 경우
    if (notificationAppLaunchDetails?.notificationResponse != null) {
      final NotificationResponse response =
          notificationAppLaunchDetails!.notificationResponse!;
      if (response.payload != null && response.payload!.isNotEmpty) {
        initialRoute = '/dashboard'; // 알림에 포함된 payload로 라우트 결정
      }
    }
  }

  await initializeDateFormatting('ko_KR', '');
  KakaoSdk.init(
    nativeAppKey: '8318983612332f29a372019cd65997a6',
    javaScriptAppKey: 'c85dd45dd6a8bc233775dd97496eeaad',
  );

  ApiClient.deleteJwt();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Okay Life App',
      initialRoute: initialRoute,
      routes: {
        '/': (context) => SplashPage(),
        '/dashboard': (context) => DashboardPage(),
        '/createGalaxy': (context) => CreateGalaxyPage(),
        '/galaxyPage': (context) => GalaxyPage(galaxyData: _dummyGalaxyData()),
        '/settings': (context) => SettingPage()
      },
    );
  }
}

// 최상위 수준에 backgroundHandler 추가
@pragma('vm:entry-point') // 엔트리 포인트로 지정
void backgroundHandler(NotificationResponse response) {
  debugPrint('Background notification payload: ${response.payload}');
  if (response.payload != null && response.payload!.isNotEmpty) {
    navigatorKey.currentState
        ?.pushNamed('/dashboard', arguments: response.payload);
  }
}

class LocalPushNotifications {
  static Future<void> init() async {
    tz.initializeTimeZones();

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          navigatorKey.currentState?.pushNamed(
            '/dashboard',
            arguments: response.payload,
          );
        }
      },
      onDidReceiveBackgroundNotificationResponse:
          backgroundHandler, // backgroundHandler 등록
    );

    // await scheduleTestNotification();
    await scheduleDailyNotification();
  }

  static Future<void> scheduleDailyNotification() async {
    try {
      // 백엔드에서 알림 내용 가져오기
      final notificationData = await ApiClient.get('/notifications'); // API 경로

      final String title = notificationData?['title'] ?? '기본 제목';
      final String body = notificationData?['body'] ?? '기본 내용';
      final String payload = notificationData?['payload'] ?? 'dashboard';

      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        iOS: iosNotificationDetails,
      );

      final tz.TZDateTime scheduledDate = _nextInstanceOfSixPM();

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0, // Notification ID
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간
      );
    } catch (e) {
      debugPrint('Failed to fetch notification data: $e');
    }
  }

  // 10초 뒤 테스트 알림 추가
  static Future<void> scheduleTestNotification() async {
    try {
      const String title = "테스트 알림";
      const String body = "이 알림은 10초 뒤에 표시됩니다.";
      const String payload = "test_payload";

      const DarwinNotificationDetails iosNotificationDetails =
          DarwinNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        iOS: iosNotificationDetails,
      );

      final tz.TZDateTime scheduledDate =
          tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)); // 10초 뒤

      await flutterLocalNotificationsPlugin.zonedSchedule(
        1, // 다른 Notification ID
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Failed to schedule test notification: $e');
    }
  }

  static tz.TZDateTime _nextInstanceOfSixPM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 18); // 오후 6시

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}

// Dummy data generator
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
            "status": "ON_PROGRESS",
          },
          {
            "missionId": 2,
            "content": "Complete task 2",
            "date": "2024-11-29",
            "status": "ON_PROGRESS",
          },
        ],
      },
    ],
    "startDate": "2024-11-20",
    "endDate": "2024-12-31",
  };
}
