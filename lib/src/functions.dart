part of env;

var modes = {
  'multiply': (a, b) => (a * b) / 255,

  'average': (a, b) => (a + b) / 2,

  'add': (a, b) => min(255, a + b),

  'substract': (a, b) => (a + b < 255) ? 0 : a + b - 255,

  'difference': (a, b) => (a - b).abs(),

  'negation': (a, b) => 255 - (255 - a - b).abs(),

  'screen': (a, b) => 255 - (((255 - a) * (255 - b)) >> 8),

  'exclusion': (a, b) => a + b - 2 * a * b / 255,

  'overlay': (a, b) => b < 128 ? (2 * a * b / 255) : (255 - 2 * (255 - a) * (255 - b) / 255),

  'softlight': (a, b) => b < 128
    ? (2 * ((a >> 1) + 64)) * (b / 255)
    : 255 - (2 * (255 - (( a >> 1) + 64)) * (255 - b) / 255),

  'hardlight': (a, b) => modes.overlay(b, a),

  'colordodge': (a, b) => b == 255 ? b : min(255, ((a << 8 ) / (255 - b))),

  'colorburn': (a, b) => b == 0 ? b : max(0, (255 - ((255 - a) << 8 ) / b)),

  'lineardodge': (a, b) => modes.add(a, b),

  'linearburn': (a, b) => modes.substract(a, b),

  'linearlight': (a, b) => b < 128
    ? modes.linearburn(a, 2 * b)
    : modes.lineardodge(a, (2 * (b - 128))),

  'vividlight': (a, b) => b < 128
    ? modes.colorburn(a, 2 * b)
    : modes.colordodge(a, (2 * (b - 128))),

  'pinlight': (a, b) => b < 128
      ? modes.darken(a, 2 * b)
      : modes.lighten(a, (2 * (b - 128))),

  'hardmix': (a, b) => modes.vividlight(a, b) < 128 ? 0 : 255,

  'reflect': (a, b) => b == 255 ? b : min(255, (a * a / (255 - b))),

  'glow': (a, b) => modes.reflect(b, a),

  'phoenix': (a, b) => min(a, b) - max(a, b) + 255
};

