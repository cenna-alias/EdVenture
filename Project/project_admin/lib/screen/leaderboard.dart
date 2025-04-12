import 'package:flutter/material.dart';
import 'package:project_admin/main.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading leaderboard: $e')),
      );
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

  Widget _buildTopThreePodium(List<dynamic> data) {
    if (data.isEmpty || isLoading) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Second place
          if (data.length > 1)
            _buildPodiumItem(data[1], 120, Colors.grey[400]!, '2nd'),

          // First place
          if (data.isNotEmpty)
            _buildPodiumItem(data[0], 150, Colors.yellow[700]!, '1st'),

          // Third place
          if (data.length > 2)
            _buildPodiumItem(data[2], 100, Colors.brown[400]!, '3rd'),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
      Map<String, dynamic> user, double height, Color color, String rank) {
    return Column(
      children: [
        Container(
          width: 90,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.5),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: height == 150 ? 40 : 30,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  user['username'],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: height == 150 ? 16 : 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${user['total_score']} pts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: height == 150 ? 14 : 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 90,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Center(
            child: Text(
              rank,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> user, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRankColor(index).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(index),
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user['username'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: _getRankColor(index), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${user['total_score']} pts',
                  style: TextStyle(
                    color: Colors.purpleAccent[100],
                  ),
                ),
              ],
            ),
            Text(
              '${user['level_name']} • ${user['subject_name']}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.yellow[700]!;
      case 1:
        return Colors.grey[400]!;
      case 2:
        return Colors.brown[400]!;
      default:
        return Colors.purple[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple[900]!,
                  Colors.purple[800]!,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Top Performers',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.purpleAccent.withOpacity(0.3),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[300],
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: 'OVERALL'),
                    Tab(text: 'MCQ'),
                    Tab(text: 'TRUE/FALSE'),
                    Tab(text: 'FILL UP'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardTab(overallData),
                _buildLeaderboardTab(mcqData),
                _buildLeaderboardTab(tfData),
                _buildLeaderboardTab(fillData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(List<dynamic> data) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
            ),
          )
        : data.isEmpty
            ? const Center(
                child: Text(
                  'No scores yet, be the first!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.purpleAccent,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTopThreePodium(data),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Divider(
                        color: Colors.purpleAccent,
                        thickness: 0.5,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'All Participants',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return _buildLeaderboardItem(data[index], index);
                      },
                    ),
                  ],
                ),
              );
  }
}
