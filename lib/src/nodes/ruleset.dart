part of nodes;

class Ruleset implements Node {
  List selectors;
  Block block;

  Ruleset([this.selectors, this.block]) {
    if (this.selectors == null) {
      this.selectors = [];
    }
  }

  push(selector) => selectors.add(selector);

  eval(env) {
    selectors = selectors.mappedBy((selector) => selector.eval(env)).toList();
    block = block.eval(env);
    return this;
  }

  css(env) {
    var stack = env.selectors;
    stack.add(selectors);
    if (block.hasDeclarations) {
      var sel = normalize(stack, env);
      env.buff..add(env.indent)
              ..add(sel.join(env.compress > 3 ? ',' : ',\n${env.indent}'));
    }

    block.css(env);
    stack.removeLast();
  }

  List normalize(stack, env) {
    var selectors = [],
        buff = [];

    compile(arr, i) {
      if (i > 0) {
        arr[i].forEach((selector) {
          selector = selector.css(env);
          buff.insertRange(0, 1, selector);
          compile(arr, i - 1);
          buff.removeAt(0);
        });
      } else {
        arr[0].forEach((selector) {
          selector = selector.css(env);
          if (buff.length > 0) {
            for (var i = 0, len = buff.length; i < len; i++) {
              if (buff[i].indexOf('&') != -1) {
                selector = buff[i].replaceAll('&', selector).trim();
              } else {
                selector = selector.concat(' ${buff[i].trim()}');
              }
            }
          }
          selectors.add(selector.trim());
        });
      }
    }

    compile(stack, stack.length - 1);

    return selectors;
  }

}
