import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_admin/main.dart';

class Reply extends StatefulWidget {
  final Map<String, dynamic> complaint;
  final VoidCallback onReplySubmitted;

  const Reply({
    super.key,
    required this.complaint,
    required this.onReplySubmitted,
  });

  @override
  State<Reply> createState() => _ReplyState();
}

class _ReplyState extends State<Reply> {
  final primaryColor = const Color(0xFF6A1B9A);
  final accentColor = const Color(0xFFE91E63);
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> submitReply() async {
    if (_replyController.text.trim().isNotEmpty) {
      try {
        await supabase.from('tbl_complaint').update({
          'complaint_reply': _replyController.text.trim(),
          'complaint_status': 1,
        }).eq('id', widget.complaint['id']);

        _replyController.clear();
        widget.onReplySubmitted(); // Refresh the complaint list
        Navigator.pop(context, true); // Go back to the previous page

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reply submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit reply: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          "Reply to Complaint",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complaint: ${widget.complaint['complaint_text']}',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _replyController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter your reply here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: submitReply,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Submit Reply'),
            ),
          ],
        ),
      ),
    );
  }
}
