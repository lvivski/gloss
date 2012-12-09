part of nodes;

class Selector extends Node implements Node {
  List<String> segments;
  
  Selector([this.segments]) {
    if (this.segments == null) 
      this.segments = [];
  }
  
  push(segment) => segments.add(segment);
  
  css(env) {
    return env.compress > 4
      ? Strings.concatAll(segments)
          .replaceAll(new RegExp(r'\s*([+~>])\s*'), '\1')
          .trim()
      : Strings.concatAll(segments).trim();
  }
}
