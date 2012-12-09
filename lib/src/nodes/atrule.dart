part of nodes;

class Atrule implements Node {
  String name;
  var block;

  Atrule(this.name, [this.block]);

  eval(env) {
    block = block != null ? block.eval(env) : null;
    return this;
  }

  css(env) {
    env.buf.add(name);
    if (block != null) {
      env.buf.add(env.compress > 4 ? '{' : ' {\n');
      ++env.indents;
      block.css(env);
      --env.indents;
      env.buf.add('}${env.compress > 4 ? '' : '\n'}');
    } else {
      env.buf.add(env.compress > 4 ? ';' : ';\n');
    }
  }
}