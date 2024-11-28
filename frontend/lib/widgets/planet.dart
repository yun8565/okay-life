import 'package:flutter/material.dart';
import 'package:okay_life_app/pages/planet_page.dart';

class Planet extends StatelessWidget {
  final String imagePath; // 행성 이미지 경로
  final double size;
  final bool isFirst;
  final bool isLast;
  final planetId;
  final String status; 
  final Map<String, dynamic>? galaxyData;

  const Planet({
    Key? key,
    required this.imagePath,
    this.size = 50.0,
    required this.isFirst,
    required this.isLast,
    required this.planetId,
    required this.status, 
    required this.galaxyData
    // 상태 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 행성 페이지로 이동
        if (status != "SOON") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlanetPage(
                isFirst: isFirst,
                isLast: isLast,
                planetId: planetId,
                galaxyData: galaxyData,
              ),
            ),
          );
        }
      },
      child: SizedBox(
        width: size,
        height: size,
        child: _buildPlanetImage(), // 상태에 따라 이미지를 동적으로 처리
      ),
    );
  }

  Widget _buildPlanetImage() {
    // 상태에 따른 이미지 처리
    if (status == "SOON") {
      return Image.asset(
        'assets/question_planet.png', // 물음표 이미지 경로
        width: 200,
      );
    } else if (status == "FAILED") {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0, // Red channel
          0.2126, 0.7152, 0.0722, 0, 0, // Green channel
          0.2126, 0.7152, 0.0722, 0, 0, // Blue channel
          0, 0, 0, 1, 0, // Alpha channel
        ]),
        child: Image.asset(
          imagePath, // 일반 행성 이미지 경로
          fit: BoxFit.fitWidth,
        ),
      );
    } else {
      return Image.asset(
        imagePath, // 일반 행성 이미지
        fit: BoxFit.fitWidth,
      );
    }
  }
}
