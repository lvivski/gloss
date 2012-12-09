library gloss;

import 'src/parser.dart';
import 'src/env.dart';

class Gloss {
  static parse(str) {
    var parser = new Parser(str);
    var env = new Env();

    var ast = parser.parse();
    var css = ast.eval(env)
                 .css(env);

    return css;
  }
}
