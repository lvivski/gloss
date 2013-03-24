import '../lib/gloss.dart';

main() {
  var src =r'''
@media all, screen
  body
    width: 500px

background-gradient(start, end) {
  background: -webkit-linear-gradient(start, end);
  background: linear-gradient(start, end);
}

.a
  color: red
  background: url(image.png),#fff
  background: #fff, #000
  &:hover
    color: add(blue, green)
    margin: 10 + 15px
  .b & {
    color: #ddd
    background-gradient: red, blue
  }
''';
  print(Gloss.parse(src));
}