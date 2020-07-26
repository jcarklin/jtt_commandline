import 'package:xml/xml.dart';

class GttConversion {
  final TwData _twData = TwData();

  GttConversion({String xmlInput}) {
    if (xmlInput != null) {
      _fromXml(xmlInput);
    }
  }

  void _fromXml(String xmlInput) {
    final document = XmlDocument.parse(xmlInput);
    final twDataElement = document.getElement('TWData');
    _twData.source = twDataElement.getElement('Source').innerText;
    _twData.version = twDataElement.getElement('Version').innerText;
    final patternElement = twDataElement.getElement('Pattern');
    _twData.pattern = Pattern(
      name: patternElement.getElement('Name').innerText,
      type: patternElement.getAttribute('Type'),
    );
    _twData.pattern.notes = patternElement
        .getElement('Notes')
        .descendants
        .map((e) => e.innerText.trim())
        .join(' ')
        .trim();

    var el = patternElement.getElement('Cards');
    _twData.pattern.cards = Cards(
        card: el
            .findElements('Card')
            .map((element) => _createCard(element))
            .toList(),
        count: el.getAttribute('Count'));

    el = patternElement.getElement('Packs');
    if (el.getAttribute('Count') != '0') {
      _twData.pattern.packs = Packs(
        packs: el.findElements('Pack').map((e) => _createPack(e)).toList(),
        count: el.getAttribute('Count'),
      );
    }

    el = patternElement.getElement('Palette');
    _twData.pattern.palette = Palette(
      name: el.getAttribute('Name'),
      size: el.getAttribute('Size'),
      colour: el.findElements('Colour').map((e) {
        return Colour(index: e.getAttribute('Index'), text: e.innerText);
      }).toList(),
    );
    print(_twData);
  }

  Card _createCard(XmlElement cardElement) {
    XmlElement innerEl;
    var card = Card(
        cardHoles: cardElement.getAttribute('Holes'),
        number: cardElement.getAttribute('Number'));
    innerEl = cardElement.getElement('Holes');
    card.holes = Holes(colour: [], count: innerEl.getAttribute('Count'));
    innerEl.findElements('Colour').forEach((element) {
      card.holes.colour.add(element.innerText);
    });
    card.threading = cardElement.getElement('Threading').innerText == 'Z'
        ? Threading.Z
        : Threading.S;
    card.curThread = cardElement.getElement('CurThread').innerText == 'Z'
        ? Threading.Z
        : Threading.S;
    card.curPos = cardElement.getElement('CurThread').innerText;
    innerEl = cardElement.getElement('CurHoles');
    card.curHoles = Holes(colour: [], count: innerEl.getAttribute('Count'));
    innerEl.findElements('Colour').forEach((element) {
      card.curHoles.colour.add(element.innerText);
    });
    return card;
  }

  Pack _createPack(XmlElement packElement) {
    return Pack(
        name: packElement.getAttribute('name'),
        comment: packElement.getElement('Comment').innerText,
        size: packElement.getElement('Size').innerText,
        cards: packElement.getElement('Cards').innerText,
    );
  }
}

class TwData {
  String source;
  String version;
  Pattern pattern;

  TwData({
    this.source,
    this.version,
    this.pattern,
  });

  @override
  String toString() {
    return 'TwData{source: $source, version: $version, pattern: $pattern}';
  }
}

class Pattern {
  String name;
  String notes;
  Cards cards;
  Packs packs;
  Picks picks;
  Palette palette;
  String type;

  Pattern({
    this.name,
    this.notes,
    this.cards,
    this.packs,
    this.picks,
    this.palette,
    this.type,
  });

  @override
  String toString() {
    return 'Pattern{name: $name, notes: $notes, cards: $cards, packs: $packs, '
        'picks: $picks, palette: $palette, type: $type}';
  }
}

class Cards {
  Cards({
    this.card,
    this.count,
  });

  List<Card> card;
  String count;

  @override
  String toString() {
    return 'Cards{card: $card, count: $count}';
  }
}

class Card {
  Card({
    this.holes,
    this.threading,
    this.curThread,
    this.curPos,
    this.curHoles,
    this.cardHoles,
    this.number,
  });

  Holes holes;
  Threading threading;
  Threading curThread;
  String curPos;
  Holes curHoles;
  String cardHoles;
  String number;

  @override
  String toString() {
    return 'Card{holes: $holes, threading: $threading, curThread: $curThread, '
        'curPos: $curPos, curHoles: $curHoles, '
        'cardHoles: $cardHoles, number: $number}';
  }
}

class Holes {
  Holes({
    this.colour,
    this.count,
  });

  List<String> colour;
  String count;

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

  @override
  String toString() {
    return 'Packs{packs: $packs, count: $count}';
  }
}

class Pack {
  String name;
  String comment;
  String size;
  String cards;

  Pack({this.name, this.comment, this.size, this.cards});

  @override
  String toString() {
    return 'Pack{name: $name, comment: $comment, size: $size, cards: $cards}';
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

  @override
  String toString() {
    return 'Colour{index: $index, text: $text}';
  }
}

class Picks {
  Picks({
    this.pick,
    this.count,
  });

  List<Pick> pick;
  String count;
}

class Pick {
  Pick({
    this.actions,
    this.index,
  });

  Actions actions;
  String index;
}

class Actions {
  Actions({
    this.action,
    this.count,
  });

  List<Action> action;
  String count;
}

class Action {
  Action({
    this.type,
    this.target,
    this.targetId,
    this.dir,
    this.dist,
  });

  Type type;
  Target target;
  String targetId;
  Dir dir;
  String dist;
}

enum Dir { F, B }
enum Target { CARD }
enum Type { TURN }
enum Threading { Z, S }
