class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final String country;
  final String product;
  final String? imageUrl;

  UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.country,
    required this.product,
    this.imageUrl,
  });
}
