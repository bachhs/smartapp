import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_manager/models/shop_model.dart';
// import 'package:task_manager/helpers/database_helper.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/screens/navigator_draw.dart';
import 'package:task_manager/screens/add_task_screen.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/screens/settings_screen.dart';
import 'qr_scan.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:connectivity/connectivity.dart';
// import 'package:toast/toast.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  // final String current_email;
  final String name_shop;
  final String current_email;
  final String current_role;
  HomeScreen(this.name_shop, this.current_email, this.current_role);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Task>> _taskList;
  Future<List<Shop>> _shopList;
  Future<List<String>> _shopNameList;
  Future<List<String>> _shopIdList;
  String title = "";
  List<String> todos = <String>[];
  TextEditingController controller = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy hh:mm a');
  List<Task> data = [];
  String totalPriority = "";
  String total1 = "";
  String _scanBarcode = 'Unknown';
  DateTime _selectedDate = DateTime.now();

  final String url =
      "https://gist.githubusercontent.com/thangleuet/d981ae220775be66e9366b743ad012a6/raw/f220c0574e2a9aee904b04c2fa263c43e1f7d663/smartHome";

  // convert _taskList to json data
  // data = _taskList;

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

  Future<List<Task>> getDataJsonfireStore() async {
    List<Task> taskList = [];
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('phone');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await collectionRef.get();
    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    for (var document in allData) {
      Task task = Task.fromMap(document);
      int resultday = _selectedDate.day.compareTo(task.date.day);
      int resultmonth = _selectedDate.month.compareTo(task.date.month);
      int resultyear = _selectedDate.year.compareTo(task.date.year);
      if (resultday == 0 &&
          resultmonth == 0 &&
          resultyear == 0 &&
          task.shop == widget.name_shop) taskList.add(task);
    }
    // Check task_list is empty or not
    taskList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
    return taskList;
  }

  // Get number shop
  Future<List<Shop>> getShopfireStore() async {
    List<Shop> shopList = [];
    List<String> shopNameList = [];
    List<String> shopIdList = [];
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('shop');
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await collectionRef.get();
    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    for (var document in allData) {
      Shop shop = Shop.fromMap(document);
      shopNameList.add(shop.name);
      shopIdList.add(shop.id);
      shopList.add(shop);
    }
    return shopList;
  }

  void deleteTask(Task task) async {
    var collection = FirebaseFirestore.instance.collection('phone');
    collection
        .doc(task.id) // <-- Doc ID to be deleted.
        .delete();
  }

  _updateTaskList() {
    setState(() {
      _shopList = getShopfireStore();
      _taskList = getDataJsonfireStore();
      for (var i = 0; i < data.length; i++) {
        // add the data to the _taskList
        _taskList.then((value) => value.add(data[i]));
        // Sort the _taskList
        _taskList.then((value) =>
            value.sort((taskA, taskB) => taskA.date.compareTo(taskB.date)));
      }
    });
  }

  Future<bool> onBackPressed() {
    return SystemNavigator.pop();
  }

  Future<void> _pullRefresh() async {
    Duration(seconds: 1);
    await _updateTaskList();
  }

  void sendDataFireStore(Task task) async {
    String unique_id = UniqueKey().toString();
    Map<String, String> todoList = {
      "id": unique_id,
      "title": task.title,
      "date": task.date.toString(),
      "price": task.price,
      "status": task.status,
    };
    FirebaseFirestore.instance.collection('phone').doc(unique_id).set(todoList);
  }

  // Scan qrCode
  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    setState(() {
      _scanBarcode = barcodeScanRes;
      var parts = _scanBarcode.split(':');
      var _title = parts[0].trim();
      var _priority = parts[1].trim();
      Task task = Task(title: _title, date: DateTime.now(), price: _priority);
      sendDataFireStore(task);
      _updateTaskList();
    });
  }

  Widget _buildTask(Task task) {
    return Card(
      elevation: 10,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
        child: ListTile(
          title: Text(
            task.title,
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
                'Giá: ${task.price}.000đ',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.deepOrange,
                  // Head line
                ),
              ),
              SizedBox(width: 5),
              Text(
                '${_dateFormatter.format(task.date)}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.blueGrey,
                ),
              ),
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

              // Toast.show(
              //   "Task Removed",
              //   textStyle: context,
              // );
            },

            // value: task.status == 1 ? true : false,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(
                updateTaskList: _updateTaskList,
                task: task,
                name_shop: widget.name_shop,
                current_email: widget.current_email,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: Icon(Icons.add_outlined),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTaskScreen(
              updateTaskList: _updateTaskList,
              name_shop: widget.name_shop,
              current_email: widget.current_email,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(
              Icons.phone_android,
              color: Colors.green,
            ),
            onPressed: null),
        title: Text(
          "Home",
          style: TextStyle(
              color: Colors.green,
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.7,
              fontFamily: 'Audiowide'),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          // Container(
          //   margin: const EdgeInsets.all(0),
          //   child: IconButton(
          //     icon: Icon(Icons.history_outlined),
          //     iconSize: 25.0,
          //     color: Colors.black,
          //     onPressed: () => Navigator.push(context,
          //         MaterialPageRoute(builder: (_) => HistoryScreen())),
          //   ),
          // ),
          Container(
            margin: const EdgeInsets.all(7.0),
            child: IconButton(
              icon: Icon(Icons.qr_code_scanner),
              iconSize: 25.0,
              color: Colors.black,
              onPressed: () => scanQR(),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(7.0),
            child: IconButton(
              icon: Icon(Icons.settings_outlined),
              iconSize: 25.0,
              color: Colors.black,
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                          widget.name_shop, widget.current_email))),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _taskList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final list_data =
              snapshot.data.map((Task task) => task.price).toList();
          final int completedTaskCount = snapshot.data
              .where((Task task) => task.status == 0)
              .toList()
              .length;

          // Sum of all the priority
          if (list_data.length == 0)
            totalPriority = "0";
          else
            totalPriority = list_data.reduce((value, element) =>
                (int.parse(value) + int.parse(element)).toString());

          if (list_data.length == 0)
            total1 = "0";
          else
            total1 = snapshot.data
                .map((Task task) => task.tprice)
                .toList()
                .reduce((value, element) =>
                    (int.parse(value) + int.parse(element)).toString());
          // rae = task.price - task.tprice;
          final int rate = int.parse(totalPriority) - int.parse(total1);

          final filteredTasks = snapshot.data
              .where((task) =>
                  task.date.year == _selectedDate.year &&
                  task.date.month == _selectedDate.month &&
                  task.date.day == _selectedDate.day)
              .toList();

          return RefreshIndicator(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 0.0),
              itemCount: 1 + snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
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
                        Container(
                          margin:
                              const EdgeInsets.fromLTRB(20.0, 3.0, 20.0, 3.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Color.fromRGBO(230, 230, 230, 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: ListTile(
                            title: Text(
                              'Số lượng: ${snapshot.data.length}',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            subtitle: widget.current_role == "admin"
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tổng thu: ${totalPriority}.000đ',
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      Text(
                                        'Tổng chi: ${total1}.000đ',
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      Text(
                                        'Lãi: ${rate}.000đ',
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        )
                      ],
                    ),
                  );
                }
                return _buildTask(snapshot.data[index - 1]);
              },
            ),
            onRefresh: _pullRefresh,
          );
        },
      ),
      drawer: MyDrawer(),
    );
  }
}
