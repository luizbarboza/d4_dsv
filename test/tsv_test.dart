import 'dart:io';

import 'package:d4_dsv/d4_dsv.dart';
import 'package:test/test.dart';

void main() {
  test("tsvParse(string) returns the expected objects", () {
    expect(toList(tsvParse("a\tb\tc\n1\t2\t3\n")), [
      [
        {"a": "1", "b": "2", "c": "3"}
      ],
      ["a", "b", "c"]
    ]);
    expect(
        toList(tsvParse(File("./test/data/sample.tsv").readAsStringSync())), [
      [
        {"Hello": "42", "World": "\"fish\""}
      ],
      ["Hello", "World"]
    ]);
  });

  test("tsvParse(string) does not strip whitespace", () {
    expect(toList(tsvParse("a\tb\tc\n 1\t 2\t3\n")), [
      [
        {"a": " 1", "b": " 2", "c": "3"}
      ],
      ["a", "b", "c"]
    ]);
  });

  test("tsvParse(string) parses quoted values", () {
    expect(toList(tsvParse("a\tb\tc\n\"1\"\t2\t3")), [
      [
        {"a": "1", "b": "2", "c": "3"}
      ],
      ["a", "b", "c"]
    ]);
    expect(toList(tsvParse("a\tb\tc\n\"1\"\t2\t3\n")), [
      [
        {"a": "1", "b": "2", "c": "3"}
      ],
      ["a", "b", "c"]
    ]);
  });

  test("tsvParse(string) parses quoted values with quotes", () {
    expect(toList(tsvParse("a\n\"\"\"hello\"\"\"")), [
      [
        {"a": "\"hello\""}
      ],
      ["a"]
    ]);
  });

  test("tsvParse(string) parses quoted values with newlines", () {
    expect(toList(tsvParse("a\n\"new\nline\"")), [
      [
        {"a": "new\nline"}
      ],
      ["a"]
    ]);
    expect(toList(tsvParse("a\n\"new\rline\"")), [
      [
        {"a": "new\rline"}
      ],
      ["a"]
    ]);
    expect(toList(tsvParse("a\n\"new\r\nline\"")), [
      [
        {"a": "new\r\nline"}
      ],
      ["a"]
    ]);
  });

  test("tsvParse(string) observes Unix, Mac and DOS newlines", () {
    expect(toList(tsvParse("a\tb\tc\n1\t2\t3\n4\t5\t\"6\"\n7\t8\t9")), [
      [
        {"a": "1", "b": "2", "c": "3"},
        {"a": "4", "b": "5", "c": "6"},
        {"a": "7", "b": "8", "c": "9"}
      ],
      ["a", "b", "c"]
    ]);
    expect(toList(tsvParse("a\tb\tc\r1\t2\t3\r4\t5\t\"6\"\r7\t8\t9")), [
      [
        {"a": "1", "b": "2", "c": "3"},
        {"a": "4", "b": "5", "c": "6"},
        {"a": "7", "b": "8", "c": "9"}
      ],
      ["a", "b", "c"]
    ]);
    expect(toList(tsvParse("a\tb\tc\r\n1\t2\t3\r\n4\t5\t\"6\"\r\n7\t8\t9")), [
      [
        {"a": "1", "b": "2", "c": "3"},
        {"a": "4", "b": "5", "c": "6"},
        {"a": "7", "b": "8", "c": "9"}
      ],
      ["a", "b", "c"]
    ]);
  });

  test("tsvParse(string, row) returns the expected converted objects", () {
    row(d, _, __) => {"Hello": -int.parse(d["Hello"]), "World": d["World"]};

    expect(
        toList(tsvParseWith(
            File("./test/data/sample.tsv").readAsStringSync(), row)),
        [
          [
            {"Hello": -42, "World": "\"fish\""}
          ],
          ["Hello", "World"]
        ]);
    expect(
        toList(tsvParseWith("a\tb\tc\n1\t2\t3\n", (d, _, __) {
          return d;
        })),
        [
          [
            {"a": "1", "b": "2", "c": "3"}
          ],
          ["a", "b", "c"]
        ]);
  });

  test("tsvParse(string, row) skips rows if row returns null", () {
    row(d, i, _) {
      return [d, null, null, false][i];
    }

    expect(toList(tsvParseWith("field\n42\n\n\n\n", row)), [
      [
        {"field": "42"},
        false
      ],
      ["field"]
    ]);
    expect(
        toList(tsvParseWith("a\tb\tc\n1\t2\t3\n2\t3\t4", (d, _, __) {
          return int.parse(d["a"]!).isOdd ? null : d;
        })),
        [
          [
            {"a": "2", "b": "3", "c": "4"}
          ],
          ["a", "b", "c"]
        ]);
    expect(
        toList(tsvParseWith("a\tb\tc\n1\t2\t3\n2\t3\t4", (d, _, __) {
          return int.parse(d["a"]!).isOdd ? null : d;
        })),
        [
          [
            {"a": "2", "b": "3", "c": "4"}
          ],
          ["a", "b", "c"]
        ]);
  });

  test("tsvParse(string, row) invokes row(d, i) for each row d, in order", () {
    final rows = [];
    tsvParseWith("a\n1\n2\n3\n4", (d, i, _) {
      rows.add({"d": d, "i": i});
    });
    expect(rows, [
      {
        "d": {"a": "1"},
        "i": 0
      },
      {
        "d": {"a": "2"},
        "i": 1
      },
      {
        "d": {"a": "3"},
        "i": 2
      },
      {
        "d": {"a": "4"},
        "i": 3
      }
    ]);
  });

  test("tsvParseRows(string) returns the expected array of array of string",
      () {
    expect(tsvParseRows("a\tb\tc\n"), [
      ["a", "b", "c"]
    ]);
  });

  test("tsvParseRows(string) parses quoted values", () {
    expect(tsvParseRows("\"1\"\t2\t3\n"), [
      ["1", "2", "3"]
    ]);
    expect(tsvParseRows("\"hello\""), [
      ["hello"]
    ]);
  });

  test("tsvParseRows(string) parses quoted values with quotes", () {
    expect(tsvParseRows("\"\"\"hello\"\"\""), [
      ["\"hello\""]
    ]);
  });

  test("tsvParseRows(string) parses quoted values with newlines", () {
    expect(tsvParseRows("\"new\nline\""), [
      ["new\nline"]
    ]);
    expect(tsvParseRows("\"new\rline\""), [
      ["new\rline"]
    ]);
    expect(tsvParseRows("\"new\r\nline\""), [
      ["new\r\nline"]
    ]);
  });

  test("tsvParseRows(string) parses Unix, Mac and DOS newlines", () {
    expect(tsvParseRows("a\tb\tc\n1\t2\t3\n4\t5\t\"6\"\n7\t8\t9"), [
      ["a", "b", "c"],
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"]
    ]);
    expect(tsvParseRows("a\tb\tc\r1\t2\t3\r4\t5\t\"6\"\r7\t8\t9"), [
      ["a", "b", "c"],
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"]
    ]);
    expect(tsvParseRows("a\tb\tc\r\n1\t2\t3\r\n4\t5\t\"6\"\r\n7\t8\t9"), [
      ["a", "b", "c"],
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"]
    ]);
  });

  test(
      "tsvParseRows(string, row) returns the expected converted array of array of string",
      () {
    row(d, i) {
      return i == 0 ? d : [-int.parse(d[0]), d[1]];
    }

    expect(
        tsvParseRowsWith(File("test/data/sample.tsv").readAsStringSync(), row),
        [
          ["Hello", "World"],
          [-42, "\"fish\""]
        ]);
    expect(
        tsvParseRowsWith("a\tb\tc\n1\t2\t3\n", (d, _) {
          return d;
        }),
        [
          ["a", "b", "c"],
          ["1", "2", "3"]
        ]);
  });

  test("tsvParseRows(string, row) skips rows if row returns null or undefined",
      () {
    row(d, i) {
      return [d, null, null, false][i];
    }

    expect(tsvParseRowsWith("field\n42\n\n\n", row), [
      ["field"],
      false
    ]);
    expect(
        tsvParseRowsWith("a\tb\tc\n1\t2\t3\n2\t3\t4", (d, i) {
          return i.isOdd ? null : d;
        }),
        [
          ["a", "b", "c"],
          ["2", "3", "4"]
        ]);
  });

  test("tsvParseRows(string, row) invokes row(d, i) for each row d, in order",
      () {
    final rows = [];
    tsvParseRowsWith("a\n1\n2\n3\n4", (d, i) {
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

  test("tsvFormat(array) takes an array of objects as input", () {
    expect(
        tsvFormat([
          {"a": 1, "b": 2, "c": 3}
        ]),
        "a\tb\tc\n1\t2\t3");
  });

  test("tsvFormat(array) escapes field names and values containing delimiters",
      () {
    expect(
        tsvFormat([
          {"foo\tbar": true}
        ]),
        "\"foo\tbar\"\ntrue");
    expect(
        tsvFormat([
          {"field": "foo\tbar"}
        ]),
        "field\n\"foo\tbar\"");
  });

  test("tsvFormat(array) computes the union of all fields", () {
    expect(
        tsvFormat([
          {"a": 1},
          {"a": 1, "b": 2},
          {"a": 1, "b": 2, "c": 3},
          {"b": 1, "c": 2},
          {"c": 1}
        ]),
        "a\tb\tc\n1\t\t\n1\t2\t\n1\t2\t3\n\t1\t2\n\t\t1");
  });

  test("tsvFormat(array) orders fields by first-seen", () {
    expect(
        tsvFormat([
          {"a": 1, "b": 2},
          {"c": 3, "b": 4},
          {"c": 5, "a": 1, "b": 2}
        ]),
        "a\tb\tc\n1\t2\t\n\t4\t3\n1\t2\t5");
  });

  test("tsvFormat(array, columns) observes the specified array of column names",
      () {
    expect(
        tsvFormat([
          {"a": 1, "b": 2, "c": 3}
        ], [
          "c",
          "b",
          "a"
        ]),
        "c\tb\ta\n3\t2\t1");
    expect(
        tsvFormat([
          {"a": 1, "b": 2, "c": 3}
        ], [
          "c",
          "a"
        ]),
        "c\ta\n3\t1");
    expect(
        tsvFormat([
          {"a": 1, "b": 2, "c": 3}
        ], []),
        "\n");
    expect(
        tsvFormat([
          {"a": 1, "b": 2, "c": 3}
        ], [
          "d"
        ]),
        "d\n");
  });

  test("tsvFormatRows(array) takes an array of array of string as input", () {
    expect(
        tsvFormatRows([
          ["a", "b", "c"],
          ["1", "2", "3"]
        ]),
        "a\tb\tc\n1\t2\t3");
  });

  test("tsvFormatRows(array) separates lines using Unix newline", () {
    expect(tsvFormatRows([[], []]), "\n");
  });

  test("tsvFormatRows(array) does not strip whitespace", () {
    expect(
        tsvFormatRows([
          ["a ", " b", "c"],
          ["1", "2", "3 "]
        ]),
        "a \t b\tc\n1\t2\t3 ");
  });

  test("tsvFormatRows(array) does not quote simple values", () {
    expect(
        tsvFormatRows([
          ["a"],
          [1]
        ]),
        "a\n1");
  });

  test("tsvFormatRows(array) escapes double quotes", () {
    expect(
        tsvFormatRows([
          ["\"fish\""]
        ]),
        "\"\"\"fish\"\"\"");
  });

  test("tsvFormatRows(array) escapes Unix newlines", () {
    expect(
        tsvFormatRows([
          ["new\nline"]
        ]),
        "\"new\nline\"");
  });

  test("tsvFormatRows(array) escapes Windows newlines", () {
    expect(
        tsvFormatRows([
          ["new\rline"]
        ]),
        "\"new\rline\"");
  });

  test("tsvFormatRows(array) escapes values containing delimiters", () {
    expect(
        tsvFormatRows([
          ["oxford\ttab"]
        ]),
        "\"oxford\ttab\"");
  });

  test("tsvFormatRow(array) takes a single array of string as input", () {
    expect(tsvFormatRow(["a", "b", "c"]), "a\tb\tc");
  });
}

List<T> toList<T>((T, {T columns}) pair) {
  return [pair.$1, pair.columns];
}
