import 'dart:collection';
import 'thread.dart';

enum ThreadingDirection {
  clockwise, //DA CB
  anticlockwise,//AD BC
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


class Tablet {

  final ThreadingDirection _threadingDirection;
  final Pick _startingPosition;// query: Should be immutable?
  final List<Pick> _picks = <Pick>[];

  Tablet (this._threadingDirection, List<Thread>threading, Twist twist) :
    _startingPosition = Pick._create(twist, TurningDirection.float, threading);

  void turn(TurningDirection turningDirection) {
    _picks.add(Pick._turn(turningDirection,
        _picks.isEmpty?_startingPosition.threads:_picks.last.threads,
        _picks.isEmpty?_startingPosition.twist:_picks.last.twist,));
  }

  List<Pick> get picks => _picks;

  @override
  String toString() {
    return ('${_startingPosition.twist} ${_startingPosition._threads}');
  }
}

class Pick {
  final Twist twist; //S or Z
  final TurningDirection turned;//forwards or backwards or float
  final List<Thread> _threads;// query: Should be immutable?
  static final Map<String, Tablet> _pickCache = {};
  
  factory Pick._turn(TurningDirection turningDirection, List<Thread> threads, Twist twist) {
    var queue = DoubleLinkedQueue<Thread>.from(threads);
    if (turningDirection==TurningDirection.forwards) {
      queue.addFirst(queue.removeLast());
    } else if (turningDirection==TurningDirection.backwards) {
      queue.addLast(queue.removeFirst());
    }
    var pick = Pick._create(twist, turningDirection, List.from(queue));
    return pick;
  }
  
  Pick._create(this.twist, this.turned, this._threads);

  List<Thread> get threads => _threads;

  @override
  String toString() {
    return '[$twist]\n[$turned]\n[$_threads]';
  }
}