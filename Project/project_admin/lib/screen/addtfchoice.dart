import 'package:flutter/material.dart';
import 'package:project_admin/main.dart';

class AddTFChoice extends StatefulWidget {
  final int id;
  const AddTFChoice({super.key, required this.id});

  @override
  State<AddTFChoice> createState() => _AddTFChoiceState();
}

class _AddTFChoiceState extends State<AddTFChoice> {
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
        await supabase.from('tbl_addtfchoice').update({
          'is_correct': false,
        }).eq('question_id', widget.id);
      }

      await supabase.from("tbl_addtfchoice").insert({
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
        _isFormVisible = false;
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
          .from('tbl_addtfchoice')
          .select()
          .eq('question_id', widget.id);
      setState(() {
        _answerList = (response as List<dynamic>?)
                ?.map((item) => item as Map<String, dynamic>)
                .toList() ??
            [];
      });
    } catch (e) {
      print("ERROR FETCHING DATA: $e");
      setState(() => _errorMessage = "Error fetching choices: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_addtfchoice').delete().eq('id', id);
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
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Manage T/F Choices',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black87, Colors.grey[800]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                strokeWidth: 5,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Container(
                    width: 350,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red[600], size: 40),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadInitialData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Retry",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.list_alt,
                                    color: Colors.black87, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Choices for T/F Question ${widget.id}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
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
                                  onPressed: () => setState(
                                      () => _isFormVisible = !_isFormVisible),
                                  icon: Icon(
                                      _isFormVisible ? Icons.close : Icons.add,
                                      size: 18),
                                  label: Text(_isFormVisible ? "Close" : "Add",
                                      style: const TextStyle(fontSize: 14)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            AnimatedContainer(
                              duration: _animationDuration,
                              curve: Curves.easeInOut,
                              child: _isFormVisible
                                  ? Container(
                                      width: 350,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
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
                                            Text(
                                              "New Choice",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            TextFormField(
                                              controller: _answerController,
                                              maxLines: 2,
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
                                                        horizontal: 12,
                                                        vertical: 12),
                                                prefixIcon: Icon(
                                                    Icons.question_answer,
                                                    color: Colors.grey[600]),
                                              ),
                                              validator: (value) =>
                                                  value == null || value.isEmpty
                                                      ? "Answer is required"
                                                      : null,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              "Is Correct:",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: RadioListTile<bool>(
                                                    title: const Text('True',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                    value: true,
                                                    groupValue: isCorrect,
                                                    onChanged: (value) =>
                                                        setState(() =>
                                                            isCorrect = value),
                                                    activeColor: Colors.black87,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: RadioListTile<bool>(
                                                    title: const Text('False',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                    value: false,
                                                    groupValue: isCorrect,
                                                    onChanged: (value) =>
                                                        setState(() =>
                                                            isCorrect = value),
                                                    activeColor: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: ElevatedButton(
                                                onPressed: submit,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.black87,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                  elevation: 0,
                                                ),
                                                child: const Text("Add Choice",
                                                    style: TextStyle(
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
                            const SizedBox(height: 20),
                            Container(
                              width: 350,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: _answerList.isEmpty
                                  ? Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Center(
                                        child: Text(
                                          "No choices yet",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                  : DataTable(
                                      columnSpacing: 8,
                                      dataRowHeight: 48,
                                      headingRowHeight: 48,
                                      horizontalMargin: 8,
                                      headingRowColor: WidgetStateProperty.all(
                                          Colors.grey[100]),
                                      columns: [
                                        DataColumn(
                                          label: Center(
                                            child: Text(
                                              "No.",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Center(
                                            child: Text(
                                              "Answer",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Center(
                                            child: Text(
                                              "Is Correct",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Center(
                                            child: Text(
                                              "Delete",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: _answerList
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final int index = entry.key;
                                        final Map<String, dynamic> answer =
                                            entry.value;
                                        return DataRow(cells: [
                                          DataCell(
                                            Center(
                                              child: Text(
                                                (index + 1).toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Center(
                                              child: Text(
                                                answer['answer'] ?? 'N/A',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Center(
                                              child: Text(
                                                answer['is_correct'] == true
                                                    ? "CORRECT"
                                                    : "INCORRECT",
                                                style: TextStyle(
                                                  color: answer['is_correct'] ==
                                                          true
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Center(
                                              child: IconButton(
                                                icon: Icon(Icons.delete,
                                                    color: Colors.red[600],
                                                    size: 20),
                                                onPressed: () =>
                                                    delete(answer['id']),
                                                hoverColor: Colors.red[50],
                                              ),
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
                  ),
                ),
    );
  }
}
