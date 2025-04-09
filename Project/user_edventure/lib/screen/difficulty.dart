import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_edventure/screen/mcq.dart';
import 'package:user_edventure/screen/review.dart';
import 'package:user_edventure/screen/truefalse.dart';
import 'package:user_edventure/screen/fillup.dart';
import 'package:user_edventure/screen/viewscore.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.purple[900],
        elevation: 4,
        shadowColor: Colors.black54,
        title: const Text(
          'Select Level',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'ComicSans',
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.purple[800]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child:
              isLoading
                  ? const CircularProgressIndicator(color: Colors.purpleAccent)
                  : Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple[900]!.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: levels.length,
                        itemBuilder: (context, index) {
                          final level = levels[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: GestureDetector(
                              onTap:
                                  () => startGame(
                                    level['id'],
                                    level['level_time'],
                                  ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  color: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.purple[700]!,
                                          Colors.black54,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.purpleAccent.withOpacity(
                                          0.5,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            level['level_name'] ??
                                                'Unnamed Level',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontFamily: 'ComicSans',
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.purpleAccent,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
