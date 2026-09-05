import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

/// Provides map tile configurations.
/// This abstraction ensures we are not deeply coupling our UI to a specific map backend.
abstract class MapTileProvider {
  Widget buildTileLayer();
}

/// The standard OSM tile provider.
/// ONLY for development/testing as per requirements.
/// Includes proper User-Agent attribution.
class DefaultOSMTileProvider implements MapTileProvider {
  final String userAgent;

  const DefaultOSMTileProvider({this.userAgent = 'com.trainwake.app'});

  @override
  Widget buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: userAgent,
      maxZoom: 19,
    );
  }
}

final mapTileProvider = Provider<MapTileProvider>((ref) {
  return const DefaultOSMTileProvider();
});
