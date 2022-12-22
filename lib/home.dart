import 'package:flutter/material.dart';
import 'database.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // All data
  List<Map<String, dynamic>> myData = [];
  final formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  // This function retrieves every piece of information from the database.
  void _refreshData() async {
    final data = await Sqflite.getItems();
    setState(() {
      myData = data;
      _isLoading = false;
      }
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void showMyForm(int? id) async {
    if (id != null) {
      final existingData = myData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descriptionController.text = existingData['description'];
    } else {
      _titleController.text = "";
      _descriptionController.text = "";
    }
    showModalBottomSheet(
      backgroundColor: Colors.white,
        context: context,
        elevation: 5,
        isDismissible: false,
        isScrollControlled: true,
        builder: (_) => Container(
            padding: EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
              // prevent the soft keyboard from covering the text fields
              bottom: MediaQuery.of(context).viewInsets.bottom + 120,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextFormField(
                    controller: _titleController,
                    validator: formValidator,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                        ),
                        hintText: 'Title: '),
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 6,
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    validator: formValidator,
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        hintText: 'Description:'),
                        keyboardType: TextInputType.multiline,
                        minLines: 5,
                        maxLines: 6,
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (id == null) {
                              await addItem();
                              }
                            if (id != null) {
                              await updateItem(id);
                            }
                            // Clear
                            setState(() {
                              _titleController.text = '';
                              _descriptionController.text = '';
                              }
                            );
                            // Close
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                          }
                          // Save
                        },
                        child: Text(id == null ? 'Create' : 'Update'),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Back")),
                    ],
                  )
                ],
              ),
            )
        )
    );
  }

  String? formValidator(String? value) {
    if (value!.isEmpty) return 'Field is Required';
    return null;
  }

// Create
  Future<void> addItem() async {
    await Sqflite.createItem(
        _titleController.text, _descriptionController.text);
    _refreshData();
  }

  // Update
  Future<void> updateItem(int id) async {
    await Sqflite.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshData();
  }

  // Delete
  void deleteItem(int id) async {
    await Sqflite.deleteItem(id);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Successfully deleted!'), backgroundColor: Colors.black));
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do'),
        ),
      body: _isLoading
          ? const Center(
            child: CircularProgressIndicator(),
      )
          : myData.isEmpty
          ? const Center(child: Text("Empty"))
          : ListView.builder(
            itemCount: myData.length,
                itemBuilder: (context, index) => Card(
                  color: index % 2 == 0 ? Colors.white: Colors.red[200],
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    leading: const Icon(Icons.task),
                      title: Text(myData[index]['title']),
                      subtitle: Text(myData[index]['description']),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              color: Colors.black,
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  showMyForm(myData[index]['id']),
                            ),
                            IconButton(
                              color: Colors.black,
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  deleteItem(myData[index]['id']),
                            ),
                          ],
                        ),
                      )
                  ),
                ),
          ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => showMyForm(null),
      ),
    );
  }
}