// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_song.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveSongAdapter extends TypeAdapter<HiveSong> {
  @override
  final typeId = 0;

  @override
  HiveSong read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSong(
      id: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String,
      album: fields[3] as String,
      coverUrl: fields[4] as String,
      durationMs: (fields[5] as num).toInt(),
      assetUrl: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveSong obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.album)
      ..writeByte(4)
      ..write(obj.coverUrl)
      ..writeByte(5)
      ..write(obj.durationMs)
      ..writeByte(6)
      ..write(obj.assetUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveSongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
