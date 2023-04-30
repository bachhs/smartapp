import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/helpers/database_helper.dart';
import 'package:task_manager/models/shop_model.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/screens/add_device.dart';
import 'package:task_manager/screens/add_task_screen.dart';
import 'package:task_manager/screens/home.dart';
import 'package:task_manager/models/device_model.dart';
import 'home_screen.dart';
import 'stacked_icons.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final current_shop;
  final current_email;
  final String current_role;
  SettingsScreen(this.current_shop, this.current_email, this.current_role);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  Future<List<Device>> _taskList;
  Future<List<Shop>> _shopList;
  Future<List<String>> _shopNameList;
  Future<List<String>> _shopIdList;
  List<Device> _tasks = [];
  String _searchQuery = '';
  int taskIndex = 0;
  String title = "";
  List<String> todos = <String>[];
  TextEditingController controller = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy hh:mm a');
  List<Device> data = [];
  String totalPriority = "";
  String total1 = "";
  String _scanBarcode = 'Unknown';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
    _updateTaskList();
  }

  Future<List<Device>> getDataJsonfireStore() async {
    List<Device> taskList = [];

    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('device');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await collectionRef.get();
    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    for (var document in allData) {
      Device task = Device.fromMap(document);
      // int resultday = _selectedDate.day.compareTo(task.date.day);
      // int resultmonth = _selectedDate.month.compareTo(task.date.month);
      // int resultyear = _selectedDate.year.compareTo(task.date.year);
      // if (resultday == 0 && resultmonth == 0 && resultyear == 0)
      taskList.add(task);
    }
    // Check task_list is empty or not
    return taskList;
  }

  void deleteTask(Device task) async {
    var collection = FirebaseFirestore.instance.collection('device');
    collection
        .doc(task.id) // <-- Doc ID to be deleted.
        .delete();
  }

  _updateTaskList() {
    setState(() {
      _taskList = getDataJsonfireStore();
    });
  }

  Future<bool> onBackPressed() {
    return SystemNavigator.pop();
  }

  Future<void> _pullRefresh() async {
    Duration(seconds: 1);
    await _updateTaskList();
  }

  @override
  Widget _buildTask(Device task, int index) {
    return Card(
      elevation: 10,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
        child: ListTile(
            leading: Text('${index}',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Raleway')),
            title: Text(
              task.name,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Raleway'),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 5),
                Text(
                  'Giá bán: ${task.bprice}.000đ',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.deepOrange,
                    // Head line
                  ),
                ),
                SizedBox(width: 5),
                widget.current_role == "admin"
                    ? Text(
                        'Giá nhập: ${task.nprice}.000đ',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.blueGrey,
                        ),
                      )
                    : SizedBox(width: 0),
                SizedBox(width: 5),
                Text(
                  widget.current_shop == "Cửa hàng Quang Tèo 1"
                      ? 'Số lượng: ${task.number[0]}'
                      : widget.current_shop == "Cửa hàng Quang Tèo 2"
                          ? 'Số lượng: ${task.number[1]}'
                          : 'Số lượng: ${task.number[2]}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.blueGrey,
                  ),
                ),
                Text(
                  '${_dateFormatter.format(task.date)}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            trailing: widget.current_role == "admin"
                ? IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Text("Bạn có đồng ý xóa phụ kiện này?"),
                              actions: [
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text("Delete"),
                                  onPressed: () async {
                                    await deleteTask(task);
                                    _updateTaskList();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                    },

                    // value: task.status == 1 ? true : false,
                  )
                : null,
            onTap: () => {
                  if (widget.current_role == "admin")
                    {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeviceScreen(
                            updateTaskList: _updateTaskList,
                            device: task,
                            name_shop: widget.current_shop,
                            current_email: widget.current_email,
                            current_role: widget.current_role,
                          ),
                        ),
                      ),
                    }
                }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          'Thêm phụ kiện',
          style: TextStyle(
              color: Color.fromRGBO(143, 148, 251, .6),
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.7,
              fontFamily: 'Audiowide'),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        icon: Icon(Icons.add_outlined),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DeviceScreen(
              updateTaskList: _updateTaskList,
              name_shop: widget.current_shop,
              current_email: widget.current_email,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color.fromRGBO(143, 148, 251, .6),
            ),
            onPressed: () => Navigator.pop(context)),
        title: Text(
          widget.current_shop,
          style: TextStyle(
              color: Color.fromRGBO(143, 148, 251, .6),
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.7,
              fontFamily: 'Audiowide'),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [],
      ),
      body: FutureBuilder(
        future: _taskList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final List<Device> filteredData = snapshot.data
              .where((Device task) =>
                  task.name.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
          filteredData.sort((a, b) => a.name.compareTo(b.name));

          snapshot.data.map((Device task) => task.bprice).toList();
          return RefreshIndicator(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 0.0),
              itemCount: 1 + filteredData.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // GestureDetector(
                        //   onTap: () => _selectDate(context),
                        //   child: Row(
                        //     children: [
                        //       Icon(Icons.calendar_today,
                        //           color: Colors.blueGrey),
                        //       SizedBox(width: 10),
                        //       Text(
                        //         DateFormat('EEE, MMM d, y')
                        //             .format(_selectedDate),
                        //         style: TextStyle(
                        //           fontSize: 18.0,
                        //           fontWeight: FontWeight.bold,
                        //           color: Colors.blueGrey,
                        //         ),
                        //       ),
                        //       SizedBox(width: 10),
                        //     ],
                        //   ),
                        // ),
                        SizedBox(height: 10),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm phụ kiện ...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search, color: Colors.grey),
                              onPressed: null,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  );
                }
                return _buildTask(filteredData[index - 1], index);
              },
            ),
            onRefresh: _pullRefresh,
          );
        },
      ),
      // drawer: MyDrawer(),
    );
  }
}
