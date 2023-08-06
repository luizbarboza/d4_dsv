import 'dsv.dart';

final _tsv = DsvFormat("\t");

/// Equivalent to [DsvFormat.parse] using "\t" as delimiter.
(List<Map<String, String>>, {List<String> columns}) tsvParse(String data) =>
    _tsv.parse(data);

/// Equivalent to [DsvFormat.parseWith] with a delimiter of "\t".
(List<R>, {List<String> columns}) tsvParseWith<R>(String data,
        R? Function(Map<String, String>, int, List<String>) conversion) =>
    _tsv.parseWith<R>(data, conversion);

/// Equivalent to [DsvFormat.parseRows] with a delimiter of "\t".
List<List<String>> tsvParseRows(String data) => _tsv.parseRows(data);

/// Equivalent to [DsvFormat.parseRowsWith] with a delimiter of "\t".
List<R> tsvParseRowsWith<R>(
        String data, R? Function(List<String>, int) conversion) =>
    _tsv.parseRowsWith(data, conversion);

/// Equivalent to [DsvFormat.format] with a delimiter of "\t".
String tsvFormat(Iterable<Map<String, Object?>> rows,
        [Iterable<String>? columns]) =>
    _tsv.format(rows, columns);

/// Equivalent to [DsvFormat.formatBody] with a delimiter of "\t".
String tsvFormatBody(Iterable<Map<String, Object?>> rows,
        [Iterable<String>? columns]) =>
    _tsv.formatBody(rows, columns);

/// Equivalent to [DsvFormat.formatRows] with a delimiter of "\t".
String tsvFormatRows(Iterable<Iterable<Object?>> rows) => _tsv.formatRows(rows);

/// Equivalent to [DsvFormat.formatRow] with a delimiter of "\t".
String tsvFormatRow(Iterable<Object?> row) => _tsv.formatRow(row);

/// Equivalent to [DsvFormat.formatValue] with a delimiter of "\t".
String tsvFormatValue(Object? value) => _tsv.formatValue(value);
