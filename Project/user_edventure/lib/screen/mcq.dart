import 'package:flutter/material.dart';
import 'package:user_edventure/main.dart';
import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:user_edventure/screen/homepg.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MCQ extends StatefulWidget {
  final int level;
  final int subject;
  final int time;
  const MCQ({
    super.key,
    required this.level,
    required this.subject,
    required this.time,
    required Null Function() onFirstQuestionCompleted,
    required Null Function(dynamic score) onGameCompleted,
  });

  @override
  State<MCQ> createState() => _MCQState();
}

class _MCQState extends State<MCQ> {
  List<dynamic> questions = [];
  Map<int, List<dynamic>> choices = {};
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  int score = 0;
  int totalScore = 0;
  int totalQuestionsAttended = 0;
  late Timer _timer;
  late int _remainingTime;
  int currentQuestionLevel = 1;
  final int questionsPerLevel = 5;

  Future<void> fetchMCQ() async {
    try {
      final questionResponse = await supabase
          .from('tbl_question')
          .select()
          .eq('subject', widget.subject)
          .eq('level', widget.level)
          .eq('question_level', currentQuestionLevel);

      List<dynamic> shuffledQuestions = List.from(questionResponse)
        ..shuffle(Random());
      List<dynamic> selectedQuestions =
          shuffledQuestions.take(questionsPerLevel).toList();

      for (var question in selectedQuestions) {
        final choiceResponse = await supabase
            .from('tbl_choice')
            .select()
            .eq('question_id', question['id']);

        List<dynamic> shuffledChoices = List.from(choiceResponse)
          ..shuffle(Random());
        choices[question['id']] = shuffledChoices;
      }

      setState(() {
        questions = selectedQuestions;
      });
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading questions: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.time;
    startTimer();
    fetchMCQ();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
          endQuizDueToTime();
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
        'game_type': 'MCQ',
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } catch (e) {
      print("Error saving game results: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving game results: $e')));
    }
  }

  void endQuizDueToTime() {
    totalScore += score;
    totalQuestionsAttended += questions.length;
    showEndDialog('Time\'s Up!');
  }

  void showEndDialog(String title) {
    _timer.cancel();
    totalScore += score;
    totalQuestionsAttended += questions.length;
    bool hasPassed = score > 3;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Level Score: $score/$questionsPerLevel'),
                const SizedBox(height: 8),
                Text(
                  hasPassed
                      ? 'Congratulations! Proceed to Level ${currentQuestionLevel + 1}'
                      : 'Score more than 3 to proceed',
                  style: TextStyle(
                    color: hasPassed ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Total Score: $totalScore/$totalQuestionsAttended'),
                const SizedBox(height: 8),
                Text('Remaining Time: ${formatTime(_remainingTime)}'),
              ],
            ),
            actions: [
              if (hasPassed && currentQuestionLevel < 5)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      currentQuestionLevel++;
                      currentQuestionIndex = 0;
                      score = 0;
                      selectedAnswer = null;
                      questions.clear();
                      choices.clear();
                      fetchMCQ();
                      startTimer();
                    });
                  },
                  child: const Text('Next Level'),
                ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    currentQuestionLevel = 1;
                    currentQuestionIndex = 0;
                    score = 0;
                    totalScore = 0;
                    totalQuestionsAttended = 0;
                    selectedAnswer = null;
                    _remainingTime = widget.time;
                    questions.clear();
                    choices.clear();
                    fetchMCQ();
                    startTimer();
                  });
                },
                child: const Text('Restart'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  showExitDialog();
                },
                child: const Text('Exit'),
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
                  saveGameResults();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void checkAnswer(String answer, List<dynamic> currentChoices) {
    setState(() {
      selectedAnswer = answer;

      final correctAnswer =
          currentChoices.firstWhere(
            (choice) => choice['is_correct'] == true,
          )['answer'];

      if (answer == correctAnswer) {
        score++;
      }

      Future.delayed(const Duration(seconds: 1), () {
        if (currentQuestionIndex < questions.length - 1) {
          setState(() {
            currentQuestionIndex++;
            selectedAnswer = null;
          });
        } else {
          showEndDialog('Level Completed!');
        }
      });
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String getLevelName() {
    switch (widget.level) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final currentChoices = choices[currentQuestion['id']] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: Text(
          '${getLevelName()} - Level $currentQuestionLevel',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text(
                formatTime(_remainingTime),
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[50]!, Colors.teal[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Q${currentQuestionIndex + 1}/$questionsPerLevel',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.teal[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$score',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.teal[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentQuestion['question'] ?? '',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (currentQuestion['sub_question'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          currentQuestion['sub_question'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                      if (currentQuestion['image'] != null) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: currentQuestion['image'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.teal,
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ...currentChoices.map((choice) {
                bool isSelected = selectedAnswer == choice['answer'];
                bool isCorrect = choice['is_correct'] == true && isSelected;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: isSelected ? 8 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color:
                        isSelected
                            ? (isCorrect ? Colors.green[100] : Colors.red[100])
                            : Colors.white,
                    child: ListTile(
                      leading: Icon(
                        isSelected
                            ? (isCorrect ? Icons.check_circle : Icons.cancel)
                            : Icons.circle_outlined,
                        color:
                            isSelected
                                ? (isCorrect ? Colors.green : Colors.red)
                                : Colors.grey,
                      ),
                      title: Text(
                        choice['answer'] ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          color: isSelected ? Colors.black87 : Colors.black54,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap:
                          selectedAnswer == null
                              ? () =>
                                  checkAnswer(choice['answer'], currentChoices)
                              : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal[700],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total Score: $totalScore / $totalQuestionsAttended',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
