import 'package:flutter/material.dart';
import 'package:project_admin/main.dart';

class Viewscore extends StatefulWidget {
  final String userId;

  const Viewscore({super.key, required this.userId});

  @override
  _ViewscoreState createState() => _ViewscoreState();
}

class _ViewscoreState extends State<Viewscore> {
  List<dynamic> overallData = [];
  List<dynamic> mcqData = [];
  List<dynamic> tfData = [];
  List<dynamic> fillData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserScores();
  }

  Future<void> fetchUserScores() async {
    try {
      final response = await supabase
          .from('tbl_game')
          .select('*, tbl_user(*), tbl_level(*), tbl_subject(*)')
          .eq('user_id', widget.userId)
          .order('game_score', ascending: false);

      Map<String, Map<String, dynamic>> overallAgg = {};
      Map<String, Map<String, dynamic>> mcqAgg = {};
      Map<String, Map<String, dynamic>> tfAgg = {};
      Map<String, Map<String, dynamic>> fillAgg = {};

      for (var entry in response) {
        String gameType = entry['game_type'];
        String userId = entry['user_id'];

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
          targetAgg[userId]!['total_questions'] += entry['qstn_count'];
          targetAgg[userId]!['total_score'] += entry['game_score'];
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
          Map<String, Map<String, dynamic>> agg) {
        return agg.entries.map((e) => {'user_id': e.key, ...e.value}).toList()
          ..sort((a, b) => b['total_score'].compareTo(a['total_score']));
      }

      setState(() {
        overallData = toSortedList(overallAgg);
        mcqData = toSortedList(mcqAgg);
        tfData = toSortedList(tfAgg);
        fillData = toSortedList(fillAgg);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching user scores: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user scores: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Scores',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black87,
        elevation: 4,
        shadowColor: Colors.purpleAccent.withOpacity(0.5),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.grey[900]!],
          ),
        ),
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.purpleAccent),
                    const SizedBox(height: 16),
                    Text(
                      'Loading Scores...',
                      style: TextStyle(
                        color: Colors.purpleAccent,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    _buildScoreCard('Overall', overallData, Colors.purple),
                    const SizedBox(height: 16),
                    _buildScoreCard('Multiple Choice', mcqData, Colors.purple),
                    const SizedBox(height: 16),
                    _buildScoreCard('True/False', tfData, Colors.purple),
                    const SizedBox(height: 16),
                    _buildScoreCard(
                        'Fill in the Blanks', fillData, Colors.purple),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildScoreCard(
      String title, List<dynamic> data, MaterialColor color) {
    return Card(
      elevation: 6,
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purpleAccent.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: color[400],
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color[300],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Score',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      data.isNotEmpty ? '${data.first['total_score']}' : 'N/A',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (data.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Questions',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${data.first['total_questions']}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
