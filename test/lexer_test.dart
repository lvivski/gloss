import 'package:unittest/unittest.dart';
import 'package:gloss/src/lexer.dart';

void main() {
  group('lexer', () {
    test('should parse tag selectors', () {
      var t = new Lexer('html {}').tokenize();
      expect(t, equals([['selector', 'html', 1], ['space', null, 1], ['{', null, 1], ['}', null, 1], ['eos', null, 1]]));
    });
  });
}