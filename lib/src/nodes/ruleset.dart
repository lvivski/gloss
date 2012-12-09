part of nodes;

class Ruleset implements Node {
  List selectors;
  Block block;
  
  Ruleset([this.selectors, this.block]) {
    if (this.selectors == null) 
      this.selectors = [];
  }
  
  push(selector) => selectors.add(selector);
  
  eval(env) {
    selectors = selectors.map((selector) => selector.eval(env));
    block = block.eval(env);
    return this;
  }

  css(env) {
    var stack = env.selectors;
    stack.add(selectors);
    if (block.hasDeclarations) {
      var sel = normalize(stack, env);
      env.buf.add(env.indent.concat(Strings.join(sel, env.compress > 3 ? ',' : ',\n${env.indent}')));
    }

    block.css(env);
    stack.removeLast();
  }
  
  normalize(stack, env) {
    var selectors = [],
        buf = [];
    
    compile(arr, i) {
      if (i > 0) {
        arr[i].forEach((selector) {
          selector = selector.css(env);
          buf.insertRange(0, 1, selector);
          compile(arr, i - 1);
          buf.removeAt(0);
        });
      } else {
        arr[0].forEach((selector) {
          selector = selector.css(env);
          if (buf.length > 0) {
            for (var i = 0, len = buf.length; i < len; i++) {
              if (buf[i].indexOf('&') !== -1) {
                selector = buf[i].replaceAll('&', selector).trim();
              } else {
                selector = selector.concat(' ${buf[i].trim()}');
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
