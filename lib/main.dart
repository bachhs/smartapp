import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/firebase_options.dart';
import 'package:task_manager/models/shop_model.dart';
import 'package:task_manager/models/user_model.dart';
import 'package:task_manager/screens/home.dart';
import 'package:task_manager/screens/home_screen.dart';
import 'package:task_manager/screens/login.dart';
import 'package:task_manager/screens/splash_screen.dart';

String _current_shop = "";
List<String> _shopList = [];
void _initDataShop(String current_email) async {
  UserModel user = await getNameFirestore(current_email);
  if (user.role == "admin") {
    await _initDataUser(user.role);
    _current_shop = _shopList[0];
  } else {
    await _initDataUser(user.role);
    _current_shop = user.role;
  }
}

void _initDataUser(String role) async {
  List<String> sList = await await getListShop();
  if (role == "admin")
    _shopList.addAll(sList);
  else {
    _shopList.add(role);
  }
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

Future<UserModel> getNameFirestore(String current_email) async {
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
      if (current_email == EmailList[i].email) {
        current_user = EmailList[i];
      }
    }
    return current_user;
  } catch (e) {
    print(e.toString());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String _email = await prefs.getString('username');
  String _password = await prefs.getString('password');
  if (_email != null && _password != null) {
    print(_email);
    print(_password);
    await _initDataShop(_email);
  }

  Widget _defaultHome = await _email == null || _password == null
      ? Login(UserModel(email: "", password: "", role: "", name: ""))
      : Home(_email, _current_shop);
  runApp(MyApp(_defaultHome));
}

class MyApp extends StatelessWidget {
  final Widget defaultHome;

  MyApp(this.defaultHome);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phụ kiên Điện Thoại',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: defaultHome,
    );
  }
}
