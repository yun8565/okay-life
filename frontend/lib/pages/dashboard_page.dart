import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:okay_life_app/api/api_client.dart';
import 'package:okay_life_app/pages/createGalaxy_page.dart';
import 'package:okay_life_app/pages/galaxy_dex_page.dart';
import 'package:okay_life_app/pages/galaxy_page.dart';
import 'package:okay_life_app/pages/galaxy_tutorial_page.dart';
import 'package:okay_life_app/pages/review_page.dart';
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
  Map<String, dynamic>? currentPlanet; // 진행 중인 행성
  List<Map<String, dynamic>> otherGalaxies = []; // 다른 은하수 목록
  Map<int, List<bool>> routineChecks = {}; // 은하수별 데일리 루틴 체크박스 상태
  int ongoingPlanetsCount = 0; // 진행 중인 행성의 개수
  int totalPlanetsCount = 0;

  @override
  void initState() {
    super.initState();
    _userName = fetchUserData();
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

  Future<String> fetchUserData() async {
    // 테스트용 사용자 이름 반환
    final response = await ApiClient.get("/users/me");
    return response["nickname"];
  }

  Future<void> fetchGalaxyData() async {
    try {
      print(await ApiClient.getJwt());

      // /galaxies API 호출
      final List<dynamic> response =
          await ApiClient.get('/galaxies') as List<dynamic>;
      print(response);

      // 데이터 형식에 맞게 파싱
      final List<Map<String, dynamic>> galaxies = response.map((galaxy) {
        final Map<String, dynamic> galaxyMap = galaxy as Map<String, dynamic>;
        final List<dynamic> planetsData = galaxyMap['planets'] ?? [];
        final List<Map<String, dynamic>> planets = planetsData.map((planet) {
          final Map<String, dynamic> planetMap = planet as Map<String, dynamic>;
          final List<dynamic> missionsData = planetMap['missions'] ?? [];
          final List<Map<String, dynamic>> missions =
              missionsData.map((mission) {
            final Map<String, dynamic> missionMap =
                mission as Map<String, dynamic>;
            return {
              'missionId': missionMap['missionId'] is int
                  ? missionMap['missionId']
                  : (missionMap['missionId'] as num).toInt(), // Long -> int 변환
              'content': missionMap['content']?.toString() ?? '',
              'date': missionMap['date']?.toString() ?? '', // yyyy-MM-dd 포맷
              'status': missionMap['status']?.toString() ?? '', // Enum 처리
            };
          }).toList();

          return {
            'planetId': planetMap['planetId'] is int
                ? planetMap['planetId']
                : (planetMap['planetId'] as num).toInt(), // Long -> int 변환
            'title': planetMap['title']?.toString() ?? '',
            'status': planetMap['status']?.toString() ?? '', // Enum 처리
            'planetThemeName': planetMap['planetThemeName']?.toString() ?? '',
            'startDate': planetMap['startDate']?.toString() ?? '',
            'endDate': planetMap['endDate']?.toString() ?? '',
            'missions': missions,
          };
        }).toList();

        return {
          'galaxyId': galaxyMap['galaxyId'] is int
              ? galaxyMap['galaxyId']
              : (galaxyMap['galaxyId'] as num).toInt(), // Long -> int 변환
          'title': galaxyMap['title']?.toString() ?? '',
          'planetThemeNameRepresenting':
              galaxyMap['planetThemeNameRepresenting']?.toString() ?? '',
          'startDate': galaxyMap['startDate']?.toString() ?? '',
          'endDate': galaxyMap['endDate']?.toString() ?? '',
          'planets': planets,
        };
      }).toList();

      // 데이터 저장
      setState(() {
        currentGalaxy = galaxies.first; // 가장 최근 은하수
        otherGalaxies = galaxies; // 전체 은하수 목록 저장
        totalPlanetsCount =
            currentGalaxy?['planets']?.length ?? 0; // planets 개수 계산
        ongoingPlanetsCount = currentGalaxy?['planets']
              ?.where((planet) => planet['status'] != 'SOON')
              .length ??
          0;
        print("Current Galaxy: $currentGalaxy");
        print("Total Planets Count: $totalPlanetsCount");
        print(otherGalaxies); // 디버그 출력 추가

        currentPlanet = currentGalaxy?['planets']?.firstWhere(
          (planet) => planet['status'] == 'ON_PROGRESS',
          orElse: () => <String, dynamic>{}, // 진행 중인 행성이 없을 경우 null
        );
        // 기본값 처리
        if (currentGalaxy != null && currentGalaxy!['planets'].isEmpty) {
          print("현재 은하수에 미션이 없습니다.");
        }

        // 루틴 체크 초기화
        for (var galaxy in galaxies) {
          final int id = galaxy['galaxyId'];
          final List<Map<dynamic, dynamic>> planets =
              (galaxy['planets'] as List<dynamic>)
                  .cast<Map<dynamic, dynamic>>();
          routineChecks[id] = List<bool>.filled(planets.length, false);
        }
      });
    } catch (error) {
      print(error);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("은하수 데이터를 가져오지 못했습니다: $error")),
      // );
    }
  }

  void selectGalaxy(int galaxyId) {
    print("갤럭시 선택: $galaxyId");

    setState(() {
      currentGalaxy = otherGalaxies.firstWhere(
        (galaxy) => galaxy['galaxyId'] == galaxyId,
        orElse: () => <String, dynamic>{}, // galaxyId 비교,
      );
      print("선택된 갤럭시: $currentGalaxy");

      currentPlanet = currentGalaxy?['planets']?.firstWhere(
        (planet) => planet['status'] == 'ON_PROGRESS',
        orElse: () => <String, dynamic>{}, // 진행 중인 행성이 없을 경우 null
      );

      ongoingPlanetsCount = currentGalaxy?['planets']
              ?.where((planet) => planet['status'] != 'SOON')
              .length ??
          0;
      totalPlanetsCount = currentGalaxy?['planets']?.length ?? 0;

      print("진행 중인 행성 개수: $ongoingPlanetsCount");
      print("전체 행성 개수: $totalPlanetsCount");
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
                  galaxyId: galaxy['galaxyId'],
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
      _fetchGalaxyDetailsAndNavigate(galaxy['galaxyId']);
    }
  }

  Future<void> _fetchGalaxyDetailsAndNavigate(int galaxyId) async {
    try {
      // API 호출로 데이터 가져오기
      final List<dynamic> response = await ApiClient.get('/galaxies');

      // galaxyId에 해당하는 갤럭시 선택
      final Map<String, dynamic>? selectedGalaxy = response.firstWhere(
        (galaxy) => galaxy['galaxyId'] == galaxyId,
        orElse: () => null, // 없으면 null 반환
      );

      if (selectedGalaxy == null) {
        throw Exception('해당 galaxyId에 대한 데이터를 찾을 수 없습니다.');
      }

      // GalaxyPage로 데이터 전달
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GalaxyPage(
            galaxyData: selectedGalaxy, // 선택된 갤럭시 데이터 전달
          ),
        ),
      );
    } catch (error) {
      // 에러 처리
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("은하수 데이터를 가져오지 못했습니다: $error")),
      // );
    }
  }

  Future<void> updateMissionStatus(int missionId, bool completed) async {
    try {
      final response = await ApiClient.post(
        '/missions/${missionId.toString()}/status',
        data: {'status': completed ? 'CLEAR' : 'FAILED'},
      );

      // 응답 데이터가 필요하다면 처리 (옵션)
      if (response != null) {
        print("응답 데이터: $response");
      }

      // UI 업데이트
      setState(() {
        // fetchGalaxyData();
        if (currentGalaxy != null && currentPlanet != null) {
          for (var mission in currentPlanet!['missions']) {
            if (mission['missionId'] == missionId) {
              mission['status'] = completed ? 'CLEAR' : 'FAILED';
              break;
            }
          }
        }
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("미션 상태가 성공적으로 업데이트되었습니다!"),
      //     duration: Duration(seconds: 2),
      //   ),
      // );
    } catch (error) {
      print("미션 상태 업데이트 실패: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayMissions = currentPlanet?['missions']?.where((mission) {
      final missionDate = mission?['date'];
      final missionDateParsed = DateTime.tryParse(missionDate ?? '');
      return missionDateParsed != null &&
          missionDateParsed.year == today.year &&
          missionDateParsed.month == today.month &&
          missionDateParsed.day == today.day;
    }).toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchGalaxyData();
          _userName = fetchUserData();
        },
        child: Stack(
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
                                "${currentGalaxy?['title']}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 24,
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
                                      text: "${currentGalaxy?['endDate']} ",
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
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
                                      text: "${ongoingPlanetsCount} ",
                                      style: TextStyle(
                                        color: Color(0xFF0A1C4C),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 36,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "/ ${totalPlanetsCount} ",
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
                          if (todayMissions == null || todayMissions.isEmpty)
                            Center(
                              child: Container(
                                alignment: Alignment.center,
                                // margin: EdgeInsets.(3),
                                padding: EdgeInsets.symmetric(vertical: 17),
                                decoration: BoxDecoration(
                                  color: Color(0xffd9d9d9).withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  "오늘의 할 일이 없습니다.",
                                  style: TextStyle(
                                      color: Color(0xff0a1c4c).withOpacity(0.8),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
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
                                  currentPlanet?['missions']?.length ?? 0,
                                  (index) {
                                    final mission = currentPlanet?['missions']
                                        [index]; // mission 데이터
                                    final missionTitle =
                                        mission?['content'] ?? ""; // 미션 내용
                                    final missionId =
                                        mission?['missionId']; // 미션 ID
                                    final missionStatus =
                                        mission?['status']; // 미션 상태
                                    final missionDate =
                                        mission?['date']; // 미션 날짜

                                    // 오늘 날짜와 비교
                                    final today = DateTime.now();
                                    final missionDateParsed =
                                        DateTime.tryParse(missionDate ?? '');

                                    // 오늘 미션만 표시
                                    if (missionDateParsed == null ||
                                        missionDateParsed.year != today.year ||
                                        missionDateParsed.month !=
                                            today.month ||
                                        missionDateParsed.day != today.day) {
                                      return Container(); // 오늘 날짜가 아니면 빈 위젯 반환
                                    }

                                    // 초기 체크 상태: 상태가 CLEAR면 true
                                    final isChecked = missionStatus == 'CLEAR';

                                    return CheckboxListTile(
                                      title: Text(
                                        missionTitle,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isChecked
                                              ? Colors.grey
                                              : Color(0xff0a1c4c),
                                        ),
                                      ),
                                      checkColor: Colors.white,
                                      activeColor: Color(0xff0a1c4c),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value: isChecked ||
                                          (routineChecks[currentGalaxy?[
                                                  'galaxyId']]?[index] ??
                                              false),
                                      onChanged: (value) async {
                                        if (value != null &&
                                            missionId != null) {
                                          setState(() {
                                            routineChecks[
                                                    currentGalaxy?['galaxyId']]
                                                ?[index] = value;
                                          });
                                          await updateMissionStatus(
                                              missionId, value);
                                          setState(() {});
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
                          // "+" 버튼으로 새로운 갤럭시 추가
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

                        // 기존 갤럭시 목록 출력
                        final galaxy = otherGalaxies[index];
                        final bool isSelectedGalaxy =
                            currentGalaxy?['galaxyId'] == galaxy['galaxyId'];

                        return GestureDetector(
                          onTap: () {
                            print(
                                "갤럭시 ${otherGalaxies[index]['galaxyId']} 선택됨");
                            selectGalaxy(otherGalaxies[index]['galaxyId']);
                          },
                          child: Container(
                            alignment: Alignment.center,
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
                            child: Image.asset(
                              'assets/${galaxy['planetThemeNameRepresenting']}.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
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
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        type: ExpandableFabType.fan,
        distance: 150.0,
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
            heroTag: 'settings_button',
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
            heroTag: 'collection_button',
            backgroundColor: Color(0xff324199).withOpacity(0.7),
            child: Icon(
              CupertinoIcons.rocket_fill,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CollectionPage()));
            },
          ),
          FloatingActionButton.large(
            heroTag: 'review_button',
            backgroundColor: Color(0xff324199).withOpacity(0.7),
            child: Icon(
              CupertinoIcons.doc_text,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ReviewPage()));
            },
          )
        ],
      ),
    );
  }
}
