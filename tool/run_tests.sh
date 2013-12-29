#!/bin/bash

set -e

DIR=$( cd $( dirname "${BASH_SOURCE[0]}" )/.. && pwd )

echo "Analyzing library for warnings or type errors"
dartanalyzer --fatal-warnings --fatal-type-errors lib/*.dart

for test in $DIR/test/*.dart
do
	dart --checked $test
done

echo -e "\n[32m✓ OK[0m"
