// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_source.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CacheSourceAdapter extends TypeAdapter<CacheSource> {
  @override
  final typeId = 2;

  @override
  CacheSource read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CacheSource.youtube;
      case 1:
        return CacheSource.spotify;
      default:
        return CacheSource.youtube;
    }
  }

  @override
  void write(BinaryWriter writer, CacheSource obj) {
    switch (obj) {
      case CacheSource.youtube:
        writer.writeByte(0);
      case CacheSource.spotify:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
