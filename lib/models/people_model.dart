class PeopleModel {
  String? documentId;
  int active;
  String city;
  String country;
  String created;
  int default_hourly_rate;
  String department;
  String email;
  String end_date;
  String first_name;
  String id_number;
  String job_title;
  String last_name;
  String modified;
  String notes;
  String start_date;
  String user_id;
  List work_days_hours;

  /// create current date

  PeopleModel({
    this.documentId,
    this.active = 1,
    this.city = "",
    this.country = "",
    this.created = "",
    this.default_hourly_rate = 8,
    this.department = "",
    this.email = "",
    this.end_date = "",
    this.first_name = "",
    this.id_number = "",
    this.job_title = "",
    this.last_name = "",
    this.modified = "",
    this.notes = "",
    this.start_date = "",
    this.user_id = "",
    this.work_days_hours = const [],
  });

  factory PeopleModel.fromSnapshot(snapshot) {
    return PeopleModel(
      documentId: snapshot.id,
      active: snapshot['active'],
      city: snapshot['city'],
      country: snapshot['country'],
      created: snapshot['created'],
      default_hourly_rate: snapshot['default_hourly_rate'],
      department: snapshot['department'],
      email: snapshot['email'],
      end_date: snapshot['end_date'],
      first_name: snapshot['first_name'],
      id_number: snapshot['id_number'],
      job_title: snapshot['job_title'],
      last_name: snapshot['last_name'],
      modified: snapshot['modified'],
      notes: snapshot['notes'],
      start_date: snapshot['start_date'],
      user_id: snapshot['user_id'],
      work_days_hours: snapshot['work_days_hours'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'active': active,
      'city': city,
      'country': country,
      'created': created,
      'default_hourly_rate': default_hourly_rate,
      'department': department,
      'email': email,
      'end_date': end_date,
      'first_name': first_name,
      'id_number': id_number,
      'job_title': job_title,
      'last_name': last_name,
      'modified': modified,
      'notes': notes,
      'start_date': start_date,
      'user_id': user_id,
      'work_days_hours': work_days_hours,
    };
  }
}
