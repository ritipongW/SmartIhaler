import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'snackbar.dart';


class AdaptorsOffScreen extends StatelessWidget {
  const AdaptorsOffScreen({Key? key, this.adapterState}) : super(key: key);

  final BluetoothAdapterState? adapterState;

  Widget buildAdapterOffIcon(BuildContext context, {required IconData setIcon}) {
    return Icon(
      setIcon,
      size: 100.0,
      color: Colors.white70,
    );
  }

  Widget buildTitle(BuildContext context, {required String adapterTitle}) {
    String? state = adapterState?.toString().split(".").last;
    return Text(
      '$adapterTitle Adapter is ${state != null ? state : 'not available'}',
      style: Theme.of(context).primaryTextTheme.titleSmall?.copyWith(color: Colors.white),
    );
  }

  Widget buildGPSTurnOnButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        child: const Text('TURN ON'),
        onPressed: () async {
          try {
            if (Platform.isAndroid) {
              await FlutterBluePlus.turnOn();
            }
          } catch (e) {
            Snackbar.show(ABC.a, prettyException("Error Turning On:", e), success: false);
          }
        },
      ),
    );
  }

  Widget buildBlueToothTurnOnButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        child: const Text('TURN ON'),
        onPressed: () async {
          try {
            if (Platform.isAndroid) {
              await FlutterBluePlus.turnOn();
            }
          } catch (e) {
            Snackbar.show(ABC.a, prettyException("Error Turning On:", e), success: false);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyA,
      child: Scaffold(
        backgroundColor: Colors.lightBlue,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildAdapterOffIcon(context, setIcon: Icons.bluetooth_disabled),
                  Column(
                    children: [
                      if (Platform.isAndroid) buildBlueToothTurnOnButton(context),
                      buildTitle(context, adapterTitle: 'BlueTooth'),
                    ],
                  ),
                ],
              ),
              SizedBox(
                  height:20
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildAdapterOffIcon(context,setIcon: Icons.location_disabled),
                  Column(
                    children: [
                      if (Platform.isAndroid) buildGPSTurnOnButton(context),
                      buildTitle(context, adapterTitle: 'Location'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
