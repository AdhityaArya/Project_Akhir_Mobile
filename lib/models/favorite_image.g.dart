part of 'favorite_image.dart';

class FavoriteImageAdapter extends TypeAdapter<FavoriteImage> {
  @override
  final int typeId = 0;

  @override
  FavoriteImage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteImage(
      title: fields[0] as String,
      url: fields[1] as String,
      explanation: fields[2] as String,
      date: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteImage obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.explanation)
      ..writeByte(3)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteImageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
