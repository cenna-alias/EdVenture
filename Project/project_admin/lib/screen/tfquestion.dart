import 'package:flutter/material.dart';
import 'package:project_admin/main.dart';

class Tfquestion extends StatefulWidget {
  const Tfquestion({super.key});

  @override
  State<Tfquestion> createState() => _TfquestionState();
}

class _TfquestionState extends State<Tfquestion> {
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tfquestionController = TextEditingController();

  List<Map<String, dynamic>> _levelList = [];
  String? _selectedLevel;

  List<Map<String, dynamic>> _subjectList = [];
  String? _selectedSubject;

  List<Map<String, dynamic>> _questionList = [];
  int? _selectedNumber;

  List<Map<String, dynamic>> _tfquestionList = [];
  bool? isCorrect;
  bool _isLoading = true;
  String? _errorMessage;
  int? _editingQuestionId; // To track which question is being edited

  Future<void> insert() async {
    if (!_formKey.currentState!.validate()) return;

    if (isCorrect == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select True or False"),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await supabase.from("tbl_tfquestion").insert({
        "question_text": _tfquestionController.text,
        "level": _selectedLevel,
        "subject": _selectedSubject,
        "question_iscorrect": isCorrect,
        "question_level": _selectedNumber,
      }).select();

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

      _tfquestionController.clear();
      setState(() {
        _selectedLevel = null;
        _selectedSubject = null;
        isCorrect = null;
        _isFormVisible = false;
        _editingQuestionId = null;
      });

      await fetchTfquestions();
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

    if (isCorrect == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select True or False"),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await supabase.from("tbl_tfquestion").update({
        "question_text": _tfquestionController.text,
        "level": _selectedLevel,
        "subject": _selectedSubject,
        "question_iscorrect": isCorrect,
        "question_level": _selectedNumber,
      }).eq('id', id);

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

      _tfquestionController.clear();
      setState(() {
        _selectedLevel = null;
        _selectedSubject = null;
        isCorrect = null;
        _isFormVisible = false;
        _editingQuestionId = null;
      });

      await fetchTfquestions();
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

  Future<void> fetchTfquestions() async {
    try {
      final response = await supabase
          .from('tbl_tfquestion')
          .select("*, tbl_level(*), tbl_subject(*)");
      setState(() {
        _tfquestionList = List<Map<String, dynamic>>.from(response ?? []);
        _tfquestionList.sort((a, b) => a['id'].compareTo(b['id']));
      });
    } catch (e) {
      print("Error fetching questions: $e");
      setState(() => _errorMessage = "Error fetching questions: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_tfquestion').delete().eq('id', id);
      await fetchTfquestions();
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
      _tfquestionController.text = question['question_text'] ?? '';
      _selectedLevel = question['level'].toString();
      _selectedSubject = question['subject'].toString();
      _selectedNumber = question['question_level'];
      isCorrect = question['question_iscorrect'];
      _isFormVisible = true;
    });
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
        fetchTfquestions(),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle_outline,
                                    color: Colors.black87, size: 28),
                                const SizedBox(width: 12),
                                Text(
                                  'True/False Questions',
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
                              onPressed: () => setState(() {
                                _isFormVisible = !_isFormVisible;
                                if (!_isFormVisible) {
                                  _tfquestionController.clear();
                                  _selectedLevel = null;
                                  _selectedSubject = null;
                                  _selectedNumber = null;
                                  isCorrect = null;
                                  _editingQuestionId = null;
                                }
                              }),
                              icon: Icon(
                                  _isFormVisible ? Icons.close : Icons.add,
                                  size: 20),
                              label: Text(_isFormVisible ? "Close" : "Add New"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
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
                                          _editingQuestionId != null
                                              ? "Edit True/False Question"
                                              : "New True/False Question",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        TextFormField(
                                          controller: _tfquestionController,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            labelText: 'Question',
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
                                            prefixIcon: Icon(
                                                Icons.question_answer,
                                                color: Colors.black54),
                                          ),
                                          validator: (value) =>
                                              value == null || value.isEmpty
                                                  ? "Please enter a question"
                                                  : null,
                                        ),
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
                                        Text(
                                          "Is Correct:",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: RadioListTile<bool>(
                                                title: const Text('True'),
                                                value: true,
                                                groupValue: isCorrect,
                                                onChanged: (value) => setState(
                                                    () => isCorrect = value),
                                                activeColor: Colors.black87,
                                              ),
                                            ),
                                            Expanded(
                                              child: RadioListTile<bool>(
                                                title: const Text('False'),
                                                value: false,
                                                groupValue: isCorrect,
                                                onChanged: (value) => setState(
                                                    () => isCorrect = value),
                                                activeColor: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                _editingQuestionId != null
                                                    ? update(
                                                        _editingQuestionId!)
                                                    : insert(),
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
                                            child: Text(
                                                _editingQuestionId != null
                                                    ? "Update Question"
                                                    : "Add Question"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                        ),
                        const SizedBox(height: 24),
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
                          child: _tfquestionList.isEmpty
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
                                        label: Text("Question",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Answer",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
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
                                        label: Text("Edit",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Delete",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                  ],
                                  rows: _tfquestionList
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final int index = entry.key;
                                    final Map<String, dynamic> tfquestion =
                                        entry.value;
                                    final level = tfquestion['tbl_level'] ?? {};
                                    final subject =
                                        tfquestion['tbl_subject'] ?? {};
                                    final int id = tfquestion['id'];
                                    return DataRow(cells: [
                                      DataCell(Text((index + 1).toString())),
                                      DataCell(
                                        Container(
                                          width: 200,
                                          child: Text(
                                            tfquestion['question_text'] ??
                                                'N/A',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          tfquestion['question_iscorrect'] ==
                                                  true
                                              ? "True"
                                              : "False",
                                          style: TextStyle(
                                            color: tfquestion[
                                                        'question_iscorrect'] ==
                                                    true
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(
                                          subject['subject_name'] ?? 'N/A')),
                                      DataCell(
                                          Text(level['level_name'] ?? 'N/A')),
                                      DataCell(Text(tfquestion['question_level']
                                              ?.toString() ??
                                          'N/A')),
                                      DataCell(
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.blue[600]),
                                          onPressed: () =>
                                              _editQuestion(tfquestion),
                                          hoverColor: Colors.blue[50],
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
