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
  PlatformFile? pickedImage;
  List<Map<String, dynamic>> _levelList = [];
  int? _editingId; // Added to track which level is being edited

  Future<void> submit() async {
    try {
      if (_editingId != null) {
        // Update existing level
        await supabase.from("tbl_level").update({
          "level_name": _levelnameController.text,
          "level_time": int.tryParse(_timeController.text) ?? 0,
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
        _editingId = null; // Reset editing state
      } else {
        // Add new level
        await supabase.from("tbl_level").insert({
          "level_name": _levelnameController.text,
          "level_time": int.tryParse(_timeController.text) ?? 0,
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stairs, color: Colors.black87, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Levels',
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
                    onPressed: () =>
                        setState(() => _isFormVisible = !_isFormVisible),
                    icon: Icon(_isFormVisible ? Icons.close : Icons.add,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _editingId != null ? "Edit Level" : "New Level",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _levelnameController,
                              decoration: InputDecoration(
                                labelText: 'Level Name',
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                prefixIcon:
                                    Icon(Icons.stairs, color: Colors.black54),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _timeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Time (in minutes)',
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                prefixIcon:
                                    Icon(Icons.timer, color: Colors.black54),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: Text(_editingId != null
                                    ? "Update Level"
                                    : "Add Level"),
                              ),
                            ),
                          ],
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
                child: _levelList.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
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
                        columnSpacing: 24,
                        dataRowHeight: 56,
                        headingRowHeight: 56,
                        headingRowColor:
                            WidgetStateProperty.all(Colors.grey[100]),
                        border: TableBorder(
                          horizontalInside:
                              BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                        columns: const [
                          DataColumn(
                              label: Text("No.",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text("Level",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text("Time",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text("Actions",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _levelList.asMap().entries.map((entry) {
                          return DataRow(
                            cells: [
                              DataCell(Text((entry.key + 1).toString())),
                              DataCell(
                                Container(
                                  width: 200,
                                  child: Text(
                                    entry.value['level_name']?.toString() ??
                                        'N/A',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: 150,
                                  child: Text(
                                    "${entry.value['level_time']?.toString() ?? '0'} min",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit,
                                          color: Colors.blue[600]),
                                      onPressed: () => editLevel(entry.value),
                                      hoverColor: Colors.blue[50],
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete,
                                          color: Colors.red[600]),
                                      onPressed: () =>
                                          delete(entry.value['id']),
                                      hoverColor: Colors.red[50],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
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
