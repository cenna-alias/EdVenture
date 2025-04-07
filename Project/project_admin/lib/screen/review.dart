import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Review extends StatefulWidget {
  const Review({Key? key}) : super(key: key);

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  List<dynamic> reviews = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      final response = await Supabase.instance.client
          .from('tbl_review')
          .select('review_rating, review_content, review_date')
          .order('created_at', ascending: false);

      setState(() {
        reviews = response as List<dynamic>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching reviews: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Feedback'),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RatingBarIndicator(
                              rating:
                                  double.tryParse(review['review_rating']) ??
                                      0.0,
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 24.0,
                              direction: Axis.horizontal,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review['review_content'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Date: ${review['review_date'].toString().substring(0, 10)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
