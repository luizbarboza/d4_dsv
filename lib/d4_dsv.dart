/// A parser and formatter for delimiter-separated values, such as CSV and TSV.
///
/// These tabular formats are popular with spreadsheet programs such as
/// Microsoft Excel, and are often more space-efficient than JSON. This
/// implementation is based on
/// [RFC 4180](https://datatracker.ietf.org/doc/html/rfc4180).
///
/// Comma (CSV) and tab (TSV) delimiters are built-in. For example, to parse:
///
/// ```dart
/// csvParse("foo,bar\n1,2"); // ([{foo: 1, bar: 2}], columns: [foo, bar])
/// tsvParse("foo\tbar\n1\t2"); // ([{foo: 1, bar: 2}], columns: [foo, bar])
/// ```
///
/// Or to format:
///
/// ```dart
/// csvFormat([{"foo": "1", "bar": "2"}]); // "foo,bar\n1,2"
/// tsvFormat([{"foo": "1", "bar": "2"}]); // "foo\tbar\n1\t2"
/// ```
///
/// To use a different delimiter, such as “|” for pipe-separated values, use
/// [DsvFormat](https://pub.dev/documentation/d4_dsv/latest/d4_dsv/DsvFormat-class.html):
///
/// ```dart
/// final psv = DsvFormat("|");
///
/// print(psv.parse("foo|bar\n1|2")); // ([{foo: 1, bar: 2}], columns: [foo, bar])
/// ```
export 'src/d4_dsv.dart';
