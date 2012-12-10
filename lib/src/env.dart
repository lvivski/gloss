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

  Node lookup(name) {
    num i = stack.length;
    Node needle;

    while (i-- > 0) {
      if ((needle = stack[i].lookup(name)) != null) {
        return needle;
      }
    }
    return null;
  }

  Scope get scope => stack.last;

  String get indent {
    if (compress > 4) {
      return '';
    }
    return times(times(' ', _spaces), indents);
  }
}

String times(s, n) {
  StringBuffer sb = new StringBuffer();
  for(int i = 0; i < n; i++) {
    sb.add(s);
  }
  return sb.toString();
}
