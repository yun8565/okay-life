import 'package:flutter/material.dart';
import 'package:okay_life_app/pages/createGalaxy_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<String> _userName;

  Map<String, dynamic>? currentGalaxy; // 현재 은하수
  List<Map<String, dynamic>> otherGalaxies = []; // 다른 은하수 목록
  Map<int, List<bool>> routineChecks = {}; // 은하수별 데일리 루틴 체크박스 상태

  @override
  void initState() {
    super.initState();
    _userName = fetchUserName();
    fetchGalaxyData();
  }

  Future<String> fetchUserName() async {
    // 테스트용 사용자 이름 반환
    await Future.delayed(Duration(seconds: 1));
    return "홍길동";
  }

  Future<void> fetchGalaxyData() async {
    await Future.delayed(Duration(seconds: 1));

    // 테스트 데이터
    final Map<String, dynamic> mockData = {
      "galaxies": [
        {
          "id": 1,
          "galaxy_title": "독서 100권",
          "created_date": "2024-01-01",
          "end_date": "2024-12-31",
          "total_planets": 10,
          "completed_planets": 2,
          "current_planet": {
            "title": "책 10권 읽기",
            "daily_routines": [
              {"id": 101, "title": "한 시간 독서"},
              {"id": 102, "title": "독서 메모 작성"},
              {"id": 103, "title": "책 목록 정리"}
            ]
          },
          "image_url": "assets/sun-star.png"
        },
        {
          "id": 2,
          "galaxy_title": "10kg 감량",
          "created_date": "2024-02-15",
          "end_date": "2024-12-31",
          "total_planets": 5,
          "completed_planets": 3,
          "current_planet": {
            "title": "3일 안에 2kg 감량",
            "daily_routines": [
              {"id": 104, "title": "물 2L 마시기"},
              {"id": 105, "title": "30분 걷기"},
              {"id": 106, "title": "칼로리 기록"}
            ]
          },
          "image_url": "assets/sun-star.png"
        }
      ]
    };

    final List<Map<String, dynamic>> galaxies =
        List<Map<String, dynamic>>.from(mockData['galaxies']);
    galaxies.sort((a, b) => DateTime.parse(b['created_date'])
        .compareTo(DateTime.parse(a['created_date'])));

    setState(() {
      currentGalaxy = galaxies.first; // 가장 최근 생성된 은하수 선택
      otherGalaxies = galaxies; // 전체 은하수 목록 저장

      // 초기화된 routineChecks 설정
      for (var galaxy in galaxies) {
        final id = galaxy['id'];
        final dailyRoutines = galaxy['current_planet']['daily_routines'];
        routineChecks[id] =
            List<bool>.filled(dailyRoutines.length, false); // 초기값 false
      }
    });
  }

  void selectGalaxy(int id) {
    setState(() {
      currentGalaxy = otherGalaxies.firstWhere((galaxy) => galaxy['id'] == id);

      // 선택된 은하수의 루틴 체크 상태가 없으면 초기화
      if (!routineChecks.containsKey(id)) {
        final dailyRoutines =
            currentGalaxy?['current_planet']['daily_routines'];
        routineChecks[id] =
            List<bool>.filled(dailyRoutines?.length ?? 0, false);
      }
    });
  }

  Future<void> updateMissionStatus(int missionId, bool completed) async {
    // 체크박스 업데이트를 가정한 API 호출 (테스트용)
    await Future.delayed(Duration(milliseconds: 500));
    print("미션 $missionId 상태 업데이트: $completed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/dashboard_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              children: [
                FutureBuilder<String>(
                  future: _userName,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // 로딩 상태 표시
                    } else if (snapshot.hasError) {
                      return Text(
                        "오류 발생: ${snapshot.error}",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      );
                    } else if (snapshot.hasData) {
                      final userName = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.only(top: 110, left: 40),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                              ),
                              children: [
                                TextSpan(
                                  text: "$userName",
                                  style: TextStyle(
                                    color: Color(0xFFFFCF39),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: "님, \n안녕하세요!",
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return Text(
                      "데이터를 가져올 수 없습니다.",
                      style: TextStyle(color: Colors.white),
                    );
                  },
                ),
                IntrinsicHeight(
                  child: Container(
                    width: 350,
                    padding: EdgeInsets.only(bottom: 40, left: 20, right: 20),
                    decoration: BoxDecoration(
                      color: Color(0xffebebeb),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(top: 40, right: 20),
                            child: Text(
                              "${currentGalaxy?['galaxy_title']}",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Color(0xff0a1c4c),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "${currentGalaxy?['end_date']} ",
                                    style: TextStyle(
                                      color: Color(0xFF0A1C4C),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "까지",
                                    style: TextStyle(
                                      color: Color(0xffa3a3a3),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "현재  ",
                                    style: TextStyle(
                                      color: Color(0xffa3a3a3),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        "${currentGalaxy?['completed_planets']} ", // 마감 기한 텍스트
                                    style: TextStyle(
                                      color: Color(0xFF0A1C4C),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 36,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        "/ ${currentGalaxy?['total_planets']} ", // 마감 기한 텍스트
                                    style: TextStyle(
                                      color: Color(0xFFa3a3a3),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding:
                                EdgeInsets.only(top: 15, bottom: 8, left: 20),
                            child: Text(
                              "오늘의 할 일",
                              style: TextStyle(
                                  color: Color(0xff0a1c4c).withOpacity(0.8),
                                  fontSize: 15),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Color(0xffd9d9d9).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: List.generate(
                              currentGalaxy?['current_planet']['daily_routines']
                                      ?.length ??
                                  0,
                              (index) {
                                final mission = currentGalaxy?['current_planet']
                                    ['daily_routines'][index];
                                final missionTitle = mission?['title'] ?? "";
                                final missionId = mission?['id'];

                                final galaxyId = currentGalaxy?['id'];

                                return CheckboxListTile(
                                  title: Text(
                                    missionTitle,
                                    style: TextStyle(
                                        fontSize: 21,
                                        color: (routineChecks[galaxyId]
                                                    ?[index] ??
                                                false)
                                            ? Colors.grey
                                            : Color(0xff0a1c4c)),
                                  ),
                                  checkColor: Colors.white, // 체크박스 내부 색
                                  activeColor: Color(0xff0a1c4c), // 체크 시 남색
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  value:
                                      routineChecks[galaxyId]?[index] ?? false,
                                  onChanged: (value) async {
                                    if (value != null && missionId != null) {
                                      setState(() {
                                        routineChecks[galaxyId]?[index] = value;
                                      });

                                      await updateMissionStatus(
                                          missionId, value);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Flexible(
                  child: GridView.builder(
                    padding: EdgeInsets.only(left: 40, right: 40),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: otherGalaxies.length + 1,
                    itemBuilder: (context, index) {
                      if (index == otherGalaxies.length) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CreateGalaxyPage(result: "게으른 자"),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(70),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                size: 48,
                                color: Color(0xff5185e0).withOpacity(0.5),
                              ),
                            ),
                          ),
                        );
                      }

                      final galaxy = otherGalaxies[index];
                      final bool isSelectedGalaxy =
                          currentGalaxy?['id'] == galaxy['id'];

                      return GestureDetector(
                        onTap: () {
                          selectGalaxy(galaxy['id']);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(70),
                            color: isSelectedGalaxy
                                ? Colors.white.withOpacity(0.3)
                                : Colors.black.withOpacity(0.25),
                            border: Border.all(
                              color: isSelectedGalaxy
                                  ? Color(0xFF0A1C4C)
                                  : Colors.transparent,
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                galaxy['image_url'] ??
                                    'assets/default_planet.png',
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
