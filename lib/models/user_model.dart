enum Role { admin, user }

class UserModel {
  String? documentId;
  int active;
  String city;
  String country;
  String created;
  Role role;
  String department;
  String email;
  String first_name;
  String id_number;
  String job_title;
  String last_name;
  String modified;
  String notes;
  String user_id;
  List work_days_hours;
  String tenantId;
  String company_name;

  /// create current date

  UserModel({
    this.documentId = "",
    this.active = 1,
    this.city = "",
    this.country = "",
    this.created = "",
    this.role = Role.user,
    this.department = "",
    required this.email,
    this.company_name = "",
    this.tenantId = "",
    this.first_name = "",
    this.id_number = "",
    this.job_title = "",
    this.last_name = "",
    this.modified = "",
    this.notes = "",
    this.user_id = "",
    this.work_days_hours = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'active': active,
      'city': city,
      'country': country,
      'created': created,
      'department': department,
      'email': email,
      'first_name': first_name,
      'id_number': id_number,
      'job_title': job_title,
      'last_name': last_name,
      'modified': modified,
      'notes': notes,
      'user_id': user_id,
      'work_days_hours': work_days_hours,
    };
  }

  factory UserModel.fromSnapshot(snapshot) {
    return UserModel(
      documentId: snapshot.id,
      active: snapshot['active'],
      city: snapshot['city'],
      country: snapshot['country'],
      created: snapshot['created'],
      department: snapshot['department'],
      email: snapshot['email'],
      first_name: snapshot['first_name'],
      id_number: snapshot['id_number'],
      job_title: snapshot['job_title'],
      last_name: snapshot['last_name'],
      modified: snapshot['modified'],
      notes: snapshot['notes'],
      user_id: snapshot['user_id'],
      work_days_hours: snapshot['work_days_hours'],
    );
  }
}
