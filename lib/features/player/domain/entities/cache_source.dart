import 'package:hive_ce/hive.dart';

part 'cache_source.g.dart';

@HiveType(
  typeId: 2,
) // Assuming typeId 1 is taken by something else, or I should check. 0 is HiveSong.
enum CacheSource {
  @HiveField(0)
  youtube,

  @HiveField(1)
  spotify,
}
