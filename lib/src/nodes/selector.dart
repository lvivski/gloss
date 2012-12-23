part of nodes;

class Selector extends Node implements Node {
  List segments;

  Selector(this.segments);

  css(env) {
    return env.compress > 4
      ? Strings.join(segments, '').replaceAll(new RegExp(r'\s*([+~>])\s*'), '\1').trim()
      : Strings.join(segments, '').trim();
  }
}