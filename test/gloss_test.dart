import 'package:unittest/unittest.dart';
import 'package:gloss/gloss.dart';

void main() {
  group('selector', () {
    test('can be a tag', () {
      expect(Gloss.parse('html {}'), hasLength(0));
      expect(Gloss.parse('html { color:black }'), equalsIgnoringWhitespace('html { color: black; }'));
    });

    test('can have nesting', () {
      expect(Gloss.parse('''html
  a
    color: #00f'''), equalsIgnoringWhitespace('html a { color: #0000ff; }'));

      expect(Gloss.parse('''html
  a
    color: #00f
    &:hover
      color: #f00'''), equalsIgnoringWhitespace('html a { color: #0000ff; } html a:hover { color: #ff0000; }'));

      expect(Gloss.parse('''html
  :first-child {color: #f00}'''), equalsIgnoringWhitespace('html :first-child { color: #ff0000; }'));
    });
  });
}