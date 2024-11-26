import 'package:flutter/material.dart';
import 'package:okay_life_app/pages/planet_page.dart';

class Planet extends StatelessWidget {
  final String imagePath; // 행성 이미지 경로
  final double size;
  final bool isFirst;
  final bool isLast;

  const Planet({
    Key? key,
    required this.imagePath,
    this.size = 50.0,
    required this.isFirst,
    required this.isLast
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 행성 페이지로 이동
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PlanetPage(isFirst: isFirst, isLast: isLast,)));
      },
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          imagePath,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
