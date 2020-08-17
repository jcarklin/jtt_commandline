import 'package:xml/xml.dart';

class TwData {
  String source;
  String version;
  Pattern pattern;

  TwData({this.source, this.version, this.pattern});

  TwData.fromXml(XmlElement twDataElement) {
    source = twDataElement.getElement('Source').innerText;
    version = twDataElement.getElement('Version').innerText;
    pattern = Pattern.fromXml(twDataElement.getElement('Pattern'));
  }

  @override
  String toString() {
    return 'TwData{source: $source, version: $version, pattern: $pattern}';
  }
}

class Pattern {
  String name;
  String type;
  String notes;
  Cards cards;
  Packs packs;
  Picks picks;
  Palette palette;

  Pattern({this.name, this.notes, this.cards, this.packs, this.picks, this.palette,
    this.type,});

  Pattern.fromXml(XmlElement patternElement) {
    name = patternElement.getElement('Name').innerText;
    type = patternElement.getAttribute('Type');
    notes = patternElement.getElement('Notes').descendants.map((e) =>
        e.innerText.trim()).join(' ').trim();
    cards = Cards.fromXml(patternElement.getElement('Cards'));
    packs = Packs.fromXml(patternElement.getElement('Packs'));
    picks = Picks.fromXml(patternElement.getElement('Picks'));
    palette = Palette.fromXml(patternElement.getElement('Palette'));
  }

  @override
  String toString() {
    return 'Pattern{name: $name, notes: $notes, cards: $cards, packs: $packs, '
        'picks: $picks, palette: $palette, type: $type}';
  }
}

class Cards {

  List<Card> card;
  String count;

  Cards({this.card, this.count});

  Cards.fromXml(XmlElement cardsXml) {
    count = cardsXml.getAttribute('Count');
    card = cardsXml.findElements('Card').map((element) => Card.fromXml(element))
        .toList();
  }

  @override
  String toString() {
    return 'Cards{card: $card, count: $count}';
  }
}

class Card {

  Holes holes;
  Threading threading;
  Threading curThread;
  String curPos;
  Holes curHoles;
  String cardHoles;
  String number;

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
    holes = Holes.fromXml(cardElement.getElement('Holes'));
    threading = cardElement.getElement('Threading').innerText == 'Z'
        ? Threading.Z
        : Threading.S;
    curThread = cardElement.getElement('CurThread').innerText == 'Z'
        ? Threading.Z
        : Threading.S;
    curPos = cardElement.getElement('CurThread').innerText;
    curHoles = Holes.fromXml(cardElement.getElement('CurHoles'));

  }

  @override
  String toString() {
    return 'Card{holes: $holes, threading: $threading, curThread: $curThread, '
        'curPos: $curPos, curHoles: $curHoles, '
        'cardHoles: $cardHoles, number: $number}';
  }
}

class Holes {

  List<String> colour;
  String count;

  Holes({
    this.colour,
    this.count,
  });

  Holes.fromXml(XmlElement holesElement) {
    count = holesElement.getAttribute('Count');
    colour = holesElement.findElements('Colour').map((e) => e.innerText).toList();
  }

  @override
  String toString() {
    return 'Holes{colour: $colour, count: $count}';
  }
}

class Packs {
  List<Pack> packs;
  String count;

  Packs({
    this.packs,
    this.count,
  });

  Packs.fromXml(XmlElement packsElement) {
    count = packsElement.getAttribute('Count');
    packs = packsElement.findElements('Pack').map((e) => Pack.fromXml(e)).toList();
  }

  @override
  String toString() {
    return 'Packs{packs: $packs, count: $count}';
  }
}

class Pack {
  String name;
  String comment;
  String size;
  List<int> cardIndexs;

  Pack({this.name, this.comment, this.size, this.cardIndexs});

  Pack.fromXml(XmlElement packElement) {
    name = packElement.getAttribute('name');
    comment = packElement.getElement('Comment').innerText;
    size = packElement.getElement('Size').innerText;
    cardIndexs = packElement.getElement('Cards').innerText
        .split(',')
        .map((element) => int.tryParse(element));
  }

  @override
  String toString() {
    return 'Pack{name: $name, comment: $comment, size: $size, cards: $cardIndexs}';
  }
}

class Palette {
  List<Colour> colour;
  String name;
  String size;

  Palette({
    this.colour,
    this.name,
    this.size,
  });

  Palette.fromXml(XmlElement paletteElement) {
    name = paletteElement.getAttribute('Name');
    size = paletteElement.getAttribute('Size');
    colour = paletteElement.findElements('Colour').map((e) => Colour.fromXml(e)).toList();
  }

  @override
  String toString() {
    return 'Palette{colour: $colour, name: $name, size: $size}';
  }
}

class Colour {
  String index;
  String text;

  Colour({
    this.index,
    this.text,
  });

  Colour.fromXml(XmlElement colourElement) {
    index = colourElement.getAttribute('Index');
    text = colourElement.innerText;
  }

  @override
  String toString() {
    return 'Colour{index: $index, text: $text}';
  }
}

class Picks {

  List<Pick> pick;
  String count;

  Picks({this.pick, this.count});

  Picks.fromXml(XmlElement picksElement) {
    count = picksElement.getAttribute('Count');
    pick = picksElement.findElements('Pick').map((element) => Pick.fromXml(element))
        .toList();
  }
}

class Pick {

  Actions actions;
  String index;

  Pick({this.actions, this.index});

  Pick.fromXml(XmlElement pickElement) {
    index = pickElement.getAttribute('Index');
    actions = Actions.fromXml(pickElement.getElement('Actions'));
  }
}

class Actions {

  List<Action> action;
  String count;

  Actions({this.action, this.count,});

  Actions.fromXml(XmlElement actionsElement) {
    count = actionsElement.getAttribute('Count');
    action = actionsElement.findElements('Action').map((e) => Action.fromXml(e)).toList();
  }

}

class Action {

  Type type;
  Target target;
  String targetId;
  Dir dir;
  int dist;

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
    targetId = actionElement.getAttribute('TargetID');
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
    dist = int.tryParse(actionElement.getAttribute('Dir'));
  }

}

enum Dir { F, B, I }
enum Target { CARD,PACK }
enum Type { TURN,TWIST }
enum Threading { Z, S }
