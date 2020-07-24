class Thread {
  final int _indexOnCard;
  final String _colour;

  Thread(this._indexOnCard, this._colour, );

  String get colour => _colour;

  int get index => _indexOnCard;

  @override
  String toString() {
    return _colour;
  }

}