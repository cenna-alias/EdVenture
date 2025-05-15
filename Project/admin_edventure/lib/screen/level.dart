import 'package:flutter/material.dart';
import 'package:project_admin/main.dart';
import 'package:file_picker/file_picker.dart';

class Level extends StatefulWidget {
  const Level({super.key});

  @override
  State<Level> createState() => _LevelState();
}

class _LevelState extends State<Level> with SingleTickerProviderStateMixin {
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final TextEditingController _levelnameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); 
  PlatformFile? pickedImage;
  List<Map<String, dynamic>> _levelList = [];
  int? _editingId;

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) {
      return; 
    }

    try {
      if (_editingId != null) {
        await supabase.from("tbl_level").update({
          "level_name": _levelnameController.text.trim(),
          "level_time": int.parse(_timeController.text),
        }).eq('id', _editingId!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Level updated successfully"),
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
        await supabase.from("tbl_level").insert({
          "level_name": _levelnameController.text.trim(),
          "level_time": int.parse(_timeController.text),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Level added successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      fetchLevel();
      _levelnameController.clear();
      _timeController.clear();
      setState(() => _isFormVisible = false);
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save level: $e"),
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

  Future<void> fetchLevel() async {
    try {
      final response = await supabase.from('tbl_level').select();
      setState(() => _levelList = List<Map<String, dynamic>>.from(response));
    } catch (e) {
      print("ERROR FETCHING DATA: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch levels: $e"),
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
      await supabase.from('tbl_level').delete().eq('id', id);
      fetchLevel();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Level deleted successfully"),
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
          content: const Text("Failed to delete level"),
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

  void editLevel(Map<String, dynamic> level) {
    setState(() {
      _isFormVisible = true;
      _editingId = level['id'];
      _levelnameController.text = level['level_name']?.toString() ?? '';
      _timeController.text = level['level_time']?.toString() ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    fetchLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
                    onPressed: () =>
                        setState(() => _isFormVisible = !_isFormVisible),
                    icon: Icon(_isFormVisible ? Icons.close : Icons.add,
                        size: 20),
                    label: Text(_isFormVisible ? "Close" : "Add New",
                        style: const TextStyle(fontWeight: FontWeight.w600)),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _levelnameController,
                                  decoration: InputDecoration(
                                    labelText: 'Level Name',
                                    labelStyle:
                                        TextStyle(color: Colors.grey[600]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.deepPurpleAccent,
                                          width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.deepPurpleAccent,
                                          width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.deepPurpleAccent,
                                          width: 1.5),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    prefixIcon: Icon(Icons.stacked_bar_chart,
                                        color: Colors.deepPurpleAccent),
                                  ),
                                  style: const TextStyle(color: Colors.black87),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a level name';
                                    }
                                    if (value.trim().length > 50) {
                                      return 'Level name must be 50 characters or less';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _timeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Time (in seconds)',
                                    labelStyle:
                                        TextStyle(color: Colors.grey[600]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.deepPurpleAccent,
                                          width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.deepPurpleAccent,
                                          width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.deepPurpleAccent,
                                          width: 1.5),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    prefixIcon: Icon(Icons.timer,
                                        color: Colors.deepPurpleAccent),
                                  ),
                                  style: const TextStyle(color: Colors.black87),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter time';
                                    }
                                    final time = int.tryParse(value);
                                    if (time == null) {
                                      return 'Please enter a valid number';
                                    }
                                    if (time <= 0) {
                                      return 'Time must be greater than 0';
                                    }
                                    if (time > 3600) {
                                      return 'Time must be less than 3600 seconds';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurpleAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 32, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      elevation: 2,
                                    ),
                                    child: Text(
                                        _editingId != null
                                            ? "Update Level"
                                            : "Add Level",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
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
                  width: 600,
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _levelList.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                "No levels yet",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : DataTable(
                            columnSpacing: 16,
                            dataRowHeight: 56,
                            headingRowHeight: 48,
                            headingRowColor:
                                WidgetStateProperty.all(Colors.grey[100]),
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                  color: Colors.deepPurpleAccent, width: 1),
                              top: BorderSide(
                                  color: Colors.deepPurpleAccent, width: 1),
                              bottom: BorderSide(
                                  color: Colors.deepPurpleAccent, width: 1),
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
                                  width: 250,
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
                                  width: 120,
                                  child: Center(
                                    child: Text(
                                      "Time",
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
                                  width: 120,
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
                            rows: _levelList.asMap().entries.map((entry) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: 40,
                                      child: Center(
                                        child: Text(
                                          (entry.key + 1).toString(),
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 250,
                                      child: Center(
                                        child: Text(
                                          entry.value['level_name']
                                                  ?.toString() ??
                                              'N/A',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 120,
                                      child: Center(
                                        child: Text(
                                          "${entry.value['level_time']?.toString() ?? '0'} secs",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 120,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit,
                                                  color: Colors.greenAccent,
                                                  size: 20),
                                              onPressed: () =>
                                                  editLevel(entry.value),
                                              hoverColor: Colors.greenAccent
                                                  .withOpacity(0.1),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.redAccent,
                                                  size: 20),
                                              onPressed: () =>
                                                  delete(entry.value['id']),
                                              hoverColor: Colors.redAccent
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
            ],
          ),
        ),
      ),
    );
  }
}
