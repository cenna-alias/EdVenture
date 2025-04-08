import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_edventure/screen/viewscore.dart';

class ReviewLevel extends StatefulWidget {
  final String userId;
  final int levelId;

  const ReviewLevel({super.key, required this.userId, required this.levelId});

  @override
  State<ReviewLevel> createState() => _ReviewLevelState();
}

class _ReviewLevelState extends State<ReviewLevel> {
  double rating = 0;
  final TextEditingController feedbackController = TextEditingController();
  bool isSubmitting = false;

  Future<void> submitReview() async {
    setState(() {
      isSubmitting = true;
    });

    await Supabase.instance.client.from('tbl_review').insert({
      'review_rating': rating.toString(),
      'review_content': feedbackController.text,
      'review_date': DateTime.now().toString(),
      'user_id': widget.userId,
      'level_id': widget.levelId,
    });

    setState(() {
      isSubmitting = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => ViewScorePage(
              score: 0,
              userId: widget.userId,
              levelId: widget.levelId,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Review Level")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Rate the Level",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Slider(
              min: 0,
              max: 5,
              divisions: 5,
              value: rating,
              label: rating.toString(),
              onChanged: (value) {
                setState(() {
                  rating = value;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                labelText: "Write your feedback",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: submitReview,
                  child: const Text("Submit"),
                ),
          ],
        ),
      ),
    );
  }
}
