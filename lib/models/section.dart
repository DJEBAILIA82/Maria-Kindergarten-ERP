class KindergartenSection {
  final String id;
  final String name;
  final String teacherName;
  final String ageGroup;
  final int capacity;
  final String status;

  KindergartenSection({
    required this.id,
    required this.name,
    required this.teacherName,
    required this.ageGroup,
    required this.capacity,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teacherName': teacherName,
      'ageGroup': ageGroup,
      'capacity': capacity,
      'status': status,
    };
  }

  factory KindergartenSection.fromMap(Map<String, dynamic> map) {
    return KindergartenSection(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      teacherName: map['teacherName'] as String? ?? '',
      ageGroup: map['ageGroup'] as String? ?? '',
      capacity: (map['capacity'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'نشط',
    );
  }
}