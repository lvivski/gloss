part of nodes;

class Scope {
  Map locals = {};

  add(ident) {
    locals[ident.name] = ident.value;
  }

  lookup(name) =>locals[name];

}
