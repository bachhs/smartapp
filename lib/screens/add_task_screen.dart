import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/models/task_model.dart';
import 'home_screen.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  final Function updateTaskList;
  final Task task;

  AddTaskScreen({this.updateTaskList, this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _priority;
  DateTime _date = DateTime.now();
  TextEditingController _dateController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy hh:mm a');
  Future<List<Task>> task_id;
  @override
  void initState() {
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
    super.initState();

    if (widget.task != null) {
      _title = widget.task.title;
      _date = widget.task.date;
      _priority = widget.task.priority;
    }

    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  _handleDatePicker() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date);
    }
  }

  _delete() {
    //DatabaseHelper.instance.deleteTask(widget.task.id);
    var collection = FirebaseFirestore.instance.collection('phone');
    collection
        .doc(widget.task.id) // <-- Doc ID to be deleted.
        .delete();
    Navigator.pop(context);
    widget.updateTaskList();
    // Toast.show(
    //   "Task Deleted",
    //   textStyle: context,
    // );
  }

  Future<List<Task>> getDataFirestore() async {
    List<Task> taskList = [];
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('phone').get();
      List<QueryDocumentSnapshot> documents = querySnapshot.docs;
      for (var document in documents) {
        Task task = Task.fromMap(document.data());
        taskList.add(task);
      }
    } catch (e) {
      print(e.toString());
    }
    return taskList;
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('$_title, $_date, $_priority');

      Task task = Task(title: _title, date: _date, priority: _priority);
      if (widget.task == null) {
        // Insert the task to our user's database
        task.status = "0";
        //DatabaseHelper.instance.insertTask(task);
        sendDataFireStore(task);
        // Toast.show(
        //   "New Task Added",
        //   textStyle: context,
        // );
      } else {
        // Update the task
        task.id = widget.task.id;
        task.status = widget.task.status;
        updateDataFireStore(task.id, task);
        //DatabaseHelper.instance.updateTask(task);
        // Toast.show(
        //   "Task Updated",
        //   textStyle: context,
        // );
      }

      Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      widget.updateTaskList();
    }
  }

  // Update ddataa JSON
  void updateDataFireStore(String idSelect, Task task) async {
    final docUser = FirebaseFirestore.instance.collection('phone');
    docUser.doc(idSelect).update(task.toMap());
  }

  void sendDataFireStore(Task task) async {
    String unique_id = UniqueKey().toString();
    Map<String, String> todoList = {
      "id": unique_id,
      "title": task.title,
      "date": task.date.toString(),
      "priority": task.priority,
      "status": task.status,
    };
    FirebaseFirestore.instance.collection('phone').doc(unique_id).set(todoList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context)),
        title: Text(
          widget.task == null ? 'Add Task' : 'Update Task',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Tên phụ kiện',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (input) =>
                              input.trim().isEmpty ? 'Nhập tên phụ kiện' : null,
                          onSaved: (input) => _title = input,
                          initialValue: _title,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          style: TextStyle(fontSize: 18.0),
                          onTap: _handleDatePicker,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Price',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (input) => input.trim().isEmpty
                              ? 'Please enter a price'
                              : null,
                          onSaved: (input) => _priority = input,
                          initialValue: _priority,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FloatingActionButton.extended(
                            heroTag: 'save_button',
                            shape: StadiumBorder(),
                            label: Text(
                              widget.task == null ? 'Add' : 'Update',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              ),
                            ),
                            onPressed: _submit,
                          ),
                          SizedBox(width: 20.0),
                          widget.task != null
                              ? FloatingActionButton.extended(
                                  heroTag: 'delete_button',
                                  shape: StadiumBorder(),
                                  label: Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  onPressed: _delete,
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
