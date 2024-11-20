import 'dart:async';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:okay_life_app/pages/galaxy_page.dart';

class CreateGalaxyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CreateGalaxyPageState();
}

class _CreateGalaxyPageState extends State<CreateGalaxyPage> {
  late PageController _pageController;
  final List<Map<String, dynamic>> initialQuestions = [
    {'question': '너의 우주를 정복하기 위한\n작은 목표를 적어줘', 'inputType': 'textField'},
    {'question': '기간은 얼마나 생각하고 있어?', 'inputType': 'dateRangePicker'},
    {
      'question': '몇 단계로 나눠서\n달성하고 싶어?',
      'inputType': 'button',
      'options': ['3', '4', '5']
    }
  ];

  List<Map<String, dynamic>> questions = [];
  bool isLoading = false;
  String loadingText = "행성 생성을 위한\n추가 질문 생성 중";
  int dotCount = 1;
  late Timer _loadingTimer;
  Map<String, String> answers = {}; // 사용자의 답변 저장
  int? selectedIndex; // 버튼 상태를 추적
  List<DateTime?> selectedDates = []; // 날짜 선택값
  final int additionalQuestionsCount = 3; // 추가 질문 고정 개수

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    questions = List.from(initialQuestions);
    _startLoadingAnimation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _loadingTimer.cancel();
    super.dispose();
  }

  void _startLoadingAnimation() {
    _loadingTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        dotCount = (dotCount % 3) + 1; // 1, 2, 3 반복
      });
    });
  }

  Future<void> _useDummyQuestions() async {
    setState(() {
      isLoading = true;
    });

    // 로딩 시뮬레이션 및 추가 질문 생성
    await Future.delayed(Duration(seconds: 2));
    _loadingTimer.cancel();

    final dummyQuestions = [
      {'question': '좋아하는 행성은?', 'inputType': 'textField'},
      {'question': '하루 목표는?', 'inputType': 'textField'},
      {'question': '최종 목표는?', 'inputType': 'textField'},
    ];

    setState(() {
      isLoading = false;
      questions.addAll(dummyQuestions); // 추가 질문 추가
    });

    // 추가 질문 첫 페이지로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _pageController.jumpToPage(initialQuestions.length);
      }
    });
  }

  Future<void> _submitAnswers() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 백엔드로 데이터 전송
      final data = {
        'goal': answers[initialQuestions[0]['question']],
        'start_date': selectedDates.isNotEmpty && selectedDates[0] != null
            ? selectedDates[0]!.toIso8601String()
            : null,
        'end_date': selectedDates.isNotEmpty && selectedDates[1] != null
            ? selectedDates[1]!.toIso8601String()
            : null,
        'steps': answers[initialQuestions[2]['question']],
        'additional_info': answers,
      };

      print("보내는 데이터: $data");

      // TODO: 실제 API 호출
      // final response = await ApiClient.post('/submit-goal', data: data);
      // final galaxyData = response['galaxy'];

      // 더미 데이터 시뮬레이션
      final galaxyData = {
        'name': 'Milky Way',
        'stars': 300000000000,
        'description': '우리 은하수입니다.'
      };

      setState(() {
        isLoading = false;
      });

      if (!mounted) return;

      // GalaxyPage로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GalaxyPage(galaxyData: galaxyData),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("에러 발생: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("오류 발생"),
          content: Text("데이터 전송 중 문제가 발생했습니다. 다시 시도해주세요."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("확인"),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildLoadingWidget() {
    return Stack(
      children: [
        Center(
          child: Container(
            width: 350,
            height: 320,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xff6976b6).withOpacity(0.2)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$loadingText${'.' * dotCount}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
        Positioned(
          top: 550,
          left: 270,
          child: Hero(
            tag: 'devil',
            child: SvgPicture.asset(
              "assets/devil.svg",
              width: 150,
              height: 150,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingText(String text) {
    return TypingEffect(
      fullText: text,
      typingSpeed: Duration(milliseconds: 80),
    );
  }

  Widget _buildInputWidget(Map<String, dynamic> question) {
    switch (question['inputType']) {
      case 'textField':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: TextField(
            onChanged: (value) {
              answers[question['question']] = value;
            },
            maxLength: 30,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xff0a1c4c),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white, width: 2.0),
              ),
              counterText: '',
            ),
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        );

      case 'button':
        return Wrap(
          spacing: 10,
          children: List.generate(
            question['options'].length,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  answers[question['question']] = question['options'][index];
                  selectedIndex = index;
                });
              },
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? Colors.white.withOpacity(0.8)
                      : Color(0xff0a1c4c),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  question['options'][index],
                  style: TextStyle(
                    color: selectedIndex == index
                        ? Color(0xff0a1c4c)
                        : Colors.white.withOpacity(0.3),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );

      case 'dateRangePicker':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ElevatedButton(
            onPressed: () async {
              var results = await showCalendarDatePicker2Dialog(
                context: context,
                config: CalendarDatePicker2WithActionButtonsConfig(
                    calendarType: CalendarDatePicker2Type.range,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                    selectedDayHighlightColor:
                        Color(0xff0a1c4c).withOpacity(0.8),
                    selectedDayTextStyle: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                value: selectedDates,
                dialogSize: const Size(325, 400),
              );

              if (results != null && results.length == 2) {
                setState(() {
                  selectedDates = results;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff0a1c4c),
              foregroundColor: Colors.white.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              selectedDates.isNotEmpty &&
                      selectedDates[0] != null &&
                      selectedDates[1] != null
                  ? "${selectedDates[0]!.year}-${selectedDates[0]!.month}-${selectedDates[0]!.day} ~ ${selectedDates[1]!.year}-${selectedDates[1]!.month}-${selectedDates[1]!.day}"
                  : "기간 설정",
              style: TextStyle(fontSize: 18),
            ),
          ),
        );

      default:
        return Container();
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
          isLoading
              ? _buildLoadingWidget()
              : PageView.builder(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 350,
                            height: 320,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Color(0xff6976b6).withOpacity(0.2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTypingText(question['question']),
                                const SizedBox(height: 30),
                                _buildInputWidget(question),
                                const SizedBox(height: 30),
                                GestureDetector(
                                  onTap: () async {
                                    if (index == initialQuestions.length - 1) {
                                      // 초기 질문 끝나면 추가 질문 실행
                                      await _useDummyQuestions();
                                    } else if (index == questions.length - 1) {
                                      // 추가 질문 끝나면 갤럭시 페이지 이동
                                      await _submitAnswers();
                                    } else {
                                      // 다음 페이지로 이동
                                      _pageController.nextPage(
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Color(0xff0a1c4c),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.arrowtriangle_right_fill,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 550,
                          left: 270,
                          child: Hero(
                            tag: 'devil',
                            child: SvgPicture.asset(
                              "assets/devil.svg",
                              width: 150,
                              height: 150,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class TypingEffect extends StatefulWidget {
  final String fullText;
  final Duration typingSpeed;

  TypingEffect({
    required this.fullText,
    this.typingSpeed = const Duration(milliseconds: 100),
  });

  @override
  _TypingEffectState createState() => _TypingEffectState();
}

class _TypingEffectState extends State<TypingEffect> {
  String displayedText = "";
  int currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.typingSpeed, (timer) {
      if (currentIndex < widget.fullText.length) {
        setState(() {
          displayedText += widget.fullText[currentIndex];
          currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      displayedText,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }
}
