import 'dart:convert';

import '../analysis/criteria.dart';
import '../analysis/statistics.dart';

String renderHtmlReport(
  List<double> values, {
  List<Criterion> criteria = const [],
}) {
  final statistics = analyzeSignal(values);
  final evaluation = evaluateCriteria(values, criteria);
  final evaluationHtml = _renderEvaluation(evaluation);

  const width = 900.0;
  const height = 320.0;
  const padding = 30.0;

  final points = <String>[];
  final markers = StringBuffer();

  for (var index = 0; index < values.length; index++) {
    final x = values.length == 1
        ? width / 2
        : padding + index / (values.length - 1) * (width - 2 * padding);

    final y = statistics.peakToPeak == 0
        ? height / 2
        : padding +
              (statistics.maximum - values[index]) /
                  statistics.peakToPeak *
                  (height - 2 * padding);

    final cx = x.toStringAsFixed(2);
    final cy = y.toStringAsFixed(2);

    points.add('$cx,$cy');

    markers.writeln(
      '<circle cx="$cx" cy="$cy" r="4">'
      '<title>Point ${index + 1}: ${values[index]}</title>'
      '</circle>',
    );
  }

  final rows = StringBuffer();

  for (final entry in statistics.toJson().entries) {
    rows.writeln(
      '<tr><th scope="row">${entry.key}</th>'
      '<td>${entry.value}</td></tr>',
    );
  }

  return '''
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Bench — Analysis report</title>
  <style>
    body {
      margin: 0;
      padding: 24px;
      background: #f1f5f9;
      color: #172033;
      font-family: system-ui, sans-serif;
    }

    main {
      max-width: 960px;
      margin: auto;
    }

    header {
      margin-bottom: 24px;
    }

    h1 {
      margin-bottom: 4px;
    }

    header p, .hint {
      color: #526277;
    }

    section {
      padding: 24px;
      margin-bottom: 24px;
      background: white;
      border: 1px solid #dbe3ed;
      border-radius: 12px;
    }

    svg {
      display: block;
      width: 100%;
      height: auto;
      background: #f8fafc;
    }

    polyline {
      fill: none;
      stroke: #087f8c;
      stroke-width: 2;
    }

    circle {
      fill: #087f8c;
    }

    circle:hover {
      fill: #d97706;
      r: 7;
    }

    table {
      width: 100%;
      border-collapse: collapse;
    }

    th, td {
      padding: 10px;
      border-bottom: 1px solid #e2e8f0;
    }

    th {
      text-align: left;
      font-weight: 500;
    }

    td {
      text-align: right;
      font-variant-numeric: tabular-nums;
    }
        .status {
      padding: 12px;
      border-radius: 8px;
      font-weight: 700;
    }

    .status.approved {
      background: #dcfce7;
      color: #166534;
    }

    .status.rejected {
      background: #fee2e2;
      color: #991b1b;
    }

    .status.noCriteria {
      background: #e2e8f0;
      color: #334155;
    }
  </style>
</head>
<body>
  <main>
    <header>
      <h1>Bench</h1>
      <p>Numerical series analysis</p>
    </header>

    $evaluationHtml

    <section>
      <h2>Series · ${statistics.count} points</h2>

      <svg viewBox="0 0 $width $height"
           role="img" aria-labelledby="chart-title">
        <title id="chart-title">
          Values plotted in their original point order
        </title>
        <polyline points="${points.join(' ')}"></polyline>
        $markers
      </svg>

      <p class="hint">
        Horizontal position represents point order.
        Hover over a marker to inspect its value.
        Lines connect measured points as a visual guide.
      </p>
    </section>

    <section>
      <h2>Statistics</h2>
      <table>
        <tbody>
          $rows
        </tbody>
      </table>
    </section>
  </main>
</body>
</html>
''';
}

String _renderEvaluation(CriteriaEvaluation evaluation) {
  const statuses = {
    EvaluationStatus.noCriteria: 'SEM CRITÉRIOS',
    EvaluationStatus.approved: 'APROVADO',
    EvaluationStatus.rejected: 'REPROVADO',
  };

  final reasons = evaluation.failureReasons
      .map((reason) => '<li>${const HtmlEscape().convert(reason)}</li>')
      .join('\n');

  final String details;

  if (evaluation.status == EvaluationStatus.noCriteria) {
    details = '<p>Nenhum critério está ativo.</p>';
  } else if (evaluation.status == EvaluationStatus.approved) {
    details = '<p>Todos os critérios ativos foram atendidos.</p>';
  } else {
    details = '<h3>Motivos da reprovação</h3><ul>$reasons</ul>';
  }

  return '''
<section lang="pt-BR">
  <h2>Avaliação</h2>
  <p id="evaluation-status" class="status ${evaluation.status.name}">${statuses[evaluation.status]}</p>
  $details
</section>
''';
}
