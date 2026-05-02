import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a stream of device heading (compass orientation).
/// The value is the heading in degrees (0 to 360) where 0 is North.
final compassProvider = StreamProvider<double?>((ref) {
  return FlutterCompass.events!.map((CompassEvent event) => event.heading);
});
