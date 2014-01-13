#!/bin/bash

set -e


echo "Analyzing library for warnings or type errors"
dartanalyzer --fatal-warnings --fatal-type-errors lib/*.dart

dart --checked test/benchmark_tests.dart
