library gloss;

import 'src/env.dart';
import 'src/parser.dart';

class Gloss {
  static String parse(String str) {
    Parser parser = new Parser(str);
    Env env = new Env();

    var ast = parser.parse();
    String css = ast.eval(env)
                 .css(env);

    return css;
  }
}