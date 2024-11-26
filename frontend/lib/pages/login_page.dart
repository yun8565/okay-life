import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart';
import 'package:okay_life_app/pages/onboarding_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> _loginWithKaKao() async {
    try {
      if (await isKakaoTalkInstalled()) {
        OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공: ${token.accessToken}');
      } else {
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공: ${token.accessToken}');
      }

      // 로그인 성공 후 다음 페이지로 이동
      _navigateToNextPage();
    } catch (error) {
      print('카카오 로그인 실패: $error');
      if (error is PlatformException && error.code == 'CANCELED') {
        return; // 사용자가 로그인을 취소한 경우
      }
    }
  }

  void _navigateToNextPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => OnboardingPage()),
    );
  }

  Widget _buildLoginBtn(String socialType) {
    return GestureDetector(
      onTap: () async {
        if (socialType == "Kakao") {
          await _loginWithKaKao();
        } else {
          print('$socialType 로그인 기능 미구현');
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        width: 317,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: socialType == "Apple"
              ? Colors.black
              : socialType == "Google"
                  ? Colors.white
                  : Color(0xffffe300),
        ),
        child: Row(
          children: [
            Container(
              child: SvgPicture.asset(
                "assets/${socialType}.svg",
                width: 30,
                height: 30,
              ),
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            Container(
              width: 190,
              child: Text(
                "${socialType}로 시작하기",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: socialType == "Apple" ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0A1C4C),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 96,
              left: 0,
              right: 0,
              child: Container(
                width: 200,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.5),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.35, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    'assets/planet_bg.png',
                    width: 260,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 480,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "나만의 속도로",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        "우주 정복",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  _buildLoginBtn("Google"),
                  _buildLoginBtn("Apple"),
                  _buildLoginBtn("Kakao"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
