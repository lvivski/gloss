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
      expect(t, equals([['ident', 'html'], ['indent'], ['ident', 'border'], [':'], ['space'], ['dimension', ['1', 'px']], ['space'], ['ident', 'solid'], ['newline'], ['ident', 'body'], ['indent'], ['ident', 'background'], [':'], ['space'], ['hash', '#fff'], ['outdent'], ['eos']]));
    });
  });
}