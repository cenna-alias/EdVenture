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
  int? _editingId;

  Future<void> submit() async {
    try {
      if (_editingId != null) {
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
        _editingId = null;
      } else {
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
      backgroundColor: const Color(0xFF1A1A1A), // Deep black background
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0), // Increased padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stairs,
                          color: const Color(0xFF8A4AF0), // Purple
                          size: 32),
                      const SizedBox(width: 12),
                      Text(
                        'Levels',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white, // White text
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A4AF0), // Purple
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
              const SizedBox(height: 32),
              AnimatedContainer(
                duration: _animationDuration,
                curve: Curves.easeInOut,
                child: _isFormVisible
                    ? Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A), // Lighter black
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _editingId != null ? "Edit Level" : "New Level",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white, // White text
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _levelnameController,
                              decoration: InputDecoration(
                                labelText: 'Level Name',
                                labelStyle: TextStyle(
                                    color: Colors.white70), // Subtle white
                                filled: true,
                                fillColor:
                                    const Color(0xFF2A2A2A), // Lighter black
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.grey[800]!, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.grey[800]!, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF8A4AF0),
                                      width: 1.5), // Purple
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                prefixIcon: Icon(Icons.stairs,
                                    color: const Color(0xFF8A4AF0)), // Purple
                              ),
                              style: const TextStyle(
                                  color: Colors.white), // White input text
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _timeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Time (in minutes)',
                                labelStyle: TextStyle(
                                    color: Colors.white70), // Subtle white
                                filled: true,
                                fillColor:
                                    const Color(0xFF2A2A2A), // Lighter black
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.grey[800]!, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors.grey[800]!, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF8A4AF0),
                                      width: 1.5), // Purple
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                prefixIcon: Icon(Icons.timer,
                                    color: const Color(0xFF8A4AF0)), // Purple
                              ),
                              style: const TextStyle(
                                  color: Colors.white), // White input text
                            ),
                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF8A4AF0), // Purple
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
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
                      )
                    : Container(),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A), // Lighter black
                  borderRadius:
                      BorderRadius.circular(16), // Increased for circular edges
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      16), // Matches container for full circular effect
                  child: _levelList.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              "No levels yet",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70, // Subtle white
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      : DataTable(
                          columnSpacing: 24,
                          dataRowHeight: 64,
                          headingRowHeight: 56,
                          headingRowColor: WidgetStateProperty.all(
                              const Color(0xFF2A2A2A)), // Lighter black
                          border: TableBorder(
                            horizontalInside:
                                BorderSide(color: Colors.grey[800]!, width: 1),
                            top: BorderSide(color: Colors.grey[800]!, width: 1),
                            bottom:
                                BorderSide(color: Colors.grey[800]!, width: 1),
                            left:
                                BorderSide(color: Colors.grey[800]!, width: 1),
                            right:
                                BorderSide(color: Colors.grey[800]!, width: 1),
                          ),
                          columns: const [
                            DataColumn(
                                label: Text("No.",
                                    style: TextStyle(
                                        fontSize: 16, // Medium size
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white))), // Bright white
                            DataColumn(
                                label: Text("Level",
                                    style: TextStyle(
                                        fontSize: 16, // Medium size
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white))), // Bright white
                            DataColumn(
                                label: Text("Time",
                                    style: TextStyle(
                                        fontSize: 16, // Medium size
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white))), // Bright white
                            DataColumn(
                                label: Text("Actions",
                                    style: TextStyle(
                                        fontSize: 16, // Medium size
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white))), // Bright white
                          ],
                          rows: _levelList.asMap().entries.map((entry) {
                            return DataRow(
                              cells: [
                                DataCell(Text((entry.key + 1).toString(),
                                    style: const TextStyle(
                                        fontSize: 16, // Medium size
                                        color: Colors.white))), // Bright white
                                DataCell(
                                  Container(
                                    width: 200,
                                    child: Text(
                                      entry.value['level_name']?.toString() ??
                                          'N/A',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 16, // Medium size
                                          color: Colors.white), // Bright white
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    width: 150,
                                    child: Text(
                                      "${entry.value['level_time']?.toString() ?? '0'} min",
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 16, // Medium size
                                          color: Colors.white), // Bright white
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Color(0xFF8A4AF0)), // Purple
                                        onPressed: () => editLevel(entry.value),
                                        hoverColor: const Color(0xFF8A4AF0)
                                            .withOpacity(0.1),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color:
                                                Color(0xFFF06292)), // Soft pink
                                        onPressed: () =>
                                            delete(entry.value['id']),
                                        hoverColor: const Color(0xFFF06292)
                                            .withOpacity(0.1),
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
