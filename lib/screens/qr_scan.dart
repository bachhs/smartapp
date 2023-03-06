import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_manager/helpers/database_helper.dart';
import 'package:task_manager/screens/home.dart';
import 'home_screen.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class qrScan extends StatefulWidget {
  final String name_shop;
  final String current_email;
  qrScan(this.name_shop, this.current_email);
  @override
  _qrScanState createState() => _qrScanState();
}

class _qrScanState extends State<qrScan> {
  String _scanBarcode = 'Unknown';

  showAlertDialog(BuildContext context) async {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = FloatingActionButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // ignore: deprecated_member_use
    Widget continueButton = FloatingActionButton(
      child: Text("OK"),
      onPressed: () {
        DatabaseHelper.instance.deleteAllTask();
        // Toast.show("All data cleared", textStyle: context,
        //   );
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => Home(widget.current_email, widget.name_shop)));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text("Would you like to clear all data? It cannot be undone."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)
        .listen((barcode) => print(barcode));
  }

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Barcode scan')),
        body: Builder(builder: (BuildContext context) {
          return Container(
              alignment: Alignment.center,
              child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: () => scanQR(),
                        child: Text('Start QR scan')),
                    // ElevatedButton(
                    //     onPressed: () => startBarcodeScanStream(),
                    //     child: Text('Start barcode scan stream')),
                    Text('Scan result : $_scanBarcode\n',
                        style: TextStyle(fontSize: 20))
                  ]));
        }));
  }
}
