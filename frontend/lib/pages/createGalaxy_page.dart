import 'dart:async';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:okay_life_app/api/api_client.dart';
import 'package:okay_life_app/pages/galaxy_page.dart';
import 'package:okay_life_app/pages/overview_plan_page.dart';

class CreateGalaxyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CreateGalaxyPageState();
}

class _CreateGalaxyPageState extends State<CreateGalaxyPage> {
  int currentQuestionIndex = 0;
  final TextEditingController goalController = TextEditingController();
  List<DateTime?> selectedDates = [];
  int selectedIndex = -1;
  final List<String?> selectedDay = [];
  bool isLoading = false;
  int currentPage = 0;
  int dotCount = 1; // 로딩 애니메이션 점 개수
  late Timer _loadingTimer;

  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();

    // PageController의 변화를 감지하여 현재 페이지를 업데이트
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.round(); // 현재 페이지를 추적
      });
    });
    _startLoadingAnimation();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  // 로딩 애니메이션 점 개수 조정
  void _startLoadingAnimation() {
    _loadingTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        dotCount = (dotCount % 3) + 1; // 1, 2, 3 반복
      });
    });
  }

  List<String> additionalQuestions = [];
  List<TextEditingController> additionalAnswers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/dashboard_bg.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 70,
            left: 10,
            child: IconButton(
              icon: Icon(
                CupertinoIcons.back,
                color: Colors.white60,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context); // 이전 화면으로 이동
              },
            ),
          ),
          Center(
            child: isLoading
                ? _buildLoadingPage() // 로딩 중일 때 로딩 화면 표시
                : additionalQuestions.isEmpty
                    ? _buildInitialQuestions() // 초기 질문 화면
                    : _buildAdditionalQuestions(), // 추가 질문 화면
          ),
          if (additionalQuestions.isEmpty)
            Positioned(
              top: 670,
              left: 250,
              child: Image.asset(
                "assets/lucky.png",
                width: 180,
                height: 180,
              ),
            ),
          if (additionalQuestions.isNotEmpty)
            Positioned(
              top: 560,
              left: 250,
              child: Image.asset(
                "assets/lucky.png",
                width: 180,
                height: 180,
              ),
            )
        ],
      ),
    );
  }

  Widget _buildLoadingPage() {
    return Container(
      width: 350,
      height: 350,
      decoration: BoxDecoration(
        color: Color(0xff6976b6).withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          "로딩 중 ${'.' * dotCount}",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildAdditionalQuestions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 70, bottom: 10),
          child: SizedBox(
            height: 30,
            width: 100,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: (currentPage + 2).toString(), // pageNum만 오퍼시티 100
                    style: TextStyle(
                      color: Colors.white, // 완전한 불투명 색상
                      fontSize: 24,
                      fontWeight: FontWeight.bold, // 필요한 경우 추가
                    ),
                  ),
                  TextSpan(
                    text: " / 4", // 나머지 텍스트
                    style: TextStyle(
                      color: Colors.white38, // 오퍼시티 38
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 360,
          width: 320,
          child: PageView.builder(
            controller: pageController,
            itemCount: additionalQuestions.length,
            physics: NeverScrollableScrollPhysics(), // 사용자 스크롤 방지
            itemBuilder: (context, index) {
              if (additionalAnswers.length < additionalQuestions.length) {
                // 텍스트 컨트롤러 추가 및 리스너 등록
                additionalAnswers.add(TextEditingController()
                  ..addListener(() {
                    setState(() {}); // 텍스트 변경 시 UI 업데이트
                  }));
              }
              return Container(
                decoration: BoxDecoration(
                  color: Color(0xff6976b6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 150,
                      width: 250,
                      child: Center(
                        child: TypingEffect(
                          fullText:
                              "한 가지 더 물어볼게\n${additionalQuestions[index]}",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: additionalAnswers[index],
                        maxLength: 100,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xff0a1c4c),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                BorderSide(color: Colors.white, width: 2.0),
                          ),
                          counterText: '',
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      textAlign: TextAlign.center,
                      "답변이 길고 자세할수록\n더욱 정확한 계획을 제공할 수 있습니다.",
                      style: TextStyle(color: Colors.white30, fontSize: 13),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        if (additionalAnswers[index].text.isNotEmpty) {
                          if (index < additionalQuestions.length - 1) {
                            pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _finishAdditionalQuestions(); // 추가 질문 완료 처리
                          }
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 30, bottom: 20),
                        alignment: Alignment.center,
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color(0xff0a1c4c),
                        ),
                        child: Text(
                          index < additionalQuestions.length - 1 ? "다음" : "완료",
                          style: TextStyle(
                            color: additionalAnswers[index].text.isNotEmpty
                                ? Colors.white // 텍스트 필드에 값이 있으면 하얀색
                                : Colors.white30, // 값이 없으면 회색
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInitialQuestions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: SizedBox(
            height: 30,
            width: 100,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "1", // pageNum만 오퍼시티 100
                    style: TextStyle(
                      color: Colors.white, // 완전한 불투명 색상
                      fontSize: 24,
                      fontWeight: FontWeight.bold, // 필요한 경우 추가
                    ),
                  ),
                  TextSpan(
                    text: " / 4", // 나머지 텍스트
                    style: TextStyle(
                      color: Colors.white38, // 오퍼시티 38
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 350,
          height: 620,
          decoration: BoxDecoration(
            color: Color(0xff6976b6).withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (currentQuestionIndex >= 0)
                _buildQuestion(
                  "우주를 정복하기 위한 작은 목표를 적어줘",
                  _buildGoalInput(),
                  0,
                ),
              if (currentQuestionIndex >= 1)
                _buildQuestion(
                  "기간은 얼마나 생각하고 있어?",
                  _buildDatePicker(),
                  1,
                ),
              if (currentQuestionIndex >= 2)
                _buildQuestion(
                  "몇 단계로 나눠서 이루고 싶어?",
                  _buildStepButtons(),
                  2,
                ),
              if (currentQuestionIndex >= 3)
                _buildQuestion(
                  "언제 실행하고 싶어?",
                  _buildDayButtons(),
                  3,
                ),
              if (currentQuestionIndex >= 3)
                GestureDetector(
                  onTap: _canProceed()
                      ? () {
                          _submitInitialData(); // 초기 데이터 제출 및 추가 질문 활성화
                        }
                      : null,
                  child: Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color(0xff0a1c4c),
                    ),
                    child: Text(
                      "다음",
                      style: TextStyle(
                          color: _canProceed() ? Colors.white : Colors.white30,
                          fontSize: 20),
                    ),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion(String question, Widget child, int index) {
    return AnimatedOpacity(
      opacity: currentQuestionIndex >= index ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: Visibility(
        visible: currentQuestionIndex >= index,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                question,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 10),
              child,
            ],
          ),
        ),
        replacement: SizedBox(height: 70),
      ),
    );
  }

  Widget _buildGoalInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: goalController,
        maxLength: 30,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xff0a1c4c),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.white, width: 2.0)),
          counterText: '',
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        onSubmitted: (_) {
          setState(() {
            currentQuestionIndex++;
          });
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return ElevatedButton(
      onPressed: () async {
        var results = await showCalendarDatePicker2Dialog(
            context: context,
            config: CalendarDatePicker2WithActionButtonsConfig(
                calendarType: CalendarDatePicker2Type.range,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 90)),
                selectedDayHighlightColor: Color(0xff0a1c4c).withOpacity(0.8),
                selectedDayTextStyle: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            value: selectedDates,
            dialogSize: Size(325, 400));
        if (results != null && results.length == 2) {
          setState(() {
            selectedDates = results;
          });
        }
        setState(() {
          currentQuestionIndex++;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xff0a1c4c),
        foregroundColor: Colors.white.withOpacity(0.8),
        padding: EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        selectedDates.isNotEmpty
            ? "${selectedDates[0]!.year}-${selectedDates[0]!.month}-${selectedDates[0]!.day} ~ ${selectedDates[1]!.year}-${selectedDates[1]!.month}-${selectedDates[1]!.day}"
            : "기간 설정",
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildStepButtons() {
    return Wrap(
      spacing: 10,
      children: [3, 4, 5].map((step) {
        final isSelected = selectedIndex == step; // 선택 여부 확인
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = step;
              currentQuestionIndex++;
            });
          },
          child: Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: isSelected
                  ? Colors.white.withOpacity(0.8)
                  : Color(0xff0a1c4c),
            ),
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isSelected
                    ? Color(0xff0a1c4c)
                    : Colors.white.withOpacity(0.3),
                fontSize: 18,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayButtons() {
    return Wrap(
      spacing: 10,
      children: ["월", "화", "수", "목", "금", "토", "일"].map((day) {
        final isSelected = selectedDay.contains(day); // 현재 버튼의 선택 상태 확인
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedDay.remove(day); // 선택된 상태라면 리스트에서 제거
              } else {
                selectedDay.add(day); // 선택되지 않은 상태라면 리스트에 추가
              }
            });
          },
          child: Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: isSelected
                  ? Colors.white.withOpacity(0.8)
                  : Color(0xff0a1c4c), // 선택 여부에 따라 색상 변경
            ),
            child: Text(
              day,
              style: TextStyle(
                color: isSelected
                    ? Color(0xff0a1c4c)
                    : Colors.white.withOpacity(0.3), // 선택 여부에 따라 텍스트 색상 변경
                fontSize: 18,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _canProceed() {
    return goalController.text.isNotEmpty &&
        selectedDates.length == 2 &&
        selectedIndex != null &&
        selectedDay.isNotEmpty;
  }

  // 초기 데이터 제출
  Future<void> _submitInitialData() async {
    setState(() {
      isLoading = true; // 로딩 상태 활성화
    });

    try {
      // 초기 질문 데이터를 저장
      final initialData = {
        "title": goalController.text,
        "startDate": selectedDates.isNotEmpty
            ? "${selectedDates[0]!.year}-${selectedDates[0]!.month.toString().padLeft(2, '0')}-${selectedDates[0]!.day.toString().padLeft(2, '0')}"
            : "",
        "endDate": selectedDates.length > 1
            ? "${selectedDates[1]!.year}-${selectedDates[1]!.month.toString().padLeft(2, '0')}-${selectedDates[1]!.day.toString().padLeft(2, '0')}"
            : "",
        "step": selectedIndex,
        "days": selectedDay,
      };

      print(initialData["title"]);
      print(initialData["startDate"]);
      print(initialData["endDate"]);

      print(await ApiClient.getJwt());

      // 목표만 /chat/question으로 전송
      final response = await ApiClient.post(
        '/chat/question',
        data: {
          "goal": initialData["title"],
          "startDate": initialData["startDate"],
          "endDate": initialData["endDate"]
        },
      );

      // 응답에서 추가 질문 가져오기
      if (response != null && response['three'] != null) {
        setState(() {
          additionalQuestions = List<String>.from(response['three']);
          isLoading = false; // 로딩 상태 비활성화
        });
      } else {
        throw Exception("Invalid response format");
      }
    } catch (error) {
      setState(() {
        isLoading = false; // 로딩 상태 비활성화
      });

      // 에러 처리
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("추가 질문을 가져오지 못했습니다: $error"),
      //   ),
      // );
    }
  }

  void _finishAdditionalQuestions() async {
    setState(() {
      isLoading = true; // 로딩 상태 활성화
    });

    try {
      final allData = {
        "title": goalController.text,
        "startDate": selectedDates.isNotEmpty
            ? "${selectedDates[0]!.year}-${selectedDates[0]!.month.toString().padLeft(2, '0')}-${selectedDates[0]!.day.toString().padLeft(2, '0')}"
            : "",
        "endDate": selectedDates.length > 1
            ? "${selectedDates[1]!.year}-${selectedDates[1]!.month.toString().padLeft(2, '0')}-${selectedDates[1]!.day.toString().padLeft(2, '0')}"
            : "",
        "step": selectedIndex,
        "days": selectedDay,
        "answers": List.generate(
          additionalQuestions.length,
          (index) => {
            "question": additionalQuestions[index],
            "answer": additionalAnswers[index].text,
          },
        ),
      };
      print("Sending data to /chat/plan: $allData");

      final response = await ApiClient.postWithHeaders(
        '/chat/plan',
        data: allData,
      );

      print("Received response: ${response.statusCode}");
      print("Response headers: ${response.headers}");
      print("Response data: ${response.data}");

      final locationHeader = response.headers['location']?.first;
      print("Extracted Location header: $locationHeader");

      if (locationHeader != null) {
        final galaxyId = _extractGalaxyIdFromLocation(locationHeader);
        print("Extracted Galaxy ID: $galaxyId");

        if (galaxyId != null) {
          final galaxyData = await ApiClient.get('/galaxies/$galaxyId');
          print("Galaxy data: $galaxyData");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OverviewPlanPage(galaxyData: galaxyData),
            ),
          );
        } else {
          throw Exception("galaxyId is null");
        }
      } else {
        throw Exception("Location header is missing");
      }
    } catch (error) {
      print("Error occurred: $error");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("데이터 처리 중 오류가 발생했습니다: $error")),
      // );
    }
  }

  /// Location 헤더에서 galaxyId 추출
  String? _extractGalaxyIdFromLocation(String locationHeader) {
    final uri = Uri.tryParse(locationHeader);
    if (uri != null) {
      // URI의 path에서 galaxyId 추출 (예: /some/path/{galaxyId})
      final segments = uri.pathSegments;
      return segments.isNotEmpty ? segments.last : null;
    }
    return null;
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
