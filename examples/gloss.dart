import '../lib/gloss.dart';

main() {
  var src ='''
.a
  color: red
  background: url(image.png), #fff
  &:hover
    color: blue
''';
  print(Gloss.parse(src));
}