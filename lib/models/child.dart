class Child {
  String id;
  String firstName;
  String lastName;
  String gender;
  String birthDate;
  String section;
  String guardian;
  String fatherName;
  String motherName;
  String phone1;
  String phone2;
  String address;
  String transport;
  String allergies;
  String medicalFile;
  String notes;
  String username;
  String password;
  String status;
  String imagePath;

  Child({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthDate,
    required this.section,
    required this.guardian,
    required this.fatherName,
    required this.motherName,
    required this.phone1,
    required this.phone2,
    required this.address,
    required this.transport,
    required this.allergies,
    required this.medicalFile,
    required this.notes,
    required this.username,
    required this.password,
    required this.status,
    required this.imagePath,
  });

  String get fullName => '$firstName $lastName';
}