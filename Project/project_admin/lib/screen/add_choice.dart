import 'package:flutter/material.dart';
import 'package:project_admin/main.dart';

class AddChoice extends StatefulWidget {
  final int id;
  const AddChoice({super.key, required this.id});

  @override
  State<AddChoice> createState() => _AddChoiceState();
}

class _AddChoiceState extends State<AddChoice> {
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _answerController = TextEditingController();
  List<Map<String, dynamic>> _answerList = [];
  bool? isCorrect;
  bool _isLoading = true;
  String? _errorMessage;

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (isCorrect == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select if the answer is correct"),
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
      if (_answerList.length >= 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Maximum number of choices added (4)!"),
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

      if (isCorrect!) {
        await supabase.from('tbl_choice').update({
          'is_correct': false,
        }).eq('question_id', widget.id);
      }

      await supabase.from("tbl_choice").insert({
        "answer": _answerController.text,
        "question_id": widget.id,
        "is_correct": isCorrect ?? false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Choice added successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );

      _answerController.clear();
      setState(() {
        isCorrect = null;
        _isFormVisible = false; // Hide form after adding
      });

      await fetchAnswer();
    } catch (e) {
      print("ERROR INSERTING DATA: $e");
      setState(() => _errorMessage = "Failed to insert choice: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to insert choice: $e"),
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

  Future<void> fetchAnswer() async {
    try {
      final response = await supabase
          .from('tbl_choice')
          .select()
          .eq('question_id', widget.id);
      setState(() {
        _answerList = List<Map<String, dynamic>>.from(response ?? []);
      });
    } catch (e) {
      print("ERROR FETCHING DATA: $e");
      setState(() => _errorMessage = "Error fetching choices: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_choice').delete().eq('id', id);
      await fetchAnswer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Choice deleted successfully"),
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
          content: const Text("Failed to delete choice"),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() => _errorMessage = "Error deleting choice: $e");
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
      await fetchAnswer();
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
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.list_alt,
                                    color: Colors.black87, size: 28),
                                const SizedBox(width: 12),
                                Text(
                                  'Choices for Question ${widget.id}',
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
                                          "New Choice",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        TextFormField(
                                          controller: _answerController,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            labelText: 'Answer Choice',
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
                                                  ? "Answer is required"
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
                                            onPressed: submit,
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
                                            child: const Text("Add Choice"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                        ),
                        const SizedBox(height: 24),

                        // Choices List
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
                          child: _answerList.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(20),
                                  child: const Center(
                                    child: Text(
                                      "No choices yet",
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
                                        label: Text("Answer",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Is Correct",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Delete",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                  ],
                                  rows:
                                      _answerList.asMap().entries.map((entry) {
                                    final int index = entry.key;
                                    final Map<String, dynamic> answer =
                                        entry.value;
                                    return DataRow(cells: [
                                      DataCell(Text((index + 1).toString())),
                                      DataCell(
                                        Container(
                                          width: 300,
                                          child: Text(
                                            answer['answer'] ?? 'N/A',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          answer['is_correct'] == true
                                              ? "CORRECT"
                                              : "INCORRECT",
                                          style: TextStyle(
                                            color: answer['is_correct'] == true
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red[600]),
                                          onPressed: () => delete(answer['id']),
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
