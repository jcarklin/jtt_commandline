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

  String name;
  String type;
  String patternType;
  String patternSource;
  List<Tablet> deck;
  Map<String,List<int>> packs;
  Map<String,List<String>> palettes; //<palettes name, hexadecimal color values>
  String slantRepresentation = SLANT_TABLET;
  String extraInfo;

  //tODO clockwise anti clockwise, holeLabels,starting position (hole 1 is Front or back top)

  Project (this.name, this.type, {this.patternType, this.patternSource, this.deck, this.slantRepresentation, this.extraInfo}) {
    slantRepresentation = slantRepresentation ?? SLANT_TABLET;
  }

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
  
  Future<String> toJttFile(String filename) {
    return Future.sync(() {
      return File(filename).writeAsString(toString())
          .catchError(() {
        return 'Writing File $filename Failed!!';
      })
          .then((value) {
        return 'File $filename successfully written';
      });
    });
  }

  @override
  String toString() {
    return JsonEncoder.withIndent('  ').convert(this);
  }
}

