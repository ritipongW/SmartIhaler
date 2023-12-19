import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:io';
import 'package:inhaler/variables.dart' as globals;

import 'package:inhaler/ui.dart';
import 'dart:async';
import 'package:inhaler/linechart.dart';

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
  void initState() {
    super.initState();

    // เมื่อแอปเริ่มทำงาน
    startBluetoothConnectionfinger();
  }

  startBluetoothConnectionfinger() async {
    print('เข้าสู่การสแกนหา startBluetoothConnectionfinger');
    // สแกนหาอุปกรณ์ Bluetooth
    await for (ScanResult scanResult in flutterBluefinger.scan()) {
      //print('$scanResult');
      // เชื่อมต่อกับอุปกรณ์ที่คุณต้องการ (ตามเงื่อนไขที่คุณต้องการ)
      if (scanResult.device.name == "PRT Server") {
        // ทำการเชื่อมต่อ
        setState(() {
          connectionStatusfinger = 'Connecting...';
        });
        await scanResult.device.connect().then((result) {
          // เชื่อมต่อสำเร็จ
          setState(() {
            connectedDevicefinger = scanResult.device;
            connectionStatusfinger = 'Connected';
          });

          // ค้นหา Characteristic ที่คุณต้องการ (ตาม UUID หรือเงื่อนไขที่เหมาะสม)
          scanResult.device.discoverServices().then((services) async {
            // จำลองการวนลูปทุกรอบเพื่อดึงรายการ characteristics ทั้งหมดใน service
            print('ค้นหา Characteristic');
            for (BluetoothService service in services) {
              print('Service UUID: ${service.uuid}');
              print('services: ${services}');
              // เช็คเพื่อทำให้แน่ใจว่าเรามี Characteristic ที่เราต้องการ
              if (service.uuid.toString() == serviceUuid_rq_finger) {
                // ดึงรายการ characteristics ทั้งหมดใน service
                print('เข้าเงื่อนไขที่ uuid:${service.uuid}');

                List<BluetoothCharacteristic> characteristics =
                    service.characteristics;

                // ตรวจสอบ characteristic ที่รองรับ Notify
                for (BluetoothCharacteristic characteristic
                in characteristics) {
                  if (characteristic.properties.notify) {
                    setState(() {
                      targetCharacteristicfinger = characteristic;
                    });
                    //print('charUUID = ${targetCharacteristicfinger}');

                    // เปิดการ Notify
                    targetCharacteristicfinger!.setNotifyValue(true);

                    // ฟังก์ชัน callback สำหรับการรับข้อมูล Notify
                    targetCharacteristicfinger!.value.listen((value)  async{

                      DateTime now = DateTime.now();
                      //Get Date Time using dart:math
                      String date = now.day.toString().padLeft(2,'0');
                      String month = now.month.toString().padLeft(2,'0');
                      String year = now.year.toString();
                      String hour = now.hour.toString().padLeft(2,'0');
                      String minute = now.minute.toString().padLeft(2,'0');
                      String second = now.second.toString().padLeft(2,'0');
                      String nowday = "$date/$month/$year";
                      String nowtime = "$hour:$minute:$second";
                      dataList = [
                        {
                          "Date": nowday,
                          "Time": nowtime,
                          "Pulse": value[3],
                          "SpO2": value[4]
                        }
                      ];globals.csv_file_name = "$date-$month-$year-$hour-$minute-$second";

                      List<dynamic> row = [];
                      if (globals.header_added == false) {
                        globals.header_added = true;
                        //compute the next second belonging time interval
                        globals.interval_sec = (now.second+globals.interval)%60;

                        //firstly, we once added a column header
                        row.add("Date");
                        row.add("Time");
                        row.add("Pulse");
                        row.add("SpO2");
                        globals.associateLists.add(row);
                        //also, the first row data is recorded in a List at the staring time
                        row = [];
                        row.add(dataList[0]["Date"]);
                        row.add(dataList[0]["Time"]);
                        row.add(dataList[0]["Pulse"]);
                        row.add(dataList[0]["SpO2"]);
                        globals.associateLists.add(row);
                      }else{
                        globals.header_added = true;

                        if(globals.interval_sec == now.second){
                          //add the next row in List
                          row = [];
                          row.add(dataList[0]["Date"]);
                          row.add(dataList[0]["Time"]);
                          row.add(dataList[0]["Pulse"]);
                          row.add(dataList[0]["SpO2"]);
                          globals.associateLists.add(row);

                          globals.interval_sec = (globals.interval_sec+globals.interval)%60;
                        }
                        //60 records in 5 minutes / 720 records in 60 minutes
                        if(globals.associateLists.length > 360){
                          //print("Save data List toCSV");
                          await saveListToFile();
                        }
                      }


                      setState(() {
                        // ทำอะไรกับข้อมูลที่ได้รับได้ตรงนี้
                        //time = DateTime.now();
                        if(value[3] < 50){
                          receivedDatafinger_PRbpm1 = 0;
                        }else{
                          receivedDatafinger_PRbpm1 = value[3];
                        }

                        if(value[4] < 50){
                          receivedDatafinger_PRbpm1 = 0;
                        }else{
                          receivedDatafinger_SpO21 = value[4];
                        }
                      });

                    });
                  }
                }
              } else {
                print('ไม่เข้าเงื่อนไขเลย');
              }
            }
          });
        }).catchError((error) {
          // หากการเชื่อมต่อล้มเหลว, ลองเริ่มที่ scan ใหม่
          print('Error connecting: $error');
          startBluetoothConnectionfinger();
        });
      }
    }
  }

  Future<void> myDelay() async{
    await Future.delayed(Duration(seconds: 5));
  }

  Future<void> saveListToFile() async {
    try {
      // Get the Downloads directory
      //String downloadsDirectory = (await getDownloadsDirectory())?.path ?? '';
      String csv = const ListToCsvConverter().convert(globals.associateLists);
      print(csv);
      String downloadsDirectory =
      await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);
      print(downloadsDirectory);
      //String path = "$downloadsDirectory/my_text_file.csv";
      //File file = await File(path).create(recursive: true);
      String fullname = "${downloadsDirectory}/Inhaler_log_${globals.csv_file_name}.csv";
      print(fullname);
      // File file = File('${downloadsDirectory}/Pulse_SpO2_Log.csv');
      File file = File(fullname);
      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          //content: Text('File saved successfully at ${file.path}'),
          content: Text('หยุดและบันทึกข้อมูลสำเร็จ'),
        ),

      );
      //pop up
      //closeAppUsingSystemPop();
      await disconnect();
      closeAppUsingExit();
    } catch (e) {
      print('Error saving file: $e');
    }
  }

  Future<void> disconnect() async {
    await connectedDevicefinger!.disconnect();
    await flutterBluefinger.stopScan();
  }

  void closeAppUsingSystemPop() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  void closeAppUsingExit()  {
     SystemNavigator.pop();
    // exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
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
          SizedBox(
            height: 20,
          ),
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
                          await saveListToFile();
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