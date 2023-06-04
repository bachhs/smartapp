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
  String _name = "";
  bool checkStatus = false;
  List<ComsumModel> _filteredData = [];
  List<ComsumModel> _monthDataList = [];
  List<ComsumModel> _taskListData = [];
  bool isDay = true;
  double existingGiaNhap = 0.0;
  double existingGiaBan = 0.0;

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
    Map<String, dynamic> todoList = await {
      "id": unique_id,
      "thu": task.thu,
      "date": Timestamp.fromDate(task.date),
      "chi": task.chi,
      "shop": task.shop,
      "name": task.name,
    };
    await FirebaseFirestore.instance
        .collection('consum')
        .doc(unique_id)
        .set(todoList);
  }

  List<ComsumModel> sum_money_month(List<ComsumModel> filteredData) {
    Map<String, ComsumModel> monthDataMap = {};
    List<ComsumModel> monthDataList = [];
    for (ComsumModel t in filteredData) {
      String monthKey = '${t.date.year}-${t.date.month}';
      if (monthDataMap.containsKey(monthKey)) {
        ComsumModel existingMonthData = monthDataMap[monthKey];

        // Tính tổng gia_nhap và gia_ban cho tháng hiện tại

        if (existingMonthData.chi == "") {
          existingGiaNhap = 0;
        } else {
          existingGiaNhap = double.parse(existingMonthData.chi);
        }
        // double existingGiaNhap = double.parse(existingMonthData.gia_nhap[i]);
        if (existingMonthData.thu == "") {
          existingGiaBan = 0;
        } else {
          existingGiaBan = double.parse(existingMonthData.thu);
        }
        if (t.chi == "") {
          t.chi = "0";
        } else {
          t.chi = t.chi;
        }
        double giaNhap = double.parse(t.chi);
        if (t.thu == "") {
          t.thu = "0";
        } else {
          t.thu = t.thu;
        }
        double giaBan = double.parse(t.thu);

        existingMonthData.chi = (existingGiaNhap + giaNhap).toStringAsFixed(2);
        existingMonthData.thu = (existingGiaBan + giaBan).toStringAsFixed(2);
      } else {
        // Khởi tạo một bản ghi mới cho tháng hiện tại
        ComsumModel newMonthData = ComsumModel(
          id: monthKey,
          chi: t.chi,
          thu: t.thu,
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

  void updateFilteredData(bool isDay) async {
    if (!isDay) {
      await _updateTaskListMonth();
      _filteredData = _monthDataList
          .where((ComsumModel task) =>
              task.date.month.toString().contains(_searchQuery))
          .toList();
    } else {
      _filteredData = _taskListData
          .where((ComsumModel task) =>
              task.date.day.toString().contains(_searchQuery))
          .toList();
    }
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
                'Tên',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  hintText: 'Nhập tên khoản thu chi',
                  hintStyle: TextStyle(fontSize: 18.0),
                  prefixIcon: Icon(Icons.money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (value) {
                  _name = value;
                },
              ),
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
                    name: _name,
                  );
                  sendDataFireStore(task);
                } else {
                  ComsumModel task = ComsumModel(
                      thu: _thu,
                      chi: _chi,
                      date: consum.date,
                      shop: widget.current_shop,
                      name: _name);
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
    List<ComsumModel> dataDay = [];

    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('consum');

    DateTime startDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    DateTime endDate = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day + 1);

    // Month
    if (isDay) {
      QuerySnapshot querySnapshot = await collectionRef
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThan: Timestamp.fromDate(endDate))
          .orderBy('date')
          // .where('shop', isEqualTo: widget.current_shop)
          .get();
      taskList = querySnapshot.docs
          .map((doc) => ComsumModel.fromMap(doc.data()))
          .toList();
    }
    // Check task_list is empty or not
    taskList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
    for (var document in taskList) {
      if (document.shop == widget.current_shop) dataDay.add(document);
    }
    //Month
    _filteredData = await dataDay;
    _taskListData = await dataDay;
    return dataDay;
  }

  Future<List<ComsumModel>> getDataConsumfireStoreMonth() async {
    List<ComsumModel> taskListMonth = [];
    List<ComsumModel> dataMonth = [];

    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('consum');

    // Month
    DateTime startMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    DateTime endMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 1);

    // Check task_list is empty or not
    QuerySnapshot querySnapshotMonth = await collectionRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startMonth))
        .where('date', isLessThan: Timestamp.fromDate(endMonth))
        .orderBy('date')
        // .where('shop', isEqualTo: widget.current_shop)
        .get();
    taskListMonth = querySnapshotMonth.docs
        .map((doc) => ComsumModel.fromMap(doc.data()))
        .toList();

    //Month
    for (var document in taskListMonth) {
      if (document.shop == widget.current_shop) dataMonth.add(document);
    }
    _monthDataList = await sum_money_month(dataMonth);
    return _monthDataList;
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

  _updateTaskListMonth() async {
    List newDataList = await getDataConsumfireStoreMonth();
    setState(() {
      _monthDataList = newDataList;
    });
  }

  Future<bool> onBackPressed() {
    return SystemNavigator.pop();
  }

  Future<void> _pullRefresh() async {
    Duration(seconds: 1);
    await _updateTaskList();
    isDay = true;
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
                Text(
                  'Tên: ${task.name}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.blueGrey,
                  ),
                ),
                Text(
                  'Tiền thu: ${task.thu},000đ',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.deepOrange,
                    // Head line
                  ),
                ),
                Text(
                  'Tiền chi: ${task.chi},000đ',
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
                  _name = task.name,
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
                color: Color.fromRGBO(143, 148, 251, 1),
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
                  'Tiền thu chi sửa máy',
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
                )),
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
                                // SizedBox(height: 10),
                                // TextField(
                                //   onChanged: (value) {
                                //     setState(() {
                                //       _searchQuery = value;
                                //     });
                                //   },
                                //   decoration: InputDecoration(
                                //     hintText: 'Tìm ngày ...',
                                //     border: OutlineInputBorder(
                                //       borderRadius: BorderRadius.circular(10.0),
                                //       borderSide: BorderSide.none,
                                //     ),
                                //     suffixIcon: IconButton(
                                //       icon: Icon(Icons.search,
                                //           color: Colors.grey),
                                //       onPressed: null,
                                //     ),
                                //   ),
                                // ),
                                //SizedBox(height: 10),
                              ],
                            ),
                          );
                        }

                        return _buildTask(_filteredData[index - 1], index);
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
