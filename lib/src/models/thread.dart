import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'thread.g.dart';

@JsonSerializable()
class Thread {
  final int index; //index on card
  final int colourIndex;

  Thread(this.index, this.colourIndex, );

  factory Thread.fromJson(Map<String, dynamic> json) => _$ThreadFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadToJson(this);

  @override
  String toString() {
    return json.encode(this);
  }

}