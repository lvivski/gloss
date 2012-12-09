library gloss;

import 'src/parser.dart';
import 'src/env.dart';

parse(str) {
  var p = new Parser(str);
  var ast = p.parse();
  
  var env = new Env();
  
  ast = ast.eval(env);
  
  var css = ast.css(env);
  
  return css;
}

main() {
  var gloss ='''
.a > .b
  color: #fff
  border: 1px solid red
  .b, .c
    color: #fff
    border: 1px dashed red
'''; 
  print(parse(gloss)); 
}
