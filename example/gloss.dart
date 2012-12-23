import '../lib/gloss.dart';

main() {
  var src ='''
.a
  color: red
  background: #fff, #000
  &:hover
    color: blue
  .b & {
    color: green;
  }
''';
  print(Gloss.parse(src));
}