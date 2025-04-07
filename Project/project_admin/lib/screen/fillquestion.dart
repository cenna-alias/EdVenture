import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_admin/screen/addtfchoice.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_admin/main.dart';
import 'dart:io';
import 'dart:typed_data';

class Fillquestion extends StatefulWidget {
  const Fillquestion({super.key});

  @override
  State<Fillquestion> createState() => _FillquestionState();
}

class _FillquestionState extends State<Fillquestion> {
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
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          _errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadInitialData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.edit,
                                    color: Colors.black87, size: 28),
                                const SizedBox(width: 12),
                                Text(
                                  'Fill-in-the-Blank Questions',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () => setState(
                                  () => _isFormVisible = !_isFormVisible),
                              icon: Icon(
                                  _isFormVisible ? Icons.close : Icons.add,
                                  size: 20),
                              label: Text(_isFormVisible ? "Close" : "Add New"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Form Section
                        AnimatedContainer(
                          duration: _animationDuration,
                          curve: Curves.easeInOut,
                          child: _isFormVisible
                              ? Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 12,
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
                                        Text(
                                          "New Fill-in-the-Blank Question",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        TextFormField(
                                          controller: _text1questionController,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            labelText: 'Text Before Blank',
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 14),
                                            prefixIcon: Icon(Icons.text_fields,
                                                color: Colors.black54),
                                          ),
                                          validator: (value) => value == null ||
                                                  value.isEmpty
                                              ? "Please enter text before blank"
                                              : null,
                                        ),
                                        // const SizedBox(height: 16),
                                        // TextFormField(
                                        //   controller: _text2questionController,
                                        //   maxLines: 3,
                                        //   decoration: InputDecoration(
                                        //     labelText: 'Text After Blank',
                                        //     filled: true,
                                        //     fillColor: Colors.grey[100],
                                        //     border: OutlineInputBorder(
                                        //       borderRadius:
                                        //           BorderRadius.circular(12),
                                        //       borderSide: BorderSide.none,
                                        //     ),
                                        //     contentPadding:
                                        //         const EdgeInsets.symmetric(
                                        //             horizontal: 16,
                                        //             vertical: 14),
                                        //     prefixIcon: Icon(Icons.text_fields,
                                        //         color: Colors.black54),
                                        //   ),
                                        //   // validator: (value) => value == null ||
                                        //   //         value.isEmpty
                                        //   //     ? "Please enter text after blank"
                                        //   //     : null,
                                        // ),
                                        // const SizedBox(height: 16),
                                        // TextFormField(
                                        //   controller: _answerController,
                                        //   maxLines: 3,
                                        //   decoration: InputDecoration(
                                        //     labelText: 'Answer',
                                        //     filled: true,
                                        //     fillColor: Colors.grey[100],
                                        //     border: OutlineInputBorder(
                                        //       borderRadius:
                                        //           BorderRadius.circular(12),
                                        //       borderSide: BorderSide.none,
                                        //     ),
                                        //     contentPadding:
                                        //         const EdgeInsets.symmetric(
                                        //             horizontal: 16,
                                        //             vertical: 14),
                                        //     prefixIcon: Icon(Icons.check_circle,
                                        //         color: Colors.black54),
                                        //   ),
                                        //   validator: (value) =>
                                        //       value == null || value.isEmpty
                                        //           ? "Please enter the answer"
                                        //           : null,
                                        // ),
                                        const SizedBox(height: 16),
                                        DropdownButtonFormField<String>(
                                          value: _selectedSubject,
                                          hint: const Text("Select Subject"),
                                          decoration: InputDecoration(
                                            labelText: 'Subject',
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 14),
                                            prefixIcon: Icon(Icons.book,
                                                color: Colors.black54),
                                          ),
                                          items: _subjectList.map((subject) {
                                            return DropdownMenuItem<String>(
                                              value: subject['id'].toString(),
                                              child: Text(
                                                  subject['subject_name'] ??
                                                      'N/A'),
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
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 14),
                                            prefixIcon: Icon(Icons.stairs,
                                                color: Colors.black54),
                                          ),
                                          items: _levelList.map((level) {
                                            return DropdownMenuItem<String>(
                                              value: level['id'].toString(),
                                              child: Text(
                                                  level['level_name'] ?? 'N/A'),
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
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 14),
                                            prefixIcon: Icon(Icons.trending_up,
                                                color: Colors.black54),
                                          ),
                                          items: List.generate(4, (index) {
                                            return DropdownMenuItem<int>(
                                              value: index + 1,
                                              child:
                                                  Text((index + 1).toString()),
                                            );
                                          }),
                                          onChanged: (value) => setState(
                                              () => _selectedNumber = value),
                                          validator: (value) => value == null
                                              ? "Please select a question level"
                                              : null,
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: _pickImage,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black87,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                elevation: 0,
                                              ),
                                              child: const Text("Pick Image"),
                                            ),
                                            const SizedBox(width: 16),
                                            _pickedImage != null
                                                ? SizedBox(
                                                    width: 80,
                                                    height: 80,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: _pickedImage!
                                                                  .bytes !=
                                                              null
                                                          ? Image.memory(
                                                              Uint8List.fromList(
                                                                  _pickedImage!
                                                                      .bytes!),
                                                              fit: BoxFit.cover)
                                                          : Image.file(
                                                              File(_pickedImage!
                                                                  .path!),
                                                              fit:
                                                                  BoxFit.cover),
                                                    ),
                                                  )
                                                : const Text(
                                                    "No image selected",
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                            onPressed: insert,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black87,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              elevation: 0,
                                            ),
                                            child: const Text("Add Question"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                        ),
                        const SizedBox(height: 24),

                        // Questions List
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _fillquestionList.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(20),
                                  child: const Center(
                                    child: Text(
                                      "No questions yet",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                              : DataTable(
                                  columnSpacing: 24,
                                  dataRowHeight: 56,
                                  headingRowHeight: 56,
                                  headingRowColor:
                                      WidgetStateProperty.all(Colors.grey[100]),
                                  border: TableBorder(
                                      horizontalInside: BorderSide(
                                          color: Colors.grey[200]!, width: 1)),
                                  columns: const [
                                    DataColumn(
                                        label: Text("No.",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Text Before Blank",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    // DataColumn(
                                    //     label: Text("Text After Blank",
                                    //         style: TextStyle(
                                    //             fontWeight: FontWeight.bold))),
                                    // DataColumn(
                                    //     label: Text("Answer",
                                    //         style: TextStyle(
                                    //             fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Subject",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Level",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Q. Level",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Image",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Choices",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Delete",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                  ],
                                  rows: _fillquestionList
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final int index = entry.key;
                                    final Map<String, dynamic> fillquestion =
                                        entry.value;
                                    final level =
                                        fillquestion['tbl_level'] ?? {};
                                    final subject =
                                        fillquestion['tbl_subject'] ?? {};
                                    final int id = fillquestion['id'];
                                    return DataRow(cells: [
                                      DataCell(Text((index + 1).toString())),
                                      DataCell(
                                        Container(
                                          width: 200,
                                          child: Text(
                                            fillquestion['qstn_text1'] ?? 'N/A',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      // DataCell(
                                      //   Container(
                                      //     width: 200,
                                      //     child: Text(
                                      //       fillquestion['qstn_text2'] ?? 'N/A',
                                      //       overflow: TextOverflow.ellipsis,
                                      //     ),
                                      //   ),
                                      // ),
                                      // DataCell(
                                      //   Text(
                                      //     fillquestion['qstn_answer'] ?? 'N/A',
                                      //     style: const TextStyle(
                                      //         color: Colors.green),
                                      //   ),
                                      // ),
                                      DataCell(Text(
                                          subject['subject_name'] ?? 'N/A')),
                                      DataCell(
                                          Text(level['level_name'] ?? 'N/A')),
                                      DataCell(Text(fillquestion['qstn_level']
                                              ?.toString() ??
                                          'N/A')),
                                      DataCell(
                                        fillquestion['image'] != null &&
                                                fillquestion['image'].isNotEmpty
                                            ? GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        Dialog(
                                                      child: Image.network(
                                                        fillquestion['image'],
                                                        fit: BoxFit.contain,
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            const Text(
                                                                "Failed to load image"),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          fillquestion[
                                                              'image']),
                                                      fit: BoxFit.cover,
                                                      onError: (exception,
                                                              stackTrace) =>
                                                          const Icon(
                                                              Icons.error),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const Text("No Image"),
                                      ),
                                      DataCell(
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black87,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            elevation: 0,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddTFChoice(id: id)),
                                            ).then((_) => fetchFillquestions());
                                          },
                                          child: const Text("Add Choices"),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red[600]),
                                          onPressed: () => delete(id),
                                          hoverColor: Colors.red[50],
                                        ),
                                      ),
                                    ]);
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
