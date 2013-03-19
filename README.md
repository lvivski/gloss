# Gloss
Glamour CSS preprocessor

[![](https://drone.io/lvivski/gloss/status.png)](https://drone.io/lvivski/gloss/latest)

## Syntax
Gloss is the dynamic stylesheet language. It supports both regular CSS syntax and nested syntax. You can create variables and mixing.

### Nesting
You can use `&` to override the default selectors nesting order
```css
.a {
	.b & {
		background: red
	}
	.c {
		color: white
	}
}
```
will become
```css
.b .a {
  background: #ff0000;
}
.a .c {
  color: #ffffff;
}
```

### Indentation
You can use curly braces or indentation for blocks
```css
.a
	.b
		background: white
```

### Variables
To create a variable you simply assign it with `=` sign
```css
button-color = overlay(#401010, #303030)
.a
  color: button-color
```
produces
```css
.a {
  color: #180606;
}
```

### Mixins
Mixins can be used as a block of properties.
```css
bg-gradient(start, end)
  background: -webkit-linear-gradient(start, end);
  background: linear-gradient(start, end);
.a
	bg-gradient: red, blue
```
output:
```css
.a {
  background: -webkit-linear-gradient(#ff0000, #0000ff);
  background: linear-gradient(#ff0000, #0000ff);
}
```


## License

(The MIT License)

Copyright (c) 2012 Yehor Lvivski <lvivski@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.