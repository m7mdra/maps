import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'main.dart';
import 'page.dart';

class StyleInfo {
  final String name;
  final String baseStyle;
  final Future<void> Function(MaplibreMapController) addDetails;
  final CameraPosition position;

  const StyleInfo(
      {required this.name,
      required this.baseStyle,
      required this.addDetails,
      required this.position});
}

class Sources extends ExamplePage {
  Sources() : super(const Icon(Icons.map), 'Various Sources');

  @override
  Widget build(BuildContext context) {
    return const FullMap();
  }
}

class FullMap extends StatefulWidget {
  const FullMap();

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  MaplibreMapController? controller;
  final watercolorRasterId = "watercolorRaster";
  int selectedStyleId = 0;

  _onMapCreated(MaplibreMapController controller) {
    this.controller = controller;
  }

  static Future<void> addRaster(MaplibreMapController controller) async {
    await controller.addSource(
      "watercolor",
      RasterSourceProperties(
          tiles: [
            'https://stamen-tiles.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.jpg'
          ],
          tileSize: 256,
          attribution:
              'Map tiles by <a target="_top" rel="noopener" href="http://stamen.com">Stamen Design</a>, under <a target="_top" rel="noopener" href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a target="_top" rel="noopener" href="http://openstreetmap.org">OpenStreetMap</a>, under <a target="_top" rel="noopener" href="http://creativecommons.org/licenses/by-sa/3.0">CC BY SA</a>'),
    );
    await controller.addLayer(
        "watercolor", "watercolor", RasterLayerProperties());
  }

  static Future<void> addGeojsonCluster(MaplibreMapController controller) async {
    await controller.addSource(
        "earthquakes",
        GeojsonSourceProperties(
            data:
                'https://docs.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson',
            cluster: true,
            clusterMaxZoom: 14, // Max zoom to cluster points on
            clusterRadius:
                50 // Radius of each cluster when clustering points (defaults to 50)
            ));
    await controller.addLayer(
        "earthquakes",
        "earthquakes-circles",
        CircleLayerProperties(circleColor: [
          Expressions.step,
          [Expressions.get, 'point_count'],
          '#51bbd6',
          100,
          '#f1f075',
          750,
          '#f28cb1'
        ], circleRadius: [
          Expressions.step,
          [Expressions.get, 'point_count'],
          20,
          100,
          30,
          750,
          40
        ]));
    await controller.addLayer(
        "earthquakes",
        "earthquakes-count",
        SymbolLayerProperties(
          textField: [Expressions.get, 'point_count_abbreviated'],
          textFont: ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
          textSize: 12,
        ));
  }

  static Future<void> addVector(MaplibreMapController controller) async {
    await controller.addSource(
        "terrain",
        VectorSourceProperties(
          url: "mapbox://mapbox.mapbox-terrain-v2",
        ));

    await controller.addLayer(
        "terrain",
        "contour",
        LineLayerProperties(
          lineColor: "#ff69b4",
          lineWidth: 1,
          lineCap: "round",
          lineJoin: "round",
        ),
        sourceLayer: "contour");
  }

  static Future<void> addImage(MaplibreMapController controller) async {
    await controller.addSource(
        "radar",
        ImageSourceProperties(
            url: "https://docs.mapbox.com/mapbox-gl-js/assets/radar.gif",
            coordinates: [
              [-80.425, 46.437],
              [-71.516, 46.437],
              [-71.516, 37.936],
              [-80.425, 37.936]
            ]));

    await controller.addRasterLayer(
      "radar",
      "radar",
      RasterLayerProperties(rasterFadeDuration: 0),
    );
  }

  static Future<void> addVideo(MaplibreMapController controller) async {
    await controller.addSource(
        "video",
        VideoSourceProperties(urls: [
          'https://static-assets.mapbox.com/mapbox-gl-js/drone.mp4',
          'https://static-assets.mapbox.com/mapbox-gl-js/drone.webm'
        ], coordinates: [
          [-122.51596391201019, 37.56238816766053],
          [-122.51467645168304, 37.56410183312965],
          [-122.51309394836426, 37.563391708549425],
          [-122.51423120498657, 37.56161849366671]
        ]));

    await controller.addRasterLayer(
      "video",
      "video",
      RasterLayerProperties(),
    );
  }

  static Future<void> addDem(MaplibreMapController controller) async {
    await controller.addSource(
        "dem",
        RasterDemSourceProperties(
            url: "mapbox://mapbox.mapbox-terrain-dem-v1"));

    await controller.addLayer(
      "dem",
      "hillshade",
      HillshadeLayerProperties(
          hillshadeExaggeration: 1,
          hillshadeShadowColor: Colors.blue.toHexStringRGB()),
    );
  }

  static const _stylesAndLoaders = [
    StyleInfo(
      name: "Vector",
      baseStyle: MapboxStyles.MAPBOX_DEMO,
      addDetails: addVector,
      position: CameraPosition(target: LatLng(33.3832, -118.4333), zoom: 12),
    ),
    StyleInfo(
      name: "Dem",
      baseStyle:MapboxStyles.MAPBOX_DEMO,
      addDetails: addDem,
      position: CameraPosition(target: LatLng(33.5, -118.1), zoom: 8),
    ),
    StyleInfo(
      name: "Geojson cluster",
      baseStyle: MapboxStyles.MAPBOX_DEMO,
      addDetails: addGeojsonCluster,
      position: CameraPosition(target: LatLng(33.5, -118.1), zoom: 5),
    ),
    StyleInfo(
      name: "Raster",
      baseStyle: MapboxStyles.MAPBOX_DEMO,
      addDetails: addRaster,
      position: CameraPosition(target: LatLng(40, -100), zoom: 3),
    ),
    StyleInfo(
      name: "Image",
      baseStyle: MapboxStyles.MAPBOX_DEMO,
      addDetails: addImage,
      position: CameraPosition(target: LatLng(43, -75), zoom: 6),
    ),
    //video only supported on web
    if (kIsWeb)
      StyleInfo(
        name: "Video",
        baseStyle: MapboxStyles.MAPBOX_DEMO,
        addDetails: addVideo,
        position: CameraPosition(
            target: LatLng(37.562984, -122.514426), zoom: 17, bearing: -96),
      ),
  ];

  _onStyleLoadedCallback() async {
    final styleInfo = _stylesAndLoaders[selectedStyleId];
    styleInfo.addDetails(controller!);
    controller!
        .animateCamera(CameraUpdate.newCameraPosition(styleInfo.position));
  }

  @override
  Widget build(BuildContext context) {
    final styleInfo = _stylesAndLoaders[selectedStyleId];
    final nextName =
        _stylesAndLoaders[(selectedStyleId + 1) % _stylesAndLoaders.length]
            .name;
    return new Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(32.0),
          child: FloatingActionButton.extended(
            icon: Icon(Icons.swap_horiz),
            label: SizedBox(
                width: 120, child: Center(child: Text("To $nextName"))),
            onPressed: () => setState(
              () => selectedStyleId =
                  (selectedStyleId + 1) % _stylesAndLoaders.length,
            ),
          ),
        ),
        body: Stack(
          children: [
            MaplibreMap(
              styleString: styleInfo.baseStyle,
              accessToken: MapsDemo.ACCESS_TOKEN,
              onMapCreated: _onMapCreated,
              initialCameraPosition: styleInfo.position,
              onStyleLoadedCallback: _onStyleLoadedCallback,
            ),
            Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.topCenter,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Current source ${styleInfo.name}",
                    textScaleFactor: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
