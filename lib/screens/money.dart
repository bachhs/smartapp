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
  final _selectDate;
  MoneyPage(this.current_shop, this.current_email, this.current_role,
      this._selectDate);
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
  double ban_month = 0.0;
  double nhap_month = 0.0;
  Map<String, MoneyModel> _monthDataMap = {};
  List<MoneyModel> _monthDataList = [];
  bool isDay = true;
  List<MoneyModel> _filteredData = [];
  List<MoneyModel> _taskListData = [];
  double existingGiaNhap = 0.0;
  double existingGiaBan = 0.0;
  ComsumModel consumDay;

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

  Future<List<MoneyModel>> getDataMoneyfireStore() async {
    List<MoneyModel> taskList = [];
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('money');

    DateTime startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    DateTime endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);

    QuerySnapshot querySnapshot = await collectionRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThan: Timestamp.fromDate(endDate))
        .orderBy('date')
        .get();

    // Update "date" field from DateTime to Timestamp
    // for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
    //   DateTime date = DateTime.parse(docSnapshot['date']);
    //   Timestamp timestamp = Timestamp.fromDate(date);
    //   await docSnapshot.reference.update({'date': timestamp});
    // }

    // Retrieve updated documents
    // querySnapshot = await collectionRef
    //     .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
    //     .where('date', isLessThan: Timestamp.fromDate(endDate))
    //     .orderBy('date')
    //     .get();

    taskList = querySnapshot.docs
        .map((doc) => MoneyModel.fromMap(doc.data()))
        .toList();
    _monthDataList = await sum_money_month(taskList);
    _filteredData = await taskList;
    _taskListData = await taskList;
    return taskList;
  }

  // Future<List<MoneyModel>> getDataMoneyfireStore() async {
  //   List<MoneyModel> taskList = [];

  //   CollectionReference collectionRef =
  //       await FirebaseFirestore.instance.collection('money');
  //   // Get docs from collection reference
  //   QuerySnapshot querySnapshot = await collectionRef.get();
  //   // Get data from docs and convert map to List
  //   final allData = await querySnapshot.docs.map((doc) => doc.data()).toList();
  //   for (var document in allData) {
  //     MoneyModel task = MoneyModel.fromMap(document);
  //     int resultmonth = _selectedDate.month.compareTo(task.date.month);
  //     int resultyear = _selectedDate.year.compareTo(task.date.year);
  //     if (resultmonth == 0 && resultyear == 0) {
  //       taskList.add(task);
  //     }
  //     //taskList.add(task);
  //   }
  //   // Check task_list is empty or not
  //   await taskList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));

  //   _monthDataList = await sum_money_month(taskList);
  //   _filteredData = await taskList;
  //   _taskListData = await taskList;

  //   return taskList;
  // }

  // sum thu & chi day in list
  ComsumModel sum_consum_day(List<ComsumModel> _comsumList) {
    ComsumModel consum = ComsumModel(
        id: "",
        shop: widget.current_shop,
        thu: "0",
        chi: "0",
        date: DateTime.now());
    for (ComsumModel t in _comsumList) {
      consum.thu = (double.parse(consum.thu) + double.parse(t.thu)).toString();
      consum.chi = (double.parse(consum.chi) + double.parse(t.chi)).toString();
    }
    return consum;
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
    isDay = true;
    await _updateTaskList();
  }

  List<MoneyModel> sum_money_month(List<MoneyModel> filteredData) {
    Map<String, MoneyModel> monthDataMap = {};
    List<MoneyModel> monthDataList = [];
    for (MoneyModel t in filteredData) {
      String monthKey = '${t.date.year}-${t.date.month}';
      if (monthDataMap.containsKey(monthKey)) {
        MoneyModel existingMonthData = monthDataMap[monthKey];

        // Tính tổng gia_nhap và gia_ban cho tháng hiện tại
        for (int i = 0; i < t.gia_nhap.length; i++) {
          if (existingMonthData.gia_nhap[i] == "") {
            existingGiaNhap = 0;
          } else {
            existingGiaNhap = double.parse(existingMonthData.gia_nhap[i]);
          }
          // double existingGiaNhap = double.parse(existingMonthData.gia_nhap[i]);
          if (existingMonthData.gia_ban[i] == "") {
            existingGiaBan = 0;
          } else {
            existingGiaBan = double.parse(existingMonthData.gia_ban[i]);
          }
          if (t.gia_nhap[i] == "") {
            t.gia_nhap[i] = "0";
          } else {
            t.gia_nhap[i] = t.gia_nhap[i];
          }
          double giaNhap = double.parse(t.gia_nhap[i]);
          if (t.gia_ban[i] == "") {
            t.gia_ban[i] = "0";
          } else {
            t.gia_ban[i] = t.gia_ban[i];
          }
          double giaBan = double.parse(t.gia_ban[i]);

          existingMonthData.gia_nhap[i] =
              (existingGiaNhap + giaNhap).toStringAsFixed(2);
          existingMonthData.gia_ban[i] =
              (existingGiaBan + giaBan).toStringAsFixed(2);
        }
      } else {
        // Khởi tạo một bản ghi mới cho tháng hiện tại
        MoneyModel newMonthData = MoneyModel(
          id: monthKey,
          gia_nhap: List<String>.from(t.gia_nhap),
          gia_ban: List<String>.from(t.gia_ban),
          date: DateTime(t.date.year, t.date.month),
        );
        monthDataMap[monthKey] = newMonthData;
      }
    }
    monthDataMap.forEach((key, value) {
      monthDataList.add(value);
    });
    return monthDataList;
  }

  @override
  Widget _buildTaskDay(MoneyModel task, int index) {
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
                      'Tổng bán: ${double.parse(task.gia_ban[0])},000đ',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.deepOrange,
                        // Head line
                      ),
                    )
                  : widget.current_shop == "Cửa hàng Quang Tèo 2"
                      ? Text(
                          'Tổng bán: ${double.parse(task.gia_ban[1])},000đ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.deepOrange,
                            // Head line
                          ),
                        )
                      : Text(
                          'Tổng bán: ${double.parse(task.gia_ban[2])},000đ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.deepOrange,
                            // Head line
                          ),
                        ),
              SizedBox(width: 5),
              widget.current_role == 'admin'
                  ? widget.current_shop == "Cửa hàng Quang Tèo 1"
                      ? Text(
                          'Tiền nhập: ${double.parse(task.gia_nhap[0])},000đ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.blueGrey,
                          ),
                        )
                      : widget.current_shop == "Cửa hàng Quang Tèo 2"
                          ? Text(
                              'Tiền nhập: ${double.parse(task.gia_nhap[1])},000đ',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.blueGrey,
                              ),
                            )
                          : Text(
                              'Tiền nhập: ${double.parse(task.gia_nhap[2])},000đ',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.blueGrey,
                              ),
                            )
                  : SizedBox.shrink(),
              widget.current_role == 'admin'
                  ? widget.current_shop == "Cửa hàng Quang Tèo 1"
                      ? Text(
                          'Tiền lãi: ${double.parse(task.gia_ban[0]) - double.parse(task.gia_nhap[0])},000đ',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.blueGrey,
                          ),
                        )
                      : widget.current_shop == "Cửa hàng Quang Tèo 2"
                          ? Text(
                              'Tiền lãi: ${double.parse(task.gia_ban[1]) - double.parse(task.gia_nhap[1])},000đ',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.blueGrey,
                              ),
                            )
                          : Text(
                              'Tiền lãi: ${double.parse(task.gia_ban[2]) - double.parse(task.gia_nhap[2])},000đ',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.blueGrey,
                              ),
                            )
                  : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }

  void updateFilteredData(bool isDay) {
    if (!isDay) {
      _filteredData = _monthDataList
          .where((MoneyModel task) =>
              task.date.month.toString().contains(_searchQuery))
          .toList();
    } else {
      _filteredData = _taskListData
          .where((MoneyModel task) =>
              task.date.day.toString().contains(_searchQuery))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Color.fromRGBO(143, 148, 251, 1),
              ),
              onPressed: () => Navigator.pop(context)),
          title: Text(
            widget.current_shop,
            style: TextStyle(
                color: Color.fromRGBO(143, 148, 251, 1),
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.7,
                fontFamily: 'Audiowide'),
          ),
          centerTitle: false,
          elevation: 0,
          actions: [],
        ),
        body: Column(
          children: [
            SizedBox(height: 10),
            Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(143, 148, 251, 1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white,
                    width: 5,
                  ),
                ),
                padding: EdgeInsets.all(10),
                child: Text(
                  'Tổng tiền bán phụ kiện',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: isDay,
                        onChanged: (bool value) {
                          setState(() {
                            isDay = value;
                            updateFilteredData(isDay);
                          });
                        },
                      ),
                      Text(
                        'Ngày',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 30),
                      Checkbox(
                        value: !isDay,
                        onChanged: (bool value) {
                          setState(() {
                            isDay = !value;
                            updateFilteredData(isDay);
                          });
                        },
                      ),
                      Text(
                        'Tháng',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _taskList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return RefreshIndicator(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 0.0),
                      itemCount: 1 + _filteredData.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 0.0, vertical: 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          color: Colors.blueGrey),
                                      SizedBox(width: 10),
                                      Text(
                                        DateFormat('EEE, MMM d, y')
                                            .format(_selectedDate),
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          );
                        }

                        return _buildTaskDay(_filteredData[index - 1], index);
                      },
                    ),
                    onRefresh: _pullRefresh,
                  );
                },
              ),
            )
          ],
        )
        // drawer: MyDrawer(),
        );
  }
}
