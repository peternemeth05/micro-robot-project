class RobotProfile {
  final String id;
  final String name;
  final String serviceUuid; 

  RobotProfile({required this.id, required this.name, required this.serviceUuid});
}

// database of robots
final List<RobotProfile> knownRobots = [
  RobotProfile(id: '1', name: 'Peter’s iPad', serviceUuid: '12345678-1234-5678-1234-56789abcdef0'),
  RobotProfile(id: '2', name: 'Peter’s iPhone (2)',  serviceUuid: '12345678-1234-5678-1234-56789abcdef0'),
  RobotProfile(id: '3', name: 'Robot3', serviceUuid: '12345678-1234-5678-1234-56789abcdef0'),
  RobotProfile(id: '4', name: 'Robot4', serviceUuid: '12345678-1234-5678-1234-56789abcdef0'),
  RobotProfile(id: '5', name: 'Robot5', serviceUuid: '12345678-1234-5678-1234-56789abcdef0'),
];