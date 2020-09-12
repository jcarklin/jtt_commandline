import 'dart:convert';

class Thread {
  final int _indexOnCard;
  var _colourIndex;

  Thread(this._indexOnCard, this._colourIndex, );

  Thread.fromJson(Map<String, dynamic> json)
      : _indexOnCard = json['index'],
        _colourIndex = json['colour'];

  Map<String, dynamic> toJson() =>
      {
        'index': index,
        'colour': colourIndex,
      };

  int get colourIndex => _colourIndex;

  int get index => _indexOnCard;

  set colourIndex(int colourIndex) => _colourIndex = colourIndex;

  @override
  String toString() {
    return json.encode(this);
  }

}