import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/models/shop_model.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/screens/home.dart';
import '../models/device_model.dart';
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
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  List<Device> _deviceList = [];
  List<Device> _filteredDeviceList = [];
  List<Device> data = [];
  String _title = '';
  String _numberSell = '';
  String _priority;
  String _tprice = '';
  DateTime _date = DateTime.now();
  String _role = "Cửa hàng Quang Tèo 1";
  int selectedCardIndex = -1;
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
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
    super.initState();

    if (widget.task != null) {
      _title = widget.task.title;
      _date = widget.task.date;
      _priority = widget.task.price;
      _tprice = widget.task.tprice;
      _numberSell = widget.task.numberSell;
    }

    _dateController.text = _dateFormatter.format(_date);
    _initData();
    _initDeviceData();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initData() async {
    List<String> userList = await await getDataShopFirestore();
    setState(() {
      _shopList.addAll(userList);
    });
  }

  Future<void> _initDeviceData() async {
    // Lấy danh sách thiết bị từ Firestore
    List<Device> deviceList = await getDataDeviceFirestore();
    setState(() {
      _deviceList = deviceList;
      _filteredDeviceList = deviceList;
    });
    _filteredDeviceList.sort((a, b) => a.name.compareTo(b.name));
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
    // final DateTime date = await showDatePicker(
    //   context: context,
    //   initialDate: _date,
    //   firstDate: DateTime(2000),
    //   lastDate: DateTime(2100),
    // );
    final DateTime date = DateTime.now();
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

  // Update ddataa JSON
  void updateDataDeviceFireStore(String idSelect, Device task) async {
    final docUser = FirebaseFirestore.instance.collection('device');
    docUser.doc(idSelect).update(task.toMap());
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

  _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('$_title, $_date, $_priority');

      Task task = Task(
          title: _title,
          date: _date,
          price: _priority,
          shop: widget.name_shop,
          tprice: _tprice,
          numberSell: _numberSell);
      if (widget.task == null) {
        // Insert the task to our user's database
        task.status = "0";
        //DatabaseHelper.instance.insertTask(task);
        await sendDataFireStore(task).then((value) => widget.updateTaskList());
        // Toast.show(
        //   "New Task Added",
        //   textStyle: context,
        // );
      } else {
        // Update the task
        task.id = widget.task.id;
        task.status = widget.task.status;
        await updateDataFireStore(task.id, task)
            .then((value) => widget.updateTaskList());
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
      await widget.updateTaskList();
    }
  }

  // Update ddataa JSON
  Future<void> updateDataFireStore(String idSelect, Task task) async {
    final docUser = FirebaseFirestore.instance.collection('phone');
    await docUser.doc(idSelect).update(task.toMap());
  }

  Future<void> sendDataFireStore(Task task) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('phone')
        .where('title', isEqualTo: task.title)
        .where('shop', isEqualTo: task.shop)
        .get();
    var docResult = null;
    if (snapshot.docs.isNotEmpty) {
      var doc = snapshot.docs;
      for (var i = 0; i < doc.length; i++) {
        DateTime dateDoc = DateTime.parse(doc[i]['date']);
        int resultday = dateDoc.day.compareTo(task.date.day);
        int resultmonth = dateDoc.month.compareTo(task.date.month);
        int resultyear = dateDoc.year.compareTo(task.date.year);
        if (resultday == 0 && resultmonth == 0 && resultyear == 0) {
          docResult = doc[i];
        }
      }
      if (docResult != null) {
        // Nếu tài liệu tồn tại, hãy cập nhật trường numberSell của tài liệu phù hợp đầu tiên
        final updatedNumberSell =
            (int.parse(docResult['numberSell'] ?? '0') + 1).toString();
        await docResult.reference.update({'numberSell': updatedNumberSell});
      } else {
        String unique_id = UniqueKey().toString();
        Map<String, String> todoList = await {
          "id": unique_id,
          "title": task.title,
          "date": task.date.toString(),
          "price": task.price,
          "status": task.status,
          "shop": task.shop,
          "tprice": task.tprice,
          "numberSell": task.numberSell,
          "giamgia": "0",
        };
        await FirebaseFirestore.instance
            .collection('phone')
            .doc(unique_id)
            .set(todoList);
      }
    } else {
      // Nếu không có tài liệu nào tồn tại, hãy tạo một tài liệu mới với dữ liệu được cung cấp
      String unique_id = UniqueKey().toString();
      Map<String, String> todoList = await {
        "id": unique_id,
        "title": task.title,
        "date": task.date.toString(),
        "price": task.price,
        "status": task.status,
        "shop": task.shop,
        "tprice": task.tprice,
        "numberSell": task.numberSell,
        "giamgia": "0",
      };
      await FirebaseFirestore.instance
          .collection('phone')
          .doc(unique_id)
          .set(todoList);
    }
  }

  Future<List<Device>> getDataDeviceFirestore() async {
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
    taskList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
    return taskList;
  }

  void _updateDeviceList(String query) {
    List<Device> filteredList = _deviceList
        .where(
            (device) => device.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredDeviceList = filteredList;
    });
    _filteredDeviceList.sort((a, b) => a.name.compareTo(b.name));
  }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         leading: IconButton(
//             icon: Icon(
//               Icons.arrow_back_ios,
//               color: Colors.black,
//             ),
//             onPressed: () => Navigator.pop(context)),
//         title: Text(
//           widget.task == null ? 'Thêm phụ kiện' : 'Sửa phụ kiện',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 20.0,
//             fontWeight: FontWeight.normal,
//           ),
//         ),
//         centerTitle: false,
//         elevation: 0,
//       ),
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: SingleChildScrollView(
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 Padding(
//                   padding: EdgeInsets.only(bottom: 20.0),
//                   child: IconButton(
//                     icon: Icon(
//                       Icons.phone_android_outlined,
//                       color: Color.fromRGBO(143, 148, 251, 1),
//                       size: 60,
//                     ),
//                   ),
//                 ),
//                 // Expanded(
//                 //   child: ListView.builder(
//                 //     itemCount: _filteredNames.length,
//                 //     itemBuilder: (context, index) {
//                 //       return ListTile(
//                 //         title: Text(_filteredNames[index]),
//                 //       );
//                 //     },
//                 //   ),
//                 // ),
//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     children: <Widget>[
//                       Padding(
//                         padding: EdgeInsets.symmetric(vertical: 10.0),
//                         child: TextFormField(
//                           style: TextStyle(fontSize: 18.0),
//                           decoration: InputDecoration(
//                             hintText: 'Tìm kiếm phụ kiện',
//                             hintStyle: TextStyle(fontSize: 18.0),
//                             prefixIcon: Icon(Icons.search),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                           ),
//                           validator: (input) =>
//                               input.trim().isEmpty ? 'Nhập tên phụ kiện' : null,
//                           onChanged: filterNames,
//                           initialValue: _title,
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.symmetric(vertical: 10.0),
//                         child: TextFormField(
//                           keyboardType: TextInputType.number,
//                           style: TextStyle(fontSize: 18.0),
//                           decoration: InputDecoration(
//                             labelText: 'Giá',
//                             labelStyle: TextStyle(fontSize: 18.0),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                           ),
//                           validator: (input) =>
//                               input.trim().isEmpty ? 'Nhập giá phụ kiện' : null,
//                           onSaved: (input) => _priority = input,
//                           initialValue: _priority,
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.symmetric(vertical: 10.0),
//                         child: TextFormField(
//                           keyboardType: TextInputType.number,
//                           style: TextStyle(fontSize: 18.0),
//                           decoration: InputDecoration(
//                             labelText: 'Giá nhập',
//                             labelStyle: TextStyle(fontSize: 18.0),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                           ),
//                           validator: (input) => input.trim().isEmpty
//                               ? 'Nhập giá nhập phụ kiện'
//                               : null,
//                           onSaved: (input) => _tprice = input,
//                           initialValue: _tprice,
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.symmetric(vertical: 10.0),
//                         child: TextFormField(
//                           readOnly: true,
//                           controller: _dateController,
//                           style: TextStyle(fontSize: 18.0),
//                           onTap: _handleDatePicker,
//                           decoration: InputDecoration(
//                             labelText: 'Date',
//                             labelStyle: TextStyle(fontSize: 18.0),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                           padding: EdgeInsets.all(8.0),
//                           child: DropdownButton<String>(
//                             value: widget.name_shop,
//                             items: _shopList.map((String value) {
//                               return DropdownMenuItem<String>(
//                                 value: value,
//                                 child: Text(value),
//                               );
//                             }).toList(),
//                             onChanged: (String newValue) {
//                               setState(() {
//                                 _role = newValue;
//                               });
//                             },
//                           )),
//                       SizedBox(height: 20.0),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           FloatingActionButton.extended(
//                             heroTag: 'save_button',
//                             shape: StadiumBorder(),
//                             label: Text(
//                               widget.task == null ? 'Thêm' : 'Sửa',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20.0,
//                               ),
//                             ),
//                             onPressed: _submit,
//                           ),
//                           SizedBox(width: 20.0),
//                           widget.task != null
//                               ? FloatingActionButton.extended(
//                                   heroTag: 'delete_button',
//                                   shape: StadiumBorder(),
//                                   label: Text(
//                                     'Xóa',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 20.0,
//                                     ),
//                                   ),
//                                   backgroundColor: Colors.redAccent,
//                                   onPressed: _delete,
//                                 )
//                               : SizedBox.shrink(),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text('Danh sách thiết bị', style: TextStyle(fontSize: 24)),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Tìm kiếm thiết bị',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search, color: Colors.grey),
                      onPressed: null,
                    ),
                  ),
                  onChanged: (value) {
                    _updateDeviceList(value);
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                itemCount: _filteredDeviceList.length,
                itemBuilder: (BuildContext context, int index) {
                  Device device = _filteredDeviceList[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCardIndex = index;
                      });
                      _title = device.name;
                      _priority = device.bprice;
                      _tprice = device.nprice;
                      _numberSell = '1';
                      if (widget.name_shop == "Cửa hàng Quang Tèo 1") {
                        device.number[0] =
                            (int.parse(device.number[0]) - 1).toString();
                      } else if (widget.name_shop == "Cửa hàng Quang Tèo 2") {
                        device.number[1] =
                            (int.parse(device.number[1]) - 1).toString();
                      } else {
                        device.number[2] =
                            (int.parse(device.number[2]) - 1).toString();
                      }
                      updateDataDeviceFireStore(device.id, device);
                      _handleDatePicker();
                      _submit();
                    },
                    child: Card(
                      color: selectedCardIndex == index ? Colors.purple : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        leading: Text('${index + 1}',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Raleway')),
                        title: GestureDetector(
                          child: Text(device.name,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        subtitle: Text("Giá bán: " + device.bprice + ".000 đ",
                            style: TextStyle(fontSize: 16)),
                        trailing: widget.name_shop == "Cửa hàng Quang Tèo 1"
                            ? Text(device.number[0].toString(),
                                style: TextStyle(fontSize: 16))
                            : widget.name_shop == "Cửa hàng Quang Tèo 2"
                                ? Text(device.number[1].toString(),
                                    style: TextStyle(fontSize: 16))
                                : Text(device.number[2].toString(),
                                    style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
