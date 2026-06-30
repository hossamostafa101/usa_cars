import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:unicons/unicons.dart';

import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? selectedPoint;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), //appbar size
        child: AppBar(
          bottomOpacity: 0.0,
          elevation: 0.0,
          shadowColor: Colors.transparent,
          backgroundColor: themeData.scaffoldBackgroundColor,
          leading: Padding(
            padding: EdgeInsets.only(left: size.width * 0.05),
            child: SizedBox(
              height: size.width * 0.1,
              width: size.width * 0.1,
              child: Container(
                decoration: BoxDecoration(
                  color: themeData.scaffoldBackgroundColor.withAlpha(
                    (0.03 * 255).toInt(),
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Icon(
                  UniconsLine.bars,
                  color: themeData.secondaryHeaderColor,
                  size: size.height * 0.025,
                ),
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          leadingWidth: size.width * 0.15,
          title: Image.asset(
            'assets/icons/wheely_logo_b.png', //logo
            height: size.height * 0.06,
            width: size.width * 0.35,
          ),
          centerTitle: true,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: size.width * 0.05),
              child: SizedBox(
                height: size.width * 0.1,
                width: size.width * 0.1,
                child: Container(
                  decoration: BoxDecoration(
                    color: themeData.scaffoldBackgroundColor.withAlpha(
                      (0.03 * 255).toInt(),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Icon(
                    UniconsLine.search,
                    color: themeData.secondaryHeaderColor,
                    size: size.height * 0.025,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: themeData.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  center: LatLng(30.0444, 31.2357), // Cairo
                  zoom: 13.0,
                  onTap: (tapPosition, point) {
                    setState(() {
                      selectedPoint = point;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  if (selectedPoint != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: selectedPoint!,
                          child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                        )
                      ],
                    ),
                ],
              ),
              if (selectedPoint != null)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, selectedPoint);
                    },
                    child: Text('Confirm Location'),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
