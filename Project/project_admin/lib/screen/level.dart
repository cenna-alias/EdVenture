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
  final TextEditingController _difficultyController = TextEditingController();
  PlatformFile? pickedImage;
  List<Map<String, dynamic>> _levelList = [];

  Future<void> submit() async {
    try {
      await supabase.from("tbl_level").insert({
        "level_name": _levelnameController.text,
        "level_difficulty": _difficultyController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Level inserted",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
    } catch (e) {}
  }

  Future<void> fetchLevel() async {
    try {
      final response = await supabase.from('tbl_level').select();
      setState(() {
        _levelList = response;
      });
    } catch (e) {
      print("ERROR FETCHING DATA:$e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_level').delete().eq('id', id);
      fetchLevel();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Level Deleted",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Failed",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      print("ERROR DELETING DATA:$e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Manage Level'),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF161616),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 18)),
              onPressed: () {
                setState(() {
                  _isFormVisible = !_isFormVisible;
                });
              },
              label: Text(
                _isFormVisible ? "Cancel" : "Add Level",
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(
                _isFormVisible ? Icons.cancel : Icons.add,
                color: Colors.white,
              ),
            )
          ],
        ),
        SizedBox(
          height: 50,
        ),
        AnimatedSize(
          duration: _animationDuration,
          curve: Curves.easeInOut,
          child: _isFormVisible
              ? Form(
                  child: Container(
                      width: 1000,
                      decoration: BoxDecoration(
                        // color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _levelnameController,
                                      decoration: InputDecoration(
                                          labelText: 'Level',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5))),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    TextFormField(
                                      controller: _difficultyController,
                                      decoration: InputDecoration(
                                          labelText: 'Difficulty',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5))),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    submit();
                                  },
                                  child: Text("Submit")),
                            ],
                          ),
                        ],
                      )),
                )
              : Container(),
        ),
        DataTable(
          columns: [
            DataColumn(label: Text("Sl.No")),
            DataColumn(label: Text("Level")),
            DataColumn(label: Text("Difficulty")),
            DataColumn(label: Text("Action")),
          ],
          rows: _levelList.asMap().entries.map((entry) {
            print(entry.value);
            return DataRow(cells: [
              DataCell(Text((entry.key + 1).toString())),
              DataCell(Text(entry.value['level_name'])),
              DataCell(Text(entry.value['level_difficulty'])),
              DataCell(IconButton(
                  onPressed: () {
                    delete(entry.value['id']);
                  },
                  icon: Icon(Icons.delete_outline))),
            ]);
          }).toList(),
        )
      ],
    );
  }
}
