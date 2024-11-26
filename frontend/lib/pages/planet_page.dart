import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  String title;
  bool complete;

  Event(this.title, this.complete);

  @override
  String toString() => title;
}

class PlanetPage extends StatefulWidget {
  final bool isFirst;
  final bool isLast;

  PlanetPage({Key? key, required this.isFirst, required this.isLast})
      : super(key: key);

  @override
  _PlanetPageState createState() => _PlanetPageState();
}

class _PlanetPageState extends State<PlanetPage> {
  final Map<DateTime, Event> eventSource = {
    DateTime(2024, 11, 26): Event('구독자 분석하기', true),
    DateTime(2024, 11, 28): Event('영상 업로드하기', false),
    DateTime(2024, 11, 30): Event('주제 아이디에이션', false),
  };

  late final LinkedHashMap<DateTime, Event> events = LinkedHashMap(
    equals: isSameDay,
  )..addAll(eventSource);

  Event? getEventForDay(DateTime day) {
    return events.entries
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.arrowtriangle_left_fill,
                    color: widget.isFirst
                        ? Colors.white.withOpacity(0.15)
                        : Colors.white.withOpacity(0.8),
                  ),
                  SizedBox(width: 20),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "비숑 ",
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
                  Icon(
                    CupertinoIcons.arrowtriangle_right_fill,
                    color: widget.isLast
                        ? Colors.white.withOpacity(0.15)
                        : Colors.white.withOpacity(0.8),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Calendar Section
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
              Text(
                "Today",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              todayEvent != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              todayEvent.complete = !todayEvent.complete;
                            });
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
                              )),
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
              SizedBox(
                height: 20,
              ),
            ],
          ),

          // Draggable Scrollable Sheet Section
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
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: events.entries.map((entry) {
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
                                    if (entry.key != events.keys.last)
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
