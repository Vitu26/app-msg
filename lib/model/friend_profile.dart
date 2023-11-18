class FriendProfile {
  final String? profilePictureUrl;
  final String? name;
  final String? lastName;
  final String? email;
  final String? phone;
  final String uid;

  FriendProfile({
    this.profilePictureUrl,
    required this.name,
    this.lastName,
    this.email,
    this.phone,
    required this.uid,
  });


  factory FriendProfile.fromMap(Map<String, dynamic> data, String uid) {
    return FriendProfile(
      profilePictureUrl: data['friendProfilePictureUrl'],
      name: data['friendName'],
      lastName: data['friendLastName'],
      email: data['friendEmail'],
      phone: data['friendPhone'],
      uid: uid,
    );
  }
}
