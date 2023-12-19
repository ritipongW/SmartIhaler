//import 'dart:html';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../ui.dart';
import 'dart:async';
import '../linechart.dart';
import 'dart:io';
import 'dart:math';
import 'package:external_path/external_path.dart';
import 'package:permission_handler/permission_handler.dart';

import '../variables.dart' as globals;
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
// ส่งค่า ไปทำอีกคลาส
  bool finger = false;
// config ตัวกดรับค่า
  FlutterBlue flutterBluepush = FlutterBlue.instance;
  BluetoothDevice? connectedDevicepush;
  BluetoothCharacteristic? targetCharacteristicpush;
  int receivedDatapush = 0;
  String connectionStatuspush = 'Not Connected';
  String serviceUuid_rq_push = '72213524-9407-11ee-b9d1-0242ac120002';
  int pushValue0 = 0; //เก็บค่าการกด
  int pushValue1 = 0; //เก็บค่าการกด
  int? changvalue = null;

// config ตัววัด os%
  FlutterBlue flutterBluefinger = FlutterBlue.instance;
  BluetoothDevice? connectedDevicefinger;
  BluetoothCharacteristic? targetCharacteristicfinger;
  String receivedDatafinger = '';
  String connectionStatusfinger = 'Not Connected';
  String serviceUuid_rq_finger = '6e400091-b5a3-f393-e0a9-e50e24dcca9e';

  @override
  void initState() {
    super.initState();

    // เมื่อแอปเริ่มทำงาน
    startBluetoothConnectionpush();
    //startBluetoothConnectionfinger();
  }

  startBluetoothConnectionpush() async {
    // สแกนหาอุปกรณ์ Bluetooth
    await for (ScanResult scanResult in flutterBluepush.scan()) {
      // เชื่อมต่อกับอุปกรณ์ที่คุณต้องการ (ตามเงื่อนไขที่คุณต้องการ)
      print(scanResult);
      if (scanResult.device.name == "BMEi_IoT") {
        // ทำการเชื่อมต่อ
        setState(() {
          connectionStatuspush = 'กำลังทำการเชื่อมต่อ';
        });
        await scanResult.device.connect().then((result) {
          // เชื่อมต่อสำเร็จ
          setState(() {
            connectedDevicepush = scanResult.device;
            connectionStatuspush = 'เชื่อมต่อสำเสร็จ';
          });

          // ค้นหา Characteristic ที่คุณต้องการ (ตาม UUID หรือเงื่อนไขที่เหมาะสม)
          scanResult.device.discoverServices().then((services) async {
            // จำลองการวนลูปทุกรอบเพื่อดึงรายการ characteristics ทั้งหมดใน service
            for (BluetoothService service in services) {
              print('Service UUID: ${service.uuid}');
              print('services: ${services}');
              // เช็คเพื่อทำให้แน่ใจว่าเรามี Characteristic ที่เราต้องการ
              if (service.uuid.toString() == serviceUuid_rq_push) {
                // ดึงรายการ characteristics ทั้งหมดใน service
                print('เข้าเงื่อนไขที่ uuid:${service.uuid}');

                List<BluetoothCharacteristic> characteristics =
                    service.characteristics;

                // ตรวจสอบ characteristic ที่รองรับ Notify
                for (BluetoothCharacteristic characteristic
                in characteristics) {
                  if (characteristic.properties.notify) {
                    setState(() {
                      targetCharacteristicpush = characteristic;
                    });
                    print('charUUID = ${targetCharacteristicpush}');

                    // เปิดการ Notify
                    targetCharacteristicpush!.setNotifyValue(true);

                    // ฟังก์ชัน callback สำหรับการรับข้อมูล Notify
                    targetCharacteristicpush!.value.listen((value) {
                      print('ค่าที่ส่งมาทาง ble ${value[0]}');

                      setState(() {
                        receivedDatapush = value[0];
                        if (receivedDatapush % 2 == 0) {
                          pushValue0 = receivedDatapush;
                        } else {
                          pushValue1 = receivedDatapush;
                        }
                        if (receivedDatapush ==
                            (pushValue0 - pushValue1).abs()) {
                          // แก้บัคอังกอ %2
                          changvalue == null;
                        } else {
                          changvalue = (pushValue0 - pushValue1).abs();
                        }
                        disconnect();
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
          startBluetoothConnectionpush();
        });
      }
    }
  }

/////////////////////////// startBluetoothConnectionfinger ////////////////////////////////////
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
                    print('charUUID = ${targetCharacteristicfinger}');

                    // เปิดการ Notify
                    targetCharacteristicfinger!.setNotifyValue(true);

                    // ฟังก์ชัน callback สำหรับการรับข้อมูล Notify
                    targetCharacteristicfinger!.value.listen((value) {
                      print('ค่าที่ส่งมาทาง ble ${value}');
                      setState(() {
                        // ทำอะไรกับข้อมูลที่ได้รับได้ตรงนี้
                        receivedDatafinger = value.toString();
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

//////////////////////////////////// disconnect() ///////////////////////////////////////
  Future<void> disconnect() async {
    // ตัวอย่างการใช้งานเมื่อต้องการ disconnect
    if (changvalue == 1) {
      // รับค่าจาก changvalue
      if (connectedDevicepush != null) {
        await connectedDevicepush!.disconnect();
        await flutterBluepush.stopScan();
        setState(() {
          connectedDevicepush =
          null; // ตั้งค่าให้ connectedDevicepush เป็น null เพื่อระบุว่าไม่ได้เชื่อมต่อ
          connectionStatuspush = 'มีการกดใช้งาน';
        });
      }
      finger = true;
      //startBluetoothConnectionfinger(); // ไปเชื่อมต่อ startBluetoothConnectionfinger()
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('โปรแกรมบันทึกผล Smart Inhaler'),
        backgroundColor: Color.fromARGB(255, 134, 71, 129),
      ),
      body: Center(
        child: Container(
          //color: Colors.purple,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Text('Received Data: $receivedDatapush'),
              //Text('Changvalue Data: $changvalue'),
              if (connectedDevicepush != null)
                Text(
                  'เชื่อมต่อเครื่องพ่น: ${connectedDevicepush!.name}',
                  style: TextStyle(
                    fontSize: 25, // ปรับขนาดตัวหนังสือตามต้องการ
                    fontWeight: FontWeight.bold, // ตั้งค่าความหนาของตัวหนังสือ
                    color: Color.fromARGB(255, 11, 9, 22),
                  ),
                ), // ตั้งสีตัวหนังสือ),
              Text(
                'สถานะการเชื่อมต่อ: $connectionStatuspush',
                style: TextStyle(
                  fontSize: 20.0, // ปรับขนาดตัวหนังสือตามต้องการ
                  fontWeight: FontWeight.bold, // ตั้งค่าความหนาของตัวหนังสือ
                  color: Color.fromARGB(255, 4, 1, 8),
                ),
              ),
              //if (connectedDevicepush != null)
              //  Text('Connected to: ${connectedDevicepush!.name}'),
              if (finger == true) Myfinger(),
              //Mylinecharts(),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////// class Myfinger /////////////////////////////////////////////////

class Myfinger extends StatefulWidget {
  @override
  _MyHomePageStatefinger createState() => _MyHomePageStatefinger();
}

class _MyHomePageStatefinger extends State<Myfinger> {
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
  List<dynamic> datatime = [];
  List<dynamic> dataSpO2 = [];
  List<dynamic> dataPRbpm = [];
  List<dynamic> dataList = [];
  DateTime time = DateTime.now();


  @override
  void initState() {
    super.initState();

    // เมื่อแอปเริ่มทำงาน
    startBluetoothConnectionfinger();
  }

/////////////////////////// startBluetoothConnectionfinger ////////////////////////////////////
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
                    targetCharacteristicfinger!.value.listen((value) async{
                      // print('ค่าที่ส่งมาทาง ble ${value}');
                      // print('ค่าที่ส่งมาทาง ble ${value[3]}');
                      // print('ค่าที่ส่งมาทาง ble ${value[4]}');
                      // print(time.second);
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
                        if(globals.associateLists.length > 720){
                          //print("Save data List toCSV");
                          await saveListToFile();
                        }
                      }


                      setState(() {
                        // ทำอะไรกับข้อมูลที่ได้รับได้ตรงนี้
                        time = DateTime.now();
                        receivedDatafinger_PRbpm1 = value[3];//double.parse('${value[3]}');
                        receivedDatafinger_SpO21 = value[4];//double.parse('${value[4]}');

                        // receivedDatafinger_PRbpm1 = double.parse(
                        //     receivedDatafinger_PRbpm0.toStringAsFixed(2));
                        // receivedDatafinger_SpO21 = double.parse(
                        //     receivedDatafinger_SpO20.toStringAsFixed(2));
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
    Map<Permission, PermissionStatus> statuses = await [
      Permission.manageExternalStorage,
      Permission.storage,
    ].request();

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
      // Create a new file in the Downloads directory
      //File file = File('${downloadsDirectory}/my_text_file.csv');
      //file.writeAsString(csv);
      //String fileContent =
      //rows.join('\n'); // Join list elements with newlines
      // Write the content to the file
      //await file.writeAsString(fileContent);
      // Show a success message
      disconnect();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          //content: Text('File saved successfully at ${file.path}'),
          content: Text('หยุดและบันทึกข้อมูลสำเร็จ'),
        ),

      );
      //pop up
      //closeAppUsingSystemPop();
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

  void closeAppUsingExit() {
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //แสดงข้อความของ finger os%
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Text('Data PRbpm: $receivedDatafinger_PRbpm0'),
              //Text('Data SpO2: $receivedDatafinger_SpO20'),
              if (connectedDevicefinger != null)
              //Text('Connected to: ${connectedDevicefinger!.name}'),
                Padding(
                  padding: EdgeInsets.all(9.0),
                ),
            ],
          ),

          Row(
            children: [
              Padding(
                padding: EdgeInsets.all(9.0), // หรือใส่ค่าที่ต้องการ
              ),
              SleekCircularSliderWidget(pRbpm: receivedDatafinger_PRbpm1),
              Padding(
                padding: EdgeInsets.all(15.0), // หรือใส่ค่าที่ต้องการ
              ),
              SleekCircularSliderWidget1(sp: receivedDatafinger_SpO21),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.all(25.0), // หรือใส่ค่าที่ต้องการ
              ),
              Mylinecharts(valueos: receivedDatafinger_SpO21),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 80.0),
            height: 50,
            child: TextButton(
              // onPressed: () {
              //   saveListToFile(datatime, dataPRbpm, dataSpO2);
              //   // ทำงานเมื่อปุ่มถูกกด
              //   // ตัวอย่างเช่น
              //   setState(() {
              //     save = true;
              //   });
              // },
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('กดรับทราบคำชี้แจง'),
                  content: const Text('เมื่อบันทึกข้อมูลเสร็จ โปรแกรมจะปิดตัวเองอัตโนมัติ'),
                  actions: <Widget>[
                    ElevatedButton(
                      onPressed: () async{
                        await saveListToFile();
                      },
                      child: const Text('รับทราบ'),
                    ),
                  ],
                ),
              ),
              child: const Text('หยุดเพื่อบันทึกข้อมูล',style: TextStyle(fontSize: 25.0,)),
              style: ButtonStyle(
                backgroundColor:MaterialStateProperty.all<Color>(Colors.red),
                foregroundColor:MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
