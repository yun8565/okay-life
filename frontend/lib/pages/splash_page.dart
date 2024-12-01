import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:okay_life_app/api/api_client.dart';
import 'package:okay_life_app/pages/test_page.dart';
import 'package:provider/provider.dart';
import 'package:okay_life_app/pages/dashboard_page.dart';
import 'package:okay_life_app/pages/login_page.dart';
import 'package:okay_life_app/data/auth_state.dart';

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authState = Provider.of<AuthState>(context, listen: false); // AuthState 가져오기

    try {
      // ApiClient를 통해 로컬에서 JWT 확인
      final jwt = await ApiClient.getJwt();
      if (jwt != null) {
        // JWT가 있으면 로그인 상태로 업데이트하고 대시보드로 이동
        authState.login(jwt, {});
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TestPage()),
        );
      } else {
        // JWT가 없으면 로그인 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (error) {
      // 에러 발생 시 로그인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0A1C4C),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'), 
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Lottie.asset(
            "assets/planet.json", 
            width: 200,
          ),
        ),
      ),
    );
  }
}