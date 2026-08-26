class RobotProfile {
  final String id;
  final String name;
  final String serviceUuid; 

  RobotProfile({required this.id, required this.name, required this.serviceUuid});
}

// database of robots
final List<RobotProfile> knownRobots = [
  RobotProfile(id: '0', name: 'nRF Potentiostat', serviceUuid: '0000ffe0-0000-1000-8000-00805f9b34fb'),

];