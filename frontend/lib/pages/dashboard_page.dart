import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:okay_life_app/api/api_client.dart';
import 'package:okay_life_app/pages/createGalaxy_page.dart';
import 'package:okay_life_app/pages/galaxy_dex_page.dart';
import 'package:okay_life_app/pages/galaxy_page.dart';
import 'package:okay_life_app/pages/galaxy_tutorial_page.dart';
import 'package:okay_life_app/pages/setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<String> _userName;
  bool isFirstGalaxyVisit = true;

  Map<String, dynamic>? currentGalaxy; // 현재 은하수
  List<Map<String, dynamic>> otherGalaxies = []; // 다른 은하수 목록
  Map<int, List<bool>> routineChecks = {}; // 은하수별 데일리 루틴 체크박스 상태

  @override
  void initState() {
    super.initState();
    _userName = fetchUserName();
    fetchGalaxyData();
    _checkFirstVisit();
  }

  Future<void> _checkFirstVisit() async {
    // SharedPreferences 초기화 및 방문 여부 확인
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasVisitedGalaxy = prefs.getBool('visitedGalaxy') ?? false;

    setState(() {
      isFirstGalaxyVisit = !hasVisitedGalaxy; // 방문하지 않았다면 true
    });
  }

  Future<void> _setFirstVisit() async {
    // 방문 상태를 저장
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('visitedGalaxy', true);
  }

  Future<String> fetchUserName() async {
    // 테스트용 사용자 이름 반환
    await Future.delayed(Duration(seconds: 1));
    return "홍길동";
  }

  Future<void> fetchGalaxyData() async {
    try {
      // /galaxies API 호출
      final response = await ApiClient.get('/galaxies');

      // 'galaxies' 키에서 데이터를 추출
      final List<Map<String, dynamic>> galaxies =
          List<Map<String, dynamic>>.from(response?['galaxies']);

      // 가장 최근 생성된 은하수 기준으로 정렬
      galaxies.sort((a, b) =>
          DateTime.parse(b['endDate']).compareTo(DateTime.parse(a['endDate'])));

      setState(() {
        currentGalaxy = galaxies.first; // 가장 최근 은하수
        otherGalaxies = galaxies; // 전체 은하수 목록 저장

        // 초기화된 routineChecks 설정
        for (var galaxy in galaxies) {
          final id = galaxy['planetThemeIdRepresenting'];
          final planets = galaxy['planets'] as List<dynamic>;
          routineChecks[id] =
              List<bool>.filled(planets.length, false); // 초기값 false
        }
      });
    } catch (error) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("은하수 데이터를 가져오지 못했습니다: $error")),
      );
    }
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

  void openGalaxyPage(Map<String, dynamic> galaxy) async {
    // 로컬 스토리지에서 방문 여부 확인
    await _checkFirstVisit();

    if (isFirstGalaxyVisit) {
      // 방문한 적이 없으면 설명 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GalaxyTutorialPage(
                  galaxyId: galaxy['id'],
                )),
      );

      // 방문 기록 저장
      await _setFirstVisit();

      // 플래그 업데이트
      setState(() {
        isFirstGalaxyVisit = false;
      });
    } else {
      // 이미 방문한 적이 있으면 은하수 페이지로 바로 이동
      _fetchGalaxyDetailsAndNavigate(galaxy['id']);
    }
  }

  Future<void> _fetchGalaxyDetailsAndNavigate(int galaxyId) async {
    try {
      // API 호출로 데이터 가져오기
      final response = await ApiClient.get('/galaxies/$galaxyId');

      // GalaxyPage로 데이터 전달
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GalaxyPage(
            galaxyData: response, // Fetch된 데이터 전달
          ),
        ),
      );
    } catch (error) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("은하수 데이터를 가져오지 못했습니다: $error")),
      );
    }
  }

  Future<void> updateMissionStatus(int missionId, bool completed) async {
    try {
      // /missions/{missionId}/status로 POST 요청
      final response = await ApiClient.post(
        '/missions/$missionId/status',
        data: {'completed': completed}, // 완료 상태 전달
      );

      // 성공 메시지 출력
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("미션 상태가 성공적으로 업데이트되었습니다!"),
          duration: Duration(seconds: 2),
        ),
      );
      print("미션 상태 업데이트 성공: $response");
    } catch (error) {
      // 에러 메시지 출력
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("미션 상태 업데이트 중 오류 발생: $error"),
          duration: Duration(seconds: 3),
        ),
      );
      print("미션 상태 업데이트 실패: $error");
    }
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
                    child: GestureDetector(
                  onTap: () {
                    // 은하수 페이지로 이동
                    openGalaxyPage(currentGalaxy!);
                  },
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
                                fontWeight: FontWeight.bold,
                              ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                        "${currentGalaxy?['completed_planets']} ",
                                    style: TextStyle(
                                      color: Color(0xFF0A1C4C),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 36,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        "/ ${currentGalaxy?['total_planets']} ",
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
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        AbsorbPointer(
                          // 체크박스 이벤트 분리
                          absorbing: false,
                          child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Color(0xffd9d9d9).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: List.generate(
                                currentGalaxy?['current_planet']
                                            ['daily_routines']
                                        ?.length ??
                                    0,
                                (index) {
                                  final mission =
                                      currentGalaxy?['current_planet']
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
                                            : Color(0xff0a1c4c),
                                      ),
                                    ),
                                    checkColor: Colors.white,
                                    activeColor: Color(0xff0a1c4c),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    value: routineChecks[galaxyId]?[index] ??
                                        false,
                                    onChanged: (value) async {
                                      if (value != null && missionId != null) {
                                        setState(() {
                                          routineChecks[galaxyId]?[index] =
                                              value;
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
                        ),
                      ],
                    ),
                  ),
                )),
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
                                builder: (context) => CreateGalaxyPage(),
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
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        type: ExpandableFabType.fan,
        distance: 120.0,
        openButtonBuilder: DefaultFloatingActionButtonBuilder(
          fabSize: ExpandableFabSize.large,
          child: Icon(
            CupertinoIcons.bars,
            color: Colors.white,
            size: 30,
          ),
          backgroundColor: Color(0xff324199).withOpacity(0.3),
          foregroundColor: Colors.white,
        ),
        closeButtonBuilder: DefaultFloatingActionButtonBuilder(
          fabSize: ExpandableFabSize.large,
          child: Icon(
            CupertinoIcons.clear,
            color: Colors.white,
            size: 30,
          ),
          backgroundColor: Color(0xff324199).withOpacity(0.3),
          foregroundColor: Colors.white,
        ),
        children: [
          FloatingActionButton.large(
            backgroundColor: Color(0xff324199).withOpacity(0.7),
            child: Icon(
              CupertinoIcons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingPage()));
            },
          ),
          FloatingActionButton.large(
            backgroundColor: Color(0xff324199).withOpacity(0.7),
            child: Icon(
              CupertinoIcons.rocket_fill,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CollectionPage()));
            },
          )
        ],
      ),
    );
  }
}
