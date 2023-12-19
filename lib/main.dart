import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'Adapter_screen.dart';
import 'home_page1.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _FlutterBlueAppState();
}
class _FlutterBlueAppState extends State<MyApp> {

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    Widget screen = _adapterState == BluetoothAdapterState.on
        ? const HomePage_main(title: "CMU Smart Inhaler")
        : AdaptorsOffScreen(adapterState: _adapterState);

    return MaterialApp(
      debugShowCheckedModeBanner: true,
      theme: ThemeData.light(),
      home: screen,
      //home: ,
    );
  }
}

