import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/models/shop_model.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/screens/home.dart';
import 'home_screen.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  final Function updateTaskList;
  final Task task;
  final String name_shop;
  final String current_email;

  AddTaskScreen(
      {this.updateTaskList, this.task, this.name_shop, this.current_email});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _priority;
  String _tprice = '';
  DateTime _date = DateTime.now();
  String _role = "Cửa hàng Quang Tèo 1";
  final List<String> _shopList = [];
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
      _priority = widget.task.price;
      _tprice = widget.task.tprice;
    }

    _dateController.text = _dateFormatter.format(_date);
    _initData();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _initData() async {
    List<String> userList = await await getDataShopFirestore();
    setState(() {
      _shopList.addAll(userList);
    });
  }

  Future<List<String>> getDataShopFirestore() async {
    List<String> shopList = [];
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('shop').get();
      List<QueryDocumentSnapshot> documents = querySnapshot.docs;
      for (var document in documents) {
        Shop user = Shop.fromMap(document.data());
        shopList.add(user.name);
      }
    } catch (e) {
      print(e.toString());
    }
    return shopList;
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

      Task task = Task(
          title: _title,
          date: _date,
          price: _priority,
          shop: widget.name_shop,
          tprice: _tprice);
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

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => Home(widget.current_email, widget.name_shop)));
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
      "price": task.price,
      "status": task.status,
      "shop": task.shop,
      "tprice": task.tprice,
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
          widget.task == null ? 'Thêm phụ kiện' : 'Sửa phụ kiện',
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.phone_android_outlined,
                      color: Color.fromRGBO(143, 148, 251, 1),
                      size: 60,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
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
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Giá',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (input) =>
                              input.trim().isEmpty ? 'Nhập giá phụ kiện' : null,
                          onSaved: (input) => _priority = input,
                          initialValue: _priority,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Giá nhập',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (input) => input.trim().isEmpty
                              ? 'Nhập giá nhập phụ kiện'
                              : null,
                          onSaved: (input) => _tprice = input,
                          initialValue: _tprice,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
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
                      Container(
                          padding: EdgeInsets.all(8.0),
                          child: DropdownButton<String>(
                            value: widget.name_shop,
                            items: _shopList.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String newValue) {
                              setState(() {
                                _role = newValue;
                              });
                            },
                          )),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FloatingActionButton.extended(
                            heroTag: 'save_button',
                            shape: StadiumBorder(),
                            label: Text(
                              widget.task == null ? 'Thêm' : 'Sửa',
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
                                    'Xóa',
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
