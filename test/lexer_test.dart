import 'package:unittest/unittest.dart';
import 'package:gloss/src/lexer.dart';

void main() {
  group('lexer', () {
    test('should parse braces', () {
      var t = new Lexer('html { }').tokenize();
      expect(t, equals([['ident', 'html'], ['space'], ['{'], ['space'], ['}'], ['eos']]));
    });

    test('should parse indentation', () {
      var t = new Lexer('''
html
  border: 1px solid
  body
    background: #fff
''').tokenize();
      expect(t, equals([['ident', 'html'], ['indent'], ['ident', 'border'], [':'], ['space'], ['dimension', ['1', 'px']], ['space'], ['ident', 'solid'], ['newline'], ['ident', 'body'], ['indent'], ['ident', 'background'], [':'], ['space'], ['hash', '#fff'], ['outdent'], ['outdent'], ['eos']]));
    });


    test('should parse with semicolons', () {
      var t = new Lexer('''
.a
  color: red;
  & .b
    background: url(image.png), #fff;
  &:hover
    color: green;
''').tokenize();
      expect(t, equals([['klass', '.a'], ['indent'],
                        ['ident', 'color'], [':'], ['space'], ['ident', 'red'], [';'], ['newline'],
                        ['&'], ['space'], ['klass', '.b'],
                        ['indent'], ['ident', 'background'], [':'], ['space'], ['url', 'image.png'], [','], ['space'], ['hash', '#fff'], [';'], ['outdent'],
                        ['&'], [':'], ['ident', 'hover'], ['indent'], ['ident', 'color'], [':'], ['space'], ['ident', 'green'], [';'],
                        ['outdent'], ['outdent'],['eos']]));
    });

    test('should parse mixins', () {
      var t = new Lexer('''
mixin(param, param) {
  property: value
}
''').tokenize();

      expect(t, equals([['function', 'mixin'], ['ident', 'param'], [','], ['space'], ['ident', 'param'], [')'], ['space'], ['{'],
                        ['indent'], ['ident', 'property'], [':'], ['space'], ['ident', 'value'],
                        ['outdent'], ['}'], ['newline'], ['eos']]));
    });
  });
}