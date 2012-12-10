part of nodes;

class Block implements Node {
  List nodes = [];
  num index = 0;

  Block([this.nodes]) {
    if(this.nodes == null) {
      this.nodes = [];
    }
  }

  push(node) => nodes.add(node);

  get hasDeclarations {
    for (var i = 0, len = nodes.length; i < len; ++i)
      if (nodes[i] is Declaration) {
        return true;
      }
    return false;
  }

  get length => nodes.length;

  eval(env) {
    env.block = this;

    for (index = 0; index < nodes.length; ++index) {
      nodes[index] = nodes[index].eval(env);
    }

    if (env.compress > 2) {
      var nodesMap = {},
          compressed,
          node,
          prop;

      for (var i = 0, prop, len = nodes.length; i < len; ++i) {
        node = nodes[i];
        if (
          node is Declaration
          && shorthands[prop = node.property.replaceAll(new RegExp(r'-?(top|right|bottom|left)'), '')]
        ) {
          if (nodesMap[prop] == null) {
            nodesMap[prop] = [];
          }
          nodesMap[prop].add({
            'index': i,
            'side': shorthands[prop].indexOf(node.property),
            'value': node['value']
          });
        }
      }
      nodesMap.keys.forEach((prop) {
        if (compressed = compressProperties(nodesMap[prop])) {
          node = nodes[compressed.index];
          node.property = prop;
          node.value = compressed['value'];
          node = node.eval(env);
          for(var i in compressed['toRemove']) {
            nodes[compressed.toRemove[i]] = null;
          }
        }
      });

      nodes = nodes.filter((_) => !!_);
    }

    return this;
  }

  css(env) {
    var node;

    if (this.hasDeclarations) {
      env.buff.add(env.compress > 4 ? '{' : ' {\n');
      var arr = [];
      ++env.indents;
      for (var i = 0, len = nodes.length; i < len; ++i) {
        node = nodes[i];
        if (node is Declaration) {
           arr.add(node.css(env));
        }
      }
      --env.indents;
      if (env.compress < 4) {
        arr.add('');
      }
      env.buff.add(Strings.join(arr, env.compress > 4 ? ';' : ';\n'))
              .add(env.compress == 4 ? '\n' : '')
              .add(env.indent)
              .add(env.compress > 4 ? '}' : '}\n');
    }

    for (var i = 0, len = nodes.length; i < len; ++i) {
      node = nodes[i];
      if (node is Ruleset || node is Atrule || node is Block) {
        node.css(env);
      }
    }
  }

  compressProperties(arr) {
    if (arr.length < 2) return;

    var toRemove = [],
        expr = new Expression(),
        index;

    arr.forEach((node, i) {
      if (i == 0) {
        index = node.index;
      } else {
        toRemove.add(node.index);
      }
      if (node.side == -1) {
        expr = node.value;
        if (!expr.nodes[1]) {
          expr.add(expr.nodes[0]);
        }

        if (!expr.nodes[2]) {
          expr.add(expr.nodes[0]);
        }

        if (!expr.nodes[3]) {
          expr.add(expr.nodes[1]);
        }
      } else {
        expr.nodes[node.side] = node.value.nodes[0];
      }
    });

    if (expr.nodes.every((_) => !!_)) {
      return {
        'value': expr,
        'index': index,
        'toRemove': toRemove
      };
    }
  }
}