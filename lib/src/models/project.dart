import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:jtt_commandline/src/models/tablet.dart';

part 'project.g.dart';

@JsonSerializable()
class Project {
  static const String PROJECT_TYPE_TABLET_WEAVING = 'tabletWeaving';

  static const String PATTERN_TYPE_THREADED_IN = 'threadedIn';
  static const String PATTERN_TYPE_DOUBLE_WEAVE = 'doubleWeave';
  static const String PATTERN_TYPE_BROKEN_TWILL = 'brokenTwill';

  static const String SLANT_TABLET = 'tabletSlant';
  static const String SLANT_THREAD = 'threadAngle';
  static const String SLANT_ARROWS = 'arrows';

  static const String THREADING_DIRECTION_CLOCKWISE = 'clockwise'; //DA CB
  static const String THREADING_DIRECTION_ANTICLOCKWISE =
      'anticlockwise'; //AD BC
  static const String THREADING_DIRECTION_POLES = 'poles'; // TF TB BF BB

  String name;
  String type;
  String? patternType;
  String? patternSource;
  List<Tablet>? deck;
  late Map<String, List<int?>?> packs;
  late Map<String, List<String>>? palettes; //palettes name, hex color values
  String? slantRepresentation = SLANT_TABLET;
  String? threadingDirection;
  String? extraInfo;

  //tODO clockwise anti clockwise, holeLabels,starting position (hole 1 is Front or back top)

  Project(this.name, this.type,
      {this.patternType,
      this.patternSource,
      this.deck,
      this.slantRepresentation,
      this.threadingDirection,
      this.extraInfo}) {
    slantRepresentation = slantRepresentation ?? SLANT_TABLET;
    threadingDirection =
        threadingDirection ?? THREADING_DIRECTION_ANTICLOCKWISE;
  }

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  @override
  String toString() {
    return JsonEncoder.withIndent('  ').convert(this);
  }
}
