import '../lib/gloss.dart';

main() {
  var src ='''
.a
  color: red
  background: url(image.png), #fff
  &:hover
    color: blue
  .b & {
    color: green
  }
''';
  print(Gloss.parse(src));
}