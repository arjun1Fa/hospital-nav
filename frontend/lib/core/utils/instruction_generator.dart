import 'dart:math';
import '../providers/location_provider.dart'; // Contains LocationNode

/// Generates turn-by-turn voice and text instructions based on a path.
class InstructionGenerator {
  /// Generates a list of instructions from a list of path nodes.
  static List<String> generateInstructions(List<LocationNode> path) {
    if (path.isEmpty) return ["No path found."];
    if (path.length == 1) return ["You are already at your destination."];

    final List<String> instructions = [];
    double currentDistance = 0.0;
    
    for (int i = 0; i < path.length - 1; i++) {
      final current = path[i];
      final next = path[i + 1];

      // Handle floor changes
      if (current.floor != next.floor) {
        if (currentDistance > 0) {
          instructions.add("Go straight for ${currentDistance.toStringAsFixed(1)} meters.");
          currentDistance = 0.0;
        }
        
        final action = next.floor > current.floor ? "Go up" : "Go down";
        instructions.add("$action to Floor ${next.floor}.");
        continue;
      }

      // Calculate distance between current and next node
      final dx = next.x - current.x;
      final dy = next.y - current.y;
      final distance = sqrt(dx * dx + dy * dy);

      if (i < path.length - 2) {
        final nextNext = path[i + 2];
        
        // Calculate turn angle if the next transition is on the same floor
        if (next.floor == nextNext.floor) {
          final dx2 = nextNext.x - next.x;
          final dy2 = nextNext.y - next.y;
          
          final angle1 = atan2(dy, dx);
          final angle2 = atan2(dy2, dx2);
          
          double turnAngle = (angle2 - angle1) * 180 / pi;
          
          // Normalize angle
          while (turnAngle <= -180) { turnAngle += 360; }
          while (turnAngle > 180) { turnAngle -= 360; }

          if (turnAngle.abs() > 30) {
            // Significant turn detected
            if (currentDistance + distance > 0) {
              instructions.add("Go straight for ${(currentDistance + distance).toStringAsFixed(1)} meters.");
              currentDistance = 0.0;
            }
            
            if (turnAngle > 0) {
              instructions.add("Turn right.");
            } else {
              instructions.add("Turn left.");
            }
          } else {
            // Small angle, continue straight
            currentDistance += distance;
          }
        } else {
          // Next node is an elevator/stairs
          currentDistance += distance;
        }
      } else {
        // Last segment
        currentDistance += distance;
        if (currentDistance > 0) {
          instructions.add("Go straight for ${currentDistance.toStringAsFixed(1)} meters.");
        }
      }
    }

    instructions.add("You have arrived at your destination.");
    return instructions;
  }
}
