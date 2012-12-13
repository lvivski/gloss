#!/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../test" && pwd )"

dart --enable-checked-mode $ROOT_DIR/lexer_test.dart
dart --enable-checked-mode $ROOT_DIR/gloss_test.dart