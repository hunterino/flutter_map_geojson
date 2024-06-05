import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

typedef CircleMarkerCreationCallback = CircleMarker Function(
    {required LatLng point, required Map<String, dynamic> properties});
typedef FilterFunction = bool Function(
    {required Map<String, dynamic> properties});

/// - list of [CircleMarker]s
class CircleParser {

  /// user defined callback function that creates a [Polygon] object
  CircleMarkerCreationCallback? circleMarkerCreationCallback;

  /// default [CircleMarker] border color
  Color? defaultCircleMarkerColor;

  /// default [CircleMarker] border stroke
  Color? defaultCircleMarkerBorderColor;

  /// default flag if [CircleMarker] is filled (default is true)
  bool? defaultCircleMarkerIsFilled;

  /// user defined callback function called when the [CircleMarker] is tapped
  void Function(Map<String, dynamic>)? onCircleMarkerTapCallback;

  /// user defined callback function called during parse for filtering
  FilterFunction? filterFunction;

  /// default constructor - all parameters are optional and can be set later with setters
  CircleParser({
    // callbacks
    this.circleMarkerCreationCallback,
    // filters
    this.filterFunction,
    //// styling
    this.defaultCircleMarkerColor,
    this.defaultCircleMarkerBorderColor,
    this.defaultCircleMarkerIsFilled,
    // handlers
    this.onCircleMarkerTapCallback,
  }) {
    circleMarkerCreationCallback ??= createDefaultCircleMarker;
    filterFunction ??= defaultFilterFunction;
    // style
    defaultCircleMarkerColor ??= Colors.blue.withOpacity(0.15);
    defaultCircleMarkerBorderColor ??= Colors.black.withOpacity(0.5);
    defaultCircleMarkerIsFilled ??= true;

  }


  /// set default [CircleMarker] color
  set setDefaultCircleMarkerColor(Color color) {
    defaultCircleMarkerColor = color;
  }

  /// set default [CircleMarker] tap callback function
  void setDefaultCircleMarkerTapCallback(
      Function(Map<String, dynamic> f) onTapFunction) {
    onCircleMarkerTapCallback = onTapFunction;
  }

  /// main GeoJson parsing function
  void parseGeoJson(Map<String, dynamic> geoJson) {
    // set default values if they are not specified by constructor
    // creation callbacks

    // loop through the GeoJson Map and parse it
    for (Map<String, dynamic> feature in geoJson['features'] as List) {
      if (!filterFunction!(properties: feature['properties'])) {
        continue;
      }
      makeCircle(feature);
    }
  }

  /// the default filter function returns always true - therefore no filtering
  bool defaultFilterFunction({required Map<String, dynamic> properties}) {
    return true;
  }

  CircleMarker makeCircle(Map<String, dynamic> feature) {
    return
      circleMarkerCreationCallback!(
          point: LatLng(feature['geometry']['coordinates'][1] as double,
              feature['geometry']['coordinates'][0] as double),
          properties: feature['properties']);
  }

  /// default callback function for creating [Polygon]
  CircleMarker createDefaultCircleMarker(
      {required LatLng point, required Map<String, dynamic> properties}) {
    if (properties.containsKey("type") &&
        properties["type"] == "stationKeeping") {
      return CircleMarker(
        point: point,
        radius: properties["radius"].toDouble(),
        useRadiusInMeter: true,
        color: Colors.yellow.withOpacity(0.5),
        borderColor: Colors.yellow,
        borderStrokeWidth: 4,
      );
    } else {
      return CircleMarker(
        point: point,
        radius: properties["radius"].toDouble(),
        useRadiusInMeter: true,
        color: defaultCircleMarkerColor!,
        borderColor: defaultCircleMarkerBorderColor!,
      );
    }
  }
}
