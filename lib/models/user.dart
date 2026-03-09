class User {
  final int id;
  final String name;
  final String email;
  final String surveyorLicense;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.surveyorLicense,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        surveyorLicense: json['surveyor_license'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'surveyor_license': surveyorLicense,
      };
}
