part of nodes;

class Expression implements Node {
  List nodes;
  bool isList;

  Expression([this.isList = false, this.nodes]) {
    if (this.nodes == null) {
      this.nodes = [];
    }
  }

  get isEmpty => nodes.length == 0;

  get length => nodes.length;

  push(node) => nodes.add(node);

  pop() => nodes.removeLast();

  get(idx, [field = 'value']) {
    if (nodes[idx]) {
      return nodes[idx][field];
    }
  }

  eval(env) {
    nodes = nodes.map((node) => node.eval(env));
    return this;
  }

  css(env) {
    var buff = new StringBuffer(),
        n = nodes.map((node) => node.css(env));

    for (var i = 0, len = n.length; i < len; i++) {
      var last = i == (len - 1);
      buff.add(n[i]);
      if (n[i] == '/' || (len < i + 1 && n[i + 1] == '/')) return;
      if (last) continue;
      buff.add(isList
        ? (env.compress > 4 ? ',' : ', ')
        : (env.isURL ? '' : ' '));
    }

    return buff.toString();
  }
}