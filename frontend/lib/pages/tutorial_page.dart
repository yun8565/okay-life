import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:okay_life_app/api/api_client.dart';
import 'package:okay_life_app/pages/createGalaxy_page.dart';

class TutorialPage extends StatefulWidget {
  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  late PageController _pageController;
  bool isLoading = false; // 로딩 상태 관리
  List<String> pyramidData = []; // 피라미드 데이터
  int dotCount = 1; // 로딩 애니메이션 점 개수
  late Timer _loadingTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startLoadingAnimation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _loadingTimer.cancel();
    super.dispose();
  }

  // 로딩 애니메이션 점 개수 조정
  void _startLoadingAnimation() {
    _loadingTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        dotCount = (dotCount % 3) + 1; // 1, 2, 3 반복
      });
    });
  }

  // 데이터 로딩
  // 데이터 로딩
Future<void> _fetchPyramidData() async {
  setState(() {
    isLoading = true; // 로딩 시작
  });

  try {
    // GET 요청으로 데이터 가져오기
    final response = await ApiClient.get('/chat/goal');
    
    // 응답 데이터 처리
    if (response != null && response['three'] != null) {
      setState(() {
        pyramidData = List<String>.from(response['three']); // 'three' 필드의 데이터
        isLoading = false; // 로딩 종료
      });

      // 자동으로 피라미드 페이지로 이동
      _pageController.jumpToPage(
        _pageController.page!.toInt() + 1,
      );
    } else {
      throw Exception("Invalid response format");
    }
  } catch (error) {
    setState(() {
      isLoading = false; // 로딩 종료
    });
    // 에러 처리
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("피라미드 데이터를 가져오는데 실패했습니다: $error"),
      ),
    );
  }
}

  // 페이지 컨텐츠 생성
  Widget _buildPageContent({
    required String text,
    String? svgAsset,
    bool isLastPage = false,
    VoidCallback? onNext,
    int? pageNum,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/onboarding_bg_1.png',
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (pageNum == null)
                    Padding(
                        padding: EdgeInsets.only(left: 70, bottom: 10),
                        child: SizedBox(
                          height: 30,
                          width: 100,
                        )),
                  if (pageNum != null)
                    Padding(
                      padding: EdgeInsets.only(left: 70, bottom: 10),
                      child: SizedBox(
                        height: 30,
                        width: 100,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "$pageNum", // pageNum만 오퍼시티 100
                                style: TextStyle(
                                  color: Colors.white, // 완전한 불투명 색상
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold, // 필요한 경우 추가
                                ),
                              ),
                              TextSpan(
                                text: " / 7", // 나머지 텍스트
                                style: TextStyle(
                                  color: Colors.white38, // 오퍼시티 38
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      _pageController.jumpToPage(7);
                    },
                    child: Container(
                      padding: EdgeInsets.only(right: 70),
                      width: 150,
                      height: 30,
                      alignment: Alignment.centerRight,
                      child: Text(
                        "skip",
                        style: TextStyle(color: Colors.white38, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xff6976b6).withOpacity(0.2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 150,
                        width: 250,
                        child: TypingEffect(fullText: text)),
                    SizedBox(height: 30),
                    if (!isLastPage) // 마지막 페이지가 아니면 다음 버튼 표시
                      GestureDetector(
                        onTap: onNext ??
                            () {
                              //
                              _pageController.jumpToPage(
                                _pageController.page!.toInt() + 1,
                              );
                            },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Color(0xff0a1c4c),
                          ),
                          child: Icon(
                            CupertinoIcons.arrowtriangle_right_fill,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 540,
          left: 230,
          child: SvgPicture.asset(
            svgAsset ?? "assets/devil.svg",
            width: 180,
            height: 180,
          ),
        ),
      ],
    );
  }

  // 로딩 페이지
  Widget _buildLoadingPage() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/onboarding_bg_1.png',
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _pageController.jumpToPage(7);
                },
                child: Container(
                  padding: EdgeInsets.only(right: 20),
                  width: 300,
                  height: 30,
                  alignment: Alignment.centerRight,
                  child: Text(
                    "skip",
                    style: TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Color(0xff6976b6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15)),
                width: 300,
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "우주 정복 로드맵 생성 중${'.' * dotCount}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 540,
          left: 230,
          child: SvgPicture.asset(
            "assets/devil.svg",
            width: 180,
            height: 180,
          ),
        ),
      ],
    );
  }

  // 피라미드 페이지
  Widget _buildPyramidPage() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/onboarding_bg_1.png',
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 70, bottom: 10),
                    child: SizedBox(
                      height: 30,
                      width: 100,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "3", // pageNum만 오퍼시티 100
                              style: TextStyle(
                                color: Colors.white, // 완전한 불투명 색상
                                fontSize: 24,
                                fontWeight: FontWeight.bold, // 필요한 경우 추가
                              ),
                            ),
                            TextSpan(
                              text: " / 7", // 나머지 텍스트
                              style: TextStyle(
                                color: Colors.white38, // 오퍼시티 38
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _pageController.jumpToPage(7);
                    },
                    child: Container(
                      padding: EdgeInsets.only(right: 70),
                      width: 150,
                      height: 30,
                      alignment: Alignment.centerRight,
                      child: Text(
                        "skip",
                        style: TextStyle(color: Colors.white38, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: 300,
                height: 460,
                decoration: BoxDecoration(
                    color: Color(0xff6976b6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Stack(
                      children: [
                        SvgPicture.asset(
                          "assets/pyramid.svg", // 피라미드 이미지 경로
                          width: 250,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: pyramidData.map((step) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(top: 20, left: 87),
                                child: Text(
                                  step,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: 90,
                        width: 250,
                        child: TypingEffect(
                            fullText: "입력해 준 목표에 대해\n우리가 만들어 본 로드맵이야\n어때?")),
                    SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        _pageController.jumpToPage(
                          _pageController.page!.toInt() + 1,
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Color(0xff0a1c4c),
                        ),
                        child: Icon(
                          CupertinoIcons.arrowtriangle_right_fill,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 590,
          left: 240,
          child: SvgPicture.asset(
            "assets/devil.svg",
            width: 180,
            height: 180,
          ),
        ),
      ],
    );
  }

  Widget _buildTestContent({
    required String text,
    String? svgAsset,
    bool isLastPage = false,
    VoidCallback? onNext,
    int? pageNum,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/onboarding_bg_1.png',
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (pageNum == null)
                    Padding(
                        padding: EdgeInsets.only(left: 70, bottom: 10),
                        child: SizedBox(
                          height: 30,
                          width: 100,
                        )),
                  if (pageNum != null)
                    Padding(
                      padding: EdgeInsets.only(left: 70, bottom: 10),
                      child: SizedBox(
                        height: 30,
                        width: 100,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "$pageNum", // pageNum만 오퍼시티 100
                                style: TextStyle(
                                  color: Colors.white, // 완전한 불투명 색상
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold, // 필요한 경우 추가
                                ),
                              ),
                              TextSpan(
                                text: " / 7", // 나머지 텍스트
                                style: TextStyle(
                                  color: Colors.white38, // 오퍼시티 38
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      _pageController.jumpToPage(7);
                    },
                    child: Container(
                      padding: EdgeInsets.only(right: 70),
                      width: 150,
                      height: 30,
                      alignment: Alignment.centerRight,
                      child: Text(
                        "skip",
                        style: TextStyle(color: Colors.white38, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xff6976b6).withOpacity(0.2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 150,
                        width: 250,
                        child: TypingEffect(fullText: text)),
                    SizedBox(height: 30),
                    if (!isLastPage) // 마지막 페이지가 아니면 다음 버튼 표시
                      GestureDetector(
                        onTap: onNext ??
                            () {
                              //
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateGalaxyPage(),
                                ),
                              );
                            },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Color(0xff0a1c4c),
                          ),
                          child: Icon(
                            CupertinoIcons.arrowtriangle_right_fill,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 540,
          left: 230,
          child: SvgPicture.asset(
            svgAsset ?? "assets/devil.svg",
            width: 180,
            height: 180,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(), // 사용자 스와이프 방지
        onPageChanged: (index) {
          if (index == 2) {
            // 로딩 페이지에 도달하면 데이터 fetch 시작
            _fetchPyramidData();
          }
        },
        children: [
          _buildPageContent(
              text: "안녕?\n나는 우주 정복을 도와 줄\n금성이야!\n반가워!", pageNum: 1),
          _buildPageContent(
            text: "방금 입력한\n목표를 이루기 위해\n구체적인 로드맵을\n그려본 적 있니?",
            pageNum: 2,
            onNext: () {
              _pageController.jumpToPage(
                _pageController.page!.toInt() + 1,
              );
            },
          ),
          _buildLoadingPage(), // 로딩 페이지
          _buildPyramidPage(), // 피라미드 페이지
          _buildPageContent(
              text: "노자 선생님은\n이렇게 말씀하셨어!\n\n\"천리길도 한 걸음부터\n시작한다\"", pageNum: 4),
          _buildPageContent(
              text: "목표를 이루기 위한 여정은\n작은 성취를 쌓아가는\n구체적인 계획에서\n시작될 수 있어",
              pageNum: 5),
          _buildPageContent(
              text: "지금부터\n우리와 함께\n우주 정복의 첫 걸음을\n내딛어 보자!", pageNum: 6),
          _buildPageContent(
              text:
                  "그럼 가장 먼저 정복할\n은하수를 만들어볼까?\n은하수를 생성하는 여정은\n내 동생, 럭키가\n도와줄거야!",
              pageNum: 7),
          _buildTestContent(
            text: "안녕!\n나는 은하수 생성을\n도와 줄 럭키야!",
            svgAsset: "assets/lucky.svg",
          ),
        ],
      ),
    );
  }
}

class TypingEffect extends StatefulWidget {
  final String fullText;
  final Duration typingSpeed;

  TypingEffect({
    required this.fullText,
    this.typingSpeed = const Duration(milliseconds: 100),
  });

  @override
  _TypingEffectState createState() => _TypingEffectState();
}

class _TypingEffectState extends State<TypingEffect> {
  String displayedText = "";
  int currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.typingSpeed, (timer) {
      if (currentIndex < widget.fullText.length) {
        setState(() {
          displayedText += widget.fullText[currentIndex];
          currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      displayedText,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }
}
