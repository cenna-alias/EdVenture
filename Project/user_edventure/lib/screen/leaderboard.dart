import 'package:flutter/material.dart';
import 'package:user_edventure/main.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> overallData = [];
  List<dynamic> mcqData = [];
  List<dynamic> tfData = [];
  List<dynamic> fillData = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    try {
      final response = await supabase
          .from('tbl_game')
          .select('*, tbl_user(*), tbl_level(*), tbl_subject(*)')
          .order('game_score', ascending: false);

      Map<String, Map<String, dynamic>> overallAgg = {};
      Map<String, Map<String, dynamic>> mcqAgg = {};
      Map<String, Map<String, dynamic>> tfAgg = {};
      Map<String, Map<String, dynamic>> fillAgg = {};

      for (var entry in response) {
        String userId = entry['user_id'];
        String gameType = entry['game_type'];

        if (overallAgg.containsKey(userId)) {
          overallAgg[userId]!['total_score'] += entry['game_score'];
          overallAgg[userId]!['total_questions'] += entry['qstn_count'];
        } else {
          overallAgg[userId] = {
            'total_score': entry['game_score'],
            'total_questions': entry['qstn_count'],
            'username': entry['tbl_user']['user_name'],
            'level_name': entry['tbl_level']['level_name'],
            'subject_name': entry['tbl_subject']['subject_name'],
          };
        }

        Map<String, Map<String, dynamic>> targetAgg;
        switch (gameType) {
          case 'MCQ':
            targetAgg = mcqAgg;
            break;
          case 'TF':
            targetAgg = tfAgg;
            break;
          case 'FILL':
            targetAgg = fillAgg;
            break;
          default:
            continue;
        }

        if (targetAgg.containsKey(userId)) {
          targetAgg[userId]!['total_score'] += entry['game_score'];
          targetAgg[userId]!['total_questions'] += entry['qstn_count'];
        } else {
          targetAgg[userId] = {
            'total_score': entry['game_score'],
            'total_questions': entry['qstn_count'],
            'username': entry['tbl_user']['user_name'],
            'level_name': entry['tbl_level']['level_name'],
            'subject_name': entry['tbl_subject']['subject_name'],
          };
        }
      }

      List<Map<String, dynamic>> toSortedList(
        Map<String, Map<String, dynamic>> agg,
      ) {
        return agg.entries.map((e) => {'user_id': e.key, ...e.value}).toList()
          ..sort((a, b) => b['total_score'].compareTo(a['total_score']))
          ..take(10);
      }

      setState(() {
        overallData = toSortedList(overallAgg);
        mcqData = toSortedList(mcqAgg);
        tfData = toSortedList(tfAgg);
        fillData = toSortedList(fillAgg);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching leaderboard: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading leaderboard: $e')));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget buildLeaderboard(List<dynamic> data, String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[900]!, Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.purpleAccent,
                  ),
                ),
              )
              : data.isEmpty
              ? const Center(
                child: Text(
                  'No scores yet, be the first!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.purpleAccent,
                    fontFamily: 'ComicSans',
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final entry = data[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 6,
                      color: Colors.black.withOpacity(0.85),
                      shadowColor: Colors.purple[900]!.withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    index == 0
                                        ? Colors.yellow[700]
                                        : index == 1
                                        ? Colors.grey[400]
                                        : index == 2
                                        ? Colors.brown[400]
                                        : Colors.purple[700],
                                border: Border.all(
                                  color: Colors.purpleAccent,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'ComicSans',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry['username'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'ComicSans',
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Score: ${entry['total_score']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.purpleAccent,
                                      fontFamily: 'ComicSans',
                                    ),
                                  ),
                                  Text(
                                    'Questions: ${entry['total_questions']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.purpleAccent,
                                      fontFamily: 'ComicSans',
                                    ),
                                  ),
                                  Text(
                                    'Level: ${entry['level_name']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.purpleAccent,
                                      fontFamily: 'ComicSans',
                                    ),
                                  ),
                                  Text(
                                    'Subject: ${entry['subject_name']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.purpleAccent,
                                      fontFamily: 'ComicSans',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (index < 3)
                              Icon(
                                Icons.star_rounded,
                                color:
                                    index == 0
                                        ? Colors.yellow[700]
                                        : index == 1
                                        ? Colors.grey[400]
                                        : Colors.brown[400],
                                size: 30,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'ComicSans',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple[800],
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purpleAccent,
          labelColor: Colors.purpleAccent,
          unselectedLabelColor: Colors.grey[400],
          labelStyle: const TextStyle(
            fontFamily: 'ComicSans',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'ComicSans',
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Overall'),
            Tab(text: 'MCQ'),
            Tab(text: 'T/F'),
            Tab(text: 'FILLUP'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildLeaderboard(overallData, 'Overall Top 10'),
          buildLeaderboard(mcqData, 'MCQ Top 10'),
          buildLeaderboard(tfData, 'True/False Top 10'),
          buildLeaderboard(fillData, 'Fill in the Blanks Top 10'),
        ],
      ),
    );
  }
}
