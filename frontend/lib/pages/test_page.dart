import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:okay_life_app/api/api_client.dart';
import 'package:okay_life_app/pages/start_page.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final TextEditingController _testController = TextEditingController();
  bool isFilled = false;

  @override
  void initState() {
    super.initState();

    _testController.addListener(() {
      setState(() {
        isFilled = _testController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    // 애니메이션 컨트롤러 해제
    _testController.dispose();
    super.dispose();
  }

  // 시작 버튼 로직
  Future<void> _submitData() async {
    if (!isFilled) return; // 입력값이 없으면 동작하지 않음

    final inputText = _testController.text;

    try {
      // ApiClient를 통해 POST 요청
      final response = await ApiClient.post(
        '/users',
        data: {'value': inputText}, // 서버로 보낼 데이터
      );

      // 성공 메시지 출력
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Data sent successfully: ${response['message']}")),
      );

      // 입력 필드 초기화
      setState(() {
        _testController.clear();
        isFilled = false;
      });
    } catch (error) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send data: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 키보드 표시 시 레이아웃 조정
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover, // 배경 이미지를 화면 전체에 채움
            ),
          ),
          // 메인 콘텐츠
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 질문 텍스트
                  Text(
                    "당신의 우주를\n알려주세요",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // 애니메이션 (Ripple + Lottie)
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: Lottie.asset("assets/test_planet.json"),
                  ),
                  const SizedBox(height: 40),
                  // 입력 필드
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: TextField(
                      controller: _testController,
                      maxLength: 20,
                      decoration: InputDecoration(
                        hintText: "제일 돈 많이 버는 개발자 되기",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 17,
                        ),
                        filled: true,
                        fillColor: const Color(0xff6976b6).withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        counterText: '',
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // 제출 버튼
                  GestureDetector(
                    onTap: isFilled
                        ? () {
                            _submitData();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StartPage()));
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                          color: isFilled ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1.0)),
                      child: Text(
                        "시작",
                        style: TextStyle(
                            color: isFilled
                                ? Color(0xff0a1c4c)
                                : Colors.white.withOpacity(0.5),
                            fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
