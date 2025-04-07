import 'package:flutter/material.dart';
import 'package:user_edventure/screen/difficulty.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubjectPage extends StatefulWidget {
  final String type;
  const SubjectPage({super.key, required this.type});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  List<Map<String, dynamic>> subjects = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    try {
      final response =
          await Supabase.instance.client.from('tbl_subject').select();
      if (response.isNotEmpty) {
        setState(() {
          subjects = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No subjects found';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Failed to load subjects: ${error.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[700],
        elevation: 0,
        title: const Text(
          'Select Subject',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber[50]!, Colors.amber[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child:
              isLoading
                  ? const CircularProgressIndicator(color: Colors.amber)
                  : errorMessage != null
                  ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                  : Container(
                    width:
                        MediaQuery.of(context).size.width *
                        0.8, // Smaller width
                    height:
                        MediaQuery.of(context).size.height *
                        0.4, // Smaller height
                    decoration: BoxDecoration(
                      color: Colors.amber[50], // Changed color to light amber
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: ListView.builder(
                        shrinkWrap:
                            true, // Ensures list takes only needed space
                        physics:
                            const NeverScrollableScrollPhysics(), // Disable scrolling
                        padding: const EdgeInsets.all(16),
                        itemCount: subjects.length,
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                if (subject['subject_name'] != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => Level(
                                            subject: subject['id'],
                                            type: widget.type,
                                          ),
                                    ),
                                  );
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  color: Colors.white,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.amber[200]!,
                                          Colors.amber[300]!,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            subject['subject_name'] ??
                                                'Unnamed Subject',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.black54,
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
