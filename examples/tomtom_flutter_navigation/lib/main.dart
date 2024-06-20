import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tomtom_flutter_map/tomtom_flutter_map.dart';
import 'package:tomtom_flutter_navigation/tomtom_flutter_navigation.dart';
import 'package:tomtom_flutter_navigation_ui_native/tomtom_flutter_navigation_ui_native.dart';
import 'package:tomtom_flutter_route_planner/tomtom_flutter_route_planner.dart';

const tomtomApiKey = String.fromEnvironment('TOMTOM_API_KEY');

final TomtomFlutterRoutePlannerManager _routePlannerManager =
    TomtomFlutterRoutePlannerManager.instance;
final TomTomNavigationManager _navigationManager =
    TomTomNavigationManager.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _routePlannerManager.register(tomtomApiKey);
  await _navigationManager.register(tomtomApiKey);

  runApp(const MyApp());
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
  MapManager? _mapManager;
  bool _isLoading = false;
  bool _isNavigating = false;
  bool _hasLocationPermission = false;

  @override
  void initState() {
    _checkOrRequestLocationPermission();

    super.initState();
  }

  Future<void> _checkOrRequestLocationPermission() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      setState(() {
        _hasLocationPermission = true;
      });
    } else {
      await Geolocator.requestPermission();
      await _checkOrRequestLocationPermission();
    }
  }

  Future<void> _startNavigation() async {
    final mapManager = _mapManager;
    if (mapManager == null) return;

    setState(() {
      _isLoading = true;
    });

    final costModel = FlutterCostModel(
      routeType: FlutterRouteType.fast,
      avoidOptions: FlutterAvoidOptions(
        avoids: [FlutterAvoidTypeWrapper(type: FlutterAvoidType.carpools)],
      ),
    );

    final guidanceOptions = FlutterGuidanceOptions(
      instructionType: FlutterInstructionType.tagged,
      language: FlutterRoutePlannerLocale(
        identifier: 'en-US',
      ),
      roadShieldReferences: FlutterRoadShieldReferences.all,
      announcementPoints: FlutterAnnouncementPoints.all,
      phoneticsType: FlutterInstructionPhoneticsType.ipa,
      extendedSections: FlutterExtendedSections.all,
      progressPoints: FlutterProgressPoints.all,
      guidanceVersion: FlutterOnlineApiVersion.v1,
    );

    final alternativeRoutesOptions =
        FlutterAlternativeRoutesOptions(maxAlternatives: 1);

    final routePlans = await _routePlannerManager.planRoutes(
      FlutterRoutePlanningOptions(
        guidanceOptions: guidanceOptions,
        mode: FlutterRouteInformationMode.complete,
        vehicle: FlutterVehicle(type: FlutterVehicleType.car),
        alternativeRoutesOptions: alternativeRoutesOptions,
        costModel: costModel,
        itinerary: FlutterItinerary(
          origin: FlutterItineraryPoint(
            id: 'origin',
            place: FlutterPlace(
              name: 'Home',
              coordinate: FlutterRoutePlannerLatLng(
                latitude: 37.80493982637747,
                longitude: -122.41434213033601,
              ),
            ),
          ),
          destination: FlutterItineraryPoint(
            id: 'destination',
            place: FlutterPlace(
              name: 'Work',
              coordinate: FlutterRoutePlannerLatLng(
                latitude: 37.775657150158004,
                longitude: -122.4390007274891,
              ),
            ),
          ),
        ),
      ),
    );

    // starting navigation
    await TomTomNavigationManager.instance.startNavigation();
    await mapManager.setCamera(MapManagerCameraTrackingMode.followRoute);

    await TomTomNavigationManager.instance
        .setActiveRoutePlan(routePlans.first.route.id);

    setState(() {
      _isLoading = false;
      _isNavigating = true;
    });
  }

  Future<void> _stopNavigation() async {
    final mapManager = _mapManager;
    if (mapManager == null) return;

    await TomTomNavigationManager.instance.stopNavigation();
    await mapManager.setCamera(MapManagerCameraTrackingMode.follow);

    setState(() {
      _isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLocationPermission) {
      return Scaffold(
        appBar: AppBar(title: const Text('TomTom Navigation Example')),
        body: const Center(
          child: Text('Location permission is required to use this app.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('TomTom Navigation Example')),
      body: Column(
        children: [
          if (_mapManager != null && !_isNavigating)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: !_isLoading
                        ? () async {
                            await _startNavigation();
                          }
                        : null,
                    label: const Text(
                      'Start Navigation',
                    ),
                    icon: const Icon(Icons.navigation),
                  ),
                ],
              ),
            ),
          if (_mapManager != null && _isNavigating)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: !_isLoading
                        ? () async {
                            await _stopNavigation();
                          }
                        : null,
                    label: const Text(
                      'Stop Navigation',
                    ),
                    icon: const Icon(Icons.stop),
                  ),
                ],
              ),
            ),
          Expanded(
            child: TomTomMap(
              options: MapOptions(
                styleMode: MapManagerStyleMode.main,
                initialCameraPosition: MapManagerLatLng(
                  latitude: 37.80493982637747,
                  longitude: -122.41434213033601,
                ),
                initialCameraZoom: 12,
                apiKey: tomtomApiKey,
              ),
              onPlatformViewCreated: (MapManager mapManager) async {
                await TomTomNavigationManager.instance.registerMap(mapManager);

                setState(() {
                  _mapManager = mapManager;
                });

                // activate simulated location provider
                await TomTomNavigationManager.instance
                    .activateSimulatedLocationProvider(
                  NavigationManagerCLLocation(
                    coordinate: NavigationManagerLatLng(
                      latitude: 33.65703182526604,
                      longitude: -117.99791949744645,
                    ),
                    altitude: 0,
                  ),
                );
              },
              navigationUIBuilder: (context, mapManager) {
                return TomTomFlutterNavigationUINative(
                  mapManager: mapManager,
                  onNavigationStopped: () {
                    setState(() {
                      _isNavigating = false;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
