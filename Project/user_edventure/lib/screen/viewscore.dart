// view_score_page.dart

import 'package:flutter/material.dart';
import 'package:user_edventure/screen/review.dart';

class ViewScorePage extends StatelessWidget {
  final int score;
  final String userId;
  final int levelId;

  const ViewScorePage({
    super.key,
    required this.score,
    required this.userId,
    required this.levelId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Score")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Congratulations!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "Your Score: $score",
              style: TextStyle(fontSize: 24, color: Colors.green),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewLevel(
                      userId: userId,
                      levelId: levelId,
                    ),
                  ),
                );
              },
              child: const Text("Feedback"),
            )
          ],
        ),
      ),
    );
  }
}
