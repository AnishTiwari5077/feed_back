// lib/core/models/feedback_model.dart

class FeedbackModel {
  final int? id;
  final String deviceOwner; // authenticated Google user email
  final String name;        // user details: name
  final String email;       // user details: email
  final String contact;     // user details: contact
  final String bugIssue;    // bug/issue title or summary
  final String? userDevice; // device model (auto-detected)
  final String description; // detailed bug description
  final String? mediaLinks; // comma-separated scoped storage URIs
  final String createdAt;

  const FeedbackModel({
    this.id,
    required this.deviceOwner,
    required this.name,
    required this.email,
    required this.contact,
    required this.bugIssue,
    this.userDevice,
    required this.description,
    this.mediaLinks,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'device_owner': deviceOwner,
      'name': name,
      'email': email,
      'contact': contact,
      'bug_issue': bugIssue,
      'user_device': userDevice,
      'description': description,
      'media_links': mediaLinks,
      'created_at': createdAt,
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'] as int?,
      deviceOwner: map['device_owner'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      contact: map['contact'] as String,
      bugIssue: map['bug_issue'] as String,
      userDevice: map['user_device'] as String?,
      description: map['description'] as String,
      mediaLinks: map['media_links'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  FeedbackModel copyWith({
    int? id,
    String? deviceOwner,
    String? name,
    String? email,
    String? contact,
    String? bugIssue,
    String? userDevice,
    String? description,
    String? mediaLinks,
    String? createdAt,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      deviceOwner: deviceOwner ?? this.deviceOwner,
      name: name ?? this.name,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      bugIssue: bugIssue ?? this.bugIssue,
      userDevice: userDevice ?? this.userDevice,
      description: description ?? this.description,
      mediaLinks: mediaLinks ?? this.mediaLinks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
