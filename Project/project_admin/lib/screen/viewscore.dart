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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Total Scores',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.indigo[900],
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo[900]!, Colors.indigo[700]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.indigo[700]!),
                      strokeWidth: 5,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading Scores...',
                      style: TextStyle(
                        color: Colors.indigo[700],
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 400),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        _buildScoreCard('Overall', overallData, Colors.indigo),
                        const SizedBox(height: 20),
                        _buildScoreCard(
                            'Multiple Choice', mcqData, Colors.indigo),
                        const SizedBox(height: 20),
                        _buildScoreCard('True/False', tfData, Colors.indigo),
                        const SizedBox(height: 20),
                        _buildScoreCard(
                            'Fill in the Blanks', fillData, Colors.indigo),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildScoreCard(
      String title, List<dynamic> data, MaterialColor color) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  color: color[600],
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: color[800],
                    letterSpacing: 0.3,
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
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.isNotEmpty ? '${data.first['total_score']}' : 'N/A',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color[900],
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
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data.first['total_questions']}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color[900],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (data.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${data.first['username']} | ${data.first['level_name']} | ${data.first['subject_name']}',
                  style: TextStyle(
                    color: color[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
