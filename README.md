# Bench

A Dart command-line project for learning and developing signal-analysis tools.

## Current features

- Minimum and maximum values.
- First maximum position, with points numbered from 1.
- Peak-to-peak amplitude.
- Final-minus-initial delta.
- Input validation and automated tests.
- Modular Makefile for formatting, analysis, testing, and compilation.

## Requirements

- Dart SDK compatible with the constraint in `pubspec.yaml`.
- GNU Make.
- Linux development environment; development currently uses Ubuntu on WSL.

## Build and run

```bash
dart pub get
make build
./build/bench
```

`make build` checks formatting, analyzes the code, and runs the tests before compiling.

Use `make help` to list the available commands.

## Project status

Under active development. The CLI currently analyzes a built-in nine-point example.

The long-term goal is to port selected Sinalis signal analyses to Dart
for use on SIM8905E-based Android equipment.
