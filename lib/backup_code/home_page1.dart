import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:io';
import 'home_page2.dart' as homepage2;
import 'package:inhaler/variables.dart' as globals;

import 'package:inhaler/backup_code/page2_design.dart' as page2design;

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
  FlutterBlue flutterBluepush = FlutterBlue.instance;
  BluetoothDevice? connectedDevicepush;
  BluetoothCharacteristic? targetCharacteristicpush;
  int receivedDatapush = 0;
  String connectionStatuspush = 'Not Connected';
  String serviceUuid_rq_push = '72213524-9407-11ee-b9d1-0242ac120002';
  int pushValue0 = 0; //เก็บค่าการกด
  int pushValue1 = 0; //เก็บค่าการกด
  int? changvalue = null;

  // config ตัววัด spo2%
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
  }

  startBluetoothConnectionpush() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.manageExternalStorage,
      Permission.storage,
      Permission.location
    ].request();

    // สแกนหาอุปกรณ์ Bluetooth
    await for (ScanResult scanResult in flutterBluepush.scan()) {
      // เชื่อมต่อกับอุปกรณ์ที่คุณต้องการ (ตามเงื่อนไขที่คุณต้องการ)
      log(scanResult.toString());
      if (scanResult.device.id.toString() == "30:30:F9:34:68:F5") {
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
              log('Service UUID: ${service.uuid}');
              log('services: ${services}');
              // เช็คเพื่อทำให้แน่ใจว่าเรามี Characteristic ที่เราต้องการ
              if (service.uuid.toString() == serviceUuid_rq_push) {
                // ดึงรายการ characteristics ทั้งหมดใน service
                log('เข้าเงื่อนไขที่ uuid:${service.uuid}');

                List<BluetoothCharacteristic> characteristics =
                    service.characteristics;

                // ตรวจสอบ characteristic ที่รองรับ Notify
                for (BluetoothCharacteristic characteristic
                in characteristics) {
                  if (characteristic.properties.notify) {
                    setState(() {
                      targetCharacteristicpush = characteristic;
                    });
                    log('charUUID = ${targetCharacteristicpush}');

                    // เปิดการ Notify
                    targetCharacteristicpush!.setNotifyValue(true);

                    // ฟังก์ชัน callback สำหรับการรับข้อมูล Notify
                    targetCharacteristicpush!.value.listen((value) {
                      log('ค่าที่ส่งมาทาง ble ${value[0]}');

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
                log('ไม่เข้าเงื่อนไขเลย');
              }
            }
          });
        }).catchError((error) {
          // หากการเชื่อมต่อล้มเหลว, ลองเริ่มที่ scan ใหม่
          log('Error connecting: $error');
          startBluetoothConnectionpush();
        });
      }
    }
  }

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
          globals.title_status = connectionStatuspush;
        });
      }
      finger = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Color.fromARGB(255, 134, 71, 129),
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
                Text(
                  'สถานะการเชื่อมต่อ: $connectionStatuspush',
                  style: TextStyle(
                    fontSize: 20.0, // ปรับขนาดตัวหนังสือตามต้องการ
                    fontWeight: FontWeight.bold, // ตั้งค่าความหนาของตัวหนังสือ
                    color: Color.fromARGB(255, 4, 1, 8),
                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
