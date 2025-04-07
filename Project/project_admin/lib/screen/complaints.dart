import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_admin/main.dart';
import 'package:project_admin/screen/reply.dart';

class AdminComplaints extends StatefulWidget {
  const AdminComplaints({super.key});

  @override
  State<AdminComplaints> createState() => _AdminComplaintsState();
}

class _AdminComplaintsState extends State<AdminComplaints> {
  final primaryColor = const Color(0xFF6A1B9A);
  final accentColor = const Color(0xFFE91E63);

  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      final response = await supabase
          .from('tbl_complaint')
          .select('*, tbl_user(user_name)')
          .order('created_at', ascending: false);

      setState(() {
        complaints = response;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading complaints: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String date) {
    return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          "Admin - Complaints",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : complaints.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No Complaints Found",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchComplaints,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = complaints[index];
                      final isReplied = complaint['complaint_status'] == 1;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatDate(complaint['created_at']),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isReplied
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isReplied ? "Replied" : "Pending",
                                      style: TextStyle(
                                        color: isReplied
                                            ? Colors.green
                                            : Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'User: ${complaint['tbl_user']['user_name']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                complaint['complaint_text'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              if (isReplied &&
                                  complaint['complaint_reply'] != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Reply:",
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(complaint['complaint_reply']),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              if (!isReplied)
                                ElevatedButton(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Reply(
                                          complaint: complaint,
                                          onReplySubmitted: fetchComplaints,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      fetchComplaints();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Reply'),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
