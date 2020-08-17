import 'dart:convert';

import 'thread.dart';

class Tablet {
  final ThreadingDirection threadingDirection;
  final List<Thread> threadPositions;
  final Twist startingTwist;
  final List<Pick> picks;

  // query: pick cache?

  Tablet(this.threadingDirection, this.threadPositions, this.startingTwist)
      : picks = <Pick>[];

  Tablet.fromJson(Map<String, dynamic> json)
      : threadingDirection = json['threadingDirection'],
        threadPositions = json['threadPositions'],
        startingTwist = json['startingTwist'],
        picks = json['picks'];

  Map<String, dynamic> toJson() {
    return {
      'threadingDirection': threadingDirection != null
          ? jsonEncode(threadingDirection.toString()) : null,
      'threadPositions': threadPositions != null
          ? threadPositions.map((e) => e.toJson()).toList() : null,
      'startingTwist': startingTwist != null ? jsonEncode(startingTwist.toString()) : null,
      'picks': picks != null ? picks.map((e) => e.toJson()).toList() : null
    };
  }

  void turn(TurningDirection turningDirection, {bool isTwist}) {
    var lastVisible = lastPick.visibleIndex;
    var lastTwist = lastPick.twist;
    final newTwist = isTwist ?? false == false ? lastTwist :
      lastTwist==Twist.Z ? Twist.S : Twist.Z;
    final newVisible = turningDirection==TurningDirection.forwards
        ? (lastVisible == threadPositions.length-1 ? 0 : lastVisible+1)
        : turningDirection==TurningDirection.backwards
        ? (lastVisible == 0 ? threadPositions.length-1 : lastVisible-1)
        : lastVisible;
    picks.add(Pick(newTwist, turningDirection, newVisible));
  }

  Pick get lastPick => picks.isEmpty ? Pick(startingTwist,TurningDirection.float, 0) : picks.last;

  @override
  String toString() {
    return json.encode(this);
  }
}

class Pick {
  final Twist twist; //S or Z
  final TurningDirection turned; //forwards or backwards or float
  final int visibleIndex; //This is the index of the Thread which is visible on the weaving.

  Pick(this.twist, this.turned, this.visibleIndex);

  Pick.fromJson(Map<String, dynamic> json)
      : twist = json['twist'],
        turned = json['turned'],
        visibleIndex = json['visibleIndex'];

  Map<String, dynamic> toJson() => {
        'twist': twist != null ? jsonEncode(twist.toString()) : null,
        'turned': turned != null ? jsonEncode(turned.toString()) : null,
        'visibleIndex': jsonEncode(visibleIndex ?? 0),
      };

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
  float, // Skipping turn
}

enum Twist {
  S,
  Z,
}
