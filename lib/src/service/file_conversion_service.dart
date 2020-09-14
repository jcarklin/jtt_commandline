import 'dart:convert';
import 'dart:io';

import 'package:hex/hex.dart';
import 'package:jtt_commandline/jtt_commandline.dart';
import 'package:jtt_commandline/src/models/gtt_project.dart';
import 'package:jtt_commandline/src/models/project.dart';
import 'package:xml/xml.dart';

class FileConversionService {

  TwData _twData;
  Project _jttProject;
  File gttFile;
  File jttFile;

  FileConversionService.fromGtt(File gttXml) {
    gttFile = gttXml;
    if (gttFile != null) {
      _twData = _fromGttXml(gttFile.readAsStringSync());
      _jttProject = _fromTwData();
    }
  }

  FileConversionService.fromJtt(File jttJson) {
    jttFile = jttJson;
    
    if (jttJson != null) {
      _jttProject = _fromJttJson(jttJson.readAsStringSync());
      _twData = _fromJttProject();
    }
  }

  TwData get gttTWdata => _twData;

  Project get jttProject => _jttProject;

  
  TwData _fromGttXml(String xmlInput) {
    final document = XmlDocument.parse(xmlInput);
    return TwData.fromXml(document.getElement('TWData'));
  }

  Project _fromTwData() {
    final jttProject = Project(
        gttTWdata.pattern.name,
        Project.PROJECT_TYPE_TABLET_WEAVING,
        patternSource: gttTWdata.source,
        slantRepresentation: Project.SLANT_THREAD);
    final gttPattern = gttTWdata.pattern;
    switch(gttPattern.type.toLowerCase()) {
      case 'threaded':
        jttProject.patternType = Project.PATTERN_TYPE_THREADED_IN;
        break;
      case 'doubleface'://|BrokenTwill|Brocade|LetteredBand}>'
        jttProject.patternType = Project.PATTERN_TYPE_DOUBLE_WEAVE;
        break;
      default:
        throw FormatException('Unsupported Pattern Type');
    }

    final gttCards = gttPattern.cards.card;
    jttProject.deck=List(gttCards.length);
    gttCards.asMap().forEach((k,v) => jttProject.deck[k]=_convertGttCardToTablet(k,v));
    final gttPacksMap = <String,List<int>>{};
    gttPattern.packs.packs.forEach((pack) => gttPacksMap[pack.name] = pack.cardIndexs);
    jttProject.palettes = {gttPattern.palette.name : gttPattern.palette.colour
        .map((e) => convertColorToHex(int.tryParse(e.text))).toList()};
    final gttPicks = gttPattern.picks.pick;


    gttPicks.forEach((actionParent) {
      final actions = actionParent.actions.action;

      final twists = <int>{};
      actions.forEach((action) {
        if (action.type==Type.TWIST) {
          if (action.target==Target.CARD) {
            twists.add(int.tryParse(action.targetId));
          } else if (action.target==Target.PACK) {
            gttPacksMap[action.targetId].forEach(
                    (element) => twists.add(element));
          }
        }
      });

      actions.forEach((action) {
        if (action.target==Target.CARD) {
          _processTurn(action, jttProject.deck[int.tryParse(action.targetId)-1], twists.contains(action.targetId));
        } else if (action.target==Target.PACK) {
          gttPacksMap[action.targetId].forEach((element) => _processTurn(
              action, jttProject.deck[element-1], twists.contains(element)));
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
    var cards = List<Card>(jttProject.deck.length);
    jttProject.deck.asMap().forEach((index,tablet) => cards[index]=_convertJttTabletToGttCard(tablet));
    var pattern = Pattern(
        name: jttProject.name,
        notes: 'Converted fro JTT file',
        cards: Cards(
            card: cards,
            count: '${jttProject.deck.length}'),
        type: jttProject.type,
    );
    return TwData(
        source: jttProject.patternSource,
        version: '1.15',
        pattern: pattern);

  }
  
  Future<String> writeAsJttFile() {
    return jttProject.toJttFile('${gttFile.path.replaceAll('gtt', 'jtt')}');
  }

  String writeAsGttFile() {
    return gttTWdata.toGttFile('${jttFile.path.replaceAll('jtt', 'gtt')}');
  }

  String convertColorToHex(int colorDec) {
    var r = colorDec & 0xff;
    var g = (colorDec >> 8)  & 0xff;
    var b = (colorDec >> 16) & 0xff;
    r = (r<0)?-r:r;
    g = (g<0)?-g:g;
    b = (b<0)?-b:b;
    r = (r>255)?255:r;
    g = (g>255)?255:g;
    b = (b>255)?255:b;
    return HEX.encode([r,g,b]);
  }

  Tablet _convertGttCardToTablet(int index, Card gttCard) {
    return Tablet(Tablet.THREADING_DIRECTION_ANTICLOCKWISE, _convertGttHolesToThreads(gttCard.holes),
        gttCard.threading==Threading.S?Tablet.TWIST_S:Tablet.TWIST_Z, index, []);
  }

  Card _convertJttTabletToGttCard(Tablet jttTablet) {
    var holes = _convertJttThreadsToGttHoles(jttTablet.threadPositions);
    var threading = jttTablet.startingTwist==Tablet.TWIST_S?Threading.S:Threading.Z;
    return Card(
        holes: holes,
        threading: threading,
        curThread: threading,
        curPos: '0',
        curHoles: holes,
        cardHoles: holes.colour.length.toString(),
        number: jttTablet.deckIndex.toString(),
        );
  }

  List<Thread> _convertGttHolesToThreads(Holes holes) {
    return holes.colour.asMap().entries.map((e) => Thread(e.key, e.value))
        .toList(growable: false);
  }

  Holes _convertJttThreadsToGttHoles(List<Thread> threads) {
    return  Holes(
        colour: threads.map((e) => e.colourIndex).toList(),
        count: threads.length.toString());
  }

  void _processTurn(Action action, Tablet tablet, bool twist) {

    if (action.type==Type.TURN) {
      var turningDirection = Tablet.TURNING_DIRECTION_IDLE;
      if (action.dir==Dir.F) {
        turningDirection = Tablet.TURNING_DIRECTION_FORWARDS;
      } else if (action.dir==Dir.B) {
        turningDirection = Tablet.TURNING_DIRECTION_BACKWARDS;
      }
      tablet.turn(turningDirection,isTwist: twist);
    }
  }
  
}



