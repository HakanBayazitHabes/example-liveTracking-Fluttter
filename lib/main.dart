import 'package:flutter/material.dart';
import 'package:live_tracking/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp(
    homeScreen: HomePage(),
  ));
}

class MyApp extends StatefulWidget {
  final Widget? homeScreen;

  const MyApp({super.key, this.homeScreen});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: this.widget.homeScreen,
    );
  }
}
