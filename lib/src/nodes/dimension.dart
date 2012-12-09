part of nodes;

Map coercion = {
  'mm': {
    'cm': 10,
    'in': 25.4
  },
  'cm': {
    'mm': 1 / 10,
    'in': 2.54
  },
  'in': {
    'mm': 1 / 25.4,
    'cm': 1 / 2.54
  },
  'ms': {
    's': 1000
  },
  's': {
    'ms': 1 / 1000
  },
  'rad': {
    'deg': PI / 180
  },
  'deg': {
    'rad': 180 / PI
  }
};

class Dimension extends Node implements Node {
  num value;
  String unit;
  
  Dimension(value, [unit]) {
    this.value = int.parse(value);
    this.unit = unit != null ? unit : '';
  }
  
  operate(String op, Dimension other) {
    if ((op === '-' || op === '+') && other.unit === '%') {
      other.value = value * (value / 100);
    } else {
      other = coerce(other);
    }
    return new Dimension(calc(op, value, other.value),
                         unit !== null ? unit : other.unit );
  }

  coerce(other) {
    if (other is Dimension) {
      var multiplier = 1;
      if (coercion[unit] && coercion[unit][other.unit]) {
        multiplier = coercion[unit][other.unit];
      }
      return new Dimension(other.value * multiplier, unit !== null ? unit : other.unit);
    }
    return new Dimension(double.parse(other), this.unit);
  }
  
  calc(op, a, b) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        return a / b;
    }
  }

  css(env) {
    var n = this.value;

    if (env.compress > 0) {
      var isFloat = n != (n | 0);

      if (unit !== '%' && n === 0)
        return '0';

      if (isFloat && n < 1 && n > -1) {
        return '${n.toString().replaceFirst('0.', '.')}$unit';
      }
    }

    return '$n$unit';
  }
}


