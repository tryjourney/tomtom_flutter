import 'package:flutter/material.dart';
import 'package:tomtom_flutter_map/tomtom_flutter_map.dart';

const tomtomApiKey = String.fromEnvironment('TOMTOM_API_KEY');

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  return runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TomtomFlutterMap Example')),
      body: TomTomMap(
        options: MapOptions(
          styleMode: MapManagerStyleMode.main,
          initialCameraPosition: MapManagerLatLng(
            latitude: 37.7749,
            longitude: -122.4194,
          ),
          initialCameraZoom: 12,
          apiKey: tomtomApiKey,
        ),
        onPlatformViewCreated: (MapManager mapManager) {
          print('onPlatformViewCreated');
        },
      ),
    );
  }
}
