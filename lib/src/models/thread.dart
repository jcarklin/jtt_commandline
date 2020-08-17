import 'dart:convert';

class Thread {
  final int _indexOnCard;
  final String _colour;

  Thread(this._indexOnCard, this._colour, );

  Thread.fromJson(Map<String, dynamic> json)
      : _indexOnCard = json['index'],
        _colour = json['colour'];

  Map<String, dynamic> toJson() =>
      {
        'index': index,
        'colour': colour,
      };

  String get colour => _colour;

  int get index => _indexOnCard;


  @override
  String toString() {
    return json.encode(this);
  }

}