import 'dart:convert';
import 'dart:io';

import 'package:jtt_commandline/src/models/tablet.dart';

class Project {

  ProjectType type;
  PatternType patternType;
  String patternSource;
  List<Tablet> deck;
  Map<String,List<int>> packs;
  Map<String,List<String>> palettes; //<palettes name, hexadecimal color values>
  SlantRepresentation slantRepresentation = SlantRepresentation.tabletSlant;

  //todo card slant or thread slant, clockwise anti clockwise, holeLabels,starting position (hole 1 is Front or back top)

  Project (this.type, {this.patternType, this.patternSource, this.deck, this.slantRepresentation}) {
    slantRepresentation = slantRepresentation ?? SlantRepresentation.tabletSlant;
  }

  Project.fromJson(Map<String, dynamic> json)
      : type = json['projectType'],
        patternType = json['patternType'],
        patternSource = json['patternSource'],
        deck = json['deck'],
        slantRepresentation = json['slantRepresentation'];

  Map<String, dynamic> toJson() => {
    'projectType': type != null ? type.toString() : null,
    'patternType': patternType != null ? patternType.toString() : null,
    'patternSource': patternSource,
    'deck': deck != null ? deck.map((e) => e.toJson()).toList() : null,
    'packs': packs ?? packs,
    'palette': palettes ?? palettes,
    'slantRep': slantRepresentation.toString().split('.')[1],
  };

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

enum ProjectType {
  tabletWeaving,
}

enum PatternType {
  threadedIn,
  doubleWeave,
  brokenTwill
}

enum SlantRepresentation {
  tabletSlant,
  threadAngle,
  arrows
}