import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../utils/instruction_generator.dart';

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
  
  // Routing state
  final LocationNode? destinationNode;
  final List<LocationNode>? currentRoute;
  final List<String>? instructions;

  UserLocationState({
    this.currentNode,
    this.source,
    this.confidence = 0.0,
    this.isLocating = false,
    this.destinationNode,
    this.currentRoute,
    this.instructions,
  });

  UserLocationState copyWith({
    LocationNode? currentNode,
    String? source,
    double? confidence,
    bool? isLocating,
    LocationNode? destinationNode,
    List<LocationNode>? currentRoute,
    List<String>? instructions,
  }) {
    return UserLocationState(
      currentNode: currentNode ?? this.currentNode,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
      isLocating: isLocating ?? this.isLocating,
      destinationNode: destinationNode ?? this.destinationNode,
      currentRoute: currentRoute ?? this.currentRoute,
      instructions: instructions ?? this.instructions,
    );
  }
}

class LocationNotifier extends StateNotifier<UserLocationState> {
  final Ref ref;

  LocationNotifier(this.ref) : super(UserLocationState());

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
  
  void setDestination(LocationNode dest) {
    state = state.copyWith(destinationNode: dest);
  }

  Future<void> fetchRoute(String destinationId, {bool accessible = false}) async {
    if (state.currentNode == null) return;
    
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getRoute(
        startNodeId: state.currentNode!.id,
        endNodeId: destinationId,
        accessible: accessible,
      );
      
      if (response != null && response['path'] != null) {
        final rawPath = response['path'] as List;
        final pathNodes = rawPath.map((p) => LocationNode.fromJson(p)).toList();
        
        final inst = InstructionGenerator.generateInstructions(pathNodes);
        
        state = state.copyWith(
          currentRoute: pathNodes,
          instructions: inst,
        );
      }
    } catch (e) {
      debugPrint("Error fetching route: $e");
    }
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, UserLocationState>((ref) {
  return LocationNotifier(ref);
});
