// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_playlist.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HivePlaylistOwnerAdapter extends TypeAdapter<HivePlaylistOwner> {
  @override
  final typeId = 4;

  @override
  HivePlaylistOwner read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HivePlaylistOwner(
      id: fields[0] as String,
      displayName: fields[1] as String,
      email: fields[2] as String?,
      images: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, HivePlaylistOwner obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.images);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HivePlaylistOwnerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
      owner: fields[5] as HivePlaylistOwner?,
    );
  }

  @override
  void write(BinaryWriter writer, HivePlaylist obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.creator)
      ..writeByte(3)
      ..write(obj.coverUrl)
      ..writeByte(4)
      ..write(obj.snapshotId)
      ..writeByte(5)
      ..write(obj.owner);
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
