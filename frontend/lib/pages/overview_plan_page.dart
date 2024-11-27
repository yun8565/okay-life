import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:okay_life_app/api/api_client.dart';
import 'package:okay_life_app/pages/dashboard_page.dart';

class OverviewPlanPage extends StatelessWidget {
  final Map<String, dynamic> galaxyData;

  OverviewPlanPage({required this.galaxyData});

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
          Center(
            child: Container(
              width: 350,
              height: 500,
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xff6976b6).withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "이 계획은 어때?",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child:
                        _buildPlanetToggleList(context, galaxyData['planets']),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DashboardPage()),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Color(0xff0a1c4c),
                          borderRadius: BorderRadius.circular(15)),
                      child: Text(
                        "확정",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              top: 650,
              right: -30,
              child: Image.asset(
                "assets/lucky.png",
                width: 250,
              ))
        ],
      ),
    );
  }

  Widget _buildPlanetToggleList(BuildContext context, List<dynamic> planets) {
    return ListView.builder(
      itemCount: planets.length,
      itemBuilder: (context, index) {
        final planet = planets[index];
        return ExpansionTile(
          title: Row(
            children: [
              Text(
                "${planet['title']}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showEditDialog(
                  context,
                  "행성 수정",
                  planet['title'],
                  (newValue) =>
                      _updatePlanet(planet['planetId'], newValue, context),
                ),
                child: Icon(
                  CupertinoIcons.pencil,
                  color: Colors.white,
                  size: 17,
                ),
              )
            ],
          ),
          children: _buildMissionList(context, planet['missions']),
          tilePadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          backgroundColor: const Color(0xff0a1c4c),
          collapsedBackgroundColor: const Color(0xff0a1c4c),
          textColor: Colors.white,
          iconColor: Colors.white,
          collapsedTextColor: Colors.white70,
          collapsedIconColor: Colors.white70,
        );
      },
    );
  }

  List<Widget> _buildMissionList(BuildContext context, List<dynamic> missions) {
    return missions.map((mission) {
      return ListTile(
        title: Row(
          children: [
            Text(
              mission['content'],
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () => _showEditDialog(
                context,
                "미션 수정",
                mission['content'],
                (newValue) =>
                    _updateMission(mission['missionId'], newValue, context),
              ),
              child: Icon(
                CupertinoIcons.pencil,
                color: Colors.white,
                size: 17,
              ),
            )
          ],
        ),
        tileColor: const Color(0xff6976b6).withOpacity(0.3),
      );
    }).toList();
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String currentValue,
    Function(String) onSave,
  ) {
    final TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "새 값을 입력하세요"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: Text("저장"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePlanet(
      int planetId, String newTitle, BuildContext context) async {
    try {
      await ApiClient.put('/planets/$planetId', data: {'title': newTitle});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("행성 이름이 성공적으로 수정되었습니다!")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("행성 수정 중 오류 발생: $error")),
      );
    }
  }

  Future<void> _updateMission(
      int missionId, String newContent, BuildContext context) async {
    try {
      await ApiClient.put('/missions/$missionId',
          data: {'content': newContent});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("미션 내용이 성공적으로 수정되었습니다!")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("미션 수정 중 오류 발생: $error")),
      );
    }
  }
}
