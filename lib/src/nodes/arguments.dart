part of nodes;

class Arguments extends Expression implements Node {
  Map map;

  Arguments([isList, nodes]): super(isList, nodes), map = {};

  eval(env) {
    map.keys.forEach((node) {
      map[node] = map[node].eval(env);
    });

    nodes = nodes.map((node) {
      return node.eval(env);
    });

    return this;
  }

  css(env) => '';
}