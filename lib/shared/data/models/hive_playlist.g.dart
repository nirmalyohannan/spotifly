// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_playlist.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HivePlaylistAdapter extends TypeAdapter<HivePlaylist> {
  @override
  final typeId = 1;

  @override
  HivePlaylist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HivePlaylist(
      id: fields[0] as String,
      title: fields[1] as String,
      creator: fields[2] as String,
      coverUrl: fields[3] as String,
      snapshotId: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HivePlaylist obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.creator)
      ..writeByte(3)
      ..write(obj.coverUrl)
      ..writeByte(4)
      ..write(obj.snapshotId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HivePlaylistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
