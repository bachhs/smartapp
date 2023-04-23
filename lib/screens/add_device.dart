import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/models/device_model.dart';
import 'package:task_manager/models/shop_model.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/screens/home.dart';
import 'package:task_manager/screens/settings_screen.dart';
import 'home_screen.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class DeviceScreen extends StatefulWidget {
  final Function updateTaskList;
  final Device device;
  final String name_shop;
  final String current_email;
  final String current_role;

  DeviceScreen(
      {this.updateTaskList,
      this.device,
      this.name_shop,
      this.current_email,
      this.current_role});

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _nprice = "";
  String _bprice = '';

  String numberInput = "";
  List<String> _number = ['0', '0', '0'];
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

    if (widget.device != null) {
      _name = widget.device.name;
      _nprice = widget.device.nprice;
      _bprice = widget.device.bprice;
      if (widget.name_shop == "Cửa hàng Quang Tèo 1") {
        numberInput = widget.device.number[0];
        _number = widget.device.number;
      } else if (widget.name_shop == "Cửa hàng Quang Tèo 2") {
        numberInput = widget.device.number[1];
        _number = widget.device.number;
      } else if (widget.name_shop == "Cửa hàng Quang Tèo 3") {
        numberInput = widget.device.number[2];
        _number = widget.device.number;
      }
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
          await FirebaseFirestore.instance.collection('device').get();
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
    var collection = FirebaseFirestore.instance.collection('device');
    collection
        .doc(widget.device.id) // <-- Doc ID to be deleted.
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
          await FirebaseFirestore.instance.collection('device').get();
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

      Device device = Device(
          name: _name,
          date: _date,
          bprice: _bprice,
          nprice: _nprice,
          number: _number);
      if (widget.device == null) {
        // Insert the task to our user's database
        device.status = "0";
        //DatabaseHelper.instance.insertTask(task);
        sendDataFireStore(device);
      } else {
        // Update the task
        device.id = widget.device.id;
        device.status = widget.device.status;
        updateDataFireStore(device.id, device);
      }

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SettingsScreen(widget.name_shop,
                  widget.current_email, widget.current_role)));
      widget.updateTaskList();
    }
  }

  // Update ddataa JSON
  void updateDataFireStore(String idSelect, Device task) async {
    final docUser = FirebaseFirestore.instance.collection('device');
    docUser.doc(idSelect).update(task.toMap());
  }

  void sendDataFireStore(Device task) async {
    String unique_id = Uuid().v1();
    // String uniqueIdString =
    //     unique_id.toString().replaceAll(RegExp('[^0-9]'), '');
    Map<String, dynamic> todoList = {
      "id": unique_id,
      "name": task.name,
      "date": task.date.toString(),
      "bprice": task.bprice,
      "nprice": task.nprice,
      "status": task.status,
    };
    List<String> numbers = task.number.cast<String>();
    todoList.addAll({"number": numbers});

    FirebaseFirestore.instance
        .collection('device')
        .doc(unique_id)
        .set(todoList);
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
          widget.device == null ? 'Thêm phụ kiện' : 'Sửa phụ kiện',
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
                          onSaved: (input) => _name = input,
                          initialValue: _name,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Giá bán',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (input) =>
                              input.trim().isEmpty ? 'Nhập giá phụ kiện' : null,
                          onSaved: (input) => _bprice = input,
                          initialValue: _bprice,
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
                          onSaved: (input) => _nprice = input,
                          initialValue: _nprice,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Số lượng',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (input) => input.trim().isEmpty
                              ? 'Nhập số lượng phụ kiện'
                              : null,
                          onSaved: (input) => {
                            if (widget.name_shop == "Cửa hàng Quang Tèo 1")
                              {_number[0] = input}
                            else if (widget.name_shop == "Cửa hàng Quang Tèo 2")
                              {_number[1] = input}
                            else if (widget.name_shop == "Cửa hàng Quang Tèo 3")
                              {_number[3] = input}
                          },
                          initialValue: numberInput,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          readOnly: true,
                          enabled: false,
                          focusNode: FocusNode(),
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
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: TextFormField(
                          initialValue: widget.name_shop,
                          readOnly: true,
                          enabled: false,
                          focusNode: FocusNode(),
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Shop',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FloatingActionButton.extended(
                            backgroundColor: Color.fromRGBO(143, 148, 251, 1),
                            heroTag: 'save_button',
                            shape: StadiumBorder(),
                            label: Text(
                              widget.device == null ? 'Thêm' : 'Sửa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              ),
                            ),
                            onPressed: _submit,
                          ),
                          SizedBox(width: 20.0),
                          widget.device != null
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
