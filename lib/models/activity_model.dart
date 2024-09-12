class ActivityModel {
  String? documentId;
  int active;
  String activity_id;
  String activity_name;
  String created;
  int default_minute_rate;
  String responsable_people;
  String modified;
  String notes;

  /// create current date

  ActivityModel({
    this.documentId,
    this.active = 1,
    this.activity_id = "",
    this.activity_name = "",
    this.created = "",
    this.default_minute_rate = 0,
    this.responsable_people = "",
    this.modified = "",
    this.notes = "",
  });

  factory ActivityModel.fromSnapshot(snapshot) {
    return ActivityModel(
      documentId: snapshot['documentId'],
      active: snapshot['active'],
      activity_id: snapshot['activity_id'],
      activity_name: snapshot['activity_name'],
      created: snapshot['created'],
      default_minute_rate: snapshot['default_minute_rate'],
      responsable_people: snapshot['responsable_people'],
      modified: snapshot['modified'],
      notes: snapshot['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'active': active,
      'activity_id': activity_id,
      'activity_name': activity_name,
      'created': created,
      'default_minute_rate': default_minute_rate,
      'responsable_people': responsable_people,
      'modified': modified,
      'notes': notes,
    };
  }
}
