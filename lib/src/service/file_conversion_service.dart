import 'dart:convert';
import 'dart:io';

import 'package:hex/hex.dart';
import 'package:jtt_commandline/src/models/gtt_project.dart';
import 'package:jtt_commandline/src/models/project.dart';
import 'package:jtt_commandline/src/models/tablet.dart';
import 'package:jtt_commandline/src/models/thread.dart';
import 'package:xml/xml.dart';

class FileConversionService {
  TwData? _twData;
  Project? _jttProject;
  File? gttFile;
  late File? jttFile;

  FileConversionService.fromGtt(File? gttXml) {
    gttFile = gttXml;
    if (gttFile != null) {
      _twData = _fromGttXml(gttFile!.readAsStringSync());
      _jttProject = _fromTwData();
    }
  }

  FileConversionService.fromJtt(File? jttJson) {
    jttFile = jttJson;
    if (jttJson != null) {
      _jttProject = _fromJttJson(jttJson.readAsStringSync());
      _twData = _fromJttProject();
    }
  }

  TwData? get gttTWdata => _twData;
  Project? get jttProject => _jttProject;

  TwData _fromGttXml(String xmlInput) {
    final document = XmlDocument.parse(xmlInput);
    return TwData.fromXml(document.getElement('TWData')!);
  }

  Project _fromTwData() {
    final jttProject = Project(
        gttTWdata!.pattern!.name, Project.PROJECT_TYPE_TABLET_WEAVING,
        patternSource: gttTWdata!.source,
        slantRepresentation: Project.SLANT_THREAD,
        patternType: gttTWdata!.pattern!.type,
        extraInfo: gttTWdata!.pattern!.notes);
    final gttPattern = gttTWdata!.pattern!;

    switch (gttPattern.type) {
      case GttPattern.PATTERN_TYPE_THREADED:
        jttProject.patternType = Project.PATTERN_TYPE_THREADED_IN;
        break;
      case GttPattern
          .PATTERN_TYPE_DOUBLE_FACE: //|BrokenTwill|Brocade|LetteredBand}>'
        jttProject.patternType = Project.PATTERN_TYPE_DOUBLE_WEAVE;
        break;
      default:
        throw FormatException('Unsupported Pattern Type');
    }

    final gttCards = gttPattern.cards!.card;
    jttProject.deck = gttCards
        .asMap()
        .entries
        .map((e) => _convertGttCardToTablet(e.key, e.value))
        .toList();
    final Map<String?, List<int?>?> gttPacksMap = <String?, List<int>?>{};
    gttPattern.packs!.packs!
        .forEach((pack) => gttPacksMap[pack.name] = pack.cardIndexs);
    final iter = gttPattern.palette!.colour!
        .map((e) => _convertColorToHex(int.tryParse(e.text!)!));
    jttProject.palettes = {gttPattern.palette!.name: iter.toList()};
    final gttPicks = gttPattern.picks!.pickList!;

    gttPicks.forEach((actionParent) {
      final actions = actionParent.actions!.action;

      final twists = <int?>{};
      actions.forEach((action) {
        if (action.type == Type.TWIST) {
          if (action.target == Target.CARD) {
            twists.add(action.targetId);
          } else if (action.target == Target.PACK) {
            gttPacksMap[action.targetId]!
                .forEach((element) => twists.add(element));
          }
        }
      });

      actions.forEach((action) {
        if (action.target == Target.CARD) {
          _processTurn(action, jttProject.deck![action.targetId - 1],
              twists.contains(action.targetId));
        } else if (action.target == Target.PACK) {
          gttPacksMap[action.targetId]!.forEach((element) => _processTurn(
              action,
              jttProject.deck![element! - 1],
              twists.contains(element)));
        }
      });
    });

    jttProject.packs = gttPacksMap;
    return jttProject;
  }

  Project _fromJttJson(String jttJson) {
    _jttProject = Project.fromJson(jsonDecode(jttJson));
    return jttProject;
  }

  TwData _fromJttProject() {
    final cardData = jttProject!.deck!
        .map((tablet) => _convertJttTabletToGttCard(tablet))
        .toList();
    final pattern = GttPattern(
      name: jttProject!.name,
      notes: jttProject!.extraInfo ?? 'Converted from a JTT file',
      cards: Cards(cardData),
      type: convertJttPatternTypeToGtt(jttProject!.patternType),
      palette: convertJttPaletteTypeToGtt(jttProject!.palettes),
      picks: convertJttTabletsTypeToGttPicks(jttProject!.deck!),
      packs: convertJttPacksToGtt(jttProject!.packs),
    );
    return TwData(
        source: jttProject!.patternSource, version: '1.15', pattern: pattern);
  }

  Future<String> writeAsJttFile() {
    return jttProject!.toJttFile('${gttFile!.path.replaceAll('.gtt', '.jtt')}');
  }

  Future<String> writeAsGttFile() {
    return gttTWdata!.toGttFile('${jttFile.path.replaceAll('.jtt', '.gtt')}');
  }

  String _convertColorToHex(int colorDec) {
    var r = colorDec & 0xff;
    var g = (colorDec >> 8) & 0xff;
    var b = (colorDec >> 16) & 0xff;
    r = (r < 0) ? -r : r;
    g = (g < 0) ? -g : g;
    b = (b < 0) ? -b : b;
    r = (r > 255) ? 255 : r;
    g = (g > 255) ? 255 : g;
    b = (b > 255) ? 255 : b;
    final encoded = HEX.encode([r, g, b]);
    return encoded;
  }

  int _convertHexToColour(String hex) {
    var decoded = HEX.decode(hex);
    return (decoded[2] << 16) + (decoded[1] << 8) + (decoded[0]);
  }

  Tablet _convertGttCardToTablet(int index, Card gttCard) {
    return Tablet(
        _convertGttHolesToThreads(gttCard.holes!),
        gttCard.threading == Threading.S ? Tablet.TWIST_S : Tablet.TWIST_Z,
        index, []);
  }

  Card _convertJttTabletToGttCard(Tablet jttTablet) {
    var holes = _convertJttThreadsToGttHoles(jttTablet.threadPositions);
    var threading =
        jttTablet.startingTwist == Tablet.TWIST_S ? Threading.S : Threading.Z;
    return Card(
      holes: holes,
      threading: threading,
      curThread: threading,
      curPos: '0',
      curHoles: holes,
      cardHoles: holes.colour!.length.toString(),
      number: (jttTablet.deckIndex + 1).toString(),
    );
  }

  List<Thread> _convertGttHolesToThreads(Holes holes) {
    return holes.colour!
        .asMap()
        .entries
        .map((e) => Thread(e.key, e.value))
        .toList(growable: false);
  }

  Holes _convertJttThreadsToGttHoles(List<Thread> threads) {
    return Holes(
        colour: threads.map((e) => e.colourIndex).toList(),
        count: threads.length);
  }

  String? convertJttPatternTypeToGtt(String? jttType) {
    switch (jttType) {
      case 'threadedIn':
        return GttPattern.PATTERN_TYPE_THREADED;
      case 'doubleWeave':
        return GttPattern.PATTERN_TYPE_DOUBLE_FACE;
      case 'brokenTwill':
        return GttPattern.PATTERN_TYPE_BROKEN_TWILL;
      default:
        return null;
    }
  }

  Palette convertJttPaletteTypeToGtt(Map<String?, List<String>> palettes) {
    final name = palettes.keys.first;
    final colours = palettes.values.first
        .asMap()
        .entries
        .map((entry) => Colour(
              index: (entry.key + 1),
              text: _convertHexToColour(entry.value).toString(),
            ))
        .toList();
    return Palette(colour: colours, name: name, size: colours.length);
  }

  Picks convertJttTabletsTypeToGttPicks(final List<Tablet> deck) {
    var picks = <GttPick>[];
    var pickSize = deck[0].picks.length;
    for (var i = 0; i < pickSize; i++) {
      var actions = <Action>[];
      deck.asMap().forEach((tabletIndex, tablet) {
        final prevTwist =
            i == 0 ? tablet.startingTwist : tablet.picks[i - 1]!.twist;
        final pick = tablet.picks[i]!;
        final actionType = pick.twist != prevTwist ? Type.TWIST : Type.TURN;
        final turned = pick.turned == Tablet.TURNING_DIRECTION_FORWARDS
            ? Dir.F
            : pick.turned == Tablet.TURNING_DIRECTION_BACKWARDS
                ? Dir.B
                : Dir.I;
        actions.add(Action(
            type: actionType,
            dist: 1,
            dir: turned,
            targetId: (tabletIndex + 1).toString(),
            target: Target.CARD));
      });
      picks.add(GttPick(actions: Actions(actions), index: i));
    }
    return Picks(picks);
  }

  //Packs
  //for each group, filter tablets by group
  // group by direction
  //if groupby results in one group then add action pack to map by group name
  // filter tablets by not in group results
  // add card picks
  // add group picks

  Packs convertJttPacksToGtt(Map<String?, List<int?>?> jttPacks) {
    final gttPacksList = jttPacks.entries
        .map((entry) => Pack(
            name: entry.key,
            size: entry.value!.length,
            cardIndexs: entry.value))
        .toList();
    return Packs(packs: gttPacksList, count: gttPacksList.length);
  }

  void _processTurn(Action action, Tablet tablet, bool twist) {
    if (action.type == Type.TURN) {
      var turningDirection = Tablet.TURNING_DIRECTION_IDLE;
      if (action.dir == Dir.F) {
        turningDirection = Tablet.TURNING_DIRECTION_FORWARDS;
      } else if (action.dir == Dir.B) {
        turningDirection = Tablet.TURNING_DIRECTION_BACKWARDS;
      }
      tablet.turn(turningDirection, isTwist: twist);
    }
  }
}
