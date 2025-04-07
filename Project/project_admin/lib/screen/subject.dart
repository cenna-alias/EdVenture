import 'package:flutter/material.dart';
import 'package:project_admin/main.dart';
import 'package:file_picker/file_picker.dart';

class Subject extends StatefulWidget {
  const Subject({super.key});

  @override
  State<Subject> createState() => _SubjectState();
}

class _SubjectState extends State<Subject> {
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final TextEditingController _subjectnameController = TextEditingController();
  PlatformFile? pickedImage;
  List<Map<String, dynamic>> _subjectList = [];
  int? _editingId;

  Future<void> submit() async {
    try {
      if (_editingId != null) {
        await supabase.from("tbl_subject").update({
          "subject_name": _subjectnameController.text,
        }).eq('id', _editingId!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Subject updated successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
        _editingId = null;
      } else {
        await supabase.from("tbl_subject").insert({
          "subject_name": _subjectnameController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Subject added successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      fetchSubject();
      _subjectnameController.clear();
      setState(() => _isFormVisible = false);
    } catch (e) {
      print("ERROR INSERTING/UPDATING DATA: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save subject: $e"),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> fetchSubject() async {
    try {
      final response = await supabase.from('tbl_subject').select();
      setState(() => _subjectList = response);
    } catch (e) {
      print("ERROR FETCHING DATA: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch subjects: $e"),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_subject').delete().eq('id', id);
      fetchSubject();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Subject deleted successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to delete subject"),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      print("ERROR DELETING DATA: $e");
    }
  }

  void editSubject(Map<String, dynamic> subject) {
    setState(() {
      _isFormVisible = true;
      _editingId = subject['id'];
      _subjectnameController.text = subject['subject_name']?.toString() ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    fetchSubject();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade800, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(Icons.book_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Subjects',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade800,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () =>
                            setState(() => _isFormVisible = !_isFormVisible),
                        icon: Icon(_isFormVisible ? Icons.close : Icons.add,
                            size: 20),
                        label: Text(_isFormVisible ? "Close" : "Add Subject"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Section
              AnimatedContainer(
                duration: _animationDuration,
                curve: Curves.easeInOut,
                child: _isFormVisible
                    ? Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _editingId != null
                                        ? Icons.edit
                                        : Icons.add_circle,
                                    color: Colors.blue.shade600,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _editingId != null
                                        ? "Edit Subject"
                                        : "New Subject",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _subjectnameController,
                                decoration: InputDecoration(
                                  labelText: 'Subject Name',
                                  hintText: 'Enter subject name',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.blue.shade600,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  prefixIcon: Icon(Icons.book_rounded,
                                      color: Colors.blue.shade600),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _editingId != null
                                            ? Icons.update
                                            : Icons.save,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(_editingId != null
                                          ? "Update"
                                          : "Save"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
              ),
              const SizedBox(height: 24),

              // Subjects List
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _subjectList.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.book,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No subjects available",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: DataTable(
                          columnSpacing: 24,
                          dataRowHeight: 56,
                          headingRowHeight: 56,
                          headingRowColor:
                              WidgetStateProperty.all(Colors.blue.shade50),
                          border: TableBorder(
                            horizontalInside:
                                BorderSide(color: Colors.grey[200]!, width: 1),
                          ),
                          columns: [
                            DataColumn(
                              label: Text(
                                "No.",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Subject",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Actions",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                          rows: _subjectList.asMap().entries.map((entry) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    (entry.key + 1).toString(),
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    width: 200,
                                    child: Text(
                                      entry.value['subject_name']?.toString() ??
                                          'N/A',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey[800]),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      Tooltip(
                                        message: 'Edit',
                                        child: IconButton(
                                          icon: Icon(Icons.edit_rounded,
                                              color: Colors.blue.shade600),
                                          onPressed: () =>
                                              editSubject(entry.value),
                                          hoverColor: Colors.blue[50],
                                        ),
                                      ),
                                      Tooltip(
                                        message: 'Delete',
                                        child: IconButton(
                                          icon: Icon(Icons.delete_rounded,
                                              color: Colors.red.shade600),
                                          onPressed: () =>
                                              delete(entry.value['id']),
                                          hoverColor: Colors.red[50],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
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
