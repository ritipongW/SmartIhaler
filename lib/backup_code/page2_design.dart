import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:io';
import '../variables.dart' as globals;

import '../ui.dart';
import 'dart:async';
import '../linechart.dart';

class HomePage_monitor extends StatefulWidget {
  HomePage_monitor({Key? key}) : super(key: key);
  //final String title_status;

  @override
  State<HomePage_monitor> createState() => _Homepage_monitorState();
}

class _Homepage_monitorState extends State<HomePage_monitor> {
  // config ตัววัด os%
  FlutterBlue flutterBluefinger = FlutterBlue.instance;
  BluetoothDevice? connectedDevicefinger;
  BluetoothCharacteristic? targetCharacteristicfinger;
  double receivedDatafinger_PRbpm0 = 0;
  double receivedDatafinger_SpO20 = 0;
  int receivedDatafinger_PRbpm1 = 0;
  int receivedDatafinger_SpO21 = 0;

  String connectionStatusfinger = 'Not Connected';
  String serviceUuid_rq_finger = '6e400091-b5a3-f393-e0a9-e50e24dcca9e';

///////////////// save flie////////////////////////
  bool save = false;
  String filePath = '/path/to/your/file';
  String fileName = 'your_file.txt';
  List<dynamic> dataList = [];
  DateTime time = DateTime.now();


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(""),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  SleekCircularSliderWidget(pRbpm: receivedDatafinger_PRbpm1),
                  Text('Pulse'),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 50, 0, 0), // หรือใส่ค่าที่ต้องการ
              ),
              Column(
                children: [
                  SleekCircularSliderWidget1(sp: receivedDatafinger_SpO21),
                  Text('SpO2'),
                ],
              ),
            ], //children
          ),
          Text(""),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Mylinecharts(valueos: receivedDatafinger_SpO21),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.redAccent;
                        }
                        return Colors.green;
                      },
                    ),
                  ),
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('กด "รับทราบ" คำชี้แจง'),
                      content: const Text('เมื่อบันทึกข้อมูลเสร็จ โปรแกรมจะปิดตัวเองอัตโนมัติ'),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () async{
                            //await saveListToFile();
                          },
                          child: const Text('รับทราบ'),),
                      ],
                    ),
                  ), child: const Text('หยุดเพื่อบันทึกข้อมูล',style: TextStyle(fontSize: 18.0,)),
              ),
            ],
          ),

        ],// children
      ),
    );
  }
}