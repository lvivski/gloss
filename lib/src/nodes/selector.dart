part of nodes;

class Selector extends Node implements Node {
  String selector;

  Selector(this.selector);

  css(env) {
    return env.compress > 4
      ? selector.replaceAll(new RegExp(r'\s*([+~>])\s*'), '\1').trim()
      : selector.trim();
  }
}