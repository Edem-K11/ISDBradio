// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArchiveAdapter extends TypeAdapter<Archive> {
  @override
  final int typeId = 0;

  @override
  Archive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Archive(
      title: fields[0] as String,
      audioUrl: fields[1] as String,
      imageUrl: fields[2] as String?,
      author: fields[3] as String?,
      publicationDate: fields[4] as DateTime?,
      duration: fields[5] as Duration?,
      cachedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Archive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.audioUrl)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.author)
      ..writeByte(4)
      ..write(obj.publicationDate)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArchiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
