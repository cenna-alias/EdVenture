import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_admin/main.dart';
import 'package:project_admin/screen/add_choice.dart';
import 'dart:io';
import 'dart:typed_data';

class AddQuestion extends StatefulWidget {
  const AddQuestion({super.key});

  @override
  State<AddQuestion> createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion>
    with SingleTickerProviderStateMixin {
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _subquestionController = TextEditingController();

  List<Map<String, dynamic>> _levelList = [];
  String? _selectedLevel;

  List<Map<String, dynamic>> _subjectList = [];
  String? _selectedSubject;

  List<Map<String, dynamic>> _questionList = [];
  int? _selectedNumber;

  PlatformFile? _pickedImage;
  bool _isLoading = true;
  String? _errorMessage;
  int? _editingId;

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          _pickedImage = result.files.first;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to pick image: $e"),
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

  Future<String?> _uploadImage(
      PlatformFile image, int id, String question) async {
    try {
      final fileName = '$question-$id.jpg';
      await supabase.storage.from('mcq').uploadBinary(fileName, image.bytes!);
      return supabase.storage.from('mcq').getPublicUrl(fileName);
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to upload image: $e"),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      return null;
    }
  }

  Future<void> _updateImageUrl(String url, int id) async {
    try {
      await supabase.from('tbl_question').update({'image': url}).eq('id', id);
    } catch (e) {
      print("Error updating image URL: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update image URL: $e"),
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

  Future<void> insert() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_editingId != null) {
        await supabase.from("tbl_question").update({
          "question": _questionController.text,
          "sub_question": _subquestionController.text,
          "level": _selectedLevel,
          "subject": _selectedSubject,
          "question_level": _selectedNumber,
        }).eq('id', _editingId!);

        if (_pickedImage != null) {
          String? imageUrl = await _uploadImage(
              _pickedImage!, _editingId!, _questionController.text);
          if (imageUrl != null) await _updateImageUrl(imageUrl, _editingId!);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Question updated successfully"),
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
        final response = await supabase.from("tbl_question").insert({
          "question": _questionController.text,
          "sub_question": _subquestionController.text,
          "level": _selectedLevel,
          "subject": _selectedSubject,
          "question_level": _selectedNumber,
        }).select();

        final insertedId = response[0]['id'];
        String? imageUrl;
        if (_pickedImage != null) {
          imageUrl = await _uploadImage(
              _pickedImage!, insertedId, _questionController.text);
          if (imageUrl != null) await _updateImageUrl(imageUrl, insertedId);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Question added successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      await fetchQuestions();

      _questionController.clear();
      _subquestionController.clear();
      setState(() {
        _selectedLevel = null;
        _selectedSubject = null;
        _selectedNumber = null;
        _pickedImage = null;
        _isFormVisible = false;
      });
    } catch (e) {
      print("Error saving data: $e");
      setState(() => _errorMessage = "Failed to save question: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save question: $e"),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> editQuestion(Map<String, dynamic> question) async {
    setState(() {
      _isFormVisible = true;
      _editingId = question['id'];
      _questionController.text = question['question'] ?? '';
      _subquestionController.text = question['sub_question'] ?? '';
      _selectedLevel = question['level']?.toString();
      _selectedSubject = question['subject']?.toString();
      _selectedNumber = question['question_level'];
      _pickedImage = null;
    });
  }

  Future<void> fetchLevel() async {
    try {
      final response = await supabase.from('tbl_level').select();
      setState(
          () => _levelList = List<Map<String, dynamic>>.from(response ?? []));
    } catch (e) {
      print("Error fetching level: $e");
      setState(() => _errorMessage = "Error fetching levels: $e");
    }
  }

  Future<void> fetchSubject() async {
    try {
      final response = await supabase.from('tbl_subject').select();
      setState(
          () => _subjectList = List<Map<String, dynamic>>.from(response ?? []));
    } catch (e) {
      print("Error fetching subject: $e");
      setState(() => _errorMessage = "Error fetching subjects: $e");
    }
  }

  Future<void> fetchQuestions() async {
    try {
      final response = await supabase
          .from('tbl_question')
          .select("*,tbl_level(*),tbl_subject(*)");
      setState(() {
        _questionList = List<Map<String, dynamic>>.from(response ?? []);
        _questionList.sort((a, b) => a['id'].compareTo(b['id']));
      });
    } catch (e) {
      print("Error fetching questions: $e");
      setState(() => _errorMessage = "Error fetching questions: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      final question = _questionList.firstWhere((q) => q['id'] == id);
      if (question['image'] != null && question['image'].isNotEmpty) {
        final fileName = question['image'].split('/').last;
        await supabase.storage.from('mcq').remove([fileName]);
      }

      await supabase.from('tbl_question').delete().eq('id', id);
      await fetchQuestions();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Question deleted successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("ERROR DELETING DATA: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to delete question"),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() => _errorMessage = "Error deleting question: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await Future.wait([
        fetchLevel(),
        fetchSubject(),
        fetchQuestions(),
      ]);
    } catch (e) {
      setState(() => _errorMessage = "Failed to load initial data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurpleAccent,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.deepPurpleAccent),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadInitialData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '.',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                elevation: 2,
                              ),
                              onPressed: () => setState(() {
                                _isFormVisible = !_isFormVisible;
                                if (!_isFormVisible) {
                                  _questionController.clear();
                                  _subquestionController.clear();
                                  _selectedLevel = null;
                                  _selectedSubject = null;
                                  _selectedNumber = null;
                                  _pickedImage = null;
                                  _editingId = null;
                                }
                              }),
                              icon: Icon(
                                  _isFormVisible ? Icons.close : Icons.add,
                                  size: 20),
                              label: Text(_isFormVisible ? "Close" : "Add New",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        Center(
                          child: AnimatedContainer(
                            duration: _animationDuration,
                            curve: Curves.easeInOut,
                            width: 600,
                            child: _isFormVisible
                                ? Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 24),
                                          TextFormField(
                                            controller: _questionController,
                                            maxLines: 2,
                                            decoration: InputDecoration(
                                              labelText: 'Question',
                                              labelStyle: TextStyle(
                                                  color: Colors.grey[600]),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                    width: 1),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                    width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                    width: 1.5),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14),
                                            ),
                                            style: const TextStyle(
                                                color: Colors.black87),
                                            validator: (value) =>
                                                value == null || value.isEmpty
                                                    ? "Please enter a question"
                                                    : null,
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _subquestionController,
                                            maxLines: 2,
                                            decoration: InputDecoration(
                                              labelText: 'Sub Question',
                                              labelStyle: TextStyle(
                                                  color: Colors.grey[600]),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                    width: 1),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                    width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                    width: 1.5),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14),
                                            ),
                                            style: const TextStyle(
                                                color: Colors.black87),
                                          ),
                                          const SizedBox(height: 16),
                                          DropdownButtonFormField<String>(
                                            value: _selectedSubject,
                                            hint: const Text("Select Subject"),
                                            decoration: InputDecoration(
                                              labelText: 'Subject',
                                              labelStyle: TextStyle(
                                                  color: Colors.grey[600]),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                    width: 1),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                    width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                    width: 1.5),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14),
                                            ),
                                            items: _subjectList.map((subject) {
                                              return DropdownMenuItem<String>(
                                                value: subject['id'].toString(),
                                                child: Text(
                                                    subject['subject_name'] ??
                                                        'N/A',
                                                    style: const TextStyle(
                                                        color: Colors.black87)),
                                              );
                                            }).toList(),
                                            onChanged: (value) => setState(
                                                () => _selectedSubject = value),
                                            validator: (value) => value == null
                                                ? "Please select a subject"
                                                : null,
                                          ),
                                          const SizedBox(height: 16),
                                          DropdownButtonFormField<String>(
                                            value: _selectedLevel,
                                            hint: const Text("Select Level"),
                                            decoration: InputDecoration(
                                              labelText: 'Level',
                                              labelStyle: TextStyle(
                                                  color: Colors.grey[600]),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                    width: 1),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                    width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                    width: 1.5),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14),
                                            ),
                                            items: _levelList.map((level) {
                                              return DropdownMenuItem<String>(
                                                value: level['id'].toString(),
                                                child: Text(
                                                    level['level_name'] ??
                                                        'N/A',
                                                    style: const TextStyle(
                                                        color: Colors.black87)),
                                              );
                                            }).toList(),
                                            onChanged: (value) => setState(
                                                () => _selectedLevel = value),
                                            validator: (value) => value == null
                                                ? "Please select a level"
                                                : null,
                                          ),
                                          const SizedBox(height: 16),
                                          DropdownButtonFormField<int>(
                                            value: _selectedNumber,
                                            hint: const Text(
                                                "Select Question Level"),
                                            decoration: InputDecoration(
                                              labelText: 'Question Level',
                                              labelStyle: TextStyle(
                                                  color: Colors.grey[600]),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                    width: 1),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                    width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                    width: 1.5),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14),
                                            ),
                                            items: List.generate(4, (index) {
                                              return DropdownMenuItem<int>(
                                                value: index + 1,
                                                child: Text(
                                                    (index + 1).toString(),
                                                    style: const TextStyle(
                                                        color: Colors.black87)),
                                              );
                                            }),
                                            onChanged: (value) => setState(
                                                () => _selectedNumber = value),
                                            validator: (value) => value == null
                                                ? "Please select a question level"
                                                : null,
                                          ),
                                          const SizedBox(height: 24),
                                          Center(
                                            child: SizedBox(
                                              height: 120,
                                              width: 120,
                                              child: _pickedImage == null
                                                  ? GestureDetector(
                                                      onTap: _pickImage,
                                                      child: const Icon(
                                                        Icons.add_a_photo,
                                                        color: Colors
                                                            .deepPurpleAccent,
                                                        size: 60,
                                                      ),
                                                    )
                                                  : GestureDetector(
                                                      onTap: _pickImage,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        child: _pickedImage!
                                                                    .bytes !=
                                                                null
                                                            ? Image.memory(
                                                                Uint8List.fromList(
                                                                    _pickedImage!
                                                                        .bytes!),
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : Image.file(
                                                                File(
                                                                    _pickedImage!
                                                                        .path!),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: ElevatedButton(
                                              onPressed: insert,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.deepPurpleAccent,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 32,
                                                        vertical: 14),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                elevation: 2,
                                              ),
                                              child: Text(
                                                  _editingId != null
                                                      ? "Update Question"
                                                      : "Add Question",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: Container(
                            width: 1138,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.deepPurpleAccent),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _questionList.isEmpty
                                  ? Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: Text(
                                          "No questions yet",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columnSpacing: 16,
                                        dataRowHeight: 56,
                                        headingRowHeight: 48,
                                        headingRowColor:
                                            WidgetStateProperty.all(
                                                Colors.grey[100]),
                                        border: TableBorder(
                                          horizontalInside: BorderSide(
                                              color: Colors.deepPurpleAccent,
                                              width: 1),
                                          top: BorderSide(
                                              color: Colors.deepPurpleAccent,
                                              width: 1),
                                          bottom: BorderSide(
                                              color: Colors.deepPurpleAccent,
                                              width: 1),
                                        ),
                                        columns: [
                                          DataColumn(
                                            label: SizedBox(
                                              width: 40,
                                              child: Center(
                                                child: Text(
                                                  "No.",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 200,
                                              child: Center(
                                                child: Text(
                                                  "Question",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 200,
                                              child: Center(
                                                child: Text(
                                                  "Sub Question",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 100,
                                              child: Center(
                                                child: Text(
                                                  "Subject",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 100,
                                              child: Center(
                                                child: Text(
                                                  "Level",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 60,
                                              child: Center(
                                                child: Text(
                                                  "Q. Level",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 60,
                                              child: Center(
                                                child: Text(
                                                  "Image",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 100,
                                              child: Center(
                                                child: Text(
                                                  "Choices",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 80,
                                              child: Center(
                                                child: Text(
                                                  "Actions",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        rows: _questionList
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final int index = entry.key;
                                          final Map<String, dynamic> question =
                                              entry.value;
                                          final level =
                                              question['tbl_level'] ?? {};
                                          final subject =
                                              question['tbl_subject'] ?? {};
                                          final int id = question['id'];
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                SizedBox(
                                                  width: 40,
                                                  child: Center(
                                                    child: Text(
                                                      (index + 1).toString(),
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 200,
                                                  child: Center(
                                                    child: Text(
                                                      question['question'] ??
                                                          'N/A',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 200,
                                                  child: Center(
                                                    child: Text(
                                                      question[
                                                              'sub_question'] ??
                                                          'N/A',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 100,
                                                  child: Center(
                                                    child: Text(
                                                      subject['subject_name'] ??
                                                          'N/A',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 100,
                                                  child: Center(
                                                    child: Text(
                                                      level['level_name'] ??
                                                          'N/A',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 60,
                                                  child: Center(
                                                    child: Text(
                                                      question['question_level']
                                                              ?.toString() ??
                                                          'N/A',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 70,
                                                  child: Center(
                                                    child:
                                                        question['image'] !=
                                                                null
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) =>
                                                                            Dialog(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                        child: Image
                                                                            .network(
                                                                          question[
                                                                              'image'],
                                                                          fit: BoxFit
                                                                              .contain,
                                                                          errorBuilder: (context, error, stackTrace) =>
                                                                              const Text(
                                                                            "Failed to load image",
                                                                            style:
                                                                                TextStyle(color: Colors.black),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: 40,
                                                                  height: 40,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .deepPurpleAccent,
                                                                      width: 1,
                                                                    ),
                                                                    image:
                                                                        DecorationImage(
                                                                      image: NetworkImage(
                                                                          question[
                                                                              'image']),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      onError: (exception,
                                                                              stackTrace) =>
                                                                          const Icon(
                                                                        Icons
                                                                            .error,
                                                                        color: Colors
                                                                            .redAccent,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : Text(
                                                                "No Image",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .black54),
                                                              ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 110,
                                                  child: Center(
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor: Colors
                                                            .deepPurpleAccent,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 12,
                                                          vertical: 8,
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    AddChoice(
                                                                        id: id),
                                                          ),
                                                        );
                                                      },
                                                      child: const Text(
                                                          "Add Choices"),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 80,
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.edit,
                                                              size: 20,
                                                              color: Colors
                                                                  .greenAccent),
                                                          onPressed: () =>
                                                              editQuestion(
                                                                  question),
                                                          hoverColor: Colors
                                                              .greenAccent
                                                              .withOpacity(0.1),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.delete,
                                                              size: 20,
                                                              color: Colors
                                                                  .redAccent),
                                                          onPressed: () =>
                                                              delete(id),
                                                          hoverColor: Colors
                                                              .redAccent
                                                              .withOpacity(0.1),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
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
