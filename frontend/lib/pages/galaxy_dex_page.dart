import 'package:flutter/material.dart';
import 'package:okay_life_app/api/api_client.dart';

enum ThemeStatus { ACQUIRED, DISCOVERED, HIDDEN }

class PlanetTheme {
  final String name;
  final ThemeStatus status;

  PlanetTheme({
    required this.name,
    required this.status,
  });

  // JSON 데이터를 객체로 변환
  factory PlanetTheme.fromJson(Map<String, dynamic> json) {
    return PlanetTheme(
      name: json['name'],
      status: ThemeStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
    );
  }
}

class GalaxyTheme {
  final String name;
  final List<PlanetTheme> planetThemes;

  GalaxyTheme({
    required this.name,
    required this.planetThemes,
  });

  // JSON 데이터를 객체로 변환
  factory GalaxyTheme.fromJson(Map<String, dynamic> json) {
    return GalaxyTheme(
      name: json['name'],
      planetThemes: (json['planetThemeList'] as List)
          .map((planet) => PlanetTheme.fromJson(planet))
          .toList(),
    );
  }
}

class CollectionPage extends StatefulWidget {
  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  late Future<List<GalaxyTheme>> _galaxies;

  @override
  void initState() {
    super.initState();
    _galaxies = fetchGalaxyThemes();
  }

  Future<List<GalaxyTheme>> fetchGalaxyThemes() async {
    try {
      final response = await ApiClient.get('/collections');
      final data = response as List;
      return data.map((json) => GalaxyTheme.fromJson(json)).toList();
    } catch (error) {
      print("Error fetching galaxy themes: $error");
      throw Exception("Failed to load galaxy themes");
    }
  }

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
          Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "은하수 도감",
                style: TextStyle(
                  fontFamily: "Open Sans",
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<GalaxyTheme>>(
                  future: _galaxies,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "데이터를 불러오지 못했습니다.",
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "도감 데이터가 없습니다.",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      );
                    }

                    final galaxies = snapshot.data!;

                    return ListView.builder(
                      itemCount: galaxies.length,
                      itemBuilder: (context, index) {
                        final galaxy = galaxies[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(105, 118, 182, 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                galaxy.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: galaxy.planetThemes.length,
                                itemBuilder: (context, index) {
                                  final planet = galaxy.planetThemes[index];
                                  return ColorFiltered(
                                    colorFilter: planet.status ==
                                            ThemeStatus.DISCOVERED
                                        ? const ColorFilter.matrix(<double>[
                                            0.2126, 0.7152, 0.0722, 0, 0, // Red channel
                                            0.2126, 0.7152, 0.0722, 0, 0, // Green channel
                                            0.2126, 0.7152, 0.0722, 0, 0, // Blue channel
                                            0, 0, 0, 1, 0, // Alpha channel
                                          ])
                                        : const ColorFilter.mode(
                                            Colors.transparent,
                                            BlendMode.dst,
                                          ),
                                    child: Image.asset(
                                      planet.status == ThemeStatus.HIDDEN
                                          ? "assets/hiddenPlanet.png"
                                          : "assets/planets/${planet.name}.png",
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}