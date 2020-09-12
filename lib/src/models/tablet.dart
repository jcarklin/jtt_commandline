import 'dart:convert';

import 'thread.dart';

class Tablet {
  final ThreadingDirection threadingDirection;
  final List<Thread> threadPositions;
  final Twist startingTwist;
  final List<Pick> picks;
  final pickCache = {};
  final int deckIndex;

  Tablet(this.threadingDirection, this.threadPositions, this.startingTwist, this.deckIndex)
      : picks = <Pick>[];

  Tablet.fromJson(Map<String, dynamic> json)
      : deckIndex = json['index'],
        threadingDirection = json['threadingDirection'],
        threadPositions = json['threadPositions'],
        startingTwist = json['startingTwist'],
        picks = json['picks'];

  Map<String, dynamic> toJson() {
    return {
      'index': deckIndex,
      'threadingDirection': threadingDirection != null
          ? threadingDirection.toString() : null,
      'threadPositions': threadPositions != null
          ? threadPositions.map((e) => e.toJson()).toList() : null,
      'startingTwist': startingTwist != null ? startingTwist.toString() : null,
      'picks': picks != null ? picks.map((e) => e.toJson()).toList() : null
    };
  }

  void turn(TurningDirection turningDirection, {bool isTwist}) {
    var lastVisible = lastPick.visibleThread.index;
    var lastTwist = lastPick.twist;
    final newTwist = (isTwist ?? false) ? lastTwist==Twist.Z ? Twist.S
        : Twist.Z : lastTwist;
    final newVisible = turningDirection==TurningDirection.forwards
        ? (lastVisible == threadPositions.length-1 ? 0 : lastVisible+1)
        : turningDirection==TurningDirection.backwards
        ? (lastVisible == 0 ? threadPositions.length-1 : lastVisible-1)
        : lastVisible;

    _addPick(newTwist, turningDirection, newVisible);
  }

  Pick get lastPick => picks.isEmpty ? Pick(startingTwist,TurningDirection.idle, threadPositions[0]) : picks.last;

  Pick _addPick(Twist newTwist, TurningDirection turningDirection, int newVisible) {
    final pickKey = (newTwist==Twist.S ? 'S' : 'Z')+(turningDirection == null ? 'I'
        : turningDirection==TurningDirection.forwards ? 'F'
        : turningDirection==TurningDirection.backwards ? 'B'
        : 'I')+(newVisible.toString());
    pickCache.putIfAbsent(pickKey, () => Pick(newTwist, turningDirection, threadPositions[newVisible]));
    picks.add(pickCache[pickKey]);
    return lastPick;
  }

  @override
  String toString() {
    return json.encode(this);
  }
}

class Pick {
  final Twist twist; //S or Z
  final TurningDirection turned; //forwards or backwards or float
  final Thread visibleThread; //This is the index of the Thread which is visible on the weaving.

  Pick(this.twist, this.turned, this.visibleThread);

  Pick.fromJson(Map<String, dynamic> json)
      : twist = json['twist'],
        turned = json['turned'],
        visibleThread = json['visibleIndex'];

  Map<String, dynamic> toJson() => {
        'twist': twist != null
            ? twist==Twist.S
              ? 'S' : 'Z'
            : null,
        'turned': turned == null ? 'I'
            : turned==TurningDirection.forwards ? 'F'
            : turned==TurningDirection.backwards ? 'B'
            : 'I',
        'visibleIndex': visibleThread.index,
      };

  String get pickKey => (twist==Twist.S ? 'S' : 'Z')+(turned == null ? 'I'
            : turned==TurningDirection.forwards ? 'F'
            : turned==TurningDirection.backwards ? 'B'
            : 'I')+(visibleThread.index.toString());

  @override
  String toString() {
    return json.encode(this);
  }

}

enum ThreadingDirection {
  clockwise, //DA CB
  anticlockwise, //AD BC
  poles // TF TB BF BB,
}

enum TurningDirection {
  forwards, // Away from the weaver
  backwards, // Towards the weaver
  idle, // Skipping turn
}

enum Twist {
  S,
  Z,
}
