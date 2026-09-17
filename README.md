# Bench

A Dart command-line tool for numerical signal analysis and configurable
acceptance testing.

Bench evaluates the original samples and generates a standalone HTML
report containing a chart, statistics, an acceptance status, and rejection
reasons.

## Features

- JSON input containing a non-empty `values` array of finite numbers.
- Minimum, maximum, mean, RMS, peak-to-peak amplitude, and end delta.
- First maximum position, numbered from 1, in the statistics output.
- Text, JSON, and standalone HTML output.
- INI acceptance rules for peak height, peak positions, endpoints,
  horizontal segments, drops before peaks, and rises after peaks.
- Individual point bounds and statistical bounds.
- Modular Makefile and automated unit and CLI integration tests.

## Requirements

- Dart SDK compatible with `pubspec.yaml`.
- GNU Make.
- Linux development environment; development uses Ubuntu on WSL.

## Build and run

```bash
dart pub get
make format
make build

./build/bench examples/nine_points.json
./build/bench --json examples/nine_points.json
```

`make build` checks formatting, analyzes the code, and runs the tests
before compiling. Use `make help` to list available commands.

## HTML reports

```bash
./build/bench --html \
  --criteria examples/criteria.ini \
  examples/nine_points.json > build/report.html.tmp &&
  mv -f -- build/report.html.tmp build/report.html
```

Open `build/report.html` in a browser.

With the included criteria, `examples/nine_points.json` is approved.
`examples/rejected_points.json` produces seven rejection reasons.

## Acceptance rules

Edit `examples/criteria.ini`.

- `[pico]`: `altura_minima`, `altura_maxima`, `ponto_minimo`,
  and `ponto_maximo`.
- `[extremos]`: `inicio_abaixo_de` and `fim_abaixo_de`.
- `[forma]`: `permitir_permanencia`, `permitir_queda_antes_pico`,
  `permitir_subida_depois_pico`, and `tolerancia`.

Peak height means the largest sample value, not the largest magnitude.
Height and position bounds are inclusive. Positions are numbered from 1.
Every occurrence of the maximum must satisfy the configured position bounds.

Endpoint rules use strict comparisons: equality with the limit fails.

For shape rules, `false` prohibits an event, `true` permits it, and `null`
disables the rule. Numeric limits can also be disabled individually using
unquoted `null`. Omitted keys in the named sections are inactive.

Tolerance is an absolute, nonnegative value in sample units. It defaults
to zero when omitted or null. For each adjacent difference:

- Absolute difference <= tolerance: permanence.
- Difference < -tolerance: drop.
- Difference > tolerance: rise.

Drops are checked through the last maximum; rises are checked after the
first maximum. This detects valleys between equal maxima. Tolerance does
not change peak identity or numeric acceptance bounds.

Existing `[metric.NAME]` and `[point.NUMBER]` sections remain supported.
They require both `lower` and `upper` keys; either value may be `null`.
These rules can be combined with the named sections.

Use a decimal point for fractional numbers. Comments beginning with
`;` or `#` must occupy their own lines. Unknown names, duplicate entries,
non-finite numbers, and invalid intervals are configuration errors.

## Results and exit codes

HTML displays `APROVADO`, `REPROVADO`, or `SEM CRITÉRIOS`.
With no active criteria, the result is `SEM CRITÉRIOS`.

A successfully generated report exits with code 0, including rejected
signals. Invalid input or criteria exit with code 1; command-line argument
errors exit with code 2.

## Project status

Developed as a learning and portfolio project. Builds and execution
currently target Linux. Execution on Android hardware has not been validated.
