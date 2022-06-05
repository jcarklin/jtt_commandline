import 'dart:io';

import 'package:xml/xml.dart';

class TwData {
  String source;
  String version;
  GttPattern pattern;

  TwData({this.source = 'Guntram\'s Tabletweaving Thingy', 
  this.version = '1.x', required this.pattern});

  TwData.fromXml(XmlElement twDataElement) {
    source = twDataElement.getElement('Source')??.innerText;
    version = twDataElement.getElement('Version')!.innerText;
    pattern = GttPattern.fromXml(twDataElement.getElement('Pattern'));
  }

  String toXml() {
    final builder = XmlBuilder();
    //builder.processing('xml', 'version="1.0"');
    builder.element('TWData', nest: () {
      builder.element('Source', nest: () {
        builder.text(source!);
      });
      builder.element('Version', nest: () {
        builder.text(version!);
      });
      pattern!.toXml(builder);
    });
    return builder.buildDocument().toXmlString(pretty: true);
  }

  Future<String> toGttFile(String filename) {
    return Future.sync(() {
      return File(filename).writeAsString(toXml()).catchError(() {
        return 'Writing File $filename Failed!!';
      }).then((value) {
        return 'File $filename successfully written';
      });
    });
  }


  @override
  String toString() {
    return 'TwData{source: $source, version: $version, pattern: $pattern}';
  }


}

class GttPattern {

  static const String PATTERN_TYPE_THREADED = 'Threaded';
  static const String PATTERN_TYPE_DOUBLE_FACE = 'DoubleFace';
  static const String PATTERN_TYPE_BROKEN_TWILL = 'BrokenTwill';
  //Brocade, LetteredBand


  String? name;
  String? type;
  String? notes;
  Cards? cards;
  Packs? packs;
  Picks? picks;
  Palette? palette;

  GttPattern({this.name, this.notes, this.cards, this.packs, this.picks, this.palette,
    this.type,});

  GttPattern.fromXml(XmlElement patternElement) {
    name = patternElement.getElement('Name')!.innerText;
    type = patternElement.getAttribute('Type');
    notes = patternElement.getElement('Notes')!=null
        ? patternElement.getElement('Notes')?.descendants.map((e) =>
          e.innerText.trim()).join('\n').trim()
        : '';
    cards = Cards.fromXml(patternElement.getElement('Cards'));
    packs = Packs.fromXml(patternElement.getElement('Packs'));
    picks = Picks.fromXml(patternElement.getElement('Picks'));
    palette = Palette.fromXml(patternElement.getElement('Palette'));
  }

  void toXml(final XmlBuilder patternBuilder) {
    patternBuilder.element('Pattern', nest: () {
      patternBuilder.attribute('Type', type!);
      patternBuilder.element('Name', nest: () {
        patternBuilder.cdata(name!);
      });
      notes = (notes??'')+'\nExported from JTT';
      patternBuilder.element('Notes', nest: () {
        notes!.split('\n')
            .where((element) => element!=null && element.isNotEmpty)
            .toList().asMap().forEach((index,element) {
          patternBuilder.element('L${index+1}', nest: () {
            patternBuilder.cdata(element);
          });
        });
      });
      cards!.toXml(patternBuilder);
      packs ??= Packs(count: 0);
      packs!.toXml(patternBuilder);
      picks!.toXml(patternBuilder);
      palette!.toxml(patternBuilder);
    });
  }

  @override
  String toString() {
    return 'Pattern{name: $name, notes: $notes, cards: $cards, packs: $packs, '
        'picks: $picks, palette: $palette, type: $type}';
  }

}

class Cards {

  late List<Card> card;
  int? count;

  Cards(this.card) {
    count = card.length;
  }

  Cards.fromXml(XmlElement cardsXml) {
    count = int.tryParse(cardsXml.getAttribute('Count')!);
    card = cardsXml.findElements('Card').map((element) => Card.fromXml(element))
        .toList();
  }

  void toXml(final XmlBuilder builder) {
    builder.element('Cards', nest: () {
      builder.attribute('Count', count!);
      card.forEach((element) { 
        element.toXml(builder);
      });
    });
  }

  @override
  String toString() {
    return 'Cards{card: $card, count: $count}';
  }
}

class Card {

  Holes? holes;
  Threading? threading;
  Threading? curThread;
  String? curPos;
  Holes? curHoles;
  String? cardHoles;
  String? number;

  Card({
    this.holes,
    this.threading,
    this.curThread,
    this.curPos,
    this.curHoles,
    this.cardHoles,
    this.number,
  });

  Card.fromXml(XmlElement cardElement) {

    cardHoles = cardElement.getAttribute('Holes');
    number = cardElement.getAttribute('Number');
    holes = Holes.fromXml(cardElement.getElement('Holes')!);
    threading = cardElement.getElement('Threading')!.innerText == 'Z'
        ? Threading.Z
        : Threading.S;
    curThread = cardElement.getElement('CurThread')!.innerText == 'Z'
        ? Threading.Z
        : Threading.S;
    curPos = cardElement.getElement('CurThread')!.innerText;
    curHoles = Holes.fromXml(cardElement.getElement('CurHoles')!);

  }
  
  void toXml(XmlBuilder builder) {
    builder.element('Card', nest: () {
      builder.attribute('Holes', cardHoles!);
      builder.attribute('Number', number!);
      holes!.toXml(builder, 'Holes');
      builder.element('Threading', nest: () {
        builder.text(threading==Threading.S?'S':'Z');
      });
      builder.element('CurThread', nest: () {
        builder.text(curThread==Threading.S?'S':'Z');
      });
      builder.element('CurPos', nest: () {
        builder.text(curPos!);
      });
      holes!.toXml(builder, 'CurHoles');
    });
  }

  @override
  String toString() {
    return 'Card{holes: $holes, threading: $threading, curThread: $curThread, '
        'curPos: $curPos, curHoles: $curHoles, '
        'cardHoles: $cardHoles, number: $number}';
  }
}

class Holes {

  List<int?>? colour;
  int? count;

  Holes({
    this.colour,
    this.count,
  });

  Holes.fromXml(XmlElement holesElement) {
    count = int.tryParse(holesElement.getAttribute('Count')!);
    colour = holesElement.findElements('Colour').map((e) => int.tryParse(e.innerText)).toList();
  }


  void toXml(XmlBuilder builder, String name) {
    builder.element(name, nest: () {
      builder.attribute('Count', count!);
      colour!.asMap().forEach((index, element) {
        builder.element('Colour', nest: () {
          builder.text(colour![index]!);
        });
      });
    });
  }

  @override
  String toString() {
    return 'Holes{colour: $colour, count: $count}';
  }

}

class Packs {
  List<Pack>? packs;
  int? count;

  Packs({
    this.packs,
    this.count,
  });

  Packs.fromXml(XmlElement packsElement) {
    count = int.tryParse(packsElement.getAttribute('Count')!);
    packs = packsElement.findElements('Pack').map((e) => Pack.fromXml(e)).toList();
  }

  void toXml(final XmlBuilder builder) {
    builder.element('Packs', nest: () {
      builder.attribute('Count', count!);
      if (packs!=null) {
        packs!.forEach((element) {
          element.toXml(builder);
        });
      }
    });
  }

  @override
  String toString() {
    return 'Packs{packs: $packs, count: $count}';
  }
}

class Pack {
  String? name;
  String? comment;
  int? size;
  List<int?>? cardIndexs;

  Pack({this.name, this.comment, this.size, this.cardIndexs});

  Pack.fromXml(XmlElement packElement) {
    name = packElement.getAttribute('Name');
    comment = packElement.getElement('Comment')!.innerText;
    size = int.tryParse(packElement.getElement('Size')!.innerText);
    cardIndexs = packElement.getElement('Cards')!.innerText
        .split(',')
        .map((element) => int.tryParse(element)).toList();
  }
  
  void toXml(XmlBuilder builder) {
    builder.element('Pack', nest: () {
      builder.attribute('Name', name!);
      builder.element('Comment', nest: () {
        builder.cdata(comment??'');
      });
      builder.element('Size', nest: () {
        builder.text(size!);
      });
      builder.element('Cards', nest: () {
        builder.text(cardIndexs!.join(','));
      });
    });
  }

  @override
  String toString() {
    return 'Pack{name: $name, comment: $comment, size: $size, cards: $cardIndexs}';
  }

}

class Palette {
  List<Colour>? colour;
  String? name;
  int? size;

  Palette({
    this.colour,
    this.name,
    this.size,
  });

  Palette.fromXml(XmlElement paletteElement) {
    name = paletteElement.getAttribute('Name');
    size = int.tryParse(paletteElement.getAttribute('Size')!);
    colour = paletteElement.findElements('Colour').map((e) => Colour.fromXml(e)).toList();
  }


  void toxml(XmlBuilder patternBuilder) {
    patternBuilder.element('Palette', nest: () {
      patternBuilder.attribute('Name', name!);
      patternBuilder.attribute('Size', size!);
      colour!.forEach((element) { 
        patternBuilder.element('Colour', nest: () {
          patternBuilder.attribute('Index', element.index!);
          patternBuilder.text(element.text!);
        });
      });
    });
  }
  
  @override
  String toString() {
    return 'Palette{colour: $colour, name: $name, size: $size}';
  }

}

class Colour {
  int? index;
  String? text;

  Colour({
    this.index,
    this.text,
  });

  Colour.fromXml(XmlElement colourElement) {
    index = int.tryParse(colourElement.getAttribute('Index')!);
    text = colourElement.innerText;
  }

  @override
  String toString() {
    return 'Colour{index: $index, text: $text}';
  }
}

class Picks {

  List<GttPick>? pickList;

  Picks(this.pickList);

  Picks.fromXml(XmlElement picksElement) {
    pickList = picksElement.findElements('Pick').map((element) => GttPick.fromXml(element))
        .toList();
  }

  void toXml(XmlBuilder patternBuilder) {
    patternBuilder.element('Picks', nest: () {
      patternBuilder.attribute('Count', pickList!.length);
      pickList!.forEach((element) {
        element.toXml(patternBuilder);
      });
    });
  }

}

class GttPick {

  Actions? actions;
  int? index;

  GttPick({this.actions, this.index});

  GttPick.fromXml(XmlElement pickElement) {
    index = int.tryParse(pickElement.getAttribute('Index')!);
    actions = Actions.fromXml(pickElement.getElement('Actions')!);
  }

  void toXml(XmlBuilder patternBuilder) {
    patternBuilder.element('Pick', nest: () {
      patternBuilder.attribute('Index', index!);
      actions!.toXml(patternBuilder);
    });
  }
}

class Actions {

  late List<Action> action;
  int? count;

  Actions(this.action) {
   count = action.length;
  }

  Actions.fromXml(XmlElement actionsElement) {
    count = int.tryParse(actionsElement.getAttribute('Count')!);
    action = actionsElement.findElements('Action').map((e) => Action.fromXml(e)).toList();
  }

  void toXml(XmlBuilder patternBuilder) {
    patternBuilder.element('Actions', nest: () {
      patternBuilder.attribute('Count', count!);
      action.forEach((element) {
        element.toXml(patternBuilder);
      });
    });
  }

}

class Action {

  Type? type;
  Target? target;
  dynamic targetId;
  Dir? dir;
  int? dist;

  Action({
    this.type,
    this.target,
    this.targetId,
    this.dir,
    this.dist,
  });

  Action.fromXml(XmlElement actionElement) {
    type = actionElement.getAttribute('Type')=='Turn'?Type.TURN:Type.TWIST;
    target = actionElement.getAttribute('Target')=='Pack'?Target.PACK:Target.CARD;
    final tid = actionElement.getAttribute('TargetID')!;
    targetId = int.tryParse(tid)??tid;
    switch(actionElement.getAttribute('Dir')) {
      case 'F':
        dir = Dir.F;
        break;
      case 'B':
        dir = Dir.B;
        break;
      default:
        dir = Dir.I;
    }
    dist = int.tryParse(actionElement.getAttribute('Dir')!);
  }

  void toXml(XmlBuilder patternBuilder) {
    patternBuilder.element('Action', nest: () {
      patternBuilder.attribute('Type', type==Type.TURN?'Turn':'Twist');
      patternBuilder.attribute('Target', target==Target.PACK?'Pack':'Card');
      patternBuilder.attribute('TargetID', targetId);
      patternBuilder.attribute('Dir', dir==Dir.F?'F':dir==Dir.B?'B':'I');
      patternBuilder.attribute('Dist', dist!);
    });
  }

}

enum Dir { F, B, I }
enum Target { CARD,PACK }
enum Type { TURN,TWIST }
enum Threading { Z, S }
