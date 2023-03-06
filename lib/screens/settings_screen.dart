import 'package:flutter/material.dart';
import 'package:task_manager/helpers/database_helper.dart';
import 'package:task_manager/models/shop_model.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/screens/add_task_screen.dart';
import 'package:task_manager/screens/home.dart';
import 'home_screen.dart';
import 'stacked_icons.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final current_shop;
  final current_email;
  SettingsScreen(this.current_shop, this.current_email);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
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
            ],
          ),

          //onTap: () => _updateTask(task),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        Home(widget.current_email, widget.current_shop)))),
        title: Row(children: [
          Text(
            'Settings',
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 20.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ]),
        centerTitle: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25.0, 60.0, 25.0, 25.0),
        child: Container(
          width: double.infinity,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new StakedIcons(),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: new Text(
                      "Phụ Kiện Điện Thoại",
                      style: new TextStyle(fontSize: 20.0, color: Colors.grey),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 5.0, left: 25.0, right: 20.0, bottom: 60.0),
                child: new Container(
                    alignment: Alignment.center,
                    child: new Text("Version: 3.0.0",
                        style:
                            new TextStyle(fontSize: 12.0, color: Colors.grey))),
              ),
              SizedBox(
                width: 1080,
                height: 1,
                child: const DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.black12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
