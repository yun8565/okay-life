import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart';
import 'package:okay_life_app/api/api_client.dart';
import 'package:okay_life_app/pages/onboarding_page.dart';
import 'package:okay_life_app/pages/test_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> _loginWithKaKao() async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공: ${token.accessToken}');
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공: ${token.accessToken}');
      }

      // 액세스 토큰으로 JWT 요청 및 저장
      await _fetchAndStoreJwt('kakao', token.accessToken);

      // 로그인 성공 후 다음 페이지로 이동
      _navigateToNextPage();
    } catch (error) {
      print('카카오 로그인 실패: $error');
      if (error is PlatformException && error.code == 'CANCELED') {
        return; // 사용자가 로그인을 취소한 경우
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ],
    );

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        print('Access Token: ${googleAuth.accessToken}');
        print('ID Token: ${googleAuth.idToken}');

        // 액세스 토큰으로 JWT 요청 및 저장
        await _fetchAndStoreJwt('google', googleAuth.accessToken);

        // 로그인 성공 후 다음 페이지로 이동
        _navigateToNextPage();
      } else {
        print('Google sign-in canceled by user.');
      }
    } catch (error) {
      print('Google sign-in error: $error');
    }
  }

  /// `/auth/login/{provider}`로 GET 요청하여 JWT를 받아 로컬에 저장
  Future<void> _fetchAndStoreJwt(String provider, String? accessToken) async {
    if (accessToken == null) {
      print('Access token is null');
      return;
    }

    try {
      // `/auth/login/{provider}`에 GET 요청
      final response = await ApiClient.post(
        '/auth/login/$provider',
        data: {
          'accessToken': accessToken,
        },
      );

      // 서버에서 JWT 추출
      final jwt = response?['accessToken']; // 서버 응답의 JWT 필드 이름
      if (jwt != null) {
        // JWT를 로컬 스토리지에 저장
        await ApiClient.setJwt(jwt);
        print('JWT 저장 완료: $jwt');
      } else {
        print('JWT를 받지 못했습니다.');
      }
    } catch (error) {
      print('JWT 요청 실패: $error');
    }
  }

  void _navigateToNextPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => TestPage()),
    );
  }

  Widget _buildLoginBtn(String socialType) {
    return GestureDetector(
      onTap: () async {
        if (socialType == "Kakao") {
          await _loginWithKaKao();
        } else if (socialType == "Google") {
          await _loginWithGoogle();
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
