import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_admin/screen/addtfchoice.dart';
import 'package:project_admin/main.dart';
import 'dart:io';
import 'dart:typed_data';

class Fillquestion extends StatefulWidget {
  const Fillquestion({super.key});

  @override
  State<Fillquestion> createState() => _FillquestionState();
}

class _FillquestionState extends State<Fillquestion>
    with SingleTickerProviderStateMixin {
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _text1questionController =
      TextEditingController();
  final TextEditingController _text2questionController =
      TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  List<Map<String, dynamic>> _levelList = [];
  String? _selectedLevel;

  List<Map<String, dynamic>> _subjectList = [];
  String? _selectedSubject;

  List<Map<String, dynamic>> _fillquestionList = [];
  int? _selectedNumber;

  PlatformFile? _pickedImage;
  bool _isLoading = true;
  String? _errorMessage;
  int? _editingQuestionId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

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

  Future<String?> _uploadImage(PlatformFile image, int id, String text1) async {
    try {
      final fileName = '$text1-$id.jpg';
      await supabase.storage
          .from('fill_questions')
          .uploadBinary(fileName, image.bytes!);
      return supabase.storage.from('fill_questions').getPublicUrl(fileName);
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
      await supabase
          .from('tbl_fillquestion')
          .update({'image': url}).eq('id', id);
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
      final response = await supabase.from("tbl_fillquestion").insert({
        "qstn_text1": _text1questionController.text.trim(),
        "qstn_text2": _text2questionController.text.trim(),
        "qstn_answer": _answerController.text.trim(),
        "level": _selectedLevel != null ? int.parse(_selectedLevel!) : null,
        "subject":
            _selectedSubject != null ? int.parse(_selectedSubject!) : null,
        "qstn_level": _selectedNumber,
      }).select();

      final insertedId = response[0]['id'];
      String? imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _uploadImage(
            _pickedImage!, insertedId, _text1questionController.text);
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
      await fetchFillquestions();

      _clearForm();
    } catch (e) {
      print("Error inserting data: $e");
      setState(() => _errorMessage = "Failed to insert question: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to insert question: $e"),
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

  Future<void> update(int id) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await supabase.from("tbl_fillquestion").update({
        "qstn_text1": _text1questionController.text.trim(),
        "qstn_text2": _text2questionController.text.trim(),
        "qstn_answer": _answerController.text.trim(),
        "level": _selectedLevel != null ? int.parse(_selectedLevel!) : null,
        "subject":
            _selectedSubject != null ? int.parse(_selectedSubject!) : null,
        "qstn_level": _selectedNumber,
      }).eq('id', id);

      if (_pickedImage != null) {
        final question = _fillquestionList.firstWhere((q) => q['id'] == id);
        if (question['image'] != null && question['image'].isNotEmpty) {
          final oldFileName = question['image'].split('/').last;
          await supabase.storage.from('fill_questions').remove([oldFileName]);
        }
        final imageUrl = await _uploadImage(
            _pickedImage!, id, _text1questionController.text);
        if (imageUrl != null) await _updateImageUrl(imageUrl, id);
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

      _clearForm();
      await fetchFillquestions();
    } catch (e) {
      print("Error updating data: $e");
      setState(() => _errorMessage = "Failed to update question: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update question: $e"),
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

  Future<void> fetchFillquestions() async {
    try {
      final response = await supabase
          .from('tbl_fillquestion')
          .select("*, tbl_level(*), tbl_subject(*)");
      setState(() {
        _fillquestionList = List<Map<String, dynamic>>.from(response ?? []);
        _fillquestionList.sort((a, b) => a['id'].compareTo(b['id']));
      });
    } catch (e) {
      print("Error fetching questions: $e");
      setState(() => _errorMessage = "Error fetching questions: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      final question = _fillquestionList.firstWhere((q) => q['id'] == id);
      if (question['image'] != null && question['image'].isNotEmpty) {
        final fileName = question['image'].split('/').last;
        await supabase.storage.from('fill_questions').remove([fileName]);
      }

      await supabase.from('tbl_fillquestion').delete().eq('id', id);
      await fetchFillquestions();
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

  void _editQuestion(Map<String, dynamic> question) {
    setState(() {
      _editingQuestionId = question['id'];
      _text1questionController.text = question['qstn_text1'] ?? '';
      _text2questionController.text = question['qstn_text2'] ?? '';
      _answerController.text = question['qstn_answer'] ?? '';
      _selectedLevel = question['level']?.toString();
      _selectedSubject = question['subject']?.toString();
      _selectedNumber = question['qstn_level'];
      _pickedImage = null;
      _isFormVisible = true;
    });
  }

  void _clearForm() {
    _text1questionController.clear();
    _text2questionController.clear();
    _answerController.clear();
    setState(() {
      _selectedLevel = null;
      _selectedSubject = null;
      _selectedNumber = null;
      _pickedImage = null;
      _isFormVisible = false;
      _editingQuestionId = null;
    });
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
        fetchFillquestions(),
      ]);
    } catch (e) {
      setState(() => _errorMessage = "Failed to load initial data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _text1questionController.dispose();
    _text2questionController.dispose();
    _answerController.dispose();
    super.dispose();
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
                                if (!_isFormVisible) _clearForm();
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
                        // const SizedBox(height: 10),
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
                                            controller:
                                                _text1questionController,
                                            maxLines: 2,
                                            decoration: InputDecoration(
                                              labelText: 'Text Before Blank',
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
                                              // prefixIcon: Icon(
                                              //     Icons.text_fields,
                                              //     color:
                                              //         Colors.deepPurpleAccent),
                                            ),
                                            style: const TextStyle(
                                                color: Colors.black87),
                                            validator: (value) => value ==
                                                        null ||
                                                    value.isEmpty
                                                ? "Please enter text before blank"
                                                : null,
                                          ),
                                          // const SizedBox(height: 16),
                                          // TextFormField(
                                          //   controller:
                                          //       _text2questionController,
                                          //   maxLines: 3,
                                          //   decoration: InputDecoration(
                                          //     labelText: 'Text After Blank',
                                          //     labelStyle: TextStyle(
                                          //         color: Colors.grey[600]),
                                          //     border: OutlineInputBorder(
                                          //       borderRadius:
                                          //           BorderRadius.circular(8),
                                          //       borderSide: BorderSide(
                                          //           color:
                                          //               Colors.deepPurpleAccent,
                                          //           width: 1),
                                          //     ),
                                          //     enabledBorder: OutlineInputBorder(
                                          //       borderRadius:
                                          //           BorderRadius.circular(8),
                                          //       borderSide: BorderSide(
                                          //           color:
                                          //               Colors.deepPurpleAccent,
                                          //           width: 1),
                                          //     ),
                                          //     focusedBorder: OutlineInputBorder(
                                          //       borderRadius:
                                          //           BorderRadius.circular(8),
                                          //       borderSide: const BorderSide(
                                          //           color:
                                          //               Colors.deepPurpleAccent,
                                          //           width: 1.5),
                                          //     ),
                                          //     contentPadding:
                                          //         const EdgeInsets.symmetric(
                                          //             horizontal: 16,
                                          //             vertical: 14),
                                          //     prefixIcon: Icon(
                                          //         Icons.text_fields,
                                          //         color:
                                          //             Colors.deepPurpleAccent),
                                          //   ),
                                          //   style: const TextStyle(
                                          //       color: Colors.black87),
                                          // ),
                                          // const SizedBox(height: 16),
                                          // TextFormField(
                                          //   controller: _answerController,
                                          //   decoration: InputDecoration(
                                          //     labelText: 'Correct Answer',
                                          //     labelStyle: TextStyle(
                                          //         color: Colors.grey[600]),
                                          //     border: OutlineInputBorder(
                                          //       borderRadius:
                                          //           BorderRadius.circular(8),
                                          //       borderSide: BorderSide(
                                          //           color:
                                          //               Colors.deepPurpleAccent,
                                          //           width: 1),
                                          //     ),
                                          //     enabledBorder: OutlineInputBorder(
                                          //       borderRadius:
                                          //           BorderRadius.circular(8),
                                          //       borderSide: BorderSide(
                                          //           color:
                                          //               Colors.deepPurpleAccent,
                                          //           width: 1),
                                          //     ),
                                          //     focusedBorder: OutlineInputBorder(
                                          //       borderRadius:
                                          //           BorderRadius.circular(8),
                                          //       borderSide: const BorderSide(
                                          //           color:
                                          //               Colors.deepPurpleAccent,
                                          //           width: 1.5),
                                          //     ),
                                          //     contentPadding:
                                          //         const EdgeInsets.symmetric(
                                          //             horizontal: 16,
                                          //             vertical: 14),
                                          //     prefixIcon: Icon(Icons.check,
                                          //         color:
                                          //             Colors.deepPurpleAccent),
                                          //   ),
                                          //   style: const TextStyle(
                                          //       color: Colors.black87),
                                          //   validator: (value) => value ==
                                          //               null ||
                                          //           value.isEmpty
                                          //       ? "Please enter correct answer"
                                          //       : null,
                                          // ),
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
                                              // prefixIcon: Icon(Icons.book,
                                              //     color:
                                              //         Colors.deepPurpleAccent),
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
                                            dropdownColor: Colors.white,
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
                                              // prefixIcon: Icon(Icons.stairs,
                                              //     color:
                                              //         Colors.deepPurpleAccent),
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
                                            dropdownColor: Colors.white,
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
                                              // prefixIcon: Icon(Icons.numbers,
                                              //     color:
                                              //         Colors.deepPurpleAccent),
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
                                            dropdownColor: Colors.white,
                                          ),
                                          // const SizedBox(height: 16),
                                          // Row(
                                          //   children: [
                                          //     ElevatedButton(
                                          //       onPressed: _pickImage,
                                          //       style: ElevatedButton.styleFrom(
                                          //         backgroundColor:
                                          //             Colors.deepPurpleAccent,
                                          //         foregroundColor: Colors.white,
                                          //         padding: const EdgeInsets
                                          //             .symmetric(
                                          //             horizontal: 20,
                                          //             vertical: 12),
                                          //         shape: RoundedRectangleBorder(
                                          //             borderRadius:
                                          //                 BorderRadius.circular(
                                          //                     8)),
                                          //       ),
                                          //       child: const Text("Pick Image"),
                                          //     ),
                                          //     const SizedBox(width: 16),
                                          //     _pickedImage != null
                                          //         ? SizedBox(
                                          //             width: 80,
                                          //             height: 80,
                                          //             child: ClipRRect(
                                          //               borderRadius:
                                          //                   BorderRadius
                                          //                       .circular(8),
                                          //               child: _pickedImage!
                                          //                           .bytes !=
                                          //                       null
                                          //                   ? Image.memory(
                                          //                       Uint8List.fromList(
                                          //                           _pickedImage!
                                          //                               .bytes!),
                                          //                       fit: BoxFit
                                          //                           .cover)
                                          //                   : Image.file(
                                          //                       File(
                                          //                           _pickedImage!
                                          //                               .path!),
                                          //                       fit: BoxFit
                                          //                           .cover),
                                          //             ),
                                          //           )
                                          //         : const Text(
                                          //             "No image selected",
                                          //             style: TextStyle(
                                          //                 color:
                                          //                     Colors.black54)),
                                          //   ],
                                          // ),
                                          const SizedBox(height: 24),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  _editingQuestionId != null
                                                      ? update(
                                                          _editingQuestionId!)
                                                      : insert(),
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
                                                  _editingQuestionId != null
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
                            width: 1000,
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
                              child: _fillquestionList.isEmpty
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
                                              width: 370,
                                              child: Center(
                                                child: Text(
                                                  "Text Before Blank",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // DataColumn(
                                          //   label: SizedBox(
                                          //     width: 200,
                                          //     child: Center(
                                          //       child: Text(
                                          //         "Text After Blank",
                                          //         style: TextStyle(
                                          //           fontSize: 14,
                                          //           fontWeight: FontWeight.w600,
                                          //           color: Colors.black87,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                          // DataColumn(
                                          //   label: SizedBox(
                                          //     width: 100,
                                          //     child: Center(
                                          //       child: Text(
                                          //         "Correct Answer",
                                          //         style: TextStyle(
                                          //           fontSize: 14,
                                          //           fontWeight: FontWeight.w600,
                                          //           color: Colors.black87,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
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
                                          // DataColumn(
                                          //   label: SizedBox(
                                          //     width: 60,
                                          //     child: Center(
                                          //       child: Text(
                                          //         "Image",
                                          //         style: TextStyle(
                                          //           fontSize: 14,
                                          //           fontWeight: FontWeight.w600,
                                          //           color: Colors.black87,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
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
                                        rows: _fillquestionList
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final int index = entry.key;
                                          final Map<String, dynamic>
                                              fillquestion = entry.value;
                                          final level =
                                              fillquestion['tbl_level'] ?? {};
                                          final subject =
                                              fillquestion['tbl_subject'] ?? {};
                                          final int id = fillquestion['id'];
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
                                                  width: 370,
                                                  child: Center(
                                                    child: Text(
                                                      fillquestion[
                                                              'qstn_text1'] ??
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
                                              // DataCell(
                                              //   SizedBox(
                                              //     width: 200,
                                              //     child: Center(
                                              //       child: Text(
                                              //         fillquestion[
                                              //                 'qstn_text2'] ??
                                              //             'N/A',
                                              //         overflow:
                                              //             TextOverflow.ellipsis,
                                              //         maxLines: 2,
                                              //         style: const TextStyle(
                                              //             fontSize: 14,
                                              //             color:
                                              //                 Colors.black87),
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ),
                                              // DataCell(
                                              //   SizedBox(
                                              //     width: 100,
                                              //     child: Center(
                                              //       child: Text(
                                              //         fillquestion[
                                              //                 'qstn_answer'] ??
                                              //             'N/A',
                                              //         overflow:
                                              //             TextOverflow.ellipsis,
                                              //         style: const TextStyle(
                                              //             fontSize: 14,
                                              //             color:
                                              //                 Colors.black87),
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ),
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
                                                      fillquestion['qstn_level']
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
                                              // DataCell(
                                              //   SizedBox(
                                              //     width: 70,
                                              //     child: Center(
                                              //       child:
                                              //           fillquestion['image'] !=
                                              //                   null
                                              //               ? GestureDetector(
                                              //                   onTap: () {
                                              //                     showDialog(
                                              //                       context:
                                              //                           context,
                                              //                       builder:
                                              //                           (context) =>
                                              //                               Dialog(
                                              //                         backgroundColor:
                                              //                             Colors
                                              //                                 .white,
                                              //                         child:
                                              //                             ClipRRect(
                                              //                           borderRadius:
                                              //                               BorderRadius.circular(8),
                                              //                           child: Image
                                              //                               .network(
                                              //                             fillquestion[
                                              //                                 'image'],
                                              //                             fit: BoxFit
                                              //                                 .contain,
                                              //                             errorBuilder: (context, error, stackTrace) =>
                                              //                                 const Text(
                                              //                               "Failed to load image",
                                              //                               style:
                                              //                                   TextStyle(color: Colors.black),
                                              //                             ),
                                              //                           ),
                                              //                         ),
                                              //                       ),
                                              //                     );
                                              //                   },
                                              //                   child:
                                              //                       Container(
                                              //                     width: 40,
                                              //                     height: 40,
                                              //                     decoration:
                                              //                         BoxDecoration(
                                              //                       borderRadius:
                                              //                           BorderRadius
                                              //                               .circular(8),
                                              //                       border:
                                              //                           Border
                                              //                               .all(
                                              //                         color: Colors
                                              //                             .deepPurpleAccent,
                                              //                         width: 1,
                                              //                       ),
                                              //                       image:
                                              //                           DecorationImage(
                                              //                         image: NetworkImage(
                                              //                             fillquestion[
                                              //                                 'image']),
                                              //                         fit: BoxFit
                                              //                             .cover,
                                              //                         onError: (exception,
                                              //                                 stackTrace) =>
                                              //                             const Icon(
                                              //                           Icons
                                              //                               .error,
                                              //                           color: Colors
                                              //                               .redAccent,
                                              //                         ),
                                              //                       ),
                                              //                     ),
                                              //                   ),
                                              //                 )
                                              //               : Text(
                                              //                   "No Image",
                                              //                   style: const TextStyle(
                                              //                       fontSize:
                                              //                           14,
                                              //                       color: Colors
                                              //                           .black54),
                                              //                 ),
                                              //     ),
                                              //   ),
                                              // ),
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
                                                                vertical: 8),
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
                                                              builder: (context) =>
                                                                  AddTFChoice(
                                                                      id: id)),
                                                        ).then((_) =>
                                                            fetchFillquestions());
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
                                                              _editQuestion(
                                                                  fillquestion),
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
