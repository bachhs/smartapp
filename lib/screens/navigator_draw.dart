import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/models/shop_model.dart';
import 'package:task_manager/models/user_model.dart';
import 'package:task_manager/screens/home.dart';
import 'package:task_manager/screens/home_screen.dart';
import 'package:task_manager/screens/login.dart';

class MyDrawer extends StatefulWidget {
  final String current_email;
  final String current_name;
  final List<String> list_shop;
  final String current_shop;
  MyDrawer(
      {this.current_email,
      this.current_name,
      this.list_shop,
      this.current_shop});
  @override
  MyDrawerState createState() => MyDrawerState();
}

class MyDrawerState extends State<MyDrawer> {
  @override
  void initState() {
    super.initState();
  }

  void clearLoginCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('isLoggedIn');
    prefs.remove('username');
    prefs.remove('password');
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                Login(UserModel(email: "", password: "", role: "", name: ""))));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DrawerHeader(
              decoration:
                  BoxDecoration(color: Color.fromRGBO(143, 148, 251, .6)),
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 70,
                      height: 70,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Color.fromRGBO(143, 148, 251, .6),
                          size: 40,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      widget.current_name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.current_email,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: 250.0,
              child: ListView.builder(
                itemCount: widget.list_shop.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2, horizontal: 3.0),
                    child: ListTile(
                      tileColor: widget.list_shop[index] == widget.current_shop
                          ? Color.fromRGBO(143, 148, 251, .6)
                          : Colors.white,
                      leading: Icon(Icons.store),
                      title: Text(widget.list_shop[index],
                          style: TextStyle(
                            fontSize: 16,
                          )),
                      onTap: widget.list_shop[index] == widget.current_shop
                          ? null
                          : () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => Home(widget.current_email,
                                          widget.list_shop[index])));
                            },
                    ),
                  );
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Đăng xuất',
                  style: TextStyle(
                    fontSize: 16,
                  )),
              onTap: () => {
                clearLoginCredentials(),
                _signOut(),
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => Login(UserModel(
                            email: "", password: "", role: "", name: "_name"))))
              },
            ),
          ],
        ),
      ),
    );
  }
}
