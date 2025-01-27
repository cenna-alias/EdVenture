import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:project_admin/main.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category>
    with SingleTickerProviderStateMixin {
  bool _isFormVisible = false;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  PlatformFile? pickedImage;

  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Only single file upload
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
    }
  }

  List<Map<String, dynamic>> _categoryList = [];

  get category => null;

  Future<void> insert() async {
    try {
      final response = await supabase.from("tbl_category").insert({
        "category_name": _nameController.text,
        "category_description": _descriptionController.text,
      }).select();
      print("response: $response");
      final insertedId = response[0]['id'];
      final url = await photoUpload(insertedId, _nameController.text);
      await updatePhoto(url, insertedId);
      fetchCategory();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Category added",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print("Error inserting data: $e");
    }
  }

  Future<String?> photoUpload(final id, String name) async {
    try {
      final bucketName = 'category'; // Replace with your bucket name
      final filePath = "$name-${id}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!, // Use file.bytes for Flutter Web
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print("Error photo upload: $e");
      return null;
    }
  }

  Future<void> updatePhoto(final url, final id) async {
    try {
      await supabase
          .from('tbl_category')
          .update({'category_image': url}).eq('id', id);
    } catch (e) {
      print("Error updating url: $e");
    }
  }

  Future<void> fetchCategory() async {
    try {
      final response = await supabase.from('tbl_category').select();
      setState(() {
        _categoryList = response;
      });
    } catch (e) {
      print("ERROR FETCHING DATA:$e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_category').delete().eq('id', id);
      fetchCategory();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Category Deleted",
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
    fetchCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Manage Category'),
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
                _isFormVisible ? "Cancel" : "Add Category",
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
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                          labelText: 'Name',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5))),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    TextFormField(
                                      controller: _descriptionController,
                                      decoration: InputDecoration(
                                          labelText: 'Description',
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
                              Column(
                                children: [
                                  SizedBox(
                                    height: 120,
                                    width: 120,
                                    child: pickedImage == null
                                        ? GestureDetector(
                                            onTap: handleImagePick,
                                            child: Icon(
                                              Icons.add_a_photo,
                                              color: Color(0xFF0277BD),
                                              size: 50,
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: handleImagePick,
                                            child: ClipRRect(
                                              child: pickedImage!.bytes != null
                                                  ? Image.memory(
                                                      Uint8List.fromList(
                                                          pickedImage!
                                                              .bytes!), // For web
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.file(
                                                      File(pickedImage!
                                                          .path!), // For mobile/desktop
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton(
                              onPressed: () {
                                insert();
                              },
                              child: Text("Submit")),
                        ],
                      )),
                )
              : Container(),
        ),
        DataTable(
          columns: [
            DataColumn(label: Text("Sno")),
            DataColumn(label: Text("Category")),
            DataColumn(label: Text("Description")),
            DataColumn(label: Text("Image")),
            DataColumn(label: Text("Action")),
          ],
          rows: _categoryList.asMap().entries.map((entry) {
            print(entry.value);
            return DataRow(cells: [
              DataCell(Text((entry.key + 1).toString())),
              DataCell(Text(entry.value['category_name'])),
              DataCell(Text(entry.value['category_description'])),
              DataCell(
                entry.value['category_image'] != null &&
                        entry.value['category_image'].isNotEmpty
                    ? Image.network(
                        entry.value['category_image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
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
