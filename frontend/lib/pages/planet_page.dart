import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:okay_life_app/api/api_client.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  String title;
  bool complete;
  int missionId;

  Event(this.title, this.complete, this.missionId);

  @override
  String toString() => title;
}

class PlanetPage extends StatefulWidget {
  final bool isFirst;
  final bool isLast;
  final int planetId;
  final Map<String, dynamic>? galaxyData;

  PlanetPage({
    Key? key,
    required this.isFirst,
    required this.isLast,
    required this.planetId,
    required this.galaxyData,
  }) : super(key: key);

  @override
  _PlanetPageState createState() => _PlanetPageState();
}

class _PlanetPageState extends State<PlanetPage> {
  late final String planetTitle;
  late final List<dynamic> missions; // 실제 미션 데이터
  late final List<dynamic> planets; // 전체 행성 리스트
  late final String status;
  final Map<DateTime, Event> eventSource = {};

  @override
  void initState() {
    super.initState();
    planets = widget.galaxyData?['planets'];
    _initializePlanetData();
    _initializeEventSource();
  }

  // 현재 행성 데이터 초기화
  void _initializePlanetData() {
    final planet = planets.firstWhere((p) => p['planetId'] == widget.planetId);

    planetTitle = planet['title']; // 행성 이름
    missions = planet['missions']; // 행성에 포함된 미션 리스트
    status = planet['status']; //
  }

  // 미션 데이터를 Event 형태로 변환하여 캘린더에 반영
  void _initializeEventSource() {
    eventSource.clear();
    for (final mission in missions) {
      final DateTime missionDate = DateTime.parse(mission['date']);
      final bool isComplete = mission['status'] == 'CLEAR';
      final int missionId = mission['missionId'];
      eventSource[missionDate] =
          Event(mission['content'], isComplete, missionId);
    }
  }

  // 미션 상태 업데이트
  Future<void> _updateMissionStatus(Event event) async {
  try {
    // POST 요청으로 미션 상태 업데이트
    await ApiClient.post(
      '/missions/${event.missionId}/status',
      data: {'status': event.complete ? 'FAILED' : 'CLEAR'}, // 상태 반전
    );

    // 요청 성공 시 상태 업데이트
    setState(() {
      event.complete = !event.complete; // 완료 상태 반전
      // 특정 이벤트만 eventSource에서 갱신
      final DateTime? missionDate = eventSource.keys.firstWhere(
        (date) => eventSource[date]?.missionId == event.missionId,
        orElse: () => DateTime.now(),
      );
      if (missionDate != null) {
        eventSource[missionDate] = Event(
          event.title,
          event.complete,
          event.missionId,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("미션 상태가 성공적으로 업데이트되었습니다!"),
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    print('미션 상태 업데이트 실패: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("미션 상태 업데이트 실패")),
    );
  }
}

  // 다음 행성으로 이동
  void _moveToNextPlanet() {
    final currentIndex =
        planets.indexWhere((p) => p['planetId'] == widget.planetId);
    if (currentIndex < planets.length - 1) {
      final nextPlanet = planets[currentIndex + 1];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PlanetPage(
            isFirst: currentIndex + 1 == 0,
            isLast: currentIndex + 1 == planets.length - 1,
            planetId: nextPlanet['planetId'],
            galaxyData: widget.galaxyData,
          ),
        ),
      );
    }
  }

  // 이전 행성으로 이동
  void _moveToPreviousPlanet() {
    final currentIndex =
        planets.indexWhere((p) => p['planetId'] == widget.planetId);
    if (currentIndex > 0) {
      final previousPlanet = planets[currentIndex - 1];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PlanetPage(
            isFirst: currentIndex - 1 == 0,
            isLast: currentIndex - 1 == planets.length - 1,
            planetId: previousPlanet['planetId'],
            galaxyData: widget.galaxyData,
          ),
        ),
      );
    }
  }

  Event? getEventForDay(DateTime day) {
    return eventSource.entries
        .where((entry) => isSameDay(entry.key, day))
        .map((entry) => entry.value)
        .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    Event? todayEvent = getEventForDay(today);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/background.png",
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
              // 헤더 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _moveToPreviousPlanet,
                    child: Icon(
                      CupertinoIcons.arrowtriangle_left_fill,
                      color: widget.isFirst
                          ? Colors.white.withOpacity(0.15)
                          : Colors.white.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(width: 20),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: status != "SOON" ? "$planetTitle " : "? ",
                          style: TextStyle(
                            color: Color(0xFFffcf39),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        TextSpan(
                          text: "행성",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: _moveToNextPlanet,
                    child: Icon(
                      CupertinoIcons.arrowtriangle_right_fill,
                      color: widget.isLast
                          ? Colors.white.withOpacity(0.15)
                          : Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // 캘린더 섹션
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xff6976b6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TableCalendar(
                  focusedDay: today,
                  firstDay: today.subtract(Duration(days: 365)),
                  lastDay: today.add(Duration(days: 365)),
                  daysOfWeekHeight: 30,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    dowBuilder: (context, day) {
                      final days = ['일', '월', '화', '수', '목', '금', '토'];
                      return Center(
                        child: Text(
                          days[day.weekday % 7],
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                    markerBuilder: (context, date, events) {
                      final event = getEventForDay(date);
                      if (event != null) {
                        return Positioned(
                          bottom: 3,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: event.complete
                                  ? Color(0xffffcf39)
                                  : Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle:
                        TextStyle(color: Colors.white.withOpacity(0.3)),
                    weekendTextStyle:
                        TextStyle(color: Colors.white.withOpacity(0.3)),
                    outsideDaysVisible: false,
                    todayDecoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  eventLoader: (day) =>
                      getEventForDay(day) != null ? [getEventForDay(day)!] : [],
                ),
              ),
              SizedBox(height: 20),

              // 오늘의 이벤트 섹션
              Text(
                "Today",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              todayEvent != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _updateMissionStatus(todayEvent);
                            setState(() {});
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: todayEvent.complete
                                  ? Color(0xff6976b6)
                                  : Colors.white,
                              border: Border.all(
                                color: todayEvent.complete
                                    ? Color(0xff6976b6)
                                    : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: todayEvent.complete
                                  ? Colors.white
                                  : Color(0xff0a1c4c),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          todayEvent.title,
                          style: TextStyle(
                            fontSize: 20,
                            color: todayEvent.complete
                                ? Colors.white.withOpacity(0.3)
                                : Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      "휴식",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
              SizedBox(height: 20),
            ],
          ),

          // Timeline 섹션
          DraggableScrollableSheet(
            initialChildSize: 0.1,
            minChildSize: 0.1,
            maxChildSize: 0.6,
            snap: true,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Color(0xff1d2e61),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Text(
                          "Timeline",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: eventSource.entries.map((entry) {
                          final date = entry.key;
                          final event = entry.value;
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 50.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (entry.key != eventSource.keys.last)
                                      Container(
                                        width: 2,
                                        height: 80,
                                        color: Colors.white,
                                      ),
                                  ],
                                ),
                                SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${date.month}월 ${date.day}일",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      event.title,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
