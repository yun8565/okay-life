import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:okay_life_app/api/api_client.dart';
import 'package:okay_life_app/main.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late String nickname;
  late String email;
  late String spaceGoal;
  late String concept;
  bool isLoading = true;

  // 초기 선택된 시간
  String _selectedTime = '오후 06:00';
  bool _isNotificationOn = true; // 알림 ON/OFF 상태

  // 말투 설정 상태
  bool isDefaultChecked = true; // 기본
  bool isSpaceChecked = false; // 우주 컨셉
  bool isToughChecked = false; // 건달 컨셉

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // 테스트용 사용자 이름 반환
    final response = await ApiClient.get("/users/me");

    setState(() {
      nickname = response["nickname"];
      email = response["email"];
      spaceGoal = response["spaceGoal"];
      concept = response["concept"];

      // 말투 설정 초기화
      if (concept == "DEFAULT") {
        isDefaultChecked = true;
        isSpaceChecked = false;
        isToughChecked = false;
      } else if (concept == "SPACE") {
        isDefaultChecked = false;
        isSpaceChecked = true;
        isToughChecked = false;
      } else if (concept == "BRO") {
        isDefaultChecked = false;
        isSpaceChecked = false;
        isToughChecked = true;
      }

      isLoading = false;
    });
  }

  // 1시간 단위로 시간 목록 생성
  final List<String> _timeOptions = [
    '오전 01:00',
    '오전 02:00',
    '오전 03:00',
    '오전 04:00',
    '오전 05:00',
    '오전 06:00',
    '오전 07:00',
    '오전 08:00',
    '오전 09:00',
    '오전 10:00',
    '오전 11:00',
    '오후 12:00',
    '오후 01:00',
    '오후 02:00',
    '오후 03:00',
    '오후 04:00',
    '오후 05:00',
    '오후 06:00',
    '오후 07:00',
    '오후 08:00',
    '오후 09:00',
    '오후 10:00',
    '오후 11:00',
    '오전 12:00',
  ];

  void _showTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "시간을 선택하세요",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  backgroundColor: Colors.white,
                  itemExtent: 40.0,
                  scrollController: FixedExtentScrollController(
                    initialItem: _timeOptions.indexOf(_selectedTime),
                  ),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedTime = _timeOptions[index];
                    });

                    // 선택된 시간으로 알림 업데이트
                    if (_isNotificationOn) {
                      LocalPushNotifications.scheduleDailyNotificationAt(
                          _selectedTime);
                    }
                  },
                  children: _timeOptions.map((String time) {
                    return Center(
                      child: Text(
                        time,
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateUserSettings() async {
    try {
      final updatedConcept = isDefaultChecked
          ? "DEFAULT"
          : isSpaceChecked
              ? "SPACE"
              : "BRO";

      final data = {
        "alienConcept": updatedConcept,
        "spaceGoal": spaceGoal,
      };

      final response = await ApiClient.patch('/users/me', data: data);

      LocalPushNotifications.scheduleTestNotification();

      if (response != null) {
        print("Settings updated successfully: $response");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("설정이 성공적으로 업데이트되었습니다!")),
        );
      } else {
        print("No response from the server");
      }
    } catch (e) {
      print("Error updating settings: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("설정 업데이트 중 오류가 발생했습니다.")),
      );
    }
  }

  void _showEditDialog(BuildContext context) {
    TextEditingController _dialogController =
        TextEditingController(text: spaceGoal);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "우주 목표 수정",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _dialogController,
            decoration: InputDecoration(
              hintText: "우주 목표를 입력하세요",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // 텍스트 필드 값 변경 시 업데이트
              spaceGoal = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  spaceGoal = _dialogController.text; // 수정된 값 저장
                });
                Navigator.pop(context); // 다이얼로그 닫기
                _updateUserSettings(); // 수정 API 호출
              },
              child: Text("저장"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              "assets/dashboard_bg.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 100,
            left: 20,
            child: IconButton(
              icon: Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context); // 이전 화면으로 이동
              },
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 프로필 섹션
              Padding(
                padding: EdgeInsets.only(left: 50, bottom: 30),
                child: Row(
                  children: [
                    // 프로필 이미지
                    Image.asset(
                      "assets/profile.png",
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 16),
                    // 이름과 이메일
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: nickname,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0XFFFFCF39),
                                ),
                              ),
                              TextSpan(
                                text: '님',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // 우주 목표 섹션
              Container(
                alignment: Alignment.center,
                width: 311,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xFF0A1C4C),
                ),
                child: GestureDetector(
                  onTap: () {
                    _showEditDialog(context); // 다이얼로그 표시
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            spaceGoal.isEmpty ? "우주 목표를 입력하세요" : spaceGoal,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis, // 텍스트가 길 경우 말줄임표
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          _showEditDialog(context); // 다이얼로그 표시
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 푸시 알림 섹션
              Container(
                width: 350,
                height: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xFF6976B6).withOpacity(0.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 세로 방향 중앙 정렬
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // 가로 방향 중앙 정렬
                    children: [
                      // 푸시 알림 제목 및 스위치
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: const Text(
                              '푸시 알림',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          CupertinoSwitch(
                            value: _isNotificationOn,
                            activeColor: Color(0xffaec578),
                            onChanged: (bool value) {
                              setState(() {
                                _isNotificationOn = value;
                              });

                              if (_isNotificationOn) {
                                // 알림 스케줄링
                                LocalPushNotifications
                                    .scheduleDailyNotificationAt(_selectedTime);
                              } else {
                                // 알림 취소
                                flutterLocalNotificationsPlugin.cancel(0);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        textAlign: TextAlign.center,
                        '알림 시간 설정',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      // 알림 시간 설정
                      Opacity(
                        opacity:
                            _isNotificationOn ? 1.0 : 0.5, // 비활성화 상태일 때 흐리게
                        child: GestureDetector(
                          onTap: _isNotificationOn
                              ? () => _showTimePicker(context)
                              : null, // 알림이 꺼져 있으면 클릭 불가
                          child: Container(
                            width: 300,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xFF0A1C4C),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _selectedTime, // 선택된 시간 표시
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 말투 설정 섹션
              Container(
                width: 350,
                height: 190,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xFF6976B6).withOpacity(0.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: const Text(
                          '푸시 알림 말투 커스텀',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 10, left: 8, bottom: 10),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isDefaultChecked = true;
                                  isSpaceChecked = false;
                                  isToughChecked = false;
                                });
                                _updateUserSettings();
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    isDefaultChecked
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '기본',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isDefaultChecked = false;
                                  isSpaceChecked = true;
                                  isToughChecked = false;
                                });
                                _updateUserSettings();
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    isSpaceChecked
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '우주 컨셉',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isDefaultChecked = false;
                                  isSpaceChecked = false;
                                  isToughChecked = true;
                                });
                                _updateUserSettings();
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    isToughChecked
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '건달 컨셉',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
