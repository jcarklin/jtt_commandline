import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'thread.dart';

part 'tablet.g.dart';

@JsonSerializable()
class Tablet {

  static const String THREADING_DIRECTION_CLOCKWISE = 'clockwise'; //DA CB
  static const String THREADING_DIRECTION_ANTICLOCKWISE = 'anticlockwise'; //AD BC
  static const String THREADING_DIRECTION_POLES = 'poles'; // TF TB BF BB

  static const String TURNING_DIRECTION_FORWARDS = 'F'; // Away from the weaver
  static const String TURNING_DIRECTION_BACKWARDS = 'B';// Towards the weaver
  static const String TURNING_DIRECTION_IDLE= 'I'; // Skipping turn

  static const String TWIST_Z = 'Z';
  static const String TWIST_S = 'S';

  final String threadingDirection;
  final List<Thread> threadPositions;
  final String startingTwist;
  final List<Pick> picks;
  final pickCache = {};
  final int deckIndex;

  Tablet(this.threadingDirection, this.threadPositions, this.startingTwist,
      this.deckIndex, this.picks);

  factory Tablet.fromJson(Map<String, dynamic> json) => _$TabletFromJson(json);

  Map<String, dynamic> toJson() => _$TabletToJson(this);

  void turn(String turningDirection, {bool isTwist}) {
    var lastVisible = lastPick.visibleThread.index;
    var lastTwist = lastPick.twist;
    final newTwist = (isTwist ?? false)
        ? lastTwist==TWIST_Z ? TWIST_S : TWIST_Z
        : lastTwist;
    final newVisible = turningDirection==TURNING_DIRECTION_FORWARDS
        ? (lastVisible == threadPositions.length-1 ? 0 : lastVisible+1)
        : turningDirection==TURNING_DIRECTION_BACKWARDS
        ? (lastVisible == 0 ? threadPositions.length-1 : lastVisible-1)
        : lastVisible;

    _addPick(newTwist, turningDirection, newVisible);
  }

  Pick get lastPick => picks.isEmpty ? Pick(startingTwist,TURNING_DIRECTION_IDLE, threadPositions[0]) : picks.last;

  Pick _addPick(String newTwist, String turningDirection, int newVisible) {
    final pickKey = '$newTwist$turningDirection$newVisible';
    pickCache.putIfAbsent(pickKey, () => Pick(newTwist, turningDirection, threadPositions[newVisible]));
    picks.add(pickCache[pickKey]);
    return lastPick;
  }

  @override
  String toString() {
    return json.encode(this);
  }
}

@JsonSerializable()
class Pick {
  final String twist; //S or Z
  final String turned; //forwards or backwards or float
  final Thread visibleThread; //This is the index of the Thread which is visible on the weaving.

  Pick(this.twist, this.turned, this.visibleThread);

  factory Pick.fromJson(Map<String, dynamic> json) => _$PickFromJson(json);

  Map<String, dynamic> toJson() => _$PickToJson(this);

  String get pickKey => '$twist$turned${visibleThread.index}';

  @override
  String toString() {
    return json.encode(this);
  }

}


