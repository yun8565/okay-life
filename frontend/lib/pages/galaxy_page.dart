import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:okay_life_app/api/api_client.dart';
import 'package:okay_life_app/pages/overview_plan_page.dart';
import 'package:xml/xml.dart';
import 'package:okay_life_app/widgets/planet.dart';

class GalaxyPage extends StatefulWidget {
  final Map<String, dynamic> galaxyData;

  GalaxyPage({required this.galaxyData});

  @override
  _GalaxyPageState createState() => _GalaxyPageState();
}

class _GalaxyPageState extends State<GalaxyPage> {
  List<List<XmlElement>> routeCircles = []; // 각 SVG의 원(circle) 목록
  List<bool> conquestStatus = []; // 각 행성 정복 상태
  List<String> userAnswers = [];

  bool showPopup = false; // 팝업 표시 여부
  int currentPopupIndex = 0; // 현재 보여지는 팝업 인덱스
  int activePlanetIndex = -1; // 현재 활성 팝업의 행성 인덱스

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
    _initializeConquestStatus(); // 정복 상태 초기화
    _loadRoutes(); // SVG 파일 파싱
  }

  void _initializeConquestStatus() {
    // 각 행성의 정복 상태를 false로 초기화
    conquestStatus = List.generate(
      widget.galaxyData['planets'].length,
      (index) => false,
    );
  }

  void _handleConquest(int planetIndex) async {
    final planetId = widget.galaxyData['planets'][planetIndex]['planetId'];
    final planetTitle = widget.galaxyData['planets'][planetIndex]['title'];
    final planetTheme =
        widget.galaxyData["planets"][planetIndex]["planetThemeName"];

    try {
      // POST 요청 보내기
      // final responseData = await ApiClient.post(
      //   '/planet/$planetId',
      // );

      // 더미 데이터 사용
      final responseData = {
        'acquired': planetId % 2 == 0, // planetId가 짝수면 성공, 홀수면 실패
        'clearRatio': (planetId * 10) % 100, // 임의의 달성률 계산
      };

      // 응답 데이터 처리
      final bool acquired = responseData['acquired'];
      final int clearRatio = responseData['clearRatio'];

      // 팝업 컨텐츠 업데이트
      setState(() {
        popupContent[0] = {
          "title": "",
          "contents": '$planetTitle\n$clearRatio% 달성',
          "description": "",
          "input": false,
        };
        popupContent[1] = {
          "title": "",
          "contents": acquired ? '$planetTheme\n정복 성공' : '$planetTheme\n정복 실패',
          "description": acquired ? "정복한 행성은 도감에서 볼 수 있어요!" : "다음 기회를 노려봐요!",
          "input": false,
        };
        showPopup = true;
        activePlanetIndex = planetIndex;
        currentPopupIndex = 0; // 팝업 인덱스 초기화
      });
    } catch (e) {
      print('Error during conquest request: $e');
      // 에러에 대한 사용자 알림 로직을 추가해도 좋습니다.
    }
  }

  Future<void> _loadRoutes() async {
    try {
      final int planetCount = widget.galaxyData['planets'].length;

      // SVG 파일 리스트
      List<String> routes = List.generate(
        planetCount - 1,
        (index) => 'assets/planet${planetCount}_route${index + 1}.svg',
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

  double _calculatePlanetProgress(String startDate, String endDate) {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      final now = DateTime.now();

      if (now.isBefore(start)) {
        return 0.0; // 시작일 이전이면 진행률 0%
      } else if (now.isAfter(end)) {
        return 1.0; // 종료일 이후면 진행률 100%
      }

      final totalDuration = end.difference(start).inDays;
      final elapsed = now.difference(start).inDays;

      return elapsed / totalDuration;
    } catch (e) {
      print("Error calculating planet progress: $e");
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int planetCount = widget.galaxyData['planets'].length;

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
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.galaxyData["title"],
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
          ),
          // 각 라우트 진행률에 따라 원(circle) 렌더링
          for (int routeIndex = 0;
              routeIndex < routeCircles.length;
              routeIndex++)
            for (int circleIndex = 0;
                circleIndex < routeCircles[routeIndex].length;
                circleIndex++)
              _buildCircle(routeIndex, circleIndex),
          // 행성 배치
          for (int i = 0; i < planetCount; i++)
            Positioned(
              left: _getPlanetPosition(i).dx, // 행성 x 좌표
              top: _getPlanetPosition(i).dy, // 행성 y 좌표
              child: Stack(
                children: [
                  Planet(
                    imagePath:'assets/planet${i + 1}.png',
                    size: 150,
                    isFirst: i == 0,
                    isLast: i == planetCount - 1,
                    planetId: widget.galaxyData['planets'][i]['planetId'],
                    status: widget.galaxyData['planets'][i]['status'],
                    galaxyData: widget.galaxyData, // 상태 전달
                  ),
                  if (_shouldShowConquestButton(i))
                    Padding(
                      padding: const EdgeInsets.only(top: 50, left: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _handleConquest(i);
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
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (popupContent[currentPopupIndex]["title"] != "")
                            Text(
                              popupContent[currentPopupIndex]["title"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xff566181), fontSize: 15),
                            ),
                          SizedBox(height: 20),
                          TypingEffect(
                            fullText: popupContent[currentPopupIndex]
                                ["contents"],
                          ),
                          SizedBox(height: 20),
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
                                        _handlePopupNext();
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: "입력하세요",
                                    filled: true,
                                    fillColor: const Color(0xffd9d9d9)
                                        .withOpacity(0.2),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                          SizedBox(
                            height: 10,
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
                                          // "어려웠어" 또는 "쉬웠어"일 때만 이동
                                          if (buttonText == "어려웠어" ||
                                              buttonText == "쉬웠어") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    OverviewPlanPage(
                                                  galaxyData: widget.galaxyData,
                                                ),
                                              ),
                                            );
                                          }
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
                            ElevatedButton(
                              onPressed: _handlePopupNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff0a1c4c),
                              ),
                              child: Text(
                                "다음",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      top: 550,
                      right: 0,
                      child: Image.asset(
                        "assets/lucky.png",
                        width: 210,
                      ))
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _handlePopupNext() {
    if (currentPopupIndex < popupContent.length - 1) {
      setState(() {
        currentPopupIndex++;
      });
    } else {
      setState(() {
        conquestStatus[activePlanetIndex] = true;
        showPopup = false;
        currentPopupIndex = 0;
      });
    }
  }

  bool _shouldShowConquestButton(int index) {
    final planet = widget.galaxyData['planets'][index];
    final now = DateTime.now();
    final endDate = DateTime.parse(planet['endDate']);

    // 날짜만 비교하도록 endDate와 now의 시간을 제거
    final endDateWithoutTime =
        DateTime(endDate.year, endDate.month, endDate.day);
    final nowWithoutTime = DateTime(now.year, now.month, now.day);

    // 조건: 정복하지 않았으며 종료일이 오늘 또는 상태가 "ACQUIRABLE"일 때
    return !conquestStatus[index] &&
        (nowWithoutTime.isAtSameMomentAs(endDateWithoutTime) ||
            planet['status'] == "ACQUIRABLE");
  }

  Widget _getPlanetImage(int index) {
    final planet = widget.galaxyData['planets'][index];
    final String status = planet['status'];
    final String imagePath = (status == "SOON")
        ? 'assets/question_planet.png' // 물음표 이미지 경로
        : 'assets/planet${index + 1}.png'; // 일반 행성 이미지 경로

    // 흑백 필터 적용
    if (status == "FAILED") {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Colors.grey,
          BlendMode.saturation, // 흑백으로 변환
        ),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildCircle(int routeIndex, int circleIndex) {
    final currentPlanet = widget.galaxyData['planets'][routeIndex];
    final nextPlanet = widget.galaxyData['planets'][routeIndex + 1];

    final double currentProgress = _calculatePlanetProgress(
      currentPlanet['startDate'],
      currentPlanet['endDate'],
    );
    final double nextProgress = _calculatePlanetProgress(
      nextPlanet['startDate'],
      nextPlanet['endDate'],
    );

    final routeProgress = (currentProgress + nextProgress) / 2;

    final totalCircles = routeCircles[routeIndex].length;
    final completedCircles = (routeProgress * totalCircles).floor();

    final circle = routeCircles[routeIndex][circleIndex];
    final double cx = double.parse(circle.getAttribute('cx') ?? '0');
    final double cy = double.parse(circle.getAttribute('cy') ?? '0');
    final double radius = double.parse(circle.getAttribute('r') ?? '2.5');

    final Offset baseOffset = routeOffsets[routeIndex];
    final double x = baseOffset.dx + cx;
    final double y = baseOffset.dy + cy;

    final isCompleted = circleIndex < completedCircles;

    return Positioned(
      left: x - radius,
      top: y - radius,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? Colors.yellow : Color(0xFF45548E),
        ),
      ),
    );
  }

  List<Offset> get routeOffsets {
    final int planetCount = widget.galaxyData['planets'].length;
    if (planetCount == 3) {
      return [Offset(120, 180), Offset(100, 520)];
    } else if (planetCount == 4) {
      return [
        Offset(181, 210),
        Offset(76, 390),
        Offset(170, 580),
      ];
    } else if (planetCount == 5) {
      return [
        Offset(120, 140),
        Offset(80, 320),
        Offset(190, 470),
        Offset(66, 620),
      ];
    }
    return [];
  }

  Offset _getPlanetPosition(int index) {
    final int planetCount = widget.galaxyData['planets'].length;

    if (planetCount == 3) {
      return [Offset(20, 200), Offset(250, 400), Offset(100, 720)][index];
    } else if (planetCount == 4) {
      return [
        Offset(50, 140),
        Offset(282, 260),
        Offset(43, 575),
        Offset(257, 713),
      ][index];
    } else if (planetCount == 5) {
      return [
        Offset(40, 80),
        Offset(220, 190),
        Offset(60, 420),
        Offset(250, 570),
        Offset(50, 700),
      ][index];
    }
    return Offset.zero;
  }
}

class TypingEffect extends StatefulWidget {
  final String fullText;
  final Duration typingSpeed;

  TypingEffect({
    required this.fullText,
    this.typingSpeed = const Duration(milliseconds: 70),
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
      currentIndex = 0; // 인덱스 초기화
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
