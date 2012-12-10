part of nodes;

class Stylesheet implements Node {
  List nodes;

  Stylesheet([this.nodes]) {
    if (this.nodes == null) {
      this.nodes = [];
    }
  }

  push(node) => nodes.add(node);

  unshift(node) => nodes.insertRange(0, 1, node);

  eval(env, [defOnly = false]) {
    if (defOnly) {
      nodes.forEach((node) {
        if (node is Definition || node is Declaration) {
          node.eval(env);
        }
      });
    } else {
      nodes = nodes.map((node) => node.eval(env));
    }

    return this;
  }

  css(env) {
    nodes.forEach((node) {
      var ret = node.css(env);
      if (ret != null) {
        env.buff.add('$ret\n');
      }
    });

    return env.buff;
  }

}