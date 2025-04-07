import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_edventure/main.dart';

class Complaints extends StatefulWidget {
  const Complaints({super.key});

  @override
  State<Complaints> createState() => _ComplaintsState();
}

class _ComplaintsState extends State<Complaints> {
  final primaryColor = const Color(0xFF6A1B9A); // Deep purple
  final accentColor = const Color(0xFFE91E63); // Pink accent

  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;
  final TextEditingController _complaintController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      final response = await supabase
          .from('tbl_complaint')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);

      setState(() {
        complaints = response;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching complaints: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showReportDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Report an Issue',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        content: TextField(
          controller: _complaintController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe your issue here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _complaintController.clear();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_complaintController.text.trim().isNotEmpty) {
                try {
                  await supabase.from('tbl_complaint').insert({
                    'user_id': supabase.auth.currentUser!.id,
                    'complaint_text': _complaintController.text.trim(),
                  });

                  _complaintController.clear();
                  Navigator.pop(context);
                  fetchComplaints();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Complaint submitted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to submit complaint'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
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
          "Complaints",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              onPressed: _showReportDialog,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Report Issue"),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
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
                        "No Complaints Yet",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            const SizedBox(height: 12),
                            Text(
                              complaint['complaint_text'],
                              style: const TextStyle(
                                fontSize: 16,
                              ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Admin Reply:",
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
