part of nodes;

class Scope {
  Map locals = {};

  void add(ident) {
    locals[ident.name] = ident.value;
  }

  Node lookup(name) => locals[name];

}
