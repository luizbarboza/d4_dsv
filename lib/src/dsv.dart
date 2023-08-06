const _eol = {}, _eof = {}, _quote = 34, _newline = 10, _return = 13;

Map<String, String> Function(List<String>, [int?]) _objectConverter(
    List<String> columns) {
  return (d, [_]) {
    var object = <String, String>{};
    for (var i = 0; i < columns.length; i++) {
      object[columns[i]] = i < d.length ? d[i] : "";
    }
    return object;
  };
}

R? Function(List<String>, int) _customConverter<R>(List<String> columns,
    R? Function(Map<String, String>, int, List<String>) f) {
  var object = _objectConverter(columns);
  return (row, i) {
    return f(object(row), i, columns);
  };
}

// Compute unique columns in order of discovery.
Set<String> _inferColumns(Iterable<Map<String, Object?>> rows) {
  var columns = <String>{};

  for (var row in rows) {
    for (var column in row.keys) {
      columns.add(column);
    }
  }

  return columns;
}

String _pad(int value, int width) => value.toString().padLeft(width, "0");

String _formatYear(int year) {
  return year < 0
      ? "-${_pad(-year, 6)}"
      : year > 9999
          ? "+${_pad(year, 6)}"
          : _pad(year, 4);
}

String _formatDate(DateTime date) {
  var hours = date.hour,
      minutes = date.minute,
      seconds = date.second,
      milliseconds = date.microsecond;
  return "${_formatYear(date.year)}-${_pad(date.month, 2)}-${_pad(date.day, 2)}${milliseconds != 0 ? "T${_pad(hours, 2)}:${_pad(minutes, 2)}:${_pad(seconds, 2)}.${_pad(milliseconds, 3)}Z" : seconds != 0 ? "T${_pad(hours, 2)}:${_pad(minutes, 2)}:${_pad(seconds, 2)}Z" : minutes != 0 || hours != 0 ? "T${_pad(hours, 2)}:${_pad(minutes, 2)}Z" : ""}";
}

/// A class for parsing and formatting Delimiter-Separated Values (DSV) data.
///
/// This class provides methods for parsing and formatting DSV data, which is a
/// common format for representing tabular data where values are separated by a
/// specified delimiter character (e.g., comma, semicolon, tab).
///
/// Example usage:
/// ```dart
/// final csv = DsvFormat(",");
/// final data = "Name,Age,Country\nAlice,28,USA\nBob,22,Canada";
///
/// final parsedData = csv.parse(data);
/// print(parsedData);
///
/// final formattedData = csv.format(parsedData);
/// print(formattedData);
/// ```
class DsvFormat {
  final String _delimiter;
  final RegExp _reFormat;
  final int __delimiter;

  /// Constructs a new DSV parser and formatter for the specified [delimiter].
  ///
  /// The [delimiter] must be a single character (i.e., a single 16-bit code
  /// unit); so, ASCII delimiters are fine, but emoji delimiters are not.
  DsvFormat(String delimiter)
      : _delimiter = delimiter,
        _reFormat = RegExp("[\"$delimiter\n\r]"),
        __delimiter = delimiter.codeUnitAt(0);

  /// Parses the specified [data], which must be in the delimiter-separated
  /// values format with the appropriate delimiter, returning an list of maps
  /// representing the parsed rows.
  ///
  /// Unlike [parseRows], this method requires that the first line of the DSV
  /// content contains a delimiter-separated list of column names; these column
  /// names become the keys on the returned maps. For example, consider the
  /// following CSV file:
  ///
  /// ```
  /// Year,Make,Model,Length
  /// 1997,Ford,E350,2.34
  /// 2000,Mercury,Cougar,2.38
  /// ```
  ///
  /// The resulting Dart list is:
  ///
  /// ```dart
  /// [
  ///   {"Year": "1997", "Make": "Ford", "Model": "E350", "Length": "2.34"},
  ///   {"Year": "2000", "Make": "Mercury", "Model": "Cougar", "Length": "2.38"}
  /// ];
  /// ```
  ///
  /// The returned record also exposes a columns field containing the column
  /// names in input order. For example:
  ///
  /// ```dart
  /// data.columns; // ["Year", "Make", "Model", "Length"]
  /// ```
  ///
  /// If the column names are not unique, only the last value is returned for
  /// each name; to access all values, use [parseRows] instead (see example).
  ///
  /// There is no automatic conversion to numbers, dates, or other types. To
  /// convert the maps during the parse process, use [parseWith].
  (List<Map<String, String>>, {List<String> columns}) parse(String data) =>
      parseWith<Map<String, String>>(data, (d, _, __) => d);

  /// Similar to [parse], but applies the specified [conversion] function to
  /// each row.
  ///
  /// See [autoType] for a convenient row [conversion] function that infers and
  /// coerces common types like numbers and strings.
  ///
  /// The specified [conversion] function is invoked for each row, being passed
  /// an map representing the current row (*d*), the index (*i*) starting at
  /// zero for the first non-header row, and the list of column names. If the
  /// returned value is null, the row is skipped and will be omitted from the
  /// list returned by [parseWith]; otherwise, the returned value defines the
  /// corresponding row map. For example:
  ///
  /// ```dart
  /// final data = csvParseWith(string, (d, _, __) {
  ///   return {
  ///     "year": DateTime(int.parse(d["Year"]!), 0, 1), // lowercase and convert "Year" to Date
  ///     "make": d["Make"], // lowercase
  ///     "model": d["Model"], // lowercase
  ///     "length": num.parse(d["Length"]!) // lowercase and convert "Length" to number
  ///   };
  /// });
  /// ```
  (List<R>, {List<String> columns}) parseWith<R>(String text,
      R? Function(Map<String, String>, int, List<String>) conversion) {
    R? Function(List<String>, int)? convert;
    var columns = <String>[],
        rows = parseRowsWith<R>(text, (row, i) {
          if (convert != null) return convert!(row, i - 1);
          columns = row;
          convert = _customConverter(row, conversion);
          return null;
        });
    return (rows, columns: columns);
  }

  /// Parses the specified [data], which must be in the delimiter-separated
  /// values format with the appropriate delimiter, returning an list of lists
  /// representing the parsed rows.
  ///
  /// Unlike [parse], this method treats the header line as a standard row, and
  /// should be used whenever DSV content does not contain a header. Each row is
  /// represented as an list rather than an map. Rows may have variable length.
  /// For example, consider the following CSV file, which notably lacks a header
  /// line:
  ///
  /// ```
  /// 1997,Ford,E350,2.34
  /// 2000,Mercury,Cougar,2.38
  /// ```
  ///
  /// The resulting Dart list is:
  ///
  /// ```dart
  /// [
  ///   ["1997", "Ford", "E350", "2.34"],
  ///   ["2000", "Mercury", "Cougar", "2.38"]
  /// ];
  /// ```
  ///
  /// There is no automatic conversion to numbers, dates, or other types. To
  /// convert the maps during the parse process, use [parseWith].
  List<List<String>> parseRows(String data) => parseRowsWith(data, (r, _) => r);

  /// Similar to [parseRows], but applies the specified [conversion] function to
  /// each row.
  ///
  /// See [autoType] for a convenient row [conversion] function that infers and
  /// coerces common types like numbers and strings.
  ///
  /// The specified [conversion] function is invoked for each row, being passed
  /// an map representing the current row (*d*), and the index (*i*) starting at
  /// zero for the first non-header row. If the returned value is null, the row
  /// is skipped and will be omitted from the list returned by [parseRowsWith];
  /// otherwise, the returned value defines the corresponding row map. For
  /// example:
  ///
  /// ```dart
  /// final data = csvParseRowsWith(string, (d, _) {
  ///   return {
  ///     "year": DateTime(int.parse(d[0]), 0, 1), // lowercase and convert "Year" to Date
  ///     "make": d[1], // lowercase
  ///     "model": d[2], // lowercase
  ///     "length": num.parse(d[3]) // lowercase and convert "Length" to number
  ///   };
  /// });
  /// ```
  ///
  /// In effect, [conversion] is similar to applying a [List.map] and
  /// [List.where] operator to the returned rows.
  List<R> parseRowsWith<R>(
      String text, R? Function(List<String>, int) conversion) {
    var rows = <R>[], // output rows
        N = text.length,
        I = 0, // current character index
        n = 0, // current line number
        eof = N <= 0, // current token followed by EOF?
        eol = false; // current token followed by EOL?

    Object t; // current token

    // Strip the trailing newline.
    if (N != 0 && text.codeUnitAt(N - 1) == _newline) --N;
    if (N != 0 && text.codeUnitAt(N - 1) == _return) --N;

    token() {
      if (eof) return _eof;
      if (eol) {
        eol = false;
        return _eol;
      }

      // Unescape quotes.
      int i, j = I, c;
      if (j < N && text.codeUnitAt(j) == _quote) {
        while (++I < N && text.codeUnitAt(I) != _quote ||
            ++I < N && text.codeUnitAt(I) == _quote) {}
        if ((i = I) >= N) {
          eof = true;
        } else if ((c = text.codeUnitAt(I++)) == _newline) {
          eol = true;
        } else if (c == _return) {
          eol = true;
          if (text.codeUnitAt(I) == _newline) ++I;
        }
        return text.substring(j + 1, i - 1).replaceAll('""', '"');
      }

      // Find next delimiter or newline.
      while (I < N) {
        if ((c = text.codeUnitAt(i = I++)) == _newline) {
          eol = true;
        } else if (c == _return) {
          eol = true;
          if (text.codeUnitAt(I) == _newline) ++I;
        } else if (c != __delimiter) {
          continue;
        }
        return text.substring(j, i);
      }

      // Return last token before EOF.
      eof = true;
      return text.substring(j, N);
    }

    while ((t = token()) != _eof) {
      var row = <String>[];
      while (t != _eol && t != _eof) {
        row.add(t as String);
        t = token();
      }
      var result = conversion(row, n++);
      if (result == null) continue;
      rows.add(result);
    }

    return rows;
  }

  List<String> _preformatBody(
      Iterable<Map<String, Object?>> rows, Iterable<String> columns) {
    return rows.map((row) {
      return columns.map((column) {
        return formatValue(row[column]);
      }).join(_delimiter);
    }).toList();
  }

  /// Formats the specified iterable of map rows as delimiter-separated values,
  /// returning a string.
  ///
  /// This operation is the inverse of [parse]. Each row will be separated by a
  /// newline (`\n`), and each column within each row will be separated by the
  /// delimiter (such as a comma, `,`). Values that contain either the
  /// delimiter, a double-quote (`"`) or a newline will be escaped using
  /// double-quotes.
  ///
  /// If [columns] is not specified, the list of column names that forms the
  /// header row is determined by the union of all properties on all objects in
  /// rows; the order of columns is the order in which they appear. If [columns]
  /// is specified, it is an iterable of strings representing the column names.
  /// For example:
  ///
  /// ```dart
  /// final string = csvFormat(data, ["year", "make", "model", "length"]);
  /// ```
  ///
  /// All fields on each row map will be coerced to strings. If the field value
  /// is null, the empty string is used. If the field value is a Date, the
  /// [ECMAScript date-time string format](https://www.ecma-international.org/ecma-262/9.0/index.html#sec-date-time-string-format)
  /// (a subset of ISO 8601) is used: for example, dates at UTC midnight are
  /// formatted as YYYY-MM-DD. For more control over which and how fields are
  /// formatted, first map rows to an iterable of iterable of string, and then
  /// use [formatRows].
  String format(Iterable<Map<String, Object?>> rows,
      [Iterable<String>? columns]) {
    columns ??= _inferColumns(rows);
    return [columns.map(formatValue).join(_delimiter)]
        .followedBy(_preformatBody(rows, columns))
        .join("\n");
  }

  /// Equivalent to [format], but omits the header row.
  ///
  /// This is useful, for example, when appending rows to an existing file.
  String formatBody(Iterable<Map<String, Object?>> rows,
      [Iterable<String>? columns]) {
    columns ??= _inferColumns(rows);
    return _preformatBody(rows, columns).join("\n");
  }

  /// Formats the specified iterable of iterable of string rows as
  /// delimiter-separated values, returning a string.
  ///
  /// This operation is the reverse of [parseRows]. Each row will be separated
  /// by a newline (`\n`), and each column within each row will be separated by
  /// the delimiter (such as a comma, `,`). Values that contain either the
  /// delimiter, a double-quote (`"`) or a newline will be escaped using
  /// double-quotes.
  ///
  /// To convert an iterable of maps to an iterable of iterables while
  /// explicitly specifying the columns, use [Iterable.map]. For example:
  ///
  /// ```dart
  /// final string = csvFormatRows(data.map((d) {
  ///   return [
  ///     (d["year"] as DateTime).year, // Assuming d["year"] is a DateTime instance.
  ///     d["make"],
  ///     d["model"],
  ///     d["length"]
  ///   ];
  /// }));
  /// ```
  ///
  /// Alternatively, you can use a list of column names with [List.followedBy]
  /// to generate the first row:
  ///
  /// ```dart
  /// final string = csvFormatRows([
  ///   <Object>["year", "make", "model", "length"]
  /// ].followedBy(data.map((d) {
  ///   return [
  ///     (d["year"] as DateTime).year, // Assuming d["year"] is a DateTime instance.
  ///     d["make"],
  ///     d["model"],
  ///     d["length"]
  ///   ];
  /// })));
  /// ```
  String formatRows(Iterable<Iterable<Object?>> rows) {
    return rows.map(formatRow).join("\n");
  }

  /// Formats a single iterable row of strings as delimiter-separated values,
  /// returning a string.
  ///
  /// Each column within the row will be separated by the delimiter (such as a
  /// comma, `,`). Values that contain either the delimiter, a double-quote
  /// (`"`) or a newline will be escaped using double-quotes.
  String formatRow(Iterable<Object?> row) {
    return row.map(formatValue).join(_delimiter);
  }

  /// Format a single value or string as a delimiter-separated value, returning
  /// a string.
  ///
  /// A value that contains either the delimiter, a double-quote (`"`) or a
  /// newline will be escaped using double-quotes.
  String formatValue(Object? value) {
    String formatted;
    return value == null
        ? ""
        : value is DateTime
            ? _formatDate(value)
            : _reFormat.hasMatch(formatted = value.toString())
                ? '"${formatted.replaceAll('"', '""')}"'
                : value.toString();
  }
}
