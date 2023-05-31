enum TileType {
  text('Text', '{}'),
  toggle('Switch', '{"left": "", "right": ""}'),
  button('Button', '{"value": ""}'),
  line('Line', '{}'),
  ;

  const TileType(this.value, this.initialLob);

  final String value;
  final String initialLob;
}
