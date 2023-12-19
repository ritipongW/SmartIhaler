import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:flutter/material.dart';

class SleekCircularSliderWidget extends StatefulWidget {
  final int pRbpm;
  SleekCircularSliderWidget({required this.pRbpm});

  @override
  _SleekCircularSliderWidgetState createState() =>
      _SleekCircularSliderWidgetState();
}

class _SleekCircularSliderWidgetState extends State<SleekCircularSliderWidget> {
  @override
  Widget build(BuildContext context) {
    return SleekCircularSlider(
      appearance: CircularSliderAppearance(
        customWidths: CustomSliderWidths(
          trackWidth: 4,
          progressBarWidth: 5,
          shadowWidth: 5,
        ),
        customColors: CustomSliderColors(
          shadowMaxOpacity: 0.5,
          shadowStep: 10,
        ),
        infoProperties: InfoProperties(
          bottomLabelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          bottomLabelText: 'Pulse (bpm)',
          mainLabelStyle: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.w600,
          ),
          modifier: (double value) {
            int temp_value = value.toInt();
            return '$temp_value ';
          },
        ),
        startAngle: 90,
        angleRange: 360,
        size: 120,
        animationEnabled: true,
      ),
      min: 0,
      max: 120,
      initialValue: widget.pRbpm.toDouble(),
    );
  }
}

class SleekCircularSliderWidget1 extends StatefulWidget {
  final int sp;
  SleekCircularSliderWidget1({required this.sp});

  @override
  _SleekCircularSliderWidgetState1 createState() =>
      _SleekCircularSliderWidgetState1();
}

class _SleekCircularSliderWidgetState1 extends State<SleekCircularSliderWidget1> {
  @override
  Widget build(BuildContext context) {
    return SleekCircularSlider(
      appearance: CircularSliderAppearance(
        customWidths: CustomSliderWidths(
          trackWidth: 4,
          progressBarWidth: 5,
          shadowWidth: 5,
        ),
        customColors: CustomSliderColors(
          shadowMaxOpacity: 0.5,
          shadowStep: 10,
        ),
        infoProperties: InfoProperties(
          bottomLabelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          bottomLabelText: 'SpO2 (%)',
          mainLabelStyle: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.w600,
          ),
          modifier: (double value) {
            int temp_value = value.toInt();
            return '${temp_value}';
          },
        ),
        startAngle: 90,
        angleRange: 360,
        size: 120,
        animationEnabled: true,
      ),
      min: 0,
      max: 120,
      initialValue: widget.sp.toDouble(),
    );
  }
}
