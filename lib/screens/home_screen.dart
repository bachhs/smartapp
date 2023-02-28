import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:task_manager/helpers/database_helper.dart';
import 'package:task_manager/models/task_model.dart';
import 'history_screen.dart';
import 'package:task_manager/screens/add_task_screen.dart';
import 'package:intl/intl.dart';
import 'settings_screen.dart';
import 'qr_scan.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:connectivity/connectivity.dart';
// import 'package:toast/toast.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Task>> _taskList;
  String title = "";
  List<String> todos = <String>[];
  TextEditingController controller = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy hh:mm a');
  List<Task> data = [];
  String totalPriority = "";
  String _scanBarcode = 'Unknown';

  final String url =
      "https://gist.githubusercontent.com/thangleuet/d981ae220775be66e9366b743ad012a6/raw/f220c0574e2a9aee904b04c2fa263c43e1f7d663/smartHome";

  // convert _taskList to json data
  // data = _taskList;

  @override
  void initState() {
    super.initState();
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
      taskList.add(task);
    }
    // Check task_list is empty or not

    taskList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
    for (var i = 0; i < data.length; i++) {
      // add the data to the _taskList
      _taskList.then((value) => value.add(data[i]));
      // Sort the _taskList
      _taskList.then((value) =>
          value.sort((taskA, taskB) => taskA.date.compareTo(taskB.date)));
    }
    return taskList;
  }

  void deleteTask(Task task) async {
    var collection = FirebaseFirestore.instance.collection('phone');
    collection
        .doc(task.id) // <-- Doc ID to be deleted.
        .delete();
  }

  _updateTaskList() {
    setState(() {
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
      "priority": task.priority,
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
      Task task =
          Task(title: _title, date: DateTime.now(), priority: _priority);
      sendDataFireStore(task);
      _updateTaskList();
    });
  }
  

  Widget _buildTask(Task task) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price: ${task.priority}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  // Head line
                ),
              ),
              Text(
                '${_dateFormatter.format(task.date)}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () async {
              await deleteTask(task);
              // Toast.show(
              //   "Task Removed",
              //   textStyle: context,
              // );
              _updateTaskList();
            },
            // activeColor: Theme.of(context).primaryColor,
            // value: task.status == 1 ? true : false,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(
                updateTaskList: _updateTaskList,
                task: task,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          child: Icon(Icons.add_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(
                updateTaskList: _updateTaskList,
              ),
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(
                Icons.phone_android,
                color: Colors.greenAccent,
              ),
              onPressed: null),
          title: Text(
            "List Accessories",
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: false,
          elevation: 0,
          actions: [
            Container(
              margin: const EdgeInsets.all(0),
              child: IconButton(
                icon: Icon(Icons.history_outlined),
                iconSize: 25.0,
                color: Colors.black,
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => HistoryScreen())),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(6.0),
              child: IconButton(
                icon: Icon(Icons.settings_outlined),
                iconSize: 25.0,
                color: Colors.black,
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => SettingsScreen())),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(6.0),
              child: IconButton(
                icon: Icon(Icons.qr_code_scanner),
                iconSize: 25.0,
                color: Colors.black,
                onPressed: () => scanQR(),
              ),
            )
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
                snapshot.data.map((Task task) => task.priority).toList();
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
                          Container(
                            margin:
                                const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: new BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Color.fromRGBO(240, 240, 240, 1.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            child: Center(
                              child: Text(
                                'Tổng tiền: ${totalPriority} \n Số lượng: ${snapshot.data.length}',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
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
      ),
    );
  }
}
