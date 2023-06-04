import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_manager/models/device_model.dart';
import 'package:task_manager/models/money_model.dart';
import 'package:task_manager/models/shop_model.dart';
// import 'package:task_manager/helpers/database_helper.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/screens/consum.dart';
import 'package:task_manager/screens/money.dart';
import 'package:task_manager/screens/navigator_draw.dart';
import 'package:task_manager/screens/add_task_screen.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/screens/settings_screen.dart';
import 'qr_scan.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:connectivity/connectivity.dart';
// import 'package:csv/csv.dart';
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
  Future<List<Device>> _taskDevice;
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
  String number = "";
  String _scanBarcode = 'Unknown';
  DateTime _selectedDate = DateTime.now();
  Future<List<MoneyModel>> _moneyList;
  List<String> _gia_nhap = ["0", "0", "0"];
  List<String> _gia_ban = ["0", "0", "0"];

  @override
  void initState() {
    _updateTaskList();
    super.initState();
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
    await _updateTaskList();
  }

  // void saveCSV() async {
  //   List<Device> devices = await getDataDeviceJsonfireStore();
  //   List<List<dynamic>> rows = [];

  //   // Thêm hàng tiêu đề
  //   rows.add(['id', 'name']);

  //   // Thêm các hàng dữ liệu
  //   devices.forEach((device) {
  //     rows.add([device.id, device.name]);
  //   });
  //   Directory documentsDirectory = await getApplicationDocumentsDirectory();
  //   String dir = (await getExternalStorageDirectory()).path;
  //   try {
  //     // Write data to CSV file
  //     File csvFile = File('${dir}/devices.csv');
  //     String csv = const ListToCsvConverter().convert(rows);
  //     await csvFile.writeAsString(csv);
  //   } catch (e) {
  //     print('Error writing CSV file: $e');
  //   }
  // }

  Future<List<Task>> getDataJsonfireStore() async {
    List<Task> taskList = [];
    List<Task> data = [];
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('phone');

    DateTime startDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    DateTime endDate = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day + 1);

    QuerySnapshot querySnapshot = await collectionRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThan: Timestamp.fromDate(endDate))
        .orderBy('date')
        .get();

    taskList = await querySnapshot.docs
        .map((doc) => Task.fromMap(doc.data()))
        .toList();

    for (var document in taskList) {
      if (document.shop == widget.name_shop) await data.add(document);
    }

    return data;
  }

  // Future<List<Task>> getDataJsonfireStore() async {
  //   List<Task> taskList = [];
  //   CollectionReference collectionRef =
  //       FirebaseFirestore.instance.collection('phone');
  //   // Get docs from collection reference
  //   QuerySnapshot querySnapshot = await collectionRef.get();

  //   // for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
  //   //   var dateFieldValue = docSnapshot['date'];
  //   //   if (dateFieldValue is String) {
  //   //     DateTime date = DateTime.parse(docSnapshot['date']);
  //   //     Timestamp timestamp = Timestamp.fromDate(date);
  //   //     await docSnapshot.reference.update({'date': timestamp});
  //   //   }
  //   // }

  //   // Get data from docs and convert map to List
  //   final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
  //   for (var document in allData) {
  //     Task task = Task.fromMap(document);
  //     int resultday = _selectedDate.day.compareTo(task.date.day);
  //     int resultmonth = _selectedDate.month.compareTo(task.date.month);
  //     int resultyear = _selectedDate.year.compareTo(task.date.year);
  //     if (resultday == 0 &&
  //         resultmonth == 0 &&
  //         resultyear == 0 &&
  //         task.shop == widget.name_shop) taskList.add(task);
  //   }

  //   // Check task_list is empty or not
  //   taskList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
  //   return taskList;
  // }

  Future<List<Device>> getDataDeviceJsonfireStore(String id) async {
    List<Device> taskList = [];

    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('device');
    // Get docs from collection reference
    QuerySnapshot querySnapshot =
        await collectionRef.where('id', isEqualTo: id).get();
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

  Future<void> sendDataMoneyFireStore(MoneyModel task) async {
    String unique_id = UniqueKey().toString();
    Map<String, dynamic> todoList;
    if (widget.name_shop == "Cửa hàng Quang Tèo 1") {
      todoList = await {
        "id": unique_id,
        "date": Timestamp.fromDate(task.date),
        "gia_nhap": task.gia_nhap,
        "gia_ban": task.gia_ban,
      };
    } else if (widget.name_shop == "Cửa hàng Quang Tèo 2") {
      todoList = await {
        "id": unique_id,
        "gia_nhap": task.gia_nhap,
        "date": Timestamp.fromDate(task.date),
        "gia_ban": task.gia_ban,
      };
    } else {
      todoList = await {
        "id": unique_id,
        "gia_nhap": task.gia_nhap,
        "date": Timestamp.fromDate(task.date),
        "gia_ban": task.gia_ban,
      };
    }

    await FirebaseFirestore.instance
        .collection('money')
        .doc(unique_id)
        .set(todoList);
  }

  void updateDataMoneyFireStore(String idSelect, MoneyModel task) async {
    final docUser = FirebaseFirestore.instance.collection('money');
    docUser.doc(idSelect).update(task.toMap());
  }

  void check_money_model() async {
    DateTime date = DateTime.now();
    // final snapshot = await FirebaseFirestore.instance.collection('money').get();
    // List<MoneyModel> moneyModels = await snapshot.docs
    //     .map((doc) => MoneyModel.fromMap(doc.data()))
    //     .toList();
    // List<MoneyModel> filteredMoneyModels =
    //     await moneyModels.where((moneyModel) {
    //   DateTime moneyModelDate =
    //       moneyModel.date; // Chuyển đổi Timestamp sang DateTime

    //   // So sánh ngày, tháng và năm của DateTime với ngày, tháng và năm của date
    //   return moneyModelDate.year == _selectedDate.year &&
    //       moneyModelDate.month == _selectedDate.month &&
    //       moneyModelDate.day == _selectedDate.day;
    // }).toList();

    DateTime startDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    DateTime endDate = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day + 1);

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('money')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThan: Timestamp.fromDate(endDate))
        .get();

    List<MoneyModel> filteredMoneyModels =
        snapshot.docs.map((doc) => MoneyModel.fromMap(doc.data())).toList();

    if (filteredMoneyModels.length == 0) {
      if (widget.name_shop == "Cửa hàng Quang Tèo 1") {
        _gia_nhap[0] = total1;
        _gia_ban[0] = totalPriority;
      } else if (widget.name_shop == "Cửa hàng Quang Tèo 2") {
        _gia_nhap[1] = total1;
        _gia_ban[1] = totalPriority;
      } else {
        _gia_nhap[2] = total1;
        _gia_ban[2] = totalPriority;
      }
      MoneyModel moneySend = await MoneyModel(
        date: DateTime.now(),
        gia_nhap: _gia_nhap,
        gia_ban: _gia_ban,
      );
      await sendDataMoneyFireStore(moneySend);
    } else {
      if (widget.name_shop == "Cửa hàng Quang Tèo 1") {
        filteredMoneyModels[0].gia_nhap[0] = total1;
        filteredMoneyModels[0].gia_ban[0] = totalPriority;
      } else if (widget.name_shop == "Cửa hàng Quang Tèo 2") {
        filteredMoneyModels[0].gia_nhap[1] = total1;
        filteredMoneyModels[0].gia_ban[1] = totalPriority;
      } else {
        filteredMoneyModels[0].gia_nhap[2] = total1;
        filteredMoneyModels[0].gia_ban[2] = totalPriority;
      }
      await updateDataMoneyFireStore(
          filteredMoneyModels[0].id, filteredMoneyModels[0]);
    }
  }

  void deleteTask(Task task) async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('phone');

    final snapshot = await collectionRef
        .where('title', isEqualTo: task.title)
        // .where('date', isEqualTo: task.date.toString())
        .where('shop', isEqualTo: task.shop)
        .get();

    final snapshotDevice = await FirebaseFirestore.instance
        .collection('device')
        .where('name', isEqualTo: task.title)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Nếu tài liệu tồn tại, hãy cập nhật trường numberSell của tài liệu phù hợp đầu tiên
      //final doc = snapshot.docs.first;
      for (var doc in snapshot.docs) {
        DateTime dateDevice = doc['date'].toDate();
        int resultday = dateDevice.day.compareTo(task.date.day);
        int resultmonth = dateDevice.month.compareTo(task.date.month);
        int resultyear = dateDevice.year.compareTo(task.date.year);
        if (resultday == 0 &&
            resultmonth == 0 &&
            resultyear == 0 &&
            doc['shop'] == task.shop) {
          final updatedNumberSell =
              (int.parse(doc['numberSell']) - 1).toString();
          if (updatedNumberSell == '0') {
            await doc.reference.delete();
          } else {
            await doc.reference.update({'numberSell': updatedNumberSell});
          }
        }
        if (snapshotDevice.docs.isNotEmpty) {
          final doc = snapshotDevice.docs.first;
          List<String> numberList = doc['number'].cast<String>();
          if (widget.name_shop == "Cửa hàng Quang Tèo 1") {
            numberList[0] = (int.parse(numberList[0]) + 1).toString();
          } else if (widget.name_shop == "Cửa hàng Quang Tèo 2") {
            numberList[1] = (int.parse(numberList[1]) + 1).toString();
          } else if (widget.name_shop == "Cửa hàng Quang Tèo 3") {
            numberList[2] = (int.parse(numberList[2]) + 1).toString();
          }
          await doc.reference.update({'number': numberList});
        }
      }
    }

    // var collection = FirebaseFirestore.instance.collection('phone');
    // collection
    //     .doc(task.id) // <-- Doc ID to be deleted.
    //     .delete();
  }

  void _updateTaskList() {
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

  void _updateDeviceList(String id) {
    setState(() {
      _taskDevice = getDataDeviceJsonfireStore(id);
    });
  }

  Future<bool> onBackPressed() {
    return SystemNavigator.pop();
  }

  Future<void> _pullRefresh() async {
    Duration(seconds: 1);
    await _updateTaskList();
  }

  void updateDataDeviceFireStore(String idSelect, Device task) async {
    final docUser = FirebaseFirestore.instance.collection('device');
    docUser.doc(idSelect).update(task.toMap());
  }

  void updateDataFireStore(String idSelect, Task task) async {
    final docUser = FirebaseFirestore.instance.collection('phone');
    docUser.doc(idSelect).update(task.toMap());
  }

  Future<void> sendDataFireStore(Task task) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('phone')
        .where('title', isEqualTo: task.title)
        .where('shop', isEqualTo: task.shop)
        .get();
    final snapshotDevice = await FirebaseFirestore.instance
        .collection('device')
        .where('name', isEqualTo: task.title)
        .get();
    final docDevice = snapshotDevice.docs.first;

    if (snapshotDevice.docs.isNotEmpty) {
      final docDevice = snapshotDevice.docs.first;
      if (widget.name_shop == "Cửa hàng Quang Tèo 1") {
        final updatedNumber =
            (int.parse(docDevice['number'][0]) - 1).toString();
        final number = [
          updatedNumber,
          docDevice['number'][1],
          docDevice['number'][2]
        ];
        await docDevice.reference.update({'number': number});
      } else if (widget.name_shop == "Cửa hàng Quang Tèo 2") {
        final updatedNumber =
            (int.parse(docDevice['number'][1]) - 1).toString();
        final number = [
          docDevice['number'][0],
          updatedNumber,
          docDevice['number'][2]
        ];
        await docDevice.reference.update({'number': number});
      } else {
        final updatedNumber =
            (int.parse(docDevice['number'][2]) - 1).toString();
        final number = [
          docDevice['number'][0],
          docDevice['number'][1],
          updatedNumber
        ];
        await docDevice.reference.update({'number': number});
      }
    }
    var docResult = null;
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs;
      for (var i = 0; i < doc.length; i++) {
        DateTime dateDoc = doc[i]['date'].toDate();
        int resultday = dateDoc.day.compareTo(task.date.day);
        int resultmonth = dateDoc.month.compareTo(task.date.month);
        int resultyear = dateDoc.year.compareTo(task.date.year);
        if (resultday == 0 && resultmonth == 0 && resultyear == 0) {
          docResult = doc[i];
        }
      }
      if (docResult != null) {
        if (snapshot.docs.isNotEmpty && docResult['shop'] == widget.name_shop) {
          // Nếu tài liệu tồn tại, hãy cập nhật trường numberSell của tài liệu phù hợp đầu tiên
          final updatedNumberSell =
              (int.parse(docResult['numberSell'] ?? '0') + 1).toString();
          await docResult.reference.update({'numberSell': updatedNumberSell});
        } else {
          // Nếu không có tài liệu nào tồn tại, hãy tạo một tài liệu mới với dữ liệu được cung cấp
          String unique_id = UniqueKey().toString();
          Map<String, dynamic> todoList = {
            "id": unique_id,
            "title": task.title,
            "date": Timestamp.fromDate(task.date),
            "price": task.price,
            "status": task.status,
            "shop": task.shop,
            "tprice": task.tprice,
            "numberSell": task.numberSell,
            "giamgia": "0"
          };
          await FirebaseFirestore.instance
              .collection('phone')
              .doc(unique_id)
              .set(todoList);
        }
      } else {
        // Nếu không có tài liệu nào tồn tại, hãy tạo một tài liệu mới với dữ liệu được cung cấp
        String unique_id = UniqueKey().toString();
        Map<String, dynamic> todoList = {
          "id": unique_id,
          "title": task.title,
          "date": Timestamp.fromDate(task.date),
          "price": task.price,
          "status": task.status,
          "shop": task.shop,
          "tprice": task.tprice,
          "numberSell": task.numberSell,
          "giamgia": "0"
        };
        await FirebaseFirestore.instance
            .collection('phone')
            .doc(unique_id)
            .set(todoList);
      }
    } else {
      // Nếu không có tài liệu nào tồn tại, hãy tạo một tài liệu mới với dữ liệu được cung cấp
      String unique_id = UniqueKey().toString();
      Map<String, dynamic> todoList = {
        "id": unique_id,
        "title": task.title,
        "date": Timestamp.fromDate(task.date),
        "price": task.price,
        "status": task.status,
        "shop": task.shop,
        "tprice": task.tprice,
        "numberSell": task.numberSell,
        "giamgia": "0"
      };
      await FirebaseFirestore.instance
          .collection('phone')
          .doc(unique_id)
          .set(todoList);
    }
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

    _scanBarcode = barcodeScanRes;
    final taskList = await _taskDevice;
    _updateDeviceList(_scanBarcode);
    Device matchedDevice = taskList.firstWhere(
      (task) => task.id == _scanBarcode,
      orElse: () => null,
    );

    if (matchedDevice != null) {
      Task task = Task(
        id: matchedDevice.id,
        title: matchedDevice.name,
        date: DateTime.now(),
        price: matchedDevice.bprice,
        status: '0',
        shop: widget.name_shop,
        tprice: matchedDevice.nprice,
        numberSell: "1",
        giamgia: "0",
      );

      await sendDataFireStore(task);

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Đã thêm vào giỏ hàng:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(matchedDevice.name),
                SizedBox(height: 4),
                Text("Giá: " + matchedDevice.bprice + ".000đ"),
              ],
            ),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      await _updateTaskList();
    } else {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Không tìm thấy phụ kiện! " + _scanBarcode),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showDialog(BuildContext context, Task task) {
    String textValue = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text('Nhập số tiền giảm giá'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              textValue = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy bỏ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Xác nhận'),
              onPressed: () {
                if (textValue != "") {
                  task.giamgia = textValue;
                } else {
                  task.giamgia = "0";
                }
                updateDataFireStore(task.id, task);
                // Do something with the text value
                print('Giảm giá: $textValue');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
          title: Row(children: [
            Text(
              task.title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Raleway'),
            ),
            Text(
              "  x" + task.numberSell,
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Raleway'),
            )
          ]),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 5),
              Text(
                'Giá: ${task.price},000đ',
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
              Text('Giảm giá: ${task.giamgia},000đ',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.blueGrey,
                  )),
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
                            await _updateTaskList();
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
          onTap: () => _showDialog(context, task),
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => AddTaskScreen(
          //       updateTaskList: _updateTaskList,
          //       task: task,
          //       name_shop: widget.name_shop,
          //       current_email: widget.current_email,
          //     ),
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
      floatingActionButton: widget.current_role == "admin"
          ? FloatingActionButton(
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
            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(
              Icons.phone_android,
              color: Color.fromRGBO(143, 148, 251, 1),
            ),
            onPressed: null),
        title: Text(
          "Home",
          style: TextStyle(
              color: Color.fromRGBO(143, 148, 251, 1),
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.7,
              fontFamily: 'Audiowide'),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.all(0),
            child: IconButton(
              icon: Icon(Icons.money_outlined),
              iconSize: 25.0,
              color: Colors.black,
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => Consumer(widget.name_shop,
                          widget.current_email, widget.current_role))),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(0),
            child: IconButton(
              icon: Icon(Icons.money_off_csred_outlined),
              iconSize: 25.0,
              color: Colors.black,
              onPressed: () => {
                check_money_model(),
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MoneyPage(
                            widget.name_shop,
                            widget.current_email,
                            widget.current_role,
                            _selectedDate)))
              },
            ),
          ),
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
              icon: Icon(Icons.list_alt_outlined),
              iconSize: 25.0,
              color: Colors.black,
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SettingsScreen(widget.name_shop,
                          widget.current_email, widget.current_role))),
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
          else {
            // totalPriority = list_data.reduce((value, element) =>
            //     (int.parse(value) + int.parse(element)).toString());
            totalPriority = snapshot.data
                .map((Task task) =>
                    double.parse(task.price) * int.parse(task.numberSell) -
                    int.parse(task.giamgia))
                .reduce((total, amount) => total + amount)
                .toString();
          }

          if (list_data.length == 0)
            total1 = "0";
          else
            // total1 = snapshot.data
            //     .map((Task task) => task.tprice)
            //     .toList()
            //     .reduce((value, element) =>
            //         (int.parse(value) + int.parse(element)).toString());
            total1 = snapshot.data
                .map((Task task) =>
                    double.parse(task.tprice) * int.parse(task.numberSell))
                .reduce((total, amount) => total + amount)
                .toString();
          // rae = task.price - task.tprice;
          final double rate =
              double.parse(totalPriority) - double.parse(total1);

          final filteredTasks = snapshot.data
              .where((task) =>
                  task.date.year == _selectedDate.year &&
                  task.date.month == _selectedDate.month &&
                  task.date.day == _selectedDate.day)
              .toList();
          if (list_data.length == 0)
            number = "0";
          else
            number = snapshot.data
                .map((Task task) => task.numberSell)
                .toList()
                .reduce((value, element) =>
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
                              'Số lượng: ${number}',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tổng thu: ${totalPriority},000đ',
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                if (widget.current_role == "admin")
                                  Text(
                                    'Tổng chi: ${total1},000đ',
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                if (widget.current_role == "admin")
                                  Text(
                                    'Lãi: ${rate},000đ',
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                              ],
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
      drawer: MyDrawer(),
    );
  }
}
