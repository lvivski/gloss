part of env;

var modifiers = {
  'adjust': (RGBA color, String property, Dimension amount) {
    var hsla = HSLA.fromRGBA(color),
        value = amount.value;
    print((100 - hsla.l) * value / 100);
    if (amount.unit == '%'){
      num current;
      switch (property) {
        case 'hue':
          current = hsla.h;
          break;
        case 'saturation':
          current = hsla.s;
          break;
        case 'lightness':
        case 'light':
          current = hsla.l;
          break;
        default:
          current = hsla.a;
      }
      value = (property == 'lightness' || property == 'light') && value > 0
          ? (100 - hsla.l) * value / 100
          : current * value / 100;
    }
    switch (property) {
      case 'hue':
        hsla.h += value;
        break;
      case 'saturation':
        hsla.s += value;
        break;
      case 'lightness':
      case 'light':
        hsla.l += value;
        break;
      default:
        hsla.a += value;
    }
    return RGBA.fromHSLA(hsla);
  },              
  'saturate': (color, amount) {
    return modifiers['adjust'](color, 'saturation', amount);
  },
  'desaturate': (color, amount) {
    amount.value *= -1;
    return modifiers['adjust'](color, 'saturation', amount);
  },
  'lighten': (color, amount) {
    return modifiers['adjust'](color, 'lightness', amount);
  },
  'darken': (color, amount) {
    amount.value *= -1;
    return modifiers['adjust'](color, 'lightness', amount);
  },
  'fadein': (color, amount) {
    return modifiers['adjust'](color, 'alpha', amount);
  },
  'fadeout': (color, amount) {
    amount.value *= -1;
    return modifiers['adjust'](color, 'alpha', amount);
  }
};

var modes = {
  'multiply': (a, b) => (a * b) / 255,

  'average': (a, b) => (a + b) / 2,

  'add': (a, b) => min(255, a + b),

  'substract': (a, b) => (a + b < 255) ? 0 : a + b - 255,

  'difference': (a, b) => (a - b).abs(),

  'negation': (a, b) => 255 - (255 - a - b).abs(),

  'screen': (a, b) => 255 - (((255 - a) * (255 - b)) >> 8),

  'exclusion': (a, b) => a + b - 2 * a * b / 255,

  'overlay': (a, b) => b < 128
    ? 2 * a * b / 255
    : 255 - 2 * (255 - a) * (255 - b) / 255,

  'softlight': (a, b) => b < 128
    ? (2 * ((a >> 1) + 64)) * (b / 255)
    : 255 - 2 * (255 - (( a >> 1) + 64)) * (255 - b) / 255,

  'hardlight': (a, b) => modes['overlay'](b, a),

  'colordodge': (a, b) => b == 255 ? b : min(255, ((a << 8 ) / (255 - b))),

  'colorburn': (a, b) => b == 0 ? b : max(0, (255 - ((255 - a) << 8 ) / b)),

  'lineardodge': (a, b) => modes['add'](a, b),

  'linearburn': (a, b) => modes['substract'](a, b),

  'linearlight': (a, b) => b < 128
    ? modes['linearburn'](a, 2 * b)
    : modes['lineardodge'](a, (2 * (b - 128))),

  'vividlight': (a, b) => b < 128
    ? modes['colorburn'](a, 2 * b)
    : modes['colordodge'](a, (2 * (b - 128))),

  'pinlight': (a, b) => b < 128
      ? modes['darken'](a, 2 * b)
      : modes['lighten'](a, (2 * (b - 128))),

  'hardmix': (a, b) => modes['vividlight'](a, b) < 128 ? 0 : 255,

  'reflect': (a, b) => b == 255 ? b : min(255, (a * a / (255 - b))),

  'glow': (a, b) => modes['reflect'](b, a),

  'phoenix': (a, b) => min(a, b) - max(a, b) + 255
};

