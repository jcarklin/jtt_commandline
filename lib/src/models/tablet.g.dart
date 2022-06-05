// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tablet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tablet _$TabletFromJson(Map<String, dynamic> json) => Tablet(
      (json['threadPositions'] as List<dynamic>)
          .map((e) => Thread.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['startingTwist'] as String,
      json['deckIndex'] as int,
      (json['picks'] as List<dynamic>)
          .map((e) =>
              e == null ? null : Pick.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TabletToJson(Tablet instance) => <String, dynamic>{
      'threadPositions': instance.threadPositions,
      'startingTwist': instance.startingTwist,
      'picks': instance.picks,
      'deckIndex': instance.deckIndex,
    };

Pick _$PickFromJson(Map<String, dynamic> json) => Pick(
      json['twist'] as String,
      json['turned'] as String,
      Thread.fromJson(json['visibleThread'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PickToJson(Pick instance) => <String, dynamic>{
      'twist': instance.twist,
      'turned': instance.turned,
      'visibleThread': instance.visibleThread,
    };
