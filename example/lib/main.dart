import 'package:flutter/material.dart';
import 'package:flutter_securemetric/flutter_securemetric.dart';
import 'package:flutter_securemetric_example/screen/function_example_page.dart';
import 'package:flutter_securemetric_example/screen/widget_example_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Plugin example app', home: HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugin example app')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Quick start"),
            ElevatedButton(
              onPressed: () {
                FlutterSecuremetric.verify(
                  context,
                  license: null,
                  device: SecuremetricDevice.v11,
                  onVerifyFP: (val, sdkResponse) {
                    if (!val) return;
                    if (sdkResponse == null) return;
                    if (sdkResponse.isDataMykad()) {
                      //Get my Kad details
                      sdkResponse.getMyKadModel();
                    } else {
                      //Get my Kid details
                      sdkResponse.getMyKidModel();
                    }
                  },
                );
              },
              child: Text("Open Sheet"),
            ),
            Text("Custom screen"),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FunctionExamplePage(),
                  ),
                );
              },
              child: Text("Function Screen Example"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WidgetExamplePage(onVerifyFP: (val) {}),
                  ),
                );
              },
              child: Text("Widget Screen Example"),
            ),
          ],
        ),
      ),
    );
  }
}
