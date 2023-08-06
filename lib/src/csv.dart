import 'dsv.dart';

final _csv = DsvFormat(",");

/// Equivalent to [DsvFormat.parse] using "," as delimiter.
(List<Map<String, String>>, {List<String> columns}) csvParse(String data) =>
    _csv.parse(data);

/// Equivalent to [DsvFormat.parseWith] with a delimiter of ",".
(List<R>, {List<String> columns}) csvParseWith<R>(String data,
        R? Function(Map<String, String>, int, List<String>) conversion) =>
    _csv.parseWith<R>(data, conversion);

/// Equivalent to [DsvFormat.parseRows] with a delimiter of ",".
List<List<String>> csvParseRows(String data) => _csv.parseRows(data);

/// Equivalent to [DsvFormat.parseRowsWith] with a delimiter of ",".
List<R> csvParseRowsWith<R>(
        String data, R? Function(List<String>, int) conversion) =>
    _csv.parseRowsWith(data, conversion);

/// Equivalent to [DsvFormat.format] with a delimiter of ",".
String csvFormat(Iterable<Map<String, Object?>> rows,
        [Iterable<String>? columns]) =>
    _csv.format(rows, columns);

/// Equivalent to [DsvFormat.formatBody] with a delimiter of ",".
String csvFormatBody(Iterable<Map<String, Object?>> rows,
        [Iterable<String>? columns]) =>
    _csv.formatBody(rows, columns);

/// Equivalent to [DsvFormat.formatRows] with a delimiter of ",".
String csvFormatRows(Iterable<Iterable<Object?>> rows) => _csv.formatRows(rows);

/// Equivalent to [DsvFormat.formatRow] with a delimiter of ",".
String csvFormatRow(Iterable<Object?> row) => _csv.formatRow(row);

/// Equivalent to [DsvFormat.formatValue] with a delimiter of ",".
String csvFormatValue(Object? value) => _csv.formatValue(value);
