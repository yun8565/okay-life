import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:okay_life_app/pages/test_page.dart';

class OnboardingPage extends StatefulWidget {
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose(); // 메모리 누수 방지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0A1C4C),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/onboarding_bg_1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index; // 현재 페이지 업데이트
                });
              },
              children: [
                _buildOnboardingContent(
                  "assets/onboarding_icon_1.json",
                  "나만의 우주 만들기",
                  "간단한 테스트로 나만의 맞춤 목표 루틴 만들기",
                ),
                _buildOnboardingContent(
                  "assets/onboarding_icon_2.json",
                  "행성 모으기",
                  "여러 가지 테마의 행성들을 \n모으면서 재미있게 습관 만들기",
                ),
                _buildOnboardingContent(
                  "assets/onboarding_icon_3.json",
                  "계속 유지할 수 있게",
                  "맞춤 피드백으로 계속해서 나에게 맞추기",
                ),
              ],
            ),
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: _buildActionButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingContent(
    String animationPath,
    String title,
    String description,
  ) {
    return Stack(
      children: [
        Positioned(
          top: 185,
          left: 0,
          right: 0,
          child: Container(
            width: 390,
            child: Lottie.asset(animationPath),
          ),
        ),
        Positioned(
          top: 550,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 66, bottom: 15),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                child: Text(
                  description,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w200,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: () {
        if (_currentPage < 2) {
          // NEXT 버튼: 다음 페이지로 이동
          _pageController.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          // START 버튼: 앱 시작 동작 추가
          print("START 버튼 클릭됨");
          // Navigator.pushReplacement() 등을 사용하여 다른 화면으로 이동 가능
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => TestPage()));
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 70),
        width: double.infinity,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _currentPage < 2
              ? Colors.white.withOpacity(0.8) // NEXT 버튼 색상
              : Color(0xFF294AEE).withOpacity(0.6), // START 버튼 색상
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          _currentPage < 2 ? "NEXT" : "START", // 텍스트 변경
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _currentPage < 2
                ? Color(0xff062c43) // NEXT 버튼 글자색
                : Colors.white, // START 버튼 글자색
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
