import 'dart:developer';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_blue/flutter_blue.dart';
import 'dart:io';
import 'variables.dart' as globals;
import 'snackbar.dart';
import 'ui.dart';
import 'dart:async';
import 'linechart.dart';

class HomePage_monitor extends StatefulWidget {
  HomePage_monitor({Key? key}) : super(key: key);
  //final String title_status;

  @override
  State<HomePage_monitor> createState() => _Homepage_monitorState();
}

class _Homepage_monitorState extends State<HomePage_monitor> {
  // config ตัววัด os%
  //FlutterBlue flutterBluefinger = FlutterBlue.instance;

  BluetoothCharacteristic? targetCharacteristicfinger;
  //double receivedDatafinger_PRbpm0 = 0;
  //double receivedDatafinger_SpO20 = 0;
  int receivedDatafinger_PRbpm1 = 0;
  int receivedDatafinger_SpO21 = 0;

  BluetoothDevice? connectedDevicefinger;
  String connectionStatusfinger = 'Not Connected';
  String serviceUuid_rq_finger = '6e400091-b5a3-f393-e0a9-e50e24dcca9e';
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  List<BluetoothService> _services = [];
  List<BluetoothCharacteristic> _characteristicUuid = [];
  List<int> _value = [];
  late ScanResult BlueToothScanDev;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<List<int>> _lastValueSubscription;

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

  Future<void> StartScanning() async {
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("System Devices Error:", e),
          success: false);
    }
    try {
      // android is slow when asking for all advertisments,
      // so instead we only ask for 1/8 of them
      int divisor = Platform.isAndroid ? 8 : 1;
      await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 15), continuousUpdates: true, continuousDivisor: divisor);
      //await FlutterBluePlus.startScan();
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e),
          success: false);
    }
  }

  startBluetoothConnectionfinger() async {
    // Map<Permission, PermissionStatus> statuses = await [
    //   Permission.manageExternalStorage,
    //   Permission.storage,
    //   Permission.location
    // ].request();
    StartScanning();
    print('เข้าสู่การสแกนหา startBluetoothConnectionfinger');
    // สแกนหาอุปกรณ์ Bluetooth
    _scanResultsSubscription =
        FlutterBluePlus.onScanResults.listen((results) async {
      if (results.isNotEmpty) {
        ScanResult scanResult = results.last;

        print(
            '${scanResult.device.remoteId}: "${scanResult.advertisementData.advName}" found!');
        if (scanResult.device.advName.toString() == "PRT Server") {
          await FlutterBluePlus.stopScan();
          setState(() {
            //connectionStatusfinger = 'กำลังทำการเชื่อมต่อ';
            print('กำลังเชื่อมต่อ${scanResult}');
          });

          //if (scanResult.device.remoteId.toString() == " F2:64:3B:CA:DF:12") {
          // await Future.delayed(const Duration(seconds: 3));

          await scanResult.device.connect().then((result) {
            setState(() {
              connectedDevicefinger = scanResult.device;
              connectionStatusfinger = 'เชื่อมต่อสำเสร็จ';
              print('เชื่อมต่อสำเสร็จ');
            });
          });
          await FlutterBluePlus.stopScan();

          _services = await scanResult.device.discoverServices();
          BluetoothService service = _services[2];
          _characteristicUuid = service.characteristics;

          BluetoothCharacteristic characteristicUuid = _characteristicUuid[1];
          Snackbar.show(ABC.c, "Discover Services: Success", success: true);
          print('service uuid โวยยยย ');
          print('uuid โวยยยย ${service.serviceUuid}');
          print('characteristicUuid โวยยยย ');
          print('uuid โวยยยย ${characteristicUuid.characteristicUuid}');
          characteristicUuid
              .setNotifyValue(characteristicUuid.isNotifying == false);
          characteristicUuid.read();
          _lastValueSubscription =
              characteristicUuid.lastValueStream.listen((value) async {
            // await characteristicUuid
            //     .setNotifyValue(characteristicUuid.isNotifying == false);
            // await characteristicUuid.read();
            _value = value;
            String data = _value.toString();

            setState(() {
              print('ข้อมูล');
              print(data);
              receivedDatafinger_PRbpm1 = _value[3].toInt();
              receivedDatafinger_SpO21 = _value[4].toInt();
            });

            DateTime now = DateTime.now();
            //Get Date Time using dart:math
            String date = now.day.toString().padLeft(2, '0');
            String month = now.month.toString().padLeft(2, '0');
            String year = now.year.toString();
            String hour = now.hour.toString().padLeft(2, '0');
            String minute = now.minute.toString().padLeft(2, '0');
            String second = now.second.toString().padLeft(2, '0');
            String nowday = "$date/$month/$year";
            String nowtime = "$hour:$minute:$second";
            dataList = [
              {
                "Date": nowday,
                "Time": nowtime,
                "Pulse": value[3],
                "SpO2": value[4]
              }
            ];
            globals.csv_file_name = "$date-$month-$year-$hour-$minute-$second";

            List<dynamic> row = [];
            if (globals.header_added == false) {
              globals.header_added = true;
              //compute the next second belonging time interval
              globals.interval_sec = (now.second + globals.interval) % 60;

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
            } else {
              globals.header_added = true;

              if (globals.interval_sec == now.second) {
                //add the next row in List
                row = [];
                row.add(dataList[0]["Date"]);
                row.add(dataList[0]["Time"]);
                row.add(dataList[0]["Pulse"]);
                row.add(dataList[0]["SpO2"]);
                globals.associateLists.add(row);

                globals.interval_sec =
                    (globals.interval_sec + globals.interval) % 60;
              }
              //60 records in 5 minutes / 720 records in 60 minutes
              if (globals.associateLists.length > 360) {
                //print("Save data List toCSV");
                await saveListToFile();
              }
            }

            setState(() {
              // ทำอะไรกับข้อมูลที่ได้รับได้ตรงนี้
              //time = DateTime.now();
              if (value[3] < 50) {
                receivedDatafinger_PRbpm1 = 0;
              } else {
                receivedDatafinger_PRbpm1 = value[3];
              }

              if (value[4] < 50) {
                receivedDatafinger_PRbpm1 = 0;
              } else {
                receivedDatafinger_SpO21 = value[4];
              }
            });
          });
          //}
        }
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> myDelay() async {
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
      String fullname =
          "${downloadsDirectory}/Inhaler_log_${globals.csv_file_name}.csv";
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
    //await flutterBluefinger.stopScan();
  }

  void closeAppUsingSystemPop() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  void closeAppUsingExit() {
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
                padding:
                    EdgeInsets.fromLTRB(30, 50, 0, 0), // หรือใส่ค่าที่ต้องการ
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
                    content: const Text(
                        'เมื่อบันทึกข้อมูลเสร็จ โปรแกรมจะปิดตัวเองอัตโนมัติ'),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () async {
                          await saveListToFile();
                        },
                        child: const Text('รับทราบ'),
                      ),
                    ],
                  ),
                ),
                child: const Text('หยุดเพื่อบันทึกข้อมูล',
                    style: TextStyle(
                      fontSize: 18.0,
                    )),
              ),
            ],
          ),
        ], // children
      ),
    );
  }
}
