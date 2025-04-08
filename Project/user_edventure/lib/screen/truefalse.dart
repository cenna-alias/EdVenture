import 'package:flutter/material.dart';
import 'package:user_edventure/main.dart';
import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:user_edventure/screen/homepg.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TrueFalse extends StatefulWidget {
  final int level;
  final int subject;
  final int time;
  const TrueFalse({
    super.key,
    required this.level,
    required this.subject,
    required this.time,
    required Null Function() onFirstQuestionCompleted,
    required Null Function(dynamic score) onGameCompleted,
  });

  @override
  State<TrueFalse> createState() => _TrueFalseState();
}

class _TrueFalseState extends State<TrueFalse> {
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  int currentSet = 1;
  bool? selectedAnswer;
  int setScore = 0;
  int totalScore = 0;
  int totalQuestionsAttended = 0;
  late Timer _timer;
  late int _remainingTime;
  int currentQuestionLevel = 1;
  final int questionsPerSet = 5;
  final int totalSets = 4;
  String title = "";

  Future<void> fetchTrueFalseQuestions() async {
    try {
      final questionResponse = await supabase
          .from('tbl_tfquestion')
          .select()
          .eq('subject', widget.subject)
          .eq('level', widget.level)
          .eq('question_level', currentQuestionLevel);

      List<dynamic> shuffledQuestions = List.from(questionResponse)
        ..shuffle(Random());
      List<dynamic> selectedQuestions =
          shuffledQuestions.take(questionsPerSet).toList();

      setState(() {
        questions = selectedQuestions;
      });

      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No questions available'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.time;
    startTimer();
    fetchTrueFalseQuestions();
    getLevelName();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
          endSetDueToTime();
        }
      });
    });
  }

  Future<void> saveGameResults() async {
    try {
      await supabase.from('tbl_game').insert({
        'qstn_level': currentQuestionLevel,
        'game_score': totalScore,
        'qstn_count': totalQuestionsAttended,
        'level_id': widget.level,
        'subject_id': widget.subject,
        'game_type': 'TF',
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } catch (e) {
      print("Error saving game results: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  void endSetDueToTime() {
    totalScore += setScore;
    totalQuestionsAttended += questions.length;
    showEndDialog('Time\'s Up!');
  }

  void showEndDialog(String title) {
    _timer.cancel();
    totalScore += setScore;
    totalQuestionsAttended += questions.length;
    bool hasPassed = setScore >= 4;
    bool isGameOver = !hasPassed || currentSet == totalSets;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set $currentSet Score: $setScore/$questionsPerSet',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  hasPassed
                      ? currentSet < totalSets
                          ? 'Proceed to Set ${currentSet + 1}'
                          : 'Level Completed!'
                      : 'Score at least 4 to proceed',
                  style: TextStyle(
                    color: hasPassed ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Total Score: $totalScore/$totalQuestionsAttended',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  'Remaining Time: ${formatTime(_remainingTime)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ],
            ),
            actions: [
              if (hasPassed && currentSet < totalSets)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      currentSet++;
                      currentQuestionLevel++;
                      currentQuestionIndex = 0;
                      setScore = 0;
                      selectedAnswer = null;
                      questions.clear();
                      fetchTrueFalseQuestions();
                      startTimer();
                    });
                  },
                  child: const Text(
                    'Next Set',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 16),
                  ),
                ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (isGameOver) {
                    showExitDialog();
                  } else {
                    setState(() {
                      currentSet = 1;
                      currentQuestionLevel = 1;
                      currentQuestionIndex = 0;
                      setScore = 0;
                      totalScore = 0;
                      totalQuestionsAttended = 0;
                      selectedAnswer = null;
                      _remainingTime = widget.time;
                      questions.clear();
                      fetchTrueFalseQuestions();
                      startTimer();
                    });
                  }
                },
                child: const Text(
                  'Restart',
                  style: TextStyle(color: Colors.amberAccent, fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  showExitDialog();
                },
                child: const Text(
                  'Exit',
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            ],
          ),
    );
  }

  void showExitDialog() {
    double rating = 0.0;
    TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Game Summary',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Score: $totalScore / $totalQuestionsAttended',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Rate Your Experience:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 30.0,
                    itemBuilder:
                        (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (value) {
                      rating = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Feedback:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: feedbackController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.teal[50],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  saveGameResults();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await supabase.from('tbl_game').insert({
                      'qstn_level': currentQuestionLevel,
                      'game_score': totalScore,
                      'qstn_count': totalQuestionsAttended,
                      'level_id': widget.level,
                      'subject_id': widget.subject,
                      'game_type': 'TF',
                    });

                    await supabase.from('tbl_review').insert({
                      'review_rating': rating.toString(),
                      'review_content': feedbackController.text,
                      'review_date':
                          DateTime.now().toIso8601String().split('T')[0],
                      'user_id':
                          supabase.auth.currentUser?.id ?? 'unknown_user',
                    });

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => false,
                    );
                  } catch (e) {
                    print("Error saving game results or review: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error saving game results or review: $e',
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
    );
  }

  void checkAnswer(bool answer) {
    setState(() {
      selectedAnswer = answer;
      final correctAnswer =
          questions[currentQuestionIndex]['question_iscorrect'];

      if (answer == correctAnswer) {
        setScore++;
      }

      Future.delayed(const Duration(milliseconds: 800), () {
        if (currentQuestionIndex < questions.length - 1) {
          setState(() {
            currentQuestionIndex++;
            selectedAnswer = null;
          });
        } else {
          showEndDialog('Set $currentSet Completed!');
        }
      });
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> getLevelName() async {
    final response =
        await supabase
            .from('tbl_level')
            .select("level_name")
            .eq('id', widget.level)
            .single();
    if (response.isNotEmpty) {
      setState(() {
        title = response['level_name'];
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        body: const Center(
          child: CircularProgressIndicator(color: Colors.amberAccent),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          '$title True/False - Maths (Set $currentSet)',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[800],
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Time: ${formatTime(_remainingTime)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.amberAccent,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[900]!, Colors.blueGrey[900]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1}/$questionsPerSet',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Set $currentSet/$totalSets',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentQuestion['question_text'] ?? '',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentQuestion['sub_question'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (currentQuestion['question_file'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: currentQuestion['question_file'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => const SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.amberAccent,
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => const SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton(
                      onPressed:
                          selectedAnswer == null
                              ? () => checkAnswer(true)
                              : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(150, 70),
                        backgroundColor:
                            selectedAnswer == true
                                ? Colors.green[700]
                                : Colors.green[500],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 6,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton(
                      onPressed:
                          selectedAnswer == null
                              ? () => checkAnswer(false)
                              : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(150, 70),
                        backgroundColor:
                            selectedAnswer == false
                                ? Colors.red[700]
                                : Colors.red[500],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 6,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[800]!.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Set Score: $setScore/$questionsPerSet',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Total: $totalScore/$totalQuestionsAttended',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
