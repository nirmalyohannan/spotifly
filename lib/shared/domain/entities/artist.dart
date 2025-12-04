class Artist {
  final String id;
  final String name;
  final String imageUrl;
  final String bio;

  Artist({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.bio = '',
  });
}
