// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 3;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      isDarkTheme: fields[0] as bool,
      biometricEnabled: fields[1] as bool,
      pinEnabled: fields[2] as bool,
      userPin: fields[3] as String?,
      userName: fields[4] as String,
      userEmail: fields[5] as String,
      notificationsEnabled: fields[6] as bool,
      defaultCurrency: fields[7] as String,
      compactView: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.isDarkTheme)
      ..writeByte(1)
      ..write(obj.biometricEnabled)
      ..writeByte(2)
      ..write(obj.pinEnabled)
      ..writeByte(3)
      ..write(obj.userPin)
      ..writeByte(4)
      ..write(obj.userName)
      ..writeByte(5)
      ..write(obj.userEmail)
      ..writeByte(6)
      ..write(obj.notificationsEnabled)
      ..writeByte(7)
      ..write(obj.defaultCurrency)
      ..writeByte(8)
      ..write(obj.compactView);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
