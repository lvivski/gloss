import 'package:unittest/unittest.dart';
import 'package:gloss/gloss.dart';

void main() {
  group('selector', () {
    test('can be a tag', () {
      expect(Gloss.parse('html {}'), hasLength(0));
      expect(Gloss.parse('html { color:black }'), equalsIgnoringWhitespace('html { color: #000000; }'));
    });

    test('can have nesting', () {
      expect(Gloss.parse('''html
  a
    color: #00f'''), equalsIgnoringWhitespace('html a { color: #0000ff; }'));

      expect(Gloss.parse('''html
  a
    color: #00f;
    &:hover
      color: #f00;'''), equalsIgnoringWhitespace('html a { color: #0000ff; } html a:hover { color: #ff0000; }'));

      expect(Gloss.parse('''html
  :first-child {color: #f00}'''), equalsIgnoringWhitespace('html :first-child { color: #ff0000; }'));
    });
  });
  
  group('atrule', () {
    test('can have simple rule', () {
      expect(Gloss.parse('''
@media all {
  body
    font-size: 1.5em
}
'''), equalsIgnoringWhitespace('@media all { body { font-size: 1.5em; } }'));
    });
    
    test('can have comples rules', () {
      expect(Gloss.parse('''
@media all and (max-width: 699px) and (min-width: 520px), (min-width: 1151px) {
  body
    background: #ccc
}
'''), equalsIgnoringWhitespace('@media all and ( max-width : 699px ) and ( min-width : 520px ), ( min-width : 1151px ) { body { background: #cccccc; } }'));
    });
    
    test('can have string', () {
      expect(Gloss.parse('''
@import "imported.css"
'''), equalsIgnoringWhitespace('@import "imported.css";')); 
    });
    
    test('can have url', () {
      expect(Gloss.parse('''
@import url(imported.css)
'''), equalsIgnoringWhitespace('@import url(imported.css);')); 
    });
  });
}