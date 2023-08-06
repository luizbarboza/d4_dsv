import 'csv.dart';
import 'dsv.dart';

/// Given an map representing a parsed row, infers the types of values on the
/// map and coerces them accordingly, returning the mutated map.
///
/// This function is intended to be used as a row accessor function in
/// conjunction with dsv.parse and [DsvFormat.parseRows]. For example, consider
/// the following CSV file:
///
/// ```
/// Year,Make,Model,Length
/// 1997,Ford,E350,2.34
/// 2000,Mercury,Cougar,2.38
/// ```
///
/// When used with [csvParse],
///
/// ```dart
/// csvParse(string, autoType);
/// ```
///
/// the resulting Dart list is:
///
/// ```dart
/// [
///   {"Year": 1997, "Make": "Ford", "Model": "E350", "Length": 2.34},
///   {"Year": 2000, "Make": "Mercury", "Model": "Cougar", "Length": 2.38}
/// ];
/// ```
///
/// Type inference works as follows. For each value in the given map, the
/// trimmed value is computed; the value is then re-assigned as follows:
///
/// 1. If empty, then `null`.
/// 2. If exactly `"true"`, then `true`.
/// 3. If exactly `"false"`, then `false`.
/// 4. If exactly `"NaN"`, then `double.nan`.
/// 5. Otherwise, if parsable to a [num], then a [num].
/// 6. Otherwise, if parsable to a [DateTime], then a [DateTime].
/// 7. Otherwise, a string (the original untrimmed value).
///
/// Numbers and dates must be in a format accepted by [num.parse] and
/// [DateTime.parse] respectively.
///
/// Values with leading zeroes may be parsed to numbers; for example "08904"
/// parses to 8904. However, extra characters such as commas or units (e.g.,
/// "$1.00", "(123)", "1,234" or "32px") will prevent number parsing, resulting
/// in a string.
///
/// If you need different behavior, you should implement your own row accessor
/// function.
Map<String, Object?> autoType(Map<String, String> row) {
  var result = <String, Object?>{};
  for (var MapEntry(:key, :value) in row.entries) {
    value = value.trim();
    num? number;
    DateTime? date;
    result[key] = value.isEmpty
        ? null
        : value == "true"
            ? true
            : value == "false"
                ? false
                : value == "NaN"
                    ? double.nan
                    : (number = num.tryParse(value)) != null
                        ? number
                        : (date = DateTime.tryParse(value)) != null
                            ? date
                            : value;
  }
  return result;
}
