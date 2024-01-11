import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'variables.dart' as globals;

class MyHomePagesetting extends StatefulWidget {
  @override
  MyHomePageStatesetting createState() => MyHomePageStatesetting();
  // สร้าง public method ที่ให้เรียกใช้ _loadSavedText
  // Future<void> loadSavedTextFromOut() async {
  //   return MyHomePageStatesetting().loadSavedText();
  // }
}

class MyHomePageStatesetting extends State<MyHomePagesetting> {
  final TextEditingController _textController1 = TextEditingController();
  final TextEditingController _textController2 = TextEditingController();
  final String _storageKey1 = 'user_input_key1';
  final String _storageKey2 = 'user_input_key2';

  @override
  void initState() {
    super.initState();
    loadSavedText();
  }

  // // Getter methods เพื่อให้สามารถเรียกใช้ _textController1.text จากที่อื่น
  // String get savedText1 => _textController1.text;
  // // Getter methods เพื่อให้สามารถเรียกใช้ _textController2.text จากที่อื่น
  // String get savedText2 => _textController2.text;

  Future<void> loadSavedText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedText1 = prefs.getString(_storageKey1) ?? '';
    String savedText2 = prefs.getString(_storageKey2) ?? '';
    setState(() {
      _textController1.text = savedText1;
      _textController2.text = savedText2;
      // globals.namepush = _textController1.text;
      // globals.macaddress = _textController2.text;
      // print(globals.namepush);
      // print(globals.macaddress);
    });
  }

  Future<void> _saveText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey1, _textController1.text);
    await prefs.setString(_storageKey2, _textController2.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('CMU Smart Inhaler'),
        //leading: Image.asset('assets/images/CMUIhaler.png'),
        backgroundColor: Colors.teal.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _textController1,
              decoration: InputDecoration(
                labelText: 'ใส่หมายเลขเครื่องกด',
                labelStyle: TextStyle(fontSize: 30),
              ),
              onChanged: (value) {
                _saveText();
              },
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _textController2,
              decoration: InputDecoration(
                labelText: 'ใส่หมายเลข Mac address',
                labelStyle: TextStyle(fontSize: 30),
              ),
              onChanged: (value) {
                _saveText();
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String userInput1 = _textController1.text;
                String userInput2 = _textController2.text;
                print('User input 1: $userInput1');
                print('User input 2: $userInput2');
              },
              child: Text('จำชื่ออุปกรณ์'),
            ),
            ElevatedButton(
              onPressed: () {
                _textController1.clear();
                _textController2.clear();
                _saveText();
                print('Text cleared');
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 189, 64, 26)), // กำหนดสีเมื่อปกติ
                // สามารถกำหนดสีในสถานะต่าง ๆ ได้เช่นเมื่อกด
                //overlayColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              child: Text('ล้างชื่ออุปกรณ์'),
            ),
          ],
        ),
      ),
    );
  }
}
