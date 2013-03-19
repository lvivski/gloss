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
    env.buff.write(name);
    if (block != null) {
      env.buff.write(env.compress > 4 ? '{' : ' {\n');
      ++env.indents;
      block.css(env);
      --env.indents;
      env.buff..write('}')
              ..write(env.compress > 4 ? '' : '\n');
    } else {
      env.buff..write(env.compress > 4 ? ';' : ';\n');
    }
  }
}