import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // 초기 선택된 시간
  String _selectedTime = '오후 09:00';
  bool _isNotificationOn = false; // 알림 ON/OFF 상태

  // 말투 설정 상태
  bool isDefaultChecked = true; // 기본
  bool isSpaceChecked = false; // 우주 컨셉
  bool isToughChecked = false; // 건달 컨셉

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

  // 시간 선택 Bottom Sheet
  void _showTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              // 상단 제목 및 닫기 버튼
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
              // CupertinoPicker
              Expanded(
                child: CupertinoPicker(
                  backgroundColor: Colors.white,
                  itemExtent: 40.0, // 각 아이템의 높이
                  scrollController: FixedExtentScrollController(
                    initialItem: _timeOptions.indexOf(_selectedTime),
                  ),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedTime = _timeOptions[index];
                    });
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

  @override
  Widget build(BuildContext context) {
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
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: '민희원',
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
                        const Text(
                          'lgdxschool@gmail.com',
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
                width: 350,
                height: 110,
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
                        padding: const EdgeInsets.only(left: 3),
                        child: const Text(
                          '우주 목표',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        alignment: Alignment.center,
                        width: 311,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFF0A1C4C),
                        ),
                        child: Row(
                          children: [
                            // 텍스트 입력 (초기 값으로 기존 내용 표시)
                            Expanded(
                              child: TextField(
                                controller:
                                    TextEditingController(text: "기존 우주 목표 텍스트"),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(left: 15),
                                ),
                              ),
                            ),
                            // 수정 아이콘
                            IconButton(
                              icon: Image.asset(
                                "assets/modify.png",
                                width: 24,
                                height: 24,
                              ),
                              onPressed: () {
                                // 수정 아이콘 클릭 시 동작 추가
                                print("수정 아이콘 클릭됨");
                              },
                            ),
                          ],
                        ),
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
