import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/helpers/database_helper.dart';
import 'package:task_manager/models/comsum_model.dart';
import 'package:task_manager/models/money_model.dart';
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

class MoneyPage extends StatefulWidget {
  final current_shop;
  final current_email;
  final String current_role;
  MoneyPage(this.current_shop, this.current_email, this.current_role);
  @override
  _MoneyState createState() => _MoneyState();
}

class _MoneyState extends State<MoneyPage> {
  Future<List<MoneyModel>> _taskList;
  MoneyModel default_consum;
  Future<List<Shop>> _shopList;
  String _searchQuery = '';
  int taskIndex = 0;
  String title = "";
  List<String> todos = <String>[];
  TextEditingController controller = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy hh:mm a');
  List<MoneyModel> data = [];
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

  Future<List<MoneyModel>> getDataMoneyfireStore() async {
    List<MoneyModel> taskList = [];

    CollectionReference collectionRef =
        await FirebaseFirestore.instance.collection('money');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await collectionRef.get();
    // Get data from docs and convert map to List
    final allData = await querySnapshot.docs.map((doc) => doc.data()).toList();
    for (var document in allData) {
      MoneyModel task = MoneyModel.fromMap(document);
      taskList.add(task);
    }
    // Check task_list is empty or not
    await taskList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
    return taskList;
  }

  void deleteTask(ComsumModel task) async {
    var collection = FirebaseFirestore.instance.collection('money');
    collection
        .doc(task.id) // <-- Doc ID to be deleted.
        .delete();
  }

  _updateTaskList() {
    setState(() {
      _taskList = getDataMoneyfireStore();
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
  Widget _buildTask(MoneyModel task, int index) {
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
              widget.current_shop == "Cửa hàng Quang Tèo 1"
                  ? Text(
                      'Tổng bán: ${task.gia_ban[0]}.000đ',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.deepOrange,
                        // Head line
                      ),
                    )
                  : widget.current_shop == "Cửa hàng Quang Tèo 2"
                      ? Text(
                          'Tổng bán: ${task.gia_ban[1]}.000đ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.deepOrange,
                            // Head line
                          ),
                        )
                      : Text(
                          'Tổng bán: ${task.gia_ban[2]}.000đ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.deepOrange,
                            // Head line
                          ),
                        ),
              SizedBox(width: 5),
              widget.current_shop == "Cửa hàng Quang Tèo 1"
                  ? Text(
                      'Tiền nhập: ${task.gia_nhap[0]}.000đ',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.blueGrey,
                      ),
                    )
                  : widget.current_shop == "Cửa hàng Quang Tèo 2"
                      ? Text(
                          'Tiền nhập: ${task.gia_nhap[1]}.000đ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.blueGrey,
                          ),
                        )
                      : Text(
                          'Tiền nhập: ${task.gia_nhap[2]}.000đ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.blueGrey,
                          ),
                        ),
              widget.current_shop == "Cửa hàng Quang Tèo 1"
                  ? Text(
                      'Tiền lãi: ${int.parse(task.gia_ban[0]) - int.parse(task.gia_nhap[0])}.000đ',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.blueGrey,
                      ),
                    )
                  : widget.current_shop == "Cửa hàng Quang Tèo 2"
                      ? Text(
                          'Tiền lãi: ${int.parse(task.gia_ban[1]) - int.parse(task.gia_nhap[1])}.000đ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.blueGrey,
                          ),
                        )
                      : Text(
                          'Tiền lãi: ${int.parse(task.gia_ban[2]) - int.parse(task.gia_nhap[2])}.000đ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.blueGrey,
                          ),
                        )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          final List<MoneyModel> filteredData = snapshot.data
              .where((MoneyModel task) =>
                  task.date.day.toString().contains(_searchQuery))
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
