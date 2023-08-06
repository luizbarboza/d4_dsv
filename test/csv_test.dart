import 'dart:io';

import 'package:d4_dsv/d4_dsv.dart';
import 'package:test/test.dart';

void main() {
  test("csvParse(string) returns the expected objects", () {
    expect(toList(csvParse("a,b,c\n1,2,3\n")), [
      [
        {"a": "1", "b": "2", "c": "3"}
      ],
      ["a", "b", "c"]
    ]);
    expect(
        toList(csvParse(File("./test/data/sample.csv").readAsStringSync())), [
      [
        {"Hello": "42", "World": "\"fish\""}
      ],
      ["Hello", "World"]
    ]);
  });

  test("csvParse(string) does not strip whitespace", () {
    expect(toList(csvParse("a,b,c\n 1, 2 ,3 ")), [
      [
        {"a": " 1", "b": " 2 ", "c": "3 "}
      ],
      ["a", "b", "c"]
    ]);
  });

  test("csvParse(string) treats empty fields as the empty string", () {
    expect(toList(csvParse("a,b,c\n1,,3")), [
      [
        {"a": "1", "b": "", "c": "3"}
      ],
      ["a", "b", "c"]
    ]);
  });

  test("csvParse(string) treats a trailing empty field as the empty string",
      () {
    expect(toList(csvParse("a,b,c\n1,2,\n1,2,\n")), [
      [
        {"a": "1", "b": "2", "c": ""},
        {"a": "1", "b": "2", "c": ""}
      ],
      ["a", "b", "c"]
    ]);
  });

  test(
      "csvParse(string) treats a trailing empty field on the last line as the empty string",
      () {
    expect(toList(csvParse("a,b,c\n1,2,\n1,2,")), [
      [
        {"a": "1", "b": "2", "c": ""},
        {"a": "1", "b": "2", "c": ""}
      ],
      ["a", "b", "c"]
    ]);
  });

  test("csvParse(string) treats quoted empty strings as the empty string", () {
    expect(toList(csvParse("a,b,c\n1,\"\",3")), [
      [
        {"a": "1", "b": "", "c": "3"}
      ],
      ["a", "b", "c"]
    ]);
  });

  test("csvParse(string) allows the last field to have unterminated quotes",
      () {
    expect(toList(csvParse("a,b,c\n1,2,\"3")), [
      [
        {"a": "1", "b": "2", "c": "3"}
      ],
      ["a", "b", "c"]
    ]);
    expect(toList(csvParse("a,b,c\n1,2,\"")), [
      [
        {"a": "1", "b": "2", "c": ""}
      ],
      ["a", "b", "c"]
    ]);
  });

  test("csvParse(string) ignores a blank last line", () {
    expect(toList(csvParse("a,b,c\n1,2,3\n")), [
      [
        {"a": "1", "b": "2", "c": "3"}
      ],
      ["a", "b", "c"]
    ]);
  });

  test(
      "csvParse(string) treats a blank non-last line as a single-column empty string",
      () {
    expect(toList(csvParse("a,b,c\n1,2,3\n\n")), [
      [
        {"a": "1", "b": "2", "c": "3"},
        {"a": "", "b": "", "c": ""}
      ],
      ["a", "b", "c"]
    ]);
  });

  test("csvParse(string) returns empty strings for missing columns", () {
    expect(toList(csvParse("a,b,c\n1\n1,2")), [
      [
        {"a": "1", "b": "", "c": ""},
        {"a": "1", "b": "2", "c": ""}
      ],
      ["a", "b", "c"]
    ]);
  });

  test("csvParse(string) does not ignore a whitespace-only last line", () {
    expect(toList(csvParse("a,b,c\n1,2,3\n ")), [
      [
        {"a": "1", "b": "2", "c": "3"},
        {"a": " ", "b": "", "c": ""}
      ],
      ["a", "b", "c"]
    ]);
  });

  test("csvParse(string) parses quoted values", () {
    expect(toList(csvParse("a,b,c\n\"1\",2,3")), [
      [
        {"a": "1", "b": "2", "c": "3"}
      ],
      ["a", "b", "c"]
    ]);
    expect(toList(csvParse("a,b,c\n\"1\",2,3\n")), [
      [
        {"a": "1", "b": "2", "c": "3"}
      ],
      ["a", "b", "c"]
    ]);
  });

  test("csvParse(string) parses quoted values with quotes", () {
    expect(toList(csvParse("a\n\"\"\"hello\"\"\"")), [
      [
        {"a": "\"hello\""}
      ],
      ["a"]
    ]);
  });

  test("csvParse(string) parses quoted values with newlines", () {
    expect(toList(csvParse("a\n\"new\nline\"")), [
      [
        {"a": "new\nline"}
      ],
      ["a"]
    ]);
    expect(toList(csvParse("a\n\"new\rline\"")), [
      [
        {"a": "new\rline"}
      ],
      ["a"]
    ]);
    expect(toList(csvParse("a\n\"new\r\nline\"")), [
      [
        {"a": "new\r\nline"}
      ],
      ["a"]
    ]);
  });

  test("csvParse(string) observes Unix, Mac and DOS newlines", () {
    expect(toList(csvParse("a,b,c\n1,2,3\n4,5,\"6\"\n7,8,9")), [
      [
        {"a": "1", "b": "2", "c": "3"},
        {"a": "4", "b": "5", "c": "6"},
        {"a": "7", "b": "8", "c": "9"}
      ],
      ["a", "b", "c"]
    ]);
    expect(toList(csvParse("a,b,c\r1,2,3\r4,5,\"6\"\r7,8,9")), [
      [
        {"a": "1", "b": "2", "c": "3"},
        {"a": "4", "b": "5", "c": "6"},
        {"a": "7", "b": "8", "c": "9"}
      ],
      ["a", "b", "c"]
    ]);
    expect(toList(csvParse("a,b,c\r\n1,2,3\r\n4,5,\"6\"\r\n7,8,9")), [
      [
        {"a": "1", "b": "2", "c": "3"},
        {"a": "4", "b": "5", "c": "6"},
        {"a": "7", "b": "8", "c": "9"}
      ],
      ["a", "b", "c"]
    ]);
  });

  test("csvParse(string) returns columns in the input order", () {
    expect(csvParse("a,b,c\n").columns, ["a", "b", "c"]);
    expect(csvParse("a,c,b\n").columns, ["a", "c", "b"]);
    expect(csvParse("a,0,1\n").columns, ["a", "0", "1"]);
    expect(csvParse("1,0,a\n").columns, ["1", "0", "a"]);
  });

  test("csvParseWith(string, row) returns the expected converted objects", () {
    row(d, _, __) {
      return {"Hello": -int.parse(d["Hello"]), "World": d["World"]};
    }

    expect(
        toList(csvParseWith(
            File("./test/data/sample.csv").readAsStringSync(), row)),
        [
          [
            {"Hello": -42, "World": "\"fish\""}
          ],
          ["Hello", "World"]
        ]);
    expect(
        toList(csvParseWith("a,b,c\n1,2,3\n", (d, _, __) {
          return d;
        })),
        [
          [
            {"a": "1", "b": "2", "c": "3"}
          ],
          ["a", "b", "c"]
        ]);
  });

  test("csvParse(string, row) skips rows if row returns null", () {
    row(d, i, _) {
      return [d, null, null, false][i];
    }

    expect(toList(csvParseWith("field\n42\n\n\n\n", row)), [
      [
        {"field": "42"},
        false
      ],
      ["field"]
    ]);
    expect(
        toList(csvParseWith("a,b,c\n1,2,3\n2,3,4", (d, _, __) {
          return int.parse(d["a"]!).isOdd ? null : d;
        })),
        [
          [
            {"a": "2", "b": "3", "c": "4"}
          ],
          ["a", "b", "c"]
        ]);
    expect(
        toList(csvParseWith("a,b,c\n1,2,3\n2,3,4", (d, _, __) {
          return int.parse(d["a"]!).isOdd ? null : d;
        })),
        [
          [
            {"a": "2", "b": "3", "c": "4"}
          ],
          ["a", "b", "c"]
        ]);
  });

  test("csvParse(string, row) calls row(d, i) for each row d, in order", () {
    final rows = [];
    csvParseWith("a\n1\n2\n3\n4", (d, i, columns) {
      rows.add({"d": d, "i": i});
    });
    expect(rows, [
      {
        "d": {"a": "1"},
        "i": 0,
      },
      {
        "d": {"a": "2"},
        "i": 1,
      },
      {
        "d": {"a": "3"},
        "i": 2,
      },
      {
        "d": {"a": "4"},
        "i": 3,
      }
    ]);
  });

  test("csvParseRows(string) returns the expected array of array of string",
      () {
    expect(csvParseRows("a,b,c"), [
      ["a", "b", "c"]
    ]);
    expect(csvParseRows("a,b,c\n1,2,3"), [
      ["a", "b", "c"],
      ["1", "2", "3"]
    ]);
  });

  test("csvParseRows(string) does not strip whitespace", () {
    expect(csvParseRows(" 1, 2 ,3 "), [
      [" 1", " 2 ", "3 "]
    ]);
  });

  test("csvParseRows(string) treats empty fields as the empty string", () {
    expect(csvParseRows("1,,3"), [
      ["1", "", "3"]
    ]);
  });

  test("csvParseRows(string) treats a trailing empty field as the empty string",
      () {
    expect(csvParseRows("1,2,\n1,2,3"), [
      ["1", "2", ""],
      ["1", "2", "3"]
    ]);
  });

  test(
      "csvParseRows(string) treats a trailing empty field on the last line as the empty string",
      () {
    expect(csvParseRows("1,2,\n"), [
      ["1", "2", ""]
    ]);
    expect(csvParseRows("1,2,"), [
      ["1", "2", ""]
    ]);
  });

  test("csvParseRows(string) treats quoted empty strings as the empty string",
      () {
    expect(csvParseRows("\"\",2,3"), [
      ["", "2", "3"]
    ]);
    expect(csvParseRows("1,\"\",3"), [
      ["1", "", "3"]
    ]);
    expect(csvParseRows("1,2,\"\""), [
      ["1", "2", ""]
    ]);
  });

  test("csvParseRows(string) allows the last field to have unterminated quotes",
      () {
    expect(csvParseRows("1,2,\"3"), [
      ["1", "2", "3"]
    ]);
    expect(csvParseRows("1,2,\""), [
      ["1", "2", ""]
    ]);
  });

  test("csvParseRows(string) ignores a blank last line", () {
    expect(csvParseRows("1,2,3\n"), [
      ["1", "2", "3"]
    ]);
  });

  test(
      "csvParseRows(string) treats a blank non-last line as a single-column empty string",
      () {
    expect(csvParseRows("1,2,3\n\n"), [
      ["1", "2", "3"],
      [""]
    ]);
    expect(csvParseRows("1,2,3\n\"\"\n"), [
      ["1", "2", "3"],
      [""]
    ]);
  });

  test("csvParseRows(string) can return rows of varying length", () {
    expect(csvParseRows("1\n1,2\n1,2,3"), [
      ["1"],
      ["1", "2"],
      ["1", "2", "3"]
    ]);
  });

  test("csvParseRows(string) does not ignore a whitespace-only last line", () {
    expect(csvParseRows("1,2,3\n "), [
      ["1", "2", "3"],
      [" "]
    ]);
  });

  test("csvParseRows(string) parses quoted values", () {
    expect(csvParseRows("\"1\",2,3\n"), [
      ["1", "2", "3"]
    ]);
    expect(csvParseRows("\"hello\""), [
      ["hello"]
    ]);
  });

  test("csvParseRows(string) parses quoted values with quotes", () {
    expect(csvParseRows("\"\"\"hello\"\"\""), [
      ["\"hello\""]
    ]);
  });

  test("csvParseRows(string) parses quoted values with newlines", () {
    expect(csvParseRows("\"new\nline\""), [
      ["new\nline"]
    ]);
    expect(csvParseRows("\"new\rline\""), [
      ["new\rline"]
    ]);
    expect(csvParseRows("\"new\r\nline\""), [
      ["new\r\nline"]
    ]);
  });

  test("csvParseRows(string) parses Unix, Mac and DOS newlines", () {
    expect(csvParseRows("a,b,c\n1,2,3\n4,5,\"6\"\n7,8,9"), [
      ["a", "b", "c"],
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"]
    ]);
    expect(csvParseRows("a,b,c\r1,2,3\r4,5,\"6\"\r7,8,9"), [
      ["a", "b", "c"],
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"]
    ]);
    expect(csvParseRows("a,b,c\r\n1,2,3\r\n4,5,\"6\"\r\n7,8,9"), [
      ["a", "b", "c"],
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"]
    ]);
  });

  test("csvParseRows(\"\") returns the empty array", () {
    expect(csvParseRows(""), []);
  });

  test("csvParseRows(\"\n\") returns an array of one empty string", () {
    expect(csvParseRows("\n"), [
      [""]
    ]);
    expect(csvParseRows("\r"), [
      [""]
    ]);
    expect(csvParseRows("\r\n"), [
      [""]
    ]);
  });

  test("csvParseRows(\"\n\n\") returns an array of two empty strings", () {
    expect(csvParseRows("\n\n"), [
      [""],
      [""]
    ]);
  });

  test(
      "csvParseRows(string, row) returns the expected converted array of array of string",
      () {
    row(d, i) => i == 0 ? d : [-int.parse(d[0]), d[1]];
    expect(
        csvParseRowsWith(File("test/data/sample.csv").readAsStringSync(), row),
        [
          ["Hello", "World"],
          [-42, "\"fish\""]
        ]);
    expect(
        csvParseRowsWith("a,b,c\n1,2,3\n", (d, _) {
          return d;
        }),
        [
          ["a", "b", "c"],
          ["1", "2", "3"]
        ]);
  });

  test("csvParseRows(string, row) skips rows if row returns null or undefined",
      () {
    row(d, i) {
      return [d, null, null, false][i];
    }

    expect(csvParseRowsWith("field\n42\n\n\n", row), [
      ["field"],
      false
    ]);
    expect(
        csvParseRowsWith("a,b,c\n1,2,3\n2,3,4", (d, i) {
          return i.isOdd ? null : d;
        }),
        [
          ["a", "b", "c"],
          ["2", "3", "4"]
        ]);
  });

  test("csvParseRows(string, row) invokes row(d, i) for each row d, in order",
      () {
    final rows = [];
    csvParseRowsWith("a\n1\n2\n3\n4", (d, i) {
      rows.add({"d": d, "i": i});
    });
    expect(rows, [
      {
        "d": ["a"],
        "i": 0
      },
      {
        "d": ["1"],
        "i": 1
      },
      {
        "d": ["2"],
        "i": 2
      },
      {
        "d": ["3"],
        "i": 3
      },
      {
        "d": ["4"],
        "i": 4
      }
    ]);
  });

  test("csvFormat(array) takes an array of objects as input", () {
    expect(
        csvFormat([
          {"a": 1, "b": 2, "c": 3}
        ]),
        "a,b,c\n1,2,3");
  });

  test("csvFormat(array) converts dates to ISO 8601", () {
    expect(
        csvFormat([
          {"date": DateTime.utc(2018, 1, 1)}
        ]),
        "date\n2018-01-01");
    expect(
        csvFormat([
          {"date": DateTime(2018, 1, 1, 8)}
        ]),
        "date\n2018-01-01T08:00Z");
  });

  test("csvFormat(array) escapes field names and values containing delimiters",
      () {
    expect(
        csvFormat([
          {"foo,bar": true}
        ]),
        "\"foo,bar\"\ntrue");
    expect(
        csvFormat([
          {"field": "foo,bar"}
        ]),
        "field\n\"foo,bar\"");
  });

  test("csvFormat(array) computes the union of all fields", () {
    expect(
        csvFormat([
          {"a": 1},
          {"a": 1, "b": 2},
          {"a": 1, "b": 2, "c": 3},
          {"b": 1, "c": 2},
          {"c": 1}
        ]),
        "a,b,c\n1,,\n1,2,\n1,2,3\n,1,2\n,,1");
  });

  test("csvFormat(array) orders fields by first-seen", () {
    expect(
        csvFormat([
          {"a": 1, "b": 2},
          {"c": 3, "b": 4},
          {"c": 5, "a": 1, "b": 2}
        ]),
        "a,b,c\n1,2,\n,4,3\n1,2,5");
  });

  test("csvFormat(array, columns) observes the specified array of column names",
      () {
    expect(
        csvFormat([
          {"a": 1, "b": 2, "c": 3}
        ], [
          "c",
          "b",
          "a"
        ]),
        "c,b,a\n3,2,1");
    expect(
        csvFormat([
          {"a": 1, "b": 2, "c": 3}
        ], [
          "c",
          "a"
        ]),
        "c,a\n3,1");
    expect(
        csvFormat([
          {"a": 1, "b": 2, "c": 3}
        ], []),
        "\n");
    expect(
        csvFormat([
          {"a": 1, "b": 2, "c": 3}
        ], [
          "d"
        ]),
        "d\n");
  });

  test("csvFormat(array, columns) coerces field values to strings", () {
    expect(
        csvFormat([
          {"a": null, "b": null, "c": 3}
        ]),
        "a,b,c\n,,3");
  });

  test("csvFormatBody(array) omits the header row", () {
    expect(
        csvFormatBody([
          {"a": 1, "b": 2},
          {"c": 3, "b": 4},
          {"c": 5, "a": 1, "b": 2}
        ]),
        "1,2,\n,4,3\n1,2,5");
  });

  test("csvFormatBody(array, columns) omits the header row", () {
    expect(
        csvFormatBody([
          {"a": 1, "b": 2},
          {"c": 3, "b": 4},
          {"c": 5, "a": 1, "b": 2}
        ], [
          "a",
          "b"
        ]),
        "1,2\n,4\n1,2");
  });

  test("csvFormatRows(array) takes an array of array of string as input", () {
    expect(
        csvFormatRows([
          ["a", "b", "c"],
          ["1", "2", "3"]
        ]),
        "a,b,c\n1,2,3");
  });

  test("csvFormatRows(array) separates lines using Unix newline", () {
    expect(csvFormatRows([[], []]), "\n");
  });

  test("csvFormatRows(array) converts dates to ISO 8601", () {
    expect(
        csvFormatRows([
          [DateTime.utc(2018, 1, 1)]
        ]),
        "2018-01-01");
    expect(
        csvFormatRows([
          [DateTime(2018, 1, 1, 8)]
        ]),
        "2018-01-01T08:00Z");
  });

  test("csvFormatRows(array) does not strip whitespace", () {
    expect(
        csvFormatRows([
          ["a ", " b", "c"],
          ["1", "2", "3 "]
        ]),
        "a , b,c\n1,2,3 ");
  });

  test("csvFormatRows(array) does not quote simple values", () {
    expect(
        csvFormatRows([
          ["a"],
          [1]
        ]),
        "a\n1");
  });

  test("csvFormatRows(array) escapes double quotes", () {
    expect(
        csvFormatRows([
          ["\"fish\""]
        ]),
        "\"\"\"fish\"\"\"");
  });

  test("csvFormatRows(array) escapes Unix newlines", () {
    expect(
        csvFormatRows([
          ["new\nline"]
        ]),
        "\"new\nline\"");
  });

  test("csvFormatRows(array) escapes Windows newlines", () {
    expect(
        csvFormatRows([
          ["new\rline"]
        ]),
        "\"new\rline\"");
  });

  test("csvFormatRows(array) escapes values containing delimiters", () {
    expect(
        csvFormatRows([
          ["oxford,comma"]
        ]),
        "\"oxford,comma\"");
  });

  test("csvFormatRow(array) takes a single array of string as input", () {
    expect(csvFormatRow(["a", "b", "c"]), "a,b,c");
  });
}

List<T> toList<T>((T, {T columns}) pair) {
  return [pair.$1, pair.columns];
}
