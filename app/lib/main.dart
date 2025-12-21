import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Robot App',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.grey,
          colorScheme: ColorScheme.light(
          primary: Colors.grey,
          secondary: Colors.red,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.grey,
          colorScheme: ColorScheme.dark(
          primary: Colors.black,
          secondary: Colors.red,
          ),
        ),
        themeMode: ThemeMode.system,
        home: MyHomePage(),
      );
  }
}

class MyAppState extends ChangeNotifier {
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>;
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = LandingPage();
      case 1:
        page = Placeholder();
      case 2:
        page = Placeholder();
      case 3:
        page = Placeholder();
      case 4:
        page = Placeholder();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title:Text("Robot Controller"),
            ),
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),),
                    NavigationRailDestination(
                      icon: Icon(Icons.star),
                      label: Text('Set-up Wizard'),),
                    NavigationRailDestination(
                      icon: Icon(Icons.route), 
                      label: Text("Robot Controls")),
                    NavigationRailDestination(
                      icon: Icon(Icons.polyline), 
                      label: Text("Sensor Log")),
                    NavigationRailDestination(
                      icon: Icon(Icons.camera), 
                      label: Text("Video Log"))
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class LandingPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title: Text("Animal Inspired Movement and Robotics"),),
      body: Row(children: [
        Text('Complete rest of home page in another branch')
      ],)
    );
  }
}