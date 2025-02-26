

class Users  {
  String? userId;

  String? name;
  String? employeeId;
  String? email;

  String? role;


  Users({
    required this.userId,

    this.email,

    this.role,
  this.name,
    this.employeeId,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      userId: json['userId'].toString() ,
      email: json['email'],
      role: json['role'],
      name: json['name'],
      employeeId: json['employeeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'employeeId':employeeId,
      'email': email,

      'name': name,
      'role': role,

    };
  }
}
