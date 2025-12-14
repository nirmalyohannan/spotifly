// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_song_metadata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedSongMetadataAdapter extends TypeAdapter<CachedSongMetadata> {
  @override
  final typeId = 3;

  @override
  CachedSongMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedSongMetadata(
      id: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String,
      album: fields[3] as String,
      coverUrl: fields[4] as String,
      durationMs: (fields[5] as num).toInt(),
      remoteUrl: fields[6] as String,
      source: fields[7] as CacheSource,
      filePath: fields[8] as String,
      lastPlayedAt: fields[9] as DateTime,
      fileSize: (fields[10] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, CachedSongMetadata obj) {
    writer
      ..writeByte(11)
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
      ..write(obj.remoteUrl)
      ..writeByte(7)
      ..write(obj.source)
      ..writeByte(8)
      ..write(obj.filePath)
      ..writeByte(9)
      ..write(obj.lastPlayedAt)
      ..writeByte(10)
      ..write(obj.fileSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedSongMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
