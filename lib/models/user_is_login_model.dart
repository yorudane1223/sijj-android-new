class UserIsLogin {
  final int id;
  final String nama;
  final String username;
  final String email;
  final String telepon;
  final String alamat;
  final String image;
  final String token;

  const UserIsLogin({
    required this.id,
    required this.nama,
    required this.username,
    required this.email,
    required this.telepon,
    required this.alamat,
    required this.image,
    required this.token,
    t,
  });

  factory UserIsLogin.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'nama': String nama,
        'username': String username,
        'email': String email,
        'telepon': String telepon,
        'alamat': String alamat,
        'image': String image,
        'token': String token,
      } =>
        UserIsLogin(
          id: id,
          nama: nama,
          username: username,
          email: email,
          telepon: telepon,
          alamat: alamat,
          image: image,
          token: token,
        ),
      _ => throw const FormatException('Failed to get my profile.'),
    };
  }
}
