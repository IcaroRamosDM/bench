# Bench

A Dart command-line project for learning and developing signal-analysis tools.

## Current features

- Minimum and maximum values.
- First maximum position, with points numbered from 1.
- Peak-to-peak amplitude.
- Final-minus-initial delta.
- Input validation and automated tests.
- Modular Makefile for formatting, analysis, testing, and compilation.
- Arithmetic mean.
- Root mean square (RMS).
- Validate JSON singal decoding.
- JSON file input through the command line.

## Requirements

- Dart SDK compatible with the constraint in `pubspec.yaml`.
- GNU Make.
- Linux development environment; development currently uses Ubuntu on WSL.

## Build and run

```bash
dart pub get
make build
./build/bench examples/nine_points.json
```

Input files must contain a JSON object with a non-empty 'values' array of finite numbers.

Use 'make run' to analyze the included example, or 'make run INPUT=path/to/signal.json' to select another file.

`make build` checks formatting, analyzes the code, and runs the tests before compiling.

Use `make help` to list the available commands.

## Project status

Under active development. The CLI reads JSON signal files and reports basic statistics.

The long-term goal is to port selected Sinalis signal analyses to Dart
for use on SIM8905E-based Android equipment.
