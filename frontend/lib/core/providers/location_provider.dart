import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationNode {
  final String id;
  final double x;
  final double y;
  final int floor;

  LocationNode({
    required this.id,
    required this.x,
    required this.y,
    required this.floor,
  });

  factory LocationNode.fromJson(Map<String, dynamic> json) {
    return LocationNode(
      id: json['id'] ?? json['node_id'] ?? '',
      x: (json['x'] ?? 0.0).toDouble(),
      y: (json['y'] ?? 0.0).toDouble(),
      floor: json['floor'] ?? 0,
    );
  }
}

class UserLocationState {
  final LocationNode? currentNode;
  final String? source;
  final double confidence;
  final bool isLocating;

  UserLocationState({
    this.currentNode,
    this.source,
    this.confidence = 0.0,
    this.isLocating = false,
  });

  UserLocationState copyWith({
    LocationNode? currentNode,
    String? source,
    double? confidence,
    bool? isLocating,
  }) {
    return UserLocationState(
      currentNode: currentNode ?? this.currentNode,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
      isLocating: isLocating ?? this.isLocating,
    );
  }
}

class LocationNotifier extends StateNotifier<UserLocationState> {
  LocationNotifier() : super(UserLocationState());

  void updateLocation(LocationNode node, String source, double confidence) {
    state = state.copyWith(
      currentNode: node,
      source: source,
      confidence: confidence,
      isLocating: false,
    );
  }

  void setLocating(bool isLocating) {
    state = state.copyWith(isLocating: isLocating);
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, UserLocationState>((ref) {
  return LocationNotifier();
});
