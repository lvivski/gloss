library env;

import 'nodes.dart';

class Env {
  num compress, spaces, indents = 0;
  String path;
  
  List stack, calling = [], selectors = [];
  
  Buffer buf;
  
  Block block;
  
  bool isURL = false;
  
  Env([this.compress = 0, this.spaces = 2, this.path]):
    stack = [new Scope()], buf = new Buffer();
  
  lookup(name) {
    var i = stack.length,
        needle;

    while (i-- > 0) {
      if ((needle = stack[i].lookup(name)) != null)
        return needle;
    }
    return null;
  }
  
  get scope => stack.last;
  
  get indent {
    if (compress > 4)
      return '';
    return times(times(' ', spaces), indents);
    //return Strings.join(new List(indents), Strings.join(new List(spaces + 1), ' '));
  }
}

class Buffer implements StringBuffer {
  StringBuffer buff;
  
  Buffer(): buff = new StringBuffer();
  
  operator + (obj) => buff.add(obj);
  
  get length => buff.length;
  
  get isEmpty => buff.isEmpty;
  
  add(obj) => buff.add(obj);
  
  clear() => buff.clear();
  
  addAll(objects) => buff.addAll(objects);
  
  addCharCode(int) => buff.addCharCode(int);
  
  toString() => buff.toString();
}

times(str, n) {
  var l = [];
  l.insertRange(0, n, str);
  return Strings.concatAll(l);
}
