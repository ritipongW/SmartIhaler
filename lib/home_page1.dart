import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io';
import 'home_page2.dart' as homepage2;
import 'variables.dart' as globals;

import 'backup_code/page2_design.dart' as page2design;
import 'snackbar.dart';

class HomePage_main extends StatefulWidget {
  //const HomePage_main({Key? key}) : super(key: key);
  const HomePage_main({super.key, required this.title});
  final String title;

  @override
  State<HomePage_main> createState() => _Homepage_mainState();

}

class _Homepage_mainState extends State<HomePage_main>{
  // ส่งค่า ไปทำอีกคลาส
  bool finger = false;
  // config ตัวกดรับค่า
  //FlutterBlue flutterBluepush = FlutterBlue.instance;
  BluetoothDevice? connectedDevicepush;
  BluetoothCharacteristic? targetCharacteristicpush;
  int receivedDatapush = 0;
  String connectionStatuspush = 'Not Connected';
  String serviceUuid_rq_push = '72213524-9407-11ee-b9d1-0242ac120002';
  int pushValue0 = 0; //เก็บค่าการกด
  int pushValue1 = 0; //เก็บค่าการกด
  int? changvalue = null;

  // config ตัววัด spo2%
  FlutterBluePlus? flutterBluefinger;
  BluetoothDevice? connectedDevicefinger;
  BluetoothCharacteristic? targetCharacteristicfinger;
  String receivedDatafinger = '';
  String connectionStatusfinger = 'Not Connected';
  String serviceUuid_rq_finger = '6e400091-b5a3-f393-e0a9-e50e24dcca9e';

  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];

  late ScanResult BlueToothScanDev;

  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();

    // เตรียมอ่านค่า inherler DevIDName, MAC Address Pulse Oximeter Device

    // Check permission of Storage, Location GPS

    // เมื่อแอปเริ่มทำงาน
    startBluetoothConnectionpush();
  }

  Future<void> StartScanning() async{
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("System Devices Error:", e), success: false);
    }
    try {
      // android is slow when asking for all advertisments,
      // so instead we only ask for 1/8 of them
      int divisor = Platform.isAndroid ? 8 : 1;
      await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 15), continuousUpdates: true, continuousDivisor: divisor);
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e), success: false);
    }
  }

  startBluetoothConnectionpush() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.manageExternalStorage,
      Permission.storage,
      Permission.location
    ].request();

    StartScanning();

    _scanResultsSubscription = FlutterBluePlus.onScanResults.listen((results) async{

      if(results.isNotEmpty){
        ScanResult scanResult = results.last;
        log('${scanResult.device.remoteId}: "${scanResult.advertisementData.advName}" found!');
        if(scanResult.device.remoteId.toString() == "30:30:F9:34:68:F5") {
          setState(() {
            connectionStatuspush = 'กำลังทำการเชื่อมต่อ';
          });

          await Future.delayed(const Duration(seconds: 3));

          await scanResult.device.connect().then((result){
            setState(() {
              connectedDevicepush = scanResult.device;
              connectionStatuspush = 'เชื่อมต่อสำเสร็จ';
            });
          });
        }
      }

      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('CMU Smart Inhaler'),
        leading: Image.asset('assets/images/CMUIhaler.png'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              // do something
            },
          )
        ],
        backgroundColor: Colors.teal.shade600,
      ),
      body: Center(
        child: Container(
          //color: Colors.purple,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),

              if (connectedDevicepush != null)
                Text(
                  'เชื่อมต่อเครื่องพ่น: ${connectedDevicepush!.name} ',
                  style: TextStyle(
                    fontSize: 25, // ปรับขนาดตัวหนังสือตามต้องการ
                    fontWeight: FontWeight.bold, // ตั้งค่าความหนาของตัวหนังสือ
                    color: Color.fromARGB(255, 11, 9, 22),
                  ),
                ), // ตั้งสีตัวหนังสือ),

              if (finger == true)
                homepage2.HomePage_monitor(),
              Text(
                'สถานะการเชื่อมต่อ: $connectionStatuspush',
                style: TextStyle(
                  fontSize: 20.0, // ปรับขนาดตัวหนังสือตามต้องการ
                  fontWeight: FontWeight.bold, // ตั้งค่าความหนาของตัวหนังสือ
                  color: Color.fromARGB(255, 4, 1, 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
