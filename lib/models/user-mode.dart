

class UserModel {
  final String email;
  final String uid;


  const UserModel({
    required this.email,
    required this.uid,

  });

  Map<String, dynamic> toJson() => {

        "uid": uid,
        "email": email,

      };

//   static Userm fromsnap(DocumentSnapshot snap) {
//   var snapshot = snap.data() as Map<String, dynamic>;

//   return Userm(
//     email: snapshot['email'] ?? '',  // Default to an empty string if 'email' is null
//     uid: snapshot['uid'] ?? '',      // Default to an empty string if 'uid' is null
//     username: snapshot['username'] ?? '', // Default to an empty string if 'username' is null
//     pfpLink: snapshot['pfpLink'] ?? '', // Default to an empty string if 'username' is null
//     followers: snapshot['followers'] ?? [], // Default to an empty list if 'followers' is null
//     following: snapshot['following'] ?? [], // Default to an empty list if 'following' is null
//   );
// }

}
