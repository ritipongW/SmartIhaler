import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
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
  BluetoothAdapterState? _adapterState; //= BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  late StreamSubscription<ServiceStatus> _serviceStatusStream;

  ServiceStatus? _LocationState;

  GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  Location location = new Location();

  bool? _serviceEnabled;
  bool? _serviceEnabled1;

  @override
  void initState() {
    super.initState();

    _toggleBlueToothServiceStatusStream();
    _toggleLocationServiceStatusStream();
  }

  void _toggleBlueToothServiceStatusStream() {
    _adapterState = FlutterBluePlus.adapterStateNow;
    //log('Now: Bluetooth service is $_adapterState');

    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      log('Bluetooth service is $_adapterState');
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _toggleLocationServiceStatusStream() async {
    _serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    log('Now: geolocator Location service is $_serviceEnabled');
    if (!_serviceEnabled!) {
      _LocationState = ServiceStatus.disabled;
      _serviceEnabled = false;
    } else {
      _LocationState = ServiceStatus.enabled;
      _serviceEnabled = true;
    }

    _serviceEnabled1 = await location.serviceEnabled();
    log('Now: Location service is $_serviceEnabled');
    if (_serviceEnabled1 == false) {
      _serviceEnabled1 = await location.requestService();
      _LocationState = ServiceStatus.enabled;
      if (_serviceEnabled1 == true) {
        return;
      }
    }

    _serviceStatusStream =
        _geolocatorPlatform.getServiceStatusStream().listen((status) {
      // _LocationState = status;
      // if(status == ServiceStatus.enabled){
      //   _serviceEnabled1 = true;
      // }else{
      //   _serviceEnabled1 = false;
      // }
      // //log('Location service is $_LocationState');

      setState(() {
        _LocationState = status;
        if (status == ServiceStatus.enabled) {
          _serviceEnabled1 = true;
        } else {
          _serviceEnabled1 = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Widget screen = _adapterState == BluetoothAdapterState.on && (_LocationState == ServiceStatus.enabled && _serviceEnabled == true)
    Widget screen = _adapterState == BluetoothAdapterState.on //&& _LocationState == ServiceStatus.enabled
        ? const HomePage_main(title: "CMU Smart Inhaler")
        : AdaptorsOffScreen(
            adapterState: _adapterState, GPSadapterState: _LocationState);

    return MaterialApp(
      debugShowCheckedModeBanner: true,
      theme: ThemeData.light(),
      home: screen,
      //home: HomePage_main(title: "CMU Smart Inhaler"),
    );
  }
}
