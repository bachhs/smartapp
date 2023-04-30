import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_manager/models/shop_model.dart';
import 'package:task_manager/models/user_model.dart';
import 'package:task_manager/screens/home_screen.dart';
import 'package:task_manager/screens/navigator_draw.dart';

class Home extends StatefulWidget {
  final String current_email;
  final String current_shop;
  Home(this.current_email, this.current_shop);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _current_name = "";
  String _current_shop = "";
  List<String> _shopList = [];
  String _current_role = "";
  @override
  void initState() {
    super.initState();
    _initDataShop();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initDataShop() async {
    UserModel user = await await getNameFirestore();
    if (user.role == "admin") {
      await _initDataUser(user.role);
      _current_name = user.name;
      _current_shop = widget.current_shop;
      _current_role = user.role;
    } else {
      await _initDataUser(user.role);
      _current_name = user.name;
      _current_shop = user.role;
      _current_role = user.role;
    }
  }

  void _initDataUser(String role) async {
    List<String> sList = await await getListShop();
    setState(() {
      if (role == "admin")
        _shopList.addAll(sList);
      else {
        _shopList.add(role);
      }
    });
  }

  Future<List<String>> getListShop() async {
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

  Future<UserModel> getNameFirestore() async {
    List<UserModel> EmailList = [];
    UserModel current_user;
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('user').get();
      List<QueryDocumentSnapshot> documents = querySnapshot.docs;
      for (var document in documents) {
        UserModel user = UserModel.fromMap(document.data());
        EmailList.add(user);
      }
      for (var i = 0; i < EmailList.length; i++) {
        if (widget.current_email == EmailList[i].email) {
          current_user = EmailList[i];
        }
      }
      return current_user;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> _onWillPop() async {
    return showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Bạn có muốn thoát ứng dụng?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Không'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('Có'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // List<Widget> list = [
  //   HomeScreen(),
  // ];
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
              appBar: AppBar(
                backgroundColor: Color.fromRGBO(143, 148, 251, .6),
                title: Text(_current_shop),
              ),
              body: HomeScreen(
                  widget.current_shop, widget.current_email, _current_role),
              drawer: MyDrawer(
                current_email: widget.current_email,
                current_name: _current_name,
                list_shop: _shopList,
                current_shop: _current_shop,
              )),
        ));
  }
}
