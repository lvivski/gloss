part of nodes;

class Color {
  factory Color(hash) {
    bool single = hash.length == 3;
    num r = int.parse('0x${single ? '${hash[0]}${hash[0]}' : hash.substr(0, 2)}'),
        g = int.parse('0x${single ? '${hash[1]}${hash[1]}' : hash.substr(2, 2)}'),
        b = int.parse('0x${single ? '${hash[2]}${hash[2]}' : hash.substr(4, 2)}');

    return new RGBA(r, g, b, 1);
  }
}
