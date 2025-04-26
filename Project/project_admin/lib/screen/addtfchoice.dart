import 'package:flutter/material.dart';
import 'package:project_admin/main.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Manage T/F Choices',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A1B9A)),
                strokeWidth: 6,
                backgroundColor: Colors.grey[200],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Container(
                    width: 340,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red[600], size: 48),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.roboto(
                            color: Colors.red[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadInitialData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6A1B9A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: Text(
                            "Retry",
                            style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 24.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF6A1B9A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 2,
                                  ),
                                  onPressed: () => setState(
                                      () => _isFormVisible = !_isFormVisible),
                                  icon: Icon(
                                      _isFormVisible ? Icons.close : Icons.add,
                                      size: 20),
                                  label: Text(
                                    _isFormVisible ? "Close" : "Add",
                                    style: GoogleFonts.roboto(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            AnimatedContainer(
                              duration: _animationDuration,
                              curve: Curves.easeInOut,
                              child: _isFormVisible
                                  ? Container(
                                      width: 450,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.grey.withOpacity(0.15),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
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
                                              style: GoogleFonts.roboto(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF6A1B9A),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            TextFormField(
                                              controller: _answerController,
                                              maxLines: 2,
                                              decoration: InputDecoration(
                                                labelText: 'Answer Choice',
                                                labelStyle: GoogleFonts.roboto(
                                                    color: Colors.grey[600]),
                                                filled: true,
                                                fillColor: Colors.grey[100],
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF6A1B9A),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 14),
                                                prefixIcon: Icon(
                                                    Icons.question_answer,
                                                    color: Color(0xFF6A1B9A)),
                                              ),
                                              style: GoogleFonts.roboto(
                                                  fontSize: 16),
                                              validator: (value) =>
                                                  value == null || value.isEmpty
                                                      ? "Answer is required"
                                                      : null,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              "Is Correct:",
                                              style: GoogleFonts.roboto(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF6A1B9A),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: RadioListTile<bool>(
                                                    title: Text(
                                                      'True',
                                                      style: GoogleFonts.roboto(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 15),
                                                    ),
                                                    value: true,
                                                    groupValue: isCorrect,
                                                    onChanged: (value) =>
                                                        setState(() =>
                                                            isCorrect = value),
                                                    activeColor:
                                                        Color(0xFF6A1B9A),
                                                    dense: true,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: RadioListTile<bool>(
                                                    title: Text(
                                                      'False',
                                                      style: GoogleFonts.roboto(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 15),
                                                    ),
                                                    value: false,
                                                    groupValue: isCorrect,
                                                    onChanged: (value) =>
                                                        setState(() =>
                                                            isCorrect = value),
                                                    activeColor:
                                                        Color(0xFF6A1B9A),
                                                    dense: true,
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
                                                      Color(0xFF6A1B9A),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 24,
                                                      vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                  elevation: 2,
                                                ),
                                                child: Text(
                                                  "Add Choice",
                                                  style: GoogleFonts.roboto(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16),
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
                            Container(
                              width: 500,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: _answerList.isEmpty
                                  ? Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Center(
                                        child: Text(
                                          "No choices yet",
                                          style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                  : DataTable(
                                      columnSpacing: 20,
                                      dataRowHeight: 56,
                                      headingRowHeight: 56,
                                      horizontalMargin: 16,
                                      headingRowColor: WidgetStateProperty.all(
                                          Colors.grey[100]),
                                      columns: [
                                        DataColumn(
                                          label: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 16),
                                            child: Text(
                                              "No.",
                                              style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF6A1B9A),
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Text(
                                              "Answer",
                                              style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF6A1B9A),
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16),
                                            child: Text(
                                              "Is Correct",
                                              style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF6A1B9A),
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16),
                                            child: Text(
                                              "Delete",
                                              style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF6A1B9A),
                                                fontSize: 15,
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
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16),
                                              child: Text(
                                                (index + 1).toString(),
                                                style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF6A1B9A),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8),
                                              child: Text(
                                                answer['answer'] ?? 'N/A',
                                                style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF6A1B9A),
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 16),
                                              child: Text(
                                                answer['is_correct'] == true
                                                    ? "CORRECT"
                                                    : "INCORRECT",
                                                style: TextStyle(
                                                  color: answer['is_correct'] ==
                                                          true
                                                      ? Colors.green[600]
                                                      : Colors.red[600],
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 16),
                                              child: IconButton(
                                                icon: Icon(Icons.delete,
                                                    color: Colors.red[600],
                                                    size: 22),
                                                onPressed: () =>
                                                    delete(answer['id']),
                                                hoverColor: Colors.red[50],
                                                splashRadius: 20,
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
