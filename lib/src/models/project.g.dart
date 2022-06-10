// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      json['name'] as String,
      json['type'] as String,
      patternType: json['patternType'] as String?,
      patternSource: json['patternSource'] as String?,
      deck: (json['deck'] as List<dynamic>?)
          ?.map((e) => Tablet.fromJson(e as Map<String, dynamic>))
          .toList(),
      slantRepresentation: json['slantRepresentation'] as String?,
      threadingDirection: json['threadingDirection'] as String?,
      extraInfo: json['extraInfo'] as String?,
    )
      ..packs = (json['packs'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>?)?.map((e) => e as int?).toList()),
      )
      ..palettes = (json['palettes'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'patternType': instance.patternType,
      'patternSource': instance.patternSource,
      'deck': instance.deck,
      'packs': instance.packs,
      'palettes': instance.palettes,
      'slantRepresentation': instance.slantRepresentation,
      'threadingDirection': instance.threadingDirection,
      'extraInfo': instance.extraInfo,
    };
