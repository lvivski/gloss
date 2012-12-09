part of nodes;
class Params extends Node implements Node {
  List nodes;
  
  Params([this.nodes]) {
    if (this.nodes == null) 
      this.nodes = [];
  }
  
  get length => nodes.length;
  
  push(node) => nodes.add(node);
}
