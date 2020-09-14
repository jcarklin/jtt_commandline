import 'dart:convert';
import 'dart:io';

import 'package:jtt_commandline/src/models/tablet.dart';

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

  //tODO clockwise anti clockwise, holeLabels,starting position (hole 1 is Front or back top)

  Project (this.name, this.type, {this.patternType, this.patternSource, this.deck, this.slantRepresentation}) {
    slantRepresentation = slantRepresentation ?? SLANT_TABLET;
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    var deck = <Tablet>[];
    var jsondeck = json['deck'] as List;
    jsondeck.forEach((value) {
      deck.add(Tablet.fromJson(value));
    });
    return Project(json['name'], json['projectType'],
        patternType:  json['patternType'],
        patternSource: json['patternSource'],
        deck: deck,
        slantRepresentation: json['slantRepresentation'],
    );
  }
      

  Map<String, dynamic> toJson() => {
    'name': name,
    'projectType': type,
    'patternType': patternType,
    'patternSource': patternSource,
    'deck': deck != null ? deck.map((e) => e.toJson()).toList() : null,
    'packs': packs ?? packs,
    'palette': palettes ?? palettes,
    'slantRep': slantRepresentation,
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

