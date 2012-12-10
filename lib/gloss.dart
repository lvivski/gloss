library gloss;

import 'src/parser.dart';
import 'src/env.dart';

class Gloss {
  static parse(str) {
    Parser parser = new Parser(str);
    Env env = new Env();

    var ast = parser.parse();
    StringBuffer css = ast.eval(env)
                 .css(env);

    return css;
  }
}
