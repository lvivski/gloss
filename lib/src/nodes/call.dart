part of nodes;

class Call implements Node {
  String name;
  Arguments args;

  Call(this.name, this.args);

  eval(env) {
    args = args.eval(env);
    var fn = env.lookup(name);
    if (fn != null) {
      try {
        if (fn is Definition) { // user defined mixin
          return mixin(fn, env);
        }
        return bif(fn, env);
      } catch (e) {
        throw e;
      }
    } else {
      return this;
    }
  }

  css(env) {
    var a = args.nodes.map((arg) => arg.css(env));
    a = Strings.join(a, env.compress > 4 ? ',' : ', ');
    return '$name($a)';
  }

  mixin(fn, env) {
    var scope = new Scope()
      , i = 0
      , block = env.block;

    env.calling.add(fn.name);
    env.stack.add(scope);

    fn.params.nodes.forEach((node) {
      var arg = args.map[node.name] || args.nodes[i++];
      scope.add(new Ident(node, arg));
    });

    var mixin = fn.block.nodes.map((node) => node.eval(env))
      , len = block.nodes.length
      , head = block.nodes.slice(0, block.index)
      , tail = block.nodes.slice(block.index + 1, len);

    block.nodes = head.concat(mixin).concat(tail);
    block.index += mixin.length - 1;

    env.stack.removeLast();
    env.calling.removeLast();

    return Null;
  }

  bif(fn, env) {
    var a = args.nodes.map((arg) {
      return arg.nodes[0] is Expression ? arg.nodes[0].nodes[0] : arg.nodes[0];
    });

    switch (a.length) {
      case 1:
        return fn(a[0]);
      case 2:
        return fn(a[0], a[1]);
      case 3:
        return fn(a[0], a[1], a[2]);
    }

    // return Function.apply(fn, a);
  }
}
