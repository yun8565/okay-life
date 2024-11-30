import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:okay_life_app/api/api_client.dart';

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  List<Map<String, dynamic>> reviews = []; // 리뷰 데이터를 저장할 리스트
  bool isLoading = true; // 로딩 상태 표시

  @override
  void initState() {
    super.initState();
    fetchReviews(); // 데이터 가져오기
  }

  Future<void> fetchReviews() async {
    try {
      // /reviews POST 요청 보내기
      final response = await ApiClient.get('/reviews');

      // 응답 데이터 파싱 및 상태 업데이트
      setState(() {
        reviews = List<Map<String, dynamic>>.from(response); // 리스트로 변환
        isLoading = false; // 로딩 상태 종료
      });
    } catch (error) {
      print("Error fetching reviews: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("리뷰 데이터를 가져오지 못했습니다.")),
      );
    }
  }

  //? 더미 데이터
  // Future<void> fetchReviews() async {
  //   try {
  //     // 더미 데이터
  //     final dummyResponse = [
  //       {
  //         "planetId": 1,
  //         "title": "첫 번째 행성",
  //         "planetThemeName": "candy",
  //         "status": "CLEAR"
  //       },
  //       {
  //         "planetId": 2,
  //         "title": "두 번째 행성",
  //         "planetThemeName": "bichon",
  //         "status": "FAILED"
  //       },
  //       {
  //         "planetId": 3,
  //         "title": "세 번째 행성",
  //         "planetThemeName": "chocolate",
  //         "status": "CLEAR"
  //       }
  //     ];

  //     // 더미 데이터를 리스트에 추가
  //     setState(() {
  //       reviews = List<Map<String, dynamic>>.from(dummyResponse); // 리스트로 변환
  //       isLoading = false; // 로딩 상태 종료
  //     });
  //   } catch (error) {
  //     print("Error fetching reviews: $error");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("리뷰 데이터를 가져오지 못했습니다.")),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset(
            "assets/dashboard_bg.png",
            fit: BoxFit.cover,
          )),
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
          isLoading
              ? Center(child: CircularProgressIndicator()) // 로딩 상태 표시
              : reviews.isEmpty
                  ? Center(
                      child: Text(
                        '리뷰 데이터가 없습니다.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 130),
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailReviewPage(
                                            planetId: review['planetId'])));
                              },
                              child: ReviewContainer(
                                  review: review)); // 컨테이너 위젯 호출
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}

class ReviewContainer extends StatelessWidget {
  final Map<String, dynamic> review;

  const ReviewContainer({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = review['title'] ?? '제목 없음';
    final String planetThemeName = review['planetThemeName'] ?? '기본';
    final String status = review['status'] ?? 'UNKNOWN';

    // 테마에 따른 아이콘
    final String imageAsset = 'assets/${planetThemeName}.png';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff0A1C4C),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 16),
          ColorFiltered(
            colorFilter: status == 'FAILED'
                ? const ColorFilter.matrix(<double>[
                    0.2126, 0.7152, 0.0722, 0, 0, // Red
                    0.2126, 0.7152, 0.0722, 0, 0, // Green
                    0.2126, 0.7152, 0.0722, 0, 0, // Blue
                    0, 0, 0, 1, 0, // Alpha
                  ])
                : const ColorFilter.mode(
                    Colors.transparent, // CLEAR 상태면 이미지 그대로
                    BlendMode.dst,
                  ),
            child: Image.asset(
              imageAsset,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailReviewPage extends StatefulWidget {
  final int planetId;

  const DetailReviewPage({Key? key, required this.planetId}) : super(key: key);

  @override
  _DetailReviewPageState createState() => _DetailReviewPageState();
}

class _DetailReviewPageState extends State<DetailReviewPage> {
  Map<String, dynamic>? reviewDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetailReview();
  }

  Future<void> fetchDetailReview() async {
    try {
      final response = await ApiClient.get('/reviews/${widget.planetId}');
      setState(() {
        reviewDetail = response; // 상세 데이터 저장
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching detail review: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("상세 데이터를 가져오지 못했습니다.")),
      );
    }
  }

  //? 더미 데이터
  // Future<void> fetchDetailReview() async {
  //   try {
  //     // 더미 데이터
  //     final dummyDetailResponse = {
  //       "planetTitle": "행성이름행성이름행성이름",
  //       "keep":
  //           "목표 달성 기간동안 잘했다고 생각했던 점을 적어보세요. 텍스트가 매우 길 수도 있습니다. 잘했다고 생각했던 점이 있다면 추가로 적어주세요.",
  //       "problem": "너무 잘해서 고칠 게 없어요.",
  //       "try":
  //           "모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험모험"
  //     };

  //     setState(() {
  //       reviewDetail = dummyDetailResponse;
  //       isLoading = false;
  //     });
  //   } catch (error) {
  //     print("Error fetching detail review: $error");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 배경색 제거
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset("assets/dashboard_bg.png", fit: BoxFit.cover)),
          Positioned(
            top: 80,
            left: 10,
            child: IconButton(
              icon: Icon(
                CupertinoIcons.back,
                color: Colors.white60,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reviewDetail?['planetTitle'] ?? '행성 제목 없음',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildReviewCard(
                            title: "Keep",
                            question: "목표 달성 기간동안\n잘했다고 생각했던 점이 있어?",
                            content: reviewDetail?["keep"],
                          ),
                          SizedBox(height: 20),
                          _buildReviewCard(
                            title: "Problem",
                            question: "목표 달성 기간동안 개선이 필요하다고\n생각했던 점이 있어?",
                            content: reviewDetail?["problem"],
                          ),
                          SizedBox(height: 20),
                          _buildReviewCard(
                            title: "Try",
                            question: "다음에는 달성률을 높이기 위해\n어떤 시도를 해볼 수 있을까?",
                            content: reviewDetail?["try"],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String title,
    required String question,
    required String? content,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xff566181),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            question,
            style: TextStyle(
              color: Color(0xff1F2E5C),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          Text(
            content ?? '',
            style: TextStyle(
              color: Color(0xff566181),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
