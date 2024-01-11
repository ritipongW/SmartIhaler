import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io';
import 'home_page3.dart' as home_page3;
import 'variables.dart' as globals;

//import 'backup_code/page2_design.dart' as page2design;
import 'snackbar.dart';
import 'setting.dart';
//import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class HomePage_main extends StatefulWidget {
  //const HomePage_main({Key? key}) : super(key: key);
  const HomePage_main({super.key, required this.title});
  final String title;

  @override
  State<HomePage_main> createState() => _Homepage_mainState();
}

class _Homepage_mainState extends State<HomePage_main> {
  //final BluetoothCharacteristic characteristic;
  // ส่งค่า ไปทำอีกคลาส
  bool finger = false;
  // config ตัวกดรับค่า
  //FlutterBlue flutterBluepush = FlutterBlue.instance;
  BluetoothDevice? connectedDevicepush;
  //BluetoothCharacteristic? targetCharacteristicpush;
  String connectionStatuspush = 'ยังไม่มีการเชื่อมต่อ';
  //String serviceUuid_rq_push = '72213524-9407-11ee-b9d1-0242ac120002';
  int? changvalue = null;

  // config ตัววัด spo2%
  // FlutterBluePlus? flutterBluefinger;
  // BluetoothDevice? connectedDevicefinger;
  // //BluetoothCharacteristic? targetCharacteristicfinger;
  // String receivedDatafinger = '';
  // String connectionStatusfinger = 'Not Connected';
  // String serviceUuid_rq_finger = '6e400091-b5a3-f393-e0a9-e50e24dcca9e';

  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];

  late ScanResult BlueToothScanDev;

  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  List<BluetoothService> _services = [];
  List<BluetoothCharacteristic> _characteristicUuid = [];
  List<int> _value = [];
  late StreamSubscription<List<int>> _lastValueSubscription;
  int pushValue0 = 0;
  int pushValue1 = 0;
  //String locationData = "";
  //final TextEditingController _textController1 = TextEditingController();
  //final TextEditingController _textController2 = TextEditingController();
  String nameBMEi_IoTN = '';
  String nameBMEi_IoTE = '';
  

  @override
  void initState() {
    super.initState();

    // เตรียมอ่านค่า inherler DevIDName, MAC Address Pulse Oximeter Device
    // Check permission of Storage, Location GPS
    // เมื่อแอปเริ่มทำงาน
    //getLocation();
    loadSavedText();
    //print(globals.locationData);
    // if (namepush == '' || macaddress == '') {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (context) => MyHomePagesetting()),
    //     ).then((value) {
    //       // คำสั่งที่จะทำงานหลังจากการ pop
    //       print('Returned from MyHomePagesetting');
    //       loadSavedText();
    //       //startBluetoothConnectionpush();
    //     });
    //   }
    startBluetoothConnectionpush();
    print(globals.locationData);
  }
  
   Future<void> getLocation() async {

    print("getLocation");
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        globals.locationData =
            'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
            print(globals.locationData);
            print("getLocation สำเร็จ");

      });
    } catch (e) {
      setState(() {
        globals.locationData = 'Error getting location: $e';
        print(globals.locationData);
      });
    }
  }

  Future<void> loadSavedText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedText1 = prefs.getString('user_input_key1') ?? '';
    String savedText2 = prefs.getString('user_input_key2') ?? '';
    setState(() {
      //namepush = savedText1;
      //macaddress = savedText2;
      //_textController1.text = savedText1;
      //_textController2.text = savedText2;
      globals.numpush = savedText1;
      globals.macaddress = savedText2;

      print('function_load');
      print(savedText1);
      print(savedText2);
      if (savedText1 == '' || savedText2 == '') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePagesetting()),
        );
        // .then((value) {
        //   // คำสั่งที่จะทำงานหลังจากการ pop
        //   print('Returned from MyHomePagesetting');
        //   //startBluetoothConnectionpush();
        // });
      }
    });
  }

  Future<void> StartScanning() async {
    loadSavedText();
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
          timeout: const Duration(seconds: 15),
          continuousUpdates: true,
          continuousDivisor: divisor);
      //await FlutterBluePlus.startScan();
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e),
          success: false);
    }
  }

  // void load() async {
  //   MyHomePagesetting myHomePageSetting = MyHomePagesetting();
  //   myHomePageSetting.loadSavedTextFromOut();
  //   print('Text loaded from AnotherClass');
  // }

  startBluetoothConnectionpush() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.manageExternalStorage,
      Permission.storage,
      Permission.location
    ].request();

    StartScanning();

    _scanResultsSubscription =
        FlutterBluePlus.onScanResults.listen((results) async {
      if (results.isNotEmpty) {
        ScanResult scanResult = results.last;

        print(
            '${scanResult.device.remoteId}: "${scanResult.advertisementData.advName}" found!');
        nameBMEi_IoTN = "BMEi_IoTN" + globals.numpush;
        nameBMEi_IoTE = "BMEi_IoTE" + globals.numpush;
        if (scanResult.device.advName.toString() == nameBMEi_IoTN || scanResult.device.advName.toString() == nameBMEi_IoTE) {
          //if (scanResult.device.advName.toString() == "BMEi_IoT1") {   //if (scanResult.device.remoteId.toString() == "30:30:F9:34:68:F5") {
          await FlutterBluePlus.stopScan();
          globals.namedevice = scanResult.device.advName.toString();
          setState(() {
            connectionStatuspush = 'กำลังทำการเชื่อมต่อ';
          });

          // await Future.delayed(const Duration(seconds: 3));

          await scanResult.device.connect().then((result) {
            setState(() { 
              connectedDevicepush = scanResult.device;
              connectionStatuspush = 'เชื่อมต่อสำเร็จ';
              //getLocation();  // เมื่อมีการเชื่อมต่อเครื่องกดแล้วจะทำการเรียกใช้ function getLocation()
              print('เชื่อมต่อสำเร็จ');
            });
          });
          //await FlutterBluePlus.stopScan();
          await getLocation(); 

          _services = await scanResult.device.discoverServices();
          BluetoothService service = _services[2];
          _characteristicUuid = service.characteristics;

          BluetoothCharacteristic characteristicUuid = _characteristicUuid[0];
          Snackbar.show(ABC.c, "Discover Services: Success", success: true);
          // print('service uuid โวยยยย ');
          // print('uuid โวยยยย ${service.serviceUuid}');
          // print('characteristicUuid โวยยยย ');
          // print('uuid โวยยยย ${characteristicUuid.characteristicUuid}');
          characteristicUuid
              .setNotifyValue(characteristicUuid.isNotifying == false);
          characteristicUuid.read();
          _lastValueSubscription =
              characteristicUuid.lastValueStream.listen((value) async {
            // await characteristicUuid
            //     .setNotifyValue(characteristicUuid.isNotifying == false);
            // await characteristicUuid.read();
            _value = value;
            //String data = _value[0].toString();

            setState(() {
              print('ข้อมูล');
              //print(data);

              int receivedDatapush = _value[0].toInt();
              print(receivedDatapush);
              if (0 == receivedDatapush % 2) {
                pushValue0 = receivedDatapush;
              } else {
                pushValue1 = receivedDatapush;
              }
              if (receivedDatapush == (pushValue0 - pushValue1).abs()) {
                // แก้บัคอังกอ %2
                changvalue == null;
              } else {
                changvalue = (pushValue0 - pushValue1).abs();

                if (1 == changvalue) {
                  finger = true;
                  _lastValueSubscription.cancel();
                }
              }
            });
          });
          //await _lastValueSubscription.cancel();
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

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return FloatingActionButton(
        mini: false, // ตั้งค่า mini เป็น false เพื่อให้ขนาดใหญ่ขึ้น
        child: const Icon(
          Icons.stop,
          size: 50.0,
        ),
        onPressed: StartScanning,
        backgroundColor: Colors.red,
      );
    } else {
      return FloatingActionButton(
          mini: false, // ตั้งค่า mini เป็น false เพื่อให้ขนาดใหญ่ขึ้น
          child: const Icon(
            Icons.search,
            size: 50.0,
          ),
          onPressed: StartScanning);
    }
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
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              // เรียกใช้งานหน้าหลัก (MyHomePage)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyHomePagesetting()),
              ).then((value) {
                // คำสั่งที่จะทำงานหลังจากการ pop
                print('Returned from MyHomePagesetting');
                startBluetoothConnectionpush();
              });
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
                height: 15,
              ),

              if (connectedDevicepush != null)
                Text(
                  'เชื่อมต่อเครื่องพ่น: ${connectedDevicepush!.name.toString()} ',
                  style: TextStyle(
                    fontSize: 25, // ปรับขนาดตัวหนังสือตามต้องการ
                    fontWeight: FontWeight.bold, // ตั้งค่าความหนาของตัวหนังสือ
                    color: Color.fromARGB(255, 11, 9, 22),
                  ),
                ), // ตั้งสีตัวหนังสือ),

              //if (finger == true) home_page2.HomePage_monitor(),
              Text(
                'สถานะการเชื่อมต่อ: $connectionStatuspush',
                style: TextStyle(
                  fontSize: 20.0, // ปรับขนาดตัวหนังสือตามต้องการ
                  fontWeight: FontWeight.bold, // ตั้งค่าความหนาของตัวหนังสือ
                  color: Color.fromARGB(255, 4, 1, 8),
                ),
              ),
              if (finger == true) home_page3.HomePage_monitor(),
            ],
          ),
        ),
      ),
      floatingActionButton: buildScanButton(context),
    );
  }
}
