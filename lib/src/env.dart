library env;

import 'nodes.dart';

class Env {
  num compress, _spaces, indents = 0;
  String path;

  List stack, calling = [], selectors = [];

  StringBuffer buff;

  Block block;

  bool isURL = false;

  Env([this.compress = 0, this._spaces = 2, this.path]):
    stack = [new Scope()], buff = new StringBuffer();

  lookup(name) {
    var i = stack.length,
        needle;

    while (i-- > 0) {
      if ((needle = stack[i].lookup(name)) != null) {
        return needle;
      }
    }
    return null;
  }

  get scope => stack.last;

  get indent {
    if (compress > 4) {
      return '';
    }
    return times(times(' ', _spaces), indents);
  }
}

times(s, n) {
  var sb = new StringBuffer();
  for(int i = 0; i < n; i++) {
    sb.add(s);
  }
  return sb.toString();
}
