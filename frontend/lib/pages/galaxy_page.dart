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
              child: Planet(
                imagePath: 'assets/planet${i + 1}.png',
                size: 150,
                isFirst: i == 0,
                isLast: i == widget.planetCount - 1,
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
}
