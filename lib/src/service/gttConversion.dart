

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
    var el = patternElement.getElement('Notes');
    _twData.pattern.notes = el.descendants.map((e) => e.innerText.trim()).join(' ').trim();
    el = patternElement.getElement('Cards');
    Card card;
    XmlElement holesEl;
    final cards = el.findElements('Card').map((element) {
      card = Card(cardHoles: element.getAttribute('Holes'), number: element.getAttribute('Number'));
      holesEl = element.getElement('Holes');
      card.holes = Holes(colour: [],count: holesEl.getAttribute('Count'));
      holesEl.findElements('Colour').forEach((element) {
        card.holes.colour.add(element.innerText);
      });
      return card;
    }).toList();
    _twData.pattern.cards = Cards(card: cards, count: el.getAttribute('Count'));
    print(_twData);
  }




}


class TwData {
  TwData({
    this.source,
    this.version,
    this.pattern,
  });

  String source;
  String version;
  Pattern pattern;

  @override
  String toString() {
    return 'TwData{source: $source, version: $version, pattern: $pattern}';
  }
}

class Pattern {
  Pattern({
    this.name,
    this.notes,
    this.cards,
    this.packs,
    this.picks,
    this.palette,
    this.type,
  });

  String name;
  String notes;
  Cards cards;
  Packs packs;
  Picks picks;
  Palette palette;
  String type;

  @override
  String toString() {
    return 'Pattern{name: $name, notes: $notes, cards: $cards, packs: $packs, picks: $picks, palette: $palette, type: $type}';
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
  CurThread threading;
  CurThread curThread;
  String curPos;
  Holes curHoles;
  String cardHoles;
  String number;

  @override
  String toString() {
    return 'Card{holes: $holes, threading: $threading, curThread: $curThread, curPos: $curPos, curHoles: $curHoles, cardHoles: $cardHoles, number: $number}';
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

enum CurThread { Z, S }

class Packs {
  Packs({
    this.count,
  });

  String count;
}

class Palette {
  Palette({
    this.colour,
    this.name,
    this.size,
  });

  List<Colour> colour;
  String name;
  String size;
}

class Colour {
  Colour({
    this.index,
    this.text,
  });

  String index;
  String text;
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
