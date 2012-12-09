part of nodes;

class Atrule implements Node {
  String name;
  var block;
  
  Atrule(this.name, [this.block]);
  
  eval(env) {
    block = block && block.eval(env);
    return this;
  }

  css(env) {
    env.buf += name;
    if (block) {
      env.buf += env.compress > 4 ? '{' : ' {\n';
      ++env.indents;
      block.css(env);
      --env.indents;
      env.buf += '}${env.compress > 4 ? '' : '\n'}';
    } else {
      env.buf += env.compress > 4 ? ';' : ';\n';
    }
  }
}