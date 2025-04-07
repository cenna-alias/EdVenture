// level.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_edventure/screen/mcq.dart';
import 'package:user_edventure/screen/review.dart';
import 'package:user_edventure/screen/truefalse.dart';
import 'package:user_edventure/screen/fillup.dart';
import 'package:user_edventure/screen/viewscore.dart'; // Import view score page

class Level extends StatefulWidget {
  final int subject;
  final String type;

  const Level({super.key, required this.subject, required this.type});

  @override
  State<Level> createState() => _LevelState();
}

class _LevelState extends State<Level> {
  List<Map<String, dynamic>> levels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLevels();
  }

  Future<void> fetchLevels() async {
    final response = await Supabase.instance.client.from('tbl_level').select();
    setState(() {
      levels = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  void startGame(int levelId, dynamic time) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    int gameTime = (time is int) ? time : 60;

    Widget page;
    if (widget.type == "MCQ") {
      page = MCQ(
        time: gameTime,
        level: levelId,
        subject: widget.subject,
        onFirstQuestionCompleted: () {
          if (userId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReviewLevel(userId: userId, levelId: levelId),
              ),
            );
          }
        },
        onGameCompleted: (score) {
          if (userId != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ViewScorePage(
                      score: score,
                      userId: userId,
                      levelId: levelId,
                    ),
              ),
            );
          }
        },
      );
    } else if (widget.type == "TF") {
      page = TrueFalse(
        time: gameTime,
        level: levelId,
        subject: widget.subject,
        onFirstQuestionCompleted: () {
          if (userId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReviewLevel(userId: userId, levelId: levelId),
              ),
            );
          }
        },
        onGameCompleted: (score) {
          if (userId != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ViewScorePage(
                      score: score,
                      userId: userId,
                      levelId: levelId,
                    ),
              ),
            );
          }
        },
      );
    } else {
      page = FILL(
        time: gameTime,
        level: levelId,
        subject: widget.subject,
        onFirstQuestionCompleted: () {
          if (userId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReviewLevel(userId: userId, levelId: levelId),
              ),
            );
          }
        },
        onGameCompleted: (score) {
          if (userId != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ViewScorePage(
                      score: score,
                      userId: userId,
                      levelId: levelId,
                    ),
              ),
            );
          }
        },
      );
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Level')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final level = levels[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    color: Colors.blue.shade100,
                    child: ListTile(
                      title: Text(level['level_name'] ?? 'Level'),
                      subtitle: Text("Time: ${level['level_time']} sec"),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () => startGame(level['id'], level['level_time']),
                    ),
                  );
                },
              ),
    );
  }
}
