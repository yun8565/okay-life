import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:okay_life_app/pages/dashboard_page.dart';
import 'package:scaled_list/scaled_list.dart';

class GalaxyDexPage extends StatefulWidget {
  @override
  State<GalaxyDexPage> createState() => _GalaxyDexPageState();
}

class _GalaxyDexPageState extends State<GalaxyDexPage> {
  final List<Map<String, dynamic>> galaxyData = []; // 백엔드에서 가져올 데이터

  @override
  void initState() {
    super.initState();
    fetchGalaxyData(); // 데이터 페치
  }

  Future<void> fetchGalaxyData() async {
    // 백엔드에서 데이터 가져오기 (예제 데이터 추가)
    await Future.delayed(Duration(seconds: 2)); // 서버 호출 시뮬레이션

    setState(() {
      galaxyData.addAll([
        {
          "name": "디저트 은하",
          "image": "assets/planet1.png",
          "completed": 8,
          "total": 8,
        },
        {
          "name": "해양 은하",
          "image": "assets/planet2.png",
          "completed": 4,
          "total": 8,
        },
        {
          "name": "우주 은하",
          "image": "assets/planet3.png",
          "completed": 2,
          "total": 8,
        },
        {"name": "업데이트 예정", "image": "assets/question_planet.png", "total": 0},
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset(
            "assets/dashboard_bg.png",
            fit: BoxFit.cover,
          )),
          Positioned(
            top: 100,
            left: 50,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardPage(),
                  ),
                );
              },
              child: Icon(
                CupertinoIcons.arrowtriangle_left_circle_fill,
                color: Color(0xff6976b6).withOpacity(0.5),
                size: 50,
              ),
            ),
          ),
          galaxyData.isEmpty
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ), // 로딩 중 표시
                )
              : Center(
                  child: ScaledList(
                    itemCount: galaxyData.length,
                    itemColor: (index) {
                      // 색상은 순환적으로 설정
                      return Colors.white;
                    },
                    itemBuilder: (index, selectedIndex) {
                      final galaxy = galaxyData[index];
                      final isSelected = index == selectedIndex;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (galaxy["completed"] == galaxy["total"])
                              Icon(Icons.check_circle,
                                  color: Color(0xff0a1c4c), size: 32), // 완료 아이콘
                            SizedBox(height: 10),
                            Image.asset(
                              galaxy["image"],
                              height: isSelected ? 110 : 90, // 선택된 아이템 강조
                            ),
                            SizedBox(height: 20),
                            Text(
                              galaxy["name"],
                              style: TextStyle(
                                fontSize: isSelected ? 22 : 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0a1c4c),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              galaxy["total"] == 0
                                  ? "기대해주세요!"
                                  : galaxy["completed"] == galaxy["total"]
                                      ? "모두 모았어요!"
                                      : "${galaxy["completed"]} / ${galaxy["total"]}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (isSelected && galaxy["total"] != 0)
                              ElevatedButton(
                                onPressed: () {
                                  // 상세 화면 이동 또는 기능 구현
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff0a1c4c),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  "행성 보기",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
