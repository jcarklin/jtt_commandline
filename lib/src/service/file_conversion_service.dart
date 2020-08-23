import 'package:hex/hex.dart';
import 'package:jtt_commandline/jtt_commandline.dart';
import 'package:jtt_commandline/src/models/gtt_project.dart';
import 'package:jtt_commandline/src/models/project.dart';
import 'package:xml/xml.dart';

class FileConversionService {

  TwData _twData;
  Project _jttProject;

  FileConversionService.fromGtt(String gttXml) {
    if (gttXml != null) {
      _twData = _fromGttXml(gttXml);
      _jttProject = _fromTwData(_twData);
    }
  }

  FileConversionService.fromJtt(String jttJson) {
    if (jttJson != null) {
      _jttProject = _fromJttJson(jttJson);
      _twData = _fromJttProject(_jttProject);
    }
  }

  TwData get gttTWdata => _twData;

  Project get jttProject => _jttProject;

  //Todo String get gttTWdataXml => _twData.gttXml;

  //Todo String get jttJson => jsonEncode(_jttProject);

  TwData _fromGttXml(String xmlInput) {
    final document = XmlDocument.parse(xmlInput);
    return TwData.fromXml(document.getElement('TWData'));
  }

  Project _fromTwData(TwData twData) {
    final jttProject = Project(ProjectType.tabletWeaving,patternSource: twData.source);
    final gttPattern = twData.pattern;
    switch(gttPattern.type.toLowerCase()) {
      case 'threaded':
        jttProject.patternType = PatternType.threadedIn;
        break;
      case 'doubleface'://|BrokenTwill|Brocade|LetteredBand}>'
        jttProject.patternType = PatternType.doubleWeave;
        break;
      default:
        throw FormatException('Unsupported Pattern Type');
    }

    final gttCards = gttPattern.cards.card;
    jttProject.deck = gttCards.map((e) => _convertGttCardToTablet(e)).toList();
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

  Tablet _convertGttCardToTablet(Card gttCard) {
    return Tablet(ThreadingDirection.anticlockwise, _convertGttHolesToThreads(gttCard.holes),
        gttCard.threading==Threading.S?Twist.S:Twist.Z);
  }

  List<Thread> _convertGttHolesToThreads(Holes holes) {
    //TODO  map colour index to hex colour code using palette
    return holes.colour.asMap().entries.map((e) => Thread(e.key, e.value))
        .toList(growable: false);
  }

  void _processTurn(Action action, Tablet tablet, bool twist) {

    if (action.type==Type.TURN) {
      var turningDirection = TurningDirection.float;
      if (action.dir==Dir.F) {
        turningDirection = TurningDirection.forwards;
      } else if (action.dir==Dir.B) {
        turningDirection = TurningDirection.backwards;
      }
      tablet.turn(turningDirection,isTwist: twist);
    }
  }

  TwData _fromJttProject(Project jttProject) {
//todo
    return null;
  }

  Project _fromJttJson(String jttJson) {
    //todo
    return null;
  }
}



