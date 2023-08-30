import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final dio = Dio();

class _HomeScreenState extends State<HomeScreen> {
  final start = TextEditingController();
  final end = TextEditingController();

  bool isVisible = true;
  List<LatLng> routpoints = [
    const LatLng(16.053433672953737, 108.20395854815301)
  ];
//   21.0277644
// 105.8341598
  Future handleLocation() async {
    try {
      List<Location> startL = await locationFromAddress(start.text);
      List<Location> endL = await locationFromAddress(end.text);

      var v1 = startL[0].latitude;
      var v2 = startL[0].longitude;
      var v3 = endL[0].latitude;
      var v4 = endL[0].longitude;

      var response = await dio.get(
        'http://router.project-osrm.org/route/v1/driving/$v2,$v1;$v4,$v3?steps=true&annotations=true&geometries=geojson&overview=full',
      );

      setState(() {
        routpoints = [];
        var ruter = response.data["routes"][0]['geometry']['coordinates'];
        for (int i = 0; i < ruter.length; i++) {
          var reep = ruter[i].toString();
          reep = reep.replaceAll("[", "");
          reep = reep.replaceAll("]", "");
          var lat1 = reep.split(',');
          var long1 = reep.split(",");
          routpoints.add(LatLng(double.parse(lat1[1]), double.parse(long1[0])));
        }
        isVisible = true;
      });
    } catch (e) {
      setState(() {
        isVisible = false;
      });
    }
  }

// W7V4+XF3
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _Input(controler: start, hint: 'Enter Starting PostCode'),
              const SizedBox(height: 15),
              _Input(controler: end, hint: 'Enter Ending PostCode'),
              const SizedBox(height: 15),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.grey[500]),
                onPressed: () async {
                  await handleLocation();
                },
                child: const Text('Press'),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 500,
                width: 400,
                child: Visibility(
                  visible: isVisible,
                  child: InteractiveViewer(
                    child: FlutterMap(
                      options: MapOptions(
                        center: routpoints[0],
                        zoom: 9.2,
                      ),
                      nonRotatedChildren: [
                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              'OpenStreetMap contributors',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        PolylineLayer(
                          polylineCulling: false,
                          polylines: [
                            Polyline(
                              points: routpoints,
                              color: Colors.blue,
                              strokeWidth: 9,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Input extends StatefulWidget {
  final TextEditingController controler;
  final String hint;

  const _Input({
    required this.controler,
    required this.hint,
  });

  @override
  State<_Input> createState() => __InputState();
}

class __InputState extends State<_Input> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controler,
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        fillColor: Colors.white,
        filled: true,
        hintText: widget.hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
    );
  }
}
