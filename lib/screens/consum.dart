import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/helpers/database_helper.dart';
import 'package:task_manager/models/comsum_model.dart';
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

class Consumer extends StatefulWidget {
  final current_shop;
  final current_email;
  final String current_role;
  Consumer(this.current_shop, this.current_email, this.current_role);
  @override
  _ConsumerState createState() => _ConsumerState();
}

class _ConsumerState extends State<Consumer> {
  Future<List<ComsumModel>> _taskList;
  ComsumModel default_consum;
  Future<List<Shop>> _shopList;
  String _searchQuery = '';
  int taskIndex = 0;
  String title = "";
  List<String> todos = <String>[];
  TextEditingController controller = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy hh:mm a');
  List<ComsumModel> data = [];
  String totalPriority = "";
  String total1 = "";
  String _scanBarcode = 'Unknown';
  DateTime _selectedDate = DateTime.now();
  String _thu = "";
  String _chi = "";
  String _id = "";
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  void updateDataConsumFireStore(String idSelect, ComsumModel task) async {
    final docUser = FirebaseFirestore.instance.collection('consum');
    docUser.doc(idSelect).update(task.toMap());
  }

  Future<void> sendDataFireStore(ComsumModel task) async {
    String unique_id = UniqueKey().toString();
    Map<String, String> todoList = await {
      "id": unique_id,
      "thu": task.thu,
      "date": task.date.toString(),
      "chi": task.chi,
      "shop": task.shop,
    };
    await FirebaseFirestore.instance
        .collection('consum')
        .doc(unique_id)
        .set(todoList);
  }

  void _showDialog_daily(
      BuildContext context, bool checkStatus, ComsumModel consum) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Tiền thu chi',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
              letterSpacing: 1.2,
            ),
          ),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 16.0),
              Text(
                'Số tiền chi',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              TextFormField(
                initialValue: _chi,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Nhập số tiền chi',
                  hintStyle: TextStyle(fontSize: 18.0),
                  prefixIcon: Icon(Icons.money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (value) {
                  _chi = value;
                },
              ),
              SizedBox(height: 16.0),
              Text(
                'Số tiền thu ngoài',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              TextFormField(
                initialValue: _thu,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Nhập số tiền thu ngoài',
                  hintStyle: TextStyle(fontSize: 18.0),
                  prefixIcon: Icon(Icons.money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (value) {
                  _thu = value;
                },
              )
            ])
          ]),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Hủy bỏ',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Xác nhận',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              onPressed: () {
                if (checkStatus == false) {
                  ComsumModel task = ComsumModel(
                    thu: _thu,
                    chi: _chi,
                    date: _selectedDate,
                    shop: widget.current_shop,
                  );
                  sendDataFireStore(task);
                } else {
                  ComsumModel task = ComsumModel(
                    thu: _thu,
                    chi: _chi,
                    date: consum.date,
                    shop: widget.current_shop,
                  );
                  updateDataConsumFireStore(consum.id, task);
                }
                _updateTaskList();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  Future<List<ComsumModel>> getDataConsumfireStore() async {
    List<ComsumModel> taskList = [];

    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('consum');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await collectionRef.get();
    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    for (var document in allData) {
      ComsumModel task = ComsumModel.fromMap(document);
      taskList.add(task);
    }
    // Check task_list is empty or not
    taskList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
    return taskList;
  }

  void deleteTask(ComsumModel task) async {
    var collection = FirebaseFirestore.instance.collection('consum');
    collection
        .doc(task.id) // <-- Doc ID to be deleted.
        .delete();
  }

  _updateTaskList() {
    setState(() {
      _taskList = getDataConsumfireStore();
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
  Widget _buildTask(ComsumModel task, int index) {
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
              task.date.day.toString() +
                  "/" +
                  task.date.month.toString() +
                  "/" +
                  task.date.year.toString(),
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
                  'Tiền thu: ${task.thu}.000đ',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.deepOrange,
                    // Head line
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  'Tiền chi: ${task.chi}.000đ',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.blueGrey,
                  ),
                )
              ],
            ),
            trailing: IconButton(
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
            ),
            onTap: () => {
                  _thu = task.thu,
                  _chi = task.chi,
                  _id = task.id,
                  checkStatus = true,
                  _showDialog_daily(context, checkStatus, task)
                }
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => Home(widget.current_email, widget.current_shop),
            //   ),
            // ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          'Thêm quản lý chi tiêu',
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
        onPressed: () => {
          _thu = "",
          _chi = "",
          checkStatus = false,
          _showDialog_daily(context, checkStatus, default_consum)
        },
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
          final List<ComsumModel> filteredData = snapshot.data
              .where((ComsumModel task) =>
                  task.date.day.toString().contains(_searchQuery))
              .where((ComsumModel task) =>
                  task.shop.compareTo(widget.current_shop) == 0)
              .toList();

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
                        SizedBox(height: 10),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Tìm ngày ...',
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
