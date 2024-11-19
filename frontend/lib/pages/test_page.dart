import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:okay_life_app/pages/createGalaxy_page.dart';

class ProgressBar extends StatelessWidget {
  final int totalQuestions;
  final int currentQuestion;

  const ProgressBar({
    required this.totalQuestions,
    required this.currentQuestion,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = currentQuestion / totalQuestions;

    return Container(
      margin: EdgeInsets.only(top: 200),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            height: 30,
            width: MediaQuery.of(context).size.width - 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            width: (MediaQuery.of(context).size.width - 60) * progress,
            height: 20,
            margin: EdgeInsets.only(top: 5, left: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Color(0xff16205e),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            left: (MediaQuery.of(context).size.width - 60) * progress - 30,
            top: -25,
            child: Image.asset(
              'assets/rocket.png',
              width: 80,
              height: 80,
            ),
          ),
        ],
      ),
    );
  }
}

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final int totalQuestions = 12;
  final PageController _pageController = PageController();
  int currentQuestion = 1;
  int? selectedOptionIndex; // 선택된 답변의 인덱스
  bool isResultPage = false;

  // 성향별 점수
  int lazinessScore = 0; // 게으름/부지런함
  int judgingScore = 0; // 판단형/인식형
  int intrinsicScore = 0; // 내재적/외재적 동기

  final List<Map<String, dynamic>> questionData = [
    {
      "question": "나의 우주를 더럽히는 우주 쓰레기, \n미루지 않고 바로 바로 \n처리하는 편이다.",
      "type": "laziness",
      "options": ["당장 처리해야지!", "가능하면 해야지!", "글쎄..", "조금만 미룰래..", "나중에 해도 되겠지"]
    },
    {
      "question": "우주 탐사 하루 전 날, \n놓친 것들이 없는지 \n꼼꼼히 확인해야 \n마음이 편하다.",
      "type": "laziness",
      "options": [
        "꼼꼼하지 않으면 불안해",
        "안하는 것보단 낫지!",
        "그냥저냥..",
        "내일 봐도 되지 않을까?",
        "출발 전에만 보면 돼!"
      ]
    },
    {
      "question": "달나라 여행을 떠나기 전,\n미리 준비하고 계획을 세우는 것을\n선호한다.",
      "type": "laziness",
      "options": [
        "모든 일에 대비해둬야지!",
        "안하는 것보단 낫지!",
        "그런가..",
        "무슨 계획을 해야할 지..",
        "흐름에 나를 맡긴다.."
      ]
    },
    {
      "question": "나의 우주선에 먼지가 붙었다.\n당장 닦지 않으면 불편함을 느낀다.",
      "type": "laziness",
      "options": ["으.. 불편해", "살짝 거슬려", "이거 뭐야", "뭐가 묻긴 했네?", "묻을 수도 있지~"]
    },
    {
      "question": "우주 탐사 계획을 정확히\n관리하며 진행하는 것이 좋다.",
      "type": "judging",
      "options": [
        "계획을 지켜가며 확실하게!",
        "우선순위만 지켜도 좋아",
        "계획이 있긴 한데..",
        "계획보단 나만의 우선순위로!",
        "지금부터 뭐하지.."
      ]
    },
    {
      "question": "달나라 여행 일정이 바뀌어도\n잘 적응하는 편이다.",
      "type": "judging",
      "options": [
        "일정은 바뀌는게 맛",
        "바뀐 것도 재밌긴 한데?",
        "흠..",
        "원래 계획이 더 좋긴 한데",
        "진짜 싫어.."
      ]
    },
    {
      "question": "행성 탐사 기한이 있다면,\n미리 준비해두어야 마음이 편하다.",
      "type": "judging",
      "options": [
        "기한이 언젠지 분 단위로!",
        "이 날짜까지만 마치면!",
        "기한이 있네?",
        "기한 하루 전 날인데?",
        "기한이 지났네! 망했다!"
      ]
    },
    {
      "question": "예상치 못한 소행성 충돌이 발생해도\n유연하게 대응할 수 있다.",
      "type": "judging",
      "options": [
        "소행성 친구, 안녕~",
        "소행성이 부딪힐 줄이야",
        "이제 어떡하지..",
        "내가 준비 못한 탓인가..?",
        "난 이제 망할거야 끝이야.."
      ]
    },
    {
      "question": "우주 임무가 내게 의미있거나\n특별할 때 더 열정적으로 임하게 된다.",
      "type": "intrinsic",
      "options": [
        "의미있는게 제일 중요하지!",
        "열정의 동기라고는 느껴",
        "그런 것 같기도?",
        "둘은 별개 아닐까?",
        "우선 순위는 따로 있는 것!"
      ]
    },
    {
      "question": "우주 동료들이 나를 인정하거나\n칭찬할 때 더 힘이 난다",
      "type": "intrinsic",
      "options": [
        "나를 응원해주네..? 더 열심히!",
        "어깨가 으쓱!",
        "칭찬받으면 좋긴 해",
        "내가 열심히 하니까 받는 것 뿐",
        "인정하라고 하는거 아니거든"
      ]
    },
    {
      "question": "나만의 우주 탐사 목표를 세우고,\n그 과정을 즐길 때 만족감을 느낀다.",
      "type": "intrinsic",
      "options": [
        "하나하나 따라가는게 재밌어!",
        "나도 즐기려고 노력해!",
        "목표는 있긴 한데..",
        "목표가 있지만 버거워..",
        "이걸 어떻게 즐기란거야?"
      ]
    },
    {
      "question": "우주 탐사가 끝나고 보상으로\n특별한 메달이나 평가가 주어질 때\n더 동기부여가 된다.",
      "type": "intrinsic",
      "options": [
        "얼른 좋은 결과를 얻고 싶어!",
        "보상이 뭘까?",
        "좋은게 좋은 거지",
        "보상은 좋지만 힘들어..",
        "보상 필요없어!"
      ]
    },
  ];

  void _nextQuestion(String type, int score) {
    if (type == "laziness") {
      lazinessScore += score;
    } else if (type == "judging") {
      judgingScore += score;
    } else if (type == "intrinsic") {
      intrinsicScore += score;
    }

    if (currentQuestion < totalQuestions) {
      setState(() {
        currentQuestion++;
        selectedOptionIndex = null; // 선택 상태 초기화
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() {
        isResultPage = true; // 결과 페이지로 전환
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _getResult() {
    String lazinessType = lazinessScore <= 5 ? "게으른" : "부지런한";
    String judgingType = judgingScore <= 5 ? "인식형" : "판단형";
    String intrinsicType = intrinsicScore <= 5 ? "외재적 동기" : "내재적 동기";

    return "$lazinessType $judgingType $intrinsicType";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            if (!isResultPage)
              ProgressBar(
                totalQuestions: totalQuestions,
                currentQuestion: currentQuestion,
              ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                itemCount: questionData.length + 1, // 질문 + 결과 페이지
                itemBuilder: (context, index) {
                  if (index < questionData.length) {
                    return _buildQuestionPage(
                      questionData[index]["question"],
                      questionData[index]["type"],
                      questionData[index]["options"],
                    );
                  } else {
                    return _buildResultPage(); // 결과 페이지 표시
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPage(
      String question, String type, List<String> options) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Q$currentQuestion",
          style: TextStyle(
              fontSize: 40, fontWeight: FontWeight.w500, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Text(
          question,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        ...options.asMap().entries.map((entry) {
          int index = entry.key;
          String option = entry.value;

          bool isSelected = selectedOptionIndex == index; // 선택 여부 확인

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedOptionIndex = index; // 선택된 옵션 인덱스 저장
              });
              Future.delayed(Duration(milliseconds: 300),
                  () => _nextQuestion(type, 4 - index)); // 다음 질문으로 이동
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(vertical: 10),
              width: 280,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isSelected
                    ? Colors.white.withOpacity(1.0) // 선택 시 불투명
                    : Colors.white.withOpacity(0.5), // 기본 상태 반투명
              ),
              child: Text(
                option,
                style: TextStyle(color: Color(0xff0A1C4C), fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildResultPage() {
    String result = _getResult();
    return Stack(
      children: [
        Positioned(
          top: 230,
          left: 0,
          right: 0,
          child: Container(
            height: MediaQuery.of(context).size.height - 230,
            decoration: BoxDecoration(
              color: Color(0xffEBEBEB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 250),
                  child: Center(
                    child: Text(
                      "$result",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff16205e),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => CreateGalaxyPage(result: result)),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 40),
                    alignment: Alignment.center,
                    width: 180,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xff0A1C4C)),
                    child: Text(
                      "시작하기",
                      style: TextStyle(color: Colors.white, fontSize: 28),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Positioned(
          top: 90,
          left: 0,
          right: 0,
          child: SvgPicture.asset(
            "assets/mascot.svg",
            width: 280,
          ),
        ),
      ],
    );
  }
}
