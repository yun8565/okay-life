import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:okay_life_app/pages/galaxy_page.dart';

class GalaxyTutorialPage extends StatefulWidget {
  final int galaxyId;

  GalaxyTutorialPage({required this.galaxyId});
  @override
  _GalaxyTutorialPageState createState() => _GalaxyTutorialPageState();
}

class _GalaxyTutorialPageState extends State<GalaxyTutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> tutorialData = [
    {
      "background": "assets/galaxy_tutorial_bg_1.png",
      "message": "질문에 답해 준\n정보들을 토대로\n럭키가\n은하수를 만들어줬어!",
      "focused": false,
      "lineStart": {"x": 150.0, "y": 500.0},
    },
    {
      "background": "assets/galaxy_tutorial_bg_1.png",
      "message": "이제\n은하수에 대해\n설명할게!",
      "focused": false,
      "lineStart": {"x": 150.0, "y": 500.0},
    },
    {
      "background": "assets/galaxy_tutorial_bg_1.png",
      "message": "가장 먼저 은하수는\n우주를 정복하기 위해\n단계별로 정복해야 할 목표야",
      "focused": false,
      "lineStart": {"x": 150.0, "y": 500.0},
    },
    {
      "background": "assets/galaxy_tutorial_bg_1.png",
      "message":
          "은하수는 여러 테마가 있고 \n생성 시마다 랜덤으로\n테마가 배정 돼\n이번엔 럭키가\n강아지 은하수를 만들어줬어!",
      "focused": false,
      "lineStart": {"x": 150.0, "y": 500.0},
    },
    {
      "background": "assets/galaxy_tutorial_bg_1.png",
      "message": "이제\n은하수 안엔\n뭐가  있는지\n같이 살펴볼까?",
      "focused": false,
      "lineStart": {"x": 150.0, "y": 500.0},
    },
    {
      "background": "assets/galaxy_tutorial_bg_2.png",
      "message": "은하수 안엔\n설정한 단계만큼의\n행성이 있어\n행성은 은하수를 정복하기 위한\n또 다른 단계별 목표인거지!",
      "focused": true,
      "lineStart": {"x": 143.0, "y": 150.0},
    },
    {
      "background": "assets/galaxy_tutorial_bg_2.png",
      "message":
          "행성을 클릭하면 미션이 있어\n미션을 수행한 비율에 따라\n행성을 얻을 확률이 달라지고\n정복한 행성은 도감에서\n확인할 수 있어!",
      "focused": true,
      "lineStart": {"x": 143.0, "y": 150.0},
    },
    {
      "background": "assets/galaxy_tutorial_bg_1.png",
      "message": "자 그럼 이제\n우리만의 속도로\n우주를 정복해보자!\n행운을 빌어!",
      "focused": false,
      "lineStart": {"x": 150.0, "y": 500.0},
    },
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              tutorialData[_currentPage]["background"]!,
              fit: BoxFit.cover,
            ),
          ),
          // 선 그리기
          if (tutorialData[_currentPage]["focused"])
            CustomPaint(
              painter: LinePainter(
                startX: tutorialData[_currentPage]["lineStart"]["x"]!,
                startY: tutorialData[_currentPage]["lineStart"]["y"]!,
              ),
            ),
          // 페이지뷰 내용
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: tutorialData.length,
            itemBuilder: (context, index) {
              final data = tutorialData[index];
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 70, bottom: 5),
                            child: SizedBox(
                              height: 30,
                              width: 100,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: (_currentPage + 1).toString(),
                                      style: TextStyle(
                                        color: Colors.white, // 완전한 불투명 색상
                                        fontSize: 24,
                                        fontWeight:
                                            FontWeight.bold, // 필요한 경우 추가
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          " / ${tutorialData.length}", // 나머지 텍스트
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
                              _pageController.jumpToPage(8);
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 70),
                              width: 50,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Text(
                                "skip",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ]),
                    const SizedBox(
                      height: 10,
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          width: 320,
                          height: 340,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xff6976b6).withOpacity(0.75),
                            borderRadius: BorderRadius.circular(15),
                            border: data["focused"]
                                ? Border.all(
                                    color: Color(0xffe5b052),
                                    width: 3.5,
                                  )
                                : Border.all(color: Colors.transparent),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data["message"]!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              _currentPage < tutorialData.length - 1
                                  ? ElevatedButton(
                                      onPressed: () {
                                        _pageController.nextPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xff0a1c4c),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: const Text(
                                        "다음",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => GalaxyPage(
                                              planetCount: 4,
                                              progress: 0.5,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xff0a1c4c),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: const Text(
                                        "완료",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: 550,
            left: 230,
            child: Image.asset(
              "assets/devil.png",
              width: 210,
            ),
          )
        ],
      ),
    );
  }
}

// 선을 그리기 위한 CustomPainter
class LinePainter extends CustomPainter {
  final double startX;
  final double startY;

  LinePainter({required this.startX, required this.startY});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xffe5b052)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // 선 그리기
    canvas.drawLine(
      Offset(160, 320),
      Offset(startX, startY),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
