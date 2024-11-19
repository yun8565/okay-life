import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:okay_life_app/api/api_client.dart';
import 'package:okay_life_app/pages/dashboard_page.dart';
import 'package:toggle_switch/toggle_switch.dart';

class CreateGalaxyPage extends StatefulWidget {
  final String result; // 전달받을 데이터

  // 생성자
  const CreateGalaxyPage({required this.result, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateGalaxyPageState();
}

class _CreateGalaxyPageState extends State<CreateGalaxyPage> {
  // 시작일과 종료일 변수
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();

  final FocusNode _startDateFocus = FocusNode();
  final FocusNode _endDateFocus = FocusNode();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int selectedStep = 3;
  final List<int> stepOptions = [3, 4, 5];

  @override
  void initState() {
    super.initState();
    _startDateFocus.addListener(() {
      setState(() {}); // 포커스 상태 변경 시 UI 업데이트
    });
    _endDateFocus.addListener(() {
      setState(() {}); // 포커스 상태 변경 시 UI 업데이트
    });
  }

  @override
  void dispose() {
    _startDateFocus.dispose();
    _endDateFocus.dispose();
    super.dispose();
  }

  void _updateDateField() {
    String formattedStartDate = DateFormat('yyyy/MM/dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy/MM/dd').format(endDate);
    _dateController.text = "$formattedStartDate - $formattedEndDate";
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = isStart ? startDate : endDate;
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          if (pickedDate.isAfter(endDate)) {
            // 시작일이 종료일보다 크면 경고 표시
            _showErrorDialog("시작일은 종료일보다 클 수 없습니다.");
            return;
          }
          startDate = pickedDate;
        } else {
          if (pickedDate.isBefore(startDate)) {
            // 종료일이 시작일보다 작으면 경고 표시
            _showErrorDialog("종료일은 시작일보다 작을 수 없습니다.");
            return;
          }
          endDate = pickedDate;
        }
        _updateDateField(); // 날짜 값 업데이트
      });
    }
  }

  bool _isContainerFocused() {
    return _startDateFocus.hasFocus || _endDateFocus.hasFocus;
  }

  Future<void> postGalaxyData() async {
    try {
      // /galaxies에 보낼 데이터
      final Map<String, dynamic> galaxyData = {
        "title": _titleController.text,
        "description": _descriptionController.text,
        "start_date": DateFormat('yyyy-MM-dd').format(startDate),
        "end_date": DateFormat('yyyy-MM-dd').format(endDate),
        "step": selectedStep,
      };

      // /users에 보낼 데이터
      final Map<String, dynamic> userData = {
        "user_type": widget.result, // 테스트 결과
      };

      // ApiClient로 데이터 전송
      final galaxyResponse =
          await ApiClient.post('/galaxies', data: galaxyData);
      print("목표 데이터 전송 성공: ${galaxyResponse}");

      final userResponse = await ApiClient.post('/users', data: userData);
      print("사용자 데이터 전송 성공: ${userResponse}");

      // 성공적으로 데이터 전송 후 다음 페이지로 이동
      Navigator.pushReplacementNamed(context, '/galaxyPage');
    } catch (error) {
      // 에러 처리
      _showErrorDialog("데이터 전송 중 오류 발생: $error");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("오류"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("확인"),
          ),
        ],
      ),
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
              'assets/dashboard_bg.png',
              fit: BoxFit.cover, // 화면 전체에 꽉 채움
            ),
          ),
          // 중앙 컨테이너
          Center(
            child: Container(
              width: 350,
              height: 700,
              decoration: BoxDecoration(
                color: Color(0xff6976b6).withOpacity(0.62),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: Text(
                        "목표",
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                    child: TextField(
                      controller: _titleController,
                      maxLength: 10,
                      decoration: InputDecoration(
                        hintText: "자격증 따기",
                        hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5), fontSize: 20),
                        filled: true,
                        fillColor: Color(0xFF0A1C4C), // 배경색
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Color(0xFFFFCF39), // 포커스 시 보더 색상
                            width: 2.0, // 보더 두께
                          ),
                        ),
                        counterText: '',
                      ),
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: Text(
                        "목표 설명",
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                    child: TextField(
                      controller: _descriptionController,
                      maxLength: 100,
                      decoration: InputDecoration(
                        hintText: "정보 처리 기사 자격증따기",
                        hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5), fontSize: 20),
                        filled: true,
                        fillColor: Color(0xFF0A1C4C), // 배경색
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Color(0xFFFFCF39), // 포커스 시 보더 색상
                            width: 2.0, // 보더 두께
                          ),
                        ),
                        counterText: '',
                      ),
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: Text(
                        "기간 설정",
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF0A1C4C),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _isContainerFocused()
                              ? Color(0xFFFFCF39) // 포커스 시 노란색 보더
                              : Colors.transparent, // 기본 상태
                          width: 2.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context, true),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 12),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  "${DateFormat('yyyy/MM/dd').format(startDate)}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              "-",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context, false),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 12),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  "${DateFormat('yyyy/MM/dd').format(endDate)}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: Text(
                        "단계 설정",
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF0A1C4C),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: ToggleSwitch(
                        customTextStyles: [TextStyle(fontSize: 18)],
                        initialLabelIndex: 0,
                        totalSwitches: 3,
                        minWidth: 90.0,
                        minHeight: 40.0,
                        activeBgColor: [Color(0xff4b5ba5).withOpacity(0.8)],
                        activeFgColor: Colors.white,
                        inactiveBgColor: Color(0xff0a1c4c),
                        inactiveFgColor: Color(0xff27367b),
                        labels: ['3', '4', '5'],
                        // animate: true,
                        onToggle: (index) {
                          print('switched to: $index');
                          setState(() {
                            selectedStep = stepOptions[index!];
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  GestureDetector(
                    onTap: () async {
                      await postGalaxyData();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 190,
                      height: 60,
                      decoration: BoxDecoration(
                          color: Color(0xff0a1c4c),
                          borderRadius: BorderRadius.circular(15)),
                      child: Text(
                        "목표 생성",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DashboardPage()),
                      );
                    },
                    child: Container(
                      child: Text(
                        "skip",
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
