class RobotProfile {
  final String id;
  final String name;
  final String serviceUuid; 

  RobotProfile({required this.id, required this.name, required this.serviceUuid});
}

// database of robots
final List<RobotProfile> knownRobots = [
  RobotProfile(id: '0', name: 'Freenove-Dog-E65B7A0', serviceUuid: '0000ffe0-0000-1000-8000-00805f9b34fb'),
  RobotProfile(id: '1', name: 'DogRobot', serviceUuid: '12345678-1234-5678-1234-56789abcdef0'),
  RobotProfile(id: '2', name: 'Peter’s iPhone (2)',  serviceUuid: '12345678-1234-5678-1234-56789abcdef0'),
  RobotProfile(id: '3', name: 'Peter’s iPad', serviceUuid: '12345678-1234-5678-1234-56789abcdef0'),
  RobotProfile(id: '4', name: 'Robot3', serviceUuid: '12345678-1234-5678-1234-56789abcdef0'),
  RobotProfile(id: '5', name: 'Robot4', serviceUuid: '12345678-1234-5678-1234-56789abcdef0'),
  RobotProfile(id: '6', name: 'Robot5', serviceUuid: '12345678-1234-5678-1234-56789abcdef0'),

];