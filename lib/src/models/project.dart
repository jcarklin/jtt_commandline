import 'dart:convert';

import 'package:jtt_commandline/src/models/tablet.dart';

class Project {

  ProjectType type;
  PatternType patternType;
  String patternSource;
  List<Tablet> deck;
  Map<String,List<int>> packs;
  Map<String,List<String>> palettes; //<palettes name, hexadecimal color values>

  //todo card slant or thread slant, clockwise anti clockwise, holeLabels,starting position (hole 1 is Front or back top)

  Project (this.type, {this.patternType, this.patternSource, this.deck});

  Project.fromJson(Map<String, dynamic> json)
      : type = json['projectType'],
        patternType = json['patternType'],
        patternSource = json['patternSource'],
        deck = json['deck'];

  Map<String, dynamic> toJson() => {
    'projectType': type != null ? jsonEncode(type.toString()) : null,
    'patternType': patternType != null ? jsonEncode(patternType.toString()) : null,
    'patternSource': patternSource,
    'deck': deck != null ? deck.map((e) => e.toJson()).toList() : null,
    'packs': packs != null ? jsonEncode(packs) : null,
    'palette': palettes != null ? jsonEncode(palettes) : null,
  };



  @override
  String toString() {
    return JsonEncoder.withIndent('  ').convert(this);
  }
}

enum ProjectType {
  tabletWeaving,
}

enum PatternType {
  threadedIn,
  doubleWeave,
  brokenTwill
}