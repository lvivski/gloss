part of nodes;

class Literal extends Node implements Node {
  String value;

  Literal(this.value);

  css(env) => value;
}
