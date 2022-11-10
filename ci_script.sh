#!/usr/bin/env bash

echo "Grab packages."
flutter pub get

echo "Run analyzer to find any static analysis issues."
flutter analyze

echo "Run the formatter on all the dart files to make sure everything's linted."
flutter format --set-exit-if-changed --dry-run .

echo "Run the actual test."
flutter test