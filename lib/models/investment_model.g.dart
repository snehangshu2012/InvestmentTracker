// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvestmentAdapter extends TypeAdapter<Investment> {
  @override
  final int typeId = 0;

  @override
  Investment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Investment(
      id: fields[0] as String?,
      name: fields[1] as String,
      type: fields[2] as InvestmentType,
      amount: fields[3] as double,
      startDate: fields[4] as DateTime,
      maturityDate: fields[5] as DateTime?,
      status: fields[6] as InvestmentStatus,
      additionalData: (fields[7] as Map?)?.cast<String, dynamic>(),
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Investment obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.maturityDate)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.additionalData)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InvestmentTypeAdapter extends TypeAdapter<InvestmentType> {
  @override
  final int typeId = 1;

  @override
  InvestmentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InvestmentType.fixedDeposit;
      case 1:
        return InvestmentType.recurringDeposit;
      case 2:
        return InvestmentType.ppf;
      case 3:
        return InvestmentType.nps;
      case 4:
        return InvestmentType.mutualFundEquity;
      case 5:
        return InvestmentType.mutualFundDebt;
      case 6:
        return InvestmentType.mutualFundHybrid;
      case 7:
        return InvestmentType.goldETF;
      case 8:
        return InvestmentType.goldDigital;
      case 9:
        return InvestmentType.goldPhysical;
      case 10:
        return InvestmentType.realEstate;
      case 11:
        return InvestmentType.stocks;
      case 12:
        return InvestmentType.bonds;
      case 13:
        return InvestmentType.crypto;
      case 14:
        return InvestmentType.ulip;
      case 15:
        return InvestmentType.epf;
      case 16:
        return InvestmentType.other;
      default:
        return InvestmentType.fixedDeposit;
    }
  }

  @override
  void write(BinaryWriter writer, InvestmentType obj) {
    switch (obj) {
      case InvestmentType.fixedDeposit:
        writer.writeByte(0);
        break;
      case InvestmentType.recurringDeposit:
        writer.writeByte(1);
        break;
      case InvestmentType.ppf:
        writer.writeByte(2);
        break;
      case InvestmentType.nps:
        writer.writeByte(3);
        break;
      case InvestmentType.mutualFundEquity:
        writer.writeByte(4);
        break;
      case InvestmentType.mutualFundDebt:
        writer.writeByte(5);
        break;
      case InvestmentType.mutualFundHybrid:
        writer.writeByte(6);
        break;
      case InvestmentType.goldETF:
        writer.writeByte(7);
        break;
      case InvestmentType.goldDigital:
        writer.writeByte(8);
        break;
      case InvestmentType.goldPhysical:
        writer.writeByte(9);
        break;
      case InvestmentType.realEstate:
        writer.writeByte(10);
        break;
      case InvestmentType.stocks:
        writer.writeByte(11);
        break;
      case InvestmentType.bonds:
        writer.writeByte(12);
        break;
      case InvestmentType.crypto:
        writer.writeByte(13);
        break;
      case InvestmentType.ulip:
        writer.writeByte(14);
        break;
      case InvestmentType.epf:
        writer.writeByte(15);
        break;
      case InvestmentType.other:
        writer.writeByte(16);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestmentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InvestmentStatusAdapter extends TypeAdapter<InvestmentStatus> {
  @override
  final int typeId = 2;

  @override
  InvestmentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InvestmentStatus.active;
      case 1:
        return InvestmentStatus.matured;
      case 2:
        return InvestmentStatus.closed;
      case 3:
        return InvestmentStatus.paused;
      default:
        return InvestmentStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, InvestmentStatus obj) {
    switch (obj) {
      case InvestmentStatus.active:
        writer.writeByte(0);
        break;
      case InvestmentStatus.matured:
        writer.writeByte(1);
        break;
      case InvestmentStatus.closed:
        writer.writeByte(2);
        break;
      case InvestmentStatus.paused:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestmentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
