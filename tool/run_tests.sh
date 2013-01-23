#!/bin/bash

set -e

DIR=$( cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )

pushd $DIR/..
echo "Analyzing library for warnings or type errors"
dart_analyzer --fatal-warnings --fatal-type-errors lib/*.dart
popd

for test in $DIR/../test/*_test.dart
do
	echo "Running test suite: $test"
	dart --checked $test
done
