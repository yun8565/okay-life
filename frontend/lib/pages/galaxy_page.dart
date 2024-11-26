import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:okay_life_app/widgets/planet.dart';

class GalaxyPage extends StatefulWidget {
  final int planetCount; // 행성 개수
  final double progress; // 진행률 (0.0 ~ 1.0)

  GalaxyPage({required this.planetCount, required this.progress});

  @override
  _GalaxyPageState createState() => _GalaxyPageState();
}

class _GalaxyPageState extends State<GalaxyPage> {
  List<List<XmlElement>> routeCircles = []; // 각 SVG의 원(circle) 목록
  List<String> userAnswers = [];

  bool showPopup = false; // 팝업 표시 여부
  int currentPopupIndex = 0; // 현재 보여지는 팝업 인덱스

  // 팝업 내용을 관리하는 리스트
  final List<Map<String, dynamic>> popupContent = [
    {
      "title": "",
      "contents": "'컨텐츠 퀄리티 향상'\n100% 달성",
      "description": "",
      "input": false,
    },
    {
      "title": "",
      "contents": "비숑 행성\n정복 성공",
      "description": "정복한 행성은 도감에서 볼 수 있어요!",
      "input": false,
    },
    {
      "title": "Keep",
      "contents": "목표 달성 기간동안\n잘했다고\n생각했던 점이 있어?",
      "description": "",
      "input": true,
      "inputType": "text"
    },
    {
      "title": "Problem",
      "contents": "목표 달성 기간동안\n개선이 필요하다고\n생각했던 점이 있어?",
      "description": "",
      "input": true,
      "inputType": "text"
    },
    {
      "title": "Try",
      "contents": "다음에는 달성률을\n높이기 위해\n어떤 시도를\n해볼 수 있을까?",
      "description": "",
      "input": true,
      "inputType": "text"
    },
    {
      "title": "",
      "contents": "이번 목표의\n난이도는 어땠어?",
      "description": "",
      "input": true,
      "inputType": "button"
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadRoutes(); // SVG 파일 파싱
  }

  Future<void> _loadRoutes() async {
    try {
      // SVG 파일 리스트
      List<String> routes = List.generate(
        widget.planetCount - 1,
        (index) => 'assets/planet${widget.planetCount}_route${index + 1}.svg',
      );

      // 각 파일에서 원(circle) 태그 파싱
      for (String route in routes) {
        final svgString = await rootBundle.loadString(route);
        final document = XmlDocument.parse(svgString);

        // 모든 <circle> 태그 추출
        final circles = document.findAllElements('circle').toList();
        setState(() {
          routeCircles.add(circles); // 각 경로의 원(circle) 리스트 저장
        });
      }
    } catch (e) {
      print('Error loading SVG files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.planetCount <= 1 || widget.progress < 0 || widget.progress > 1) {
      return Center(
        child: Text(
          'Invalid parameters: planetCount=${widget.planetCount}, progress=${widget.progress}',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              "assets/background.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
              top: 70,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xff6976b6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "유튜브 구독자 1만 달성",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
              )),
          // 각 경로의 원(circle) 렌더링
          for (int routeIndex = 0;
              routeIndex < routeCircles.length;
              routeIndex++)
            for (int circleIndex = 0;
                circleIndex < routeCircles[routeIndex].length;
                circleIndex++)
              _buildCircle(routeIndex, circleIndex),
          // 행성 배치
          for (int i = 0; i < widget.planetCount; i++)
            Positioned(
              left: _getPlanetPosition(i).dx, // 행성 x 좌표
              top: _getPlanetPosition(i).dy, // 행성 y 좌표
              child: Stack(
                children: [
                  Planet(
                    imagePath: 'assets/planet${i + 1}.png',
                    size: 150,
                    isFirst: i == 0,
                    isLast: i == widget.planetCount - 1,
                  ),
                  if (_isConquestDay(i))
                    Padding(
                      padding: const EdgeInsets.only(top: 50, left: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showPopup = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(130, 40),
                          backgroundColor: Colors.white.withOpacity(0.9),
                        ),
                        child: Text(
                          "정복하기",
                          style:
                              TextStyle(color: Color(0xff0a1c4c), fontSize: 18),
                        ),
                      ),
                    )
                ],
              ),
            ),
          if (showPopup)
            Positioned.fill(
              child: Stack(
                children: [
                  Container(
                    color: Color(0xff507583).withOpacity(0.3),
                  ),
                  Center(
                    child: Container(
                      width: 320,
                      height: 350,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (popupContent[currentPopupIndex]["title"] != "")
                            Text(
                              textAlign: TextAlign.center,
                              popupContent[currentPopupIndex]["title"],
                              style: TextStyle(
                                  color: Color(0xff566181), fontSize: 15),
                            ),
                          SizedBox(
                            height: 20,
                          ),
                          TypingEffect(// 고유한 키 추가
                            fullText: popupContent[currentPopupIndex]["contents"],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          if (popupContent[currentPopupIndex]["description"] !=
                              "")
                            Text(
                              popupContent[currentPopupIndex]["description"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xff566181), fontSize: 15),
                            ),
                          if (popupContent[currentPopupIndex]["input"])
                            if (popupContent[currentPopupIndex]["inputType"] ==
                                "text")
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: TextField(
                                  onSubmitted: (value) {
                                    if (value.isNotEmpty) {
                                      setState(() {
                                        userAnswers.add(value);
                                        currentPopupIndex += 1;
                                        if (currentPopupIndex >=
                                            popupContent.length) {
                                          showPopup = false;
                                          currentPopupIndex = 0;
                                        }
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 17,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xffd9d9d9)
                                        .withOpacity(0.2),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                              ),
                          if (popupContent[currentPopupIndex]["input"])
                            if (popupContent[currentPopupIndex]["inputType"] ==
                                "button")
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ...[
                                    "어려웠어",
                                    "괜찮았어",
                                    "쉬웠어"
                                  ].map((buttonText) => GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            userAnswers.add(buttonText);
                                            showPopup = false;
                                            currentPopupIndex = 0;
                                          });
                                        },
                                        child: Container(
                                          width: 180,
                                          height: 40,
                                          margin:
                                              EdgeInsets.symmetric(vertical: 5),
                                          decoration: BoxDecoration(
                                              color: Color(0xff0a1c4c),
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          alignment: Alignment.center,
                                          child: Text(
                                            buttonText,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                          if (popupContent[currentPopupIndex]["inputType"] !=
                              "button")
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (currentPopupIndex <
                                      popupContent.length - 1) {
                                    setState(() {
                                      currentPopupIndex += 1;
                                    });
                                  } else {
                                    setState(() {
                                      showPopup = false;
                                      currentPopupIndex = 0;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xff0a1c4c)),
                                child: Text(
                                  "다음",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      top: 550,
                      right: -10,
                      child: Image.asset(
                        "assets/lucky.png",
                        width: 190,
                      ))
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 라우트의 위치 오프셋 (좌표 설정)
  List<Offset> get routeOffsets {
    if (widget.planetCount == 3) {
      return [
        Offset(120, 180), // 첫 번째 라우트 시작 위치
        Offset(100, 520), // 두 번째 라우트 시작 위치
      ];
    } else if (widget.planetCount == 4) {
      return [
        Offset(181, 210), // 첫 번째 라우트 시작 위치
        Offset(76, 390), // 두 번째 라우트 시작 위치
        Offset(170, 580), // 세 번째 라우트 시작 위치
      ];
    } else if (widget.planetCount == 5) {
      return [
        Offset(120, 140), // 첫 번째 라우트 시작 위치
        Offset(80, 320), // 두 번째 라우트 시작 위치
        Offset(190, 470), // 세 번째 라우트 시작 위치
        Offset(66, 620), // 네 번째 라우트 시작 위치
      ];
    }
    return [];
  }

  // 원(circle) 생성
  Widget _buildCircle(int routeIndex, int circleIndex) {
    if (routeIndex >= routeOffsets.length) {
      print('Invalid routeIndex: $routeIndex');
      return SizedBox.shrink();
    }

    final circle = routeCircles[routeIndex][circleIndex];

    // 원(circle)의 상대 위치와 크기 가져오기
    final double cx = double.parse(circle.getAttribute('cx') ?? '0');
    final double cy = double.parse(circle.getAttribute('cy') ?? '0');
    final double radius = double.parse(circle.getAttribute('r') ?? '2.5');

    // 라우트의 오프셋 적용
    final Offset baseOffset = routeOffsets[routeIndex];
    final double x = baseOffset.dx + cx;
    final double y = baseOffset.dy + cy;

    // 총 원(circle)의 개수 계산
    final int totalCircles =
        routeCircles.fold(0, (sum, route) => sum + route.length);
    final int completedCircles = (widget.progress * totalCircles).floor();

    // 현재 원의 순서를 계산
    int currentCircleIndex = 0;
    for (int i = 0; i < routeIndex; i++) {
      currentCircleIndex += routeCircles[i].length;
    }
    currentCircleIndex += circleIndex;

    // 색상 설정
    final bool isCompleted = currentCircleIndex < completedCircles;
    final Color color = isCompleted ? Colors.yellow : Color(0xFF45548E);

    return Positioned(
      left: x - radius,
      top: y - radius,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  // 행성 위치 반환
  Offset _getPlanetPosition(int index) {
    if (widget.planetCount == 3) {
      return [
        Offset(20, 200), // 첫 번째 행성
        Offset(250, 400), // 두 번째 행성
        Offset(100, 720), // 세 번째 행성
      ][index];
    } else if (widget.planetCount == 4) {
      return [
        Offset(50, 140), // 첫 번째 행성
        Offset(282, 260), // 두 번째 행성
        Offset(43, 575), // 세 번째 행성
        Offset(257, 713), // 네 번째 행성
      ][index];
    } else if (widget.planetCount == 5) {
      return [
        Offset(40, 80), // 첫 번째 행성
        Offset(220, 190), // 두 번째 행성
        Offset(60, 420), // 세 번째 행성
        Offset(250, 570), // 네 번째 행성
        Offset(50, 700), // 다섯 번째 행성
      ][index];
    }
    return Offset.zero;
  }

  // 행성 종료 조건 확인
  bool _isConquestDay(int planetIndex) {
    // 예제: 특정 조건에서만 "정복하기" 버튼 표시
    return planetIndex == 0; // 세 번째 행성만 정복 가능
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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(TypingEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    // fullText가 변경되면 상태 초기화
    if (widget.fullText != oldWidget.fullText) {
      _resetTyping();
      _startTyping();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
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

  void _resetTyping() {
    _timer?.cancel(); // 기존 타이머 중단
    setState(() {
      displayedText = ""; // 표시된 텍스트 초기화
      currentIndex = 0;   // 인덱스 초기화
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      displayedText,
      style: TextStyle(
          color: Color(0xff1f2e5c), fontSize: 20, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}
