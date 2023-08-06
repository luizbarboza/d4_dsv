import 'dart:io';

import 'package:d4_dsv/d4_dsv.dart';
import 'package:test/test.dart';

final psv = DsvFormat("|");

void main() {
  test("dsv(\"|\").parse(string) returns the expected objects", () {
    expect(toList(psv.parse("a|b|c\n1|2|3\n")), [
      [
        {"a": "1", "b": "2", "c": "3"}
      ],
      ["a", "b", "c"]
    ]);
    expect(
        toList(psv.parse(File("./test/data/sample.psv").readAsStringSync())), [
      [
        {"Hello": "42", "World": "\"fish\""}
      ],
      ["Hello", "World"]
    ]);
  });

  test("dsv(\"|\").parse(string) does not strip whitespace", () {
    expect(toList(psv.parse("a|b|c\n 1| 2|3\n")), [
      [
        {"a": " 1", "b": " 2", "c": "3"}
      ],
      ["a", "b", "c"]
    ]);
  });

  test("dsv(\"|\").parse(string) parses quoted values", () {
    expect(toList(psv.parse("a|b|c\n\"1\"|2|3")), [
      [
        {"a": "1", "b": "2", "c": "3"}
      ],
      ["a", "b", "c"]
    ]);
    expect(toList(psv.parse("a|b|c\n\"1\"|2|3\n")), [
      [
        {"a": "1", "b": "2", "c": "3"}
      ],
      ["a", "b", "c"]
    ]);
  });

  test("dsv(\"|\").parse(string) parses quoted values with quotes", () {
    expect(toList(psv.parse("a\n\"\"\"hello\"\"\"")), [
      [
        {"a": "\"hello\""}
      ],
      ["a"]
    ]);
  });

  test("dsv(\"|\").parse(string) parses quoted values with newlines", () {
    expect(toList(psv.parse("a\n\"new\nline\"")), [
      [
        {"a": "new\nline"}
      ],
      ["a"]
    ]);
    expect(toList(psv.parse("a\n\"new\rline\"")), [
      [
        {"a": "new\rline"}
      ],
      ["a"]
    ]);
    expect(toList(psv.parse("a\n\"new\r\nline\"")), [
      [
        {"a": "new\r\nline"}
      ],
      ["a"]
    ]);
  });

  test("dsv(\"|\").parse(string) observes Unix, Mac and DOS newlines", () {
    expect(toList(psv.parse("a|b|c\n1|2|3\n4|5|\"6\"\n7|8|9")), [
      [
        {"a": "1", "b": "2", "c": "3"},
        {"a": "4", "b": "5", "c": "6"},
        {"a": "7", "b": "8", "c": "9"}
      ],
      ["a", "b", "c"]
    ]);
    expect(toList(psv.parse("a|b|c\r1|2|3\r4|5|\"6\"\r7|8|9")), [
      [
        {"a": "1", "b": "2", "c": "3"},
        {"a": "4", "b": "5", "c": "6"},
        {"a": "7", "b": "8", "c": "9"}
      ],
      ["a", "b", "c"]
    ]);
    expect(toList(psv.parse("a|b|c\r\n1|2|3\r\n4|5|\"6\"\r\n7|8|9")), [
      [
        {"a": "1", "b": "2", "c": "3"},
        {"a": "4", "b": "5", "c": "6"},
        {"a": "7", "b": "8", "c": "9"}
      ],
      ["a", "b", "c"]
    ]);
  });

  test("dsv(\"|\").parse(string, row) returns the expected converted objects",
      () {
    row(d, _, __) => {"Hello": -int.parse(d["Hello"]), "World": d["World"]};

    expect(
        toList(psv.parseWith(
            File("./test/data/sample.psv").readAsStringSync(), row)),
        [
          [
            {"Hello": -42, "World": "\"fish\""}
          ],
          ["Hello", "World"]
        ]);
    expect(
        toList(psv.parseWith("a|b|c\n1|2|3\n", (d, _, __) {
          return d;
        })),
        [
          [
            {"a": "1", "b": "2", "c": "3"}
          ],
          ["a", "b", "c"]
        ]);
  });

  test("dsv(\"|\").parse(string, row) skips rows if row returns null", () {
    row(d, i, _) {
      return [d, null, null, false][i];
    }

    expect(toList(psv.parseWith("field\n42\n\n\n\n", row)), [
      [
        {"field": "42"},
        false
      ],
      ["field"]
    ]);
    expect(
        toList(psv.parseWith("a|b|c\n1|2|3\n2|3|4", (d, _, __) {
          return int.parse(d["a"]!).isOdd ? null : d;
        })),
        [
          [
            {"a": "2", "b": "3", "c": "4"}
          ],
          ["a", "b", "c"]
        ]);
    expect(
        toList(psv.parseWith("a|b|c\n1|2|3\n2|3|4", (d, _, __) {
          return int.parse(d["a"]!).isOdd ? null : d;
        })),
        [
          [
            {"a": "2", "b": "3", "c": "4"}
          ],
          ["a", "b", "c"]
        ]);
  });

  test(
      "dsv(\"|\").parse(string, row) invokes row(d, i, columns) for each row d, in order",
      () {
    final rows = [];
    psv.parseWith("a\n1\n2\n3\n4", (d, i, columns) {
      rows.add({"d": d, "i": i, "columns": columns});
    });
    expect(rows, [
      {
        "d": {"a": "1"},
        "i": 0,
        "columns": ["a"]
      },
      {
        "d": {"a": "2"},
        "i": 1,
        "columns": ["a"]
      },
      {
        "d": {"a": "3"},
        "i": 2,
        "columns": ["a"]
      },
      {
        "d": {"a": "4"},
        "i": 3,
        "columns": ["a"]
      }
    ]);
  });

  test(
      "dsv(\"|\").parseRows(string) returns the expected array of array of string",
      () {
    expect(psv.parseRows("a|b|c\n"), [
      ["a", "b", "c"]
    ]);
  });

  test("dsv(\"|\").parseRows(string) parses quoted values", () {
    expect(psv.parseRows("\"1\"|2|3\n"), [
      ["1", "2", "3"]
    ]);
    expect(psv.parseRows("\"hello\""), [
      ["hello"]
    ]);
  });

  test("dsv(\"|\").parseRows(string) parses quoted values with quotes", () {
    expect(psv.parseRows("\"\"\"hello\"\"\""), [
      ["\"hello\""]
    ]);
  });

  test("dsv(\"|\").parseRows(string) parses quoted values with newlines", () {
    expect(psv.parseRows("\"new\nline\""), [
      ["new\nline"]
    ]);
    expect(psv.parseRows("\"new\rline\""), [
      ["new\rline"]
    ]);
    expect(psv.parseRows("\"new\r\nline\""), [
      ["new\r\nline"]
    ]);
  });

  test("dsv(\"|\").parseRows(string) parses Unix, Mac and DOS newlines", () {
    expect(psv.parseRows("a|b|c\n1|2|3\n4|5|\"6\"\n7|8|9"), [
      ["a", "b", "c"],
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"]
    ]);
    expect(psv.parseRows("a|b|c\r1|2|3\r4|5|\"6\"\r7|8|9"), [
      ["a", "b", "c"],
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"]
    ]);
    expect(psv.parseRows("a|b|c\r\n1|2|3\r\n4|5|\"6\"\r\n7|8|9"), [
      ["a", "b", "c"],
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"]
    ]);
  });

  test(
      "dsv(\"|\").parseRows(string, row) returns the expected converted array of array of string",
      () {
    row(d, i) {
      return i == 0 ? d : [-int.parse(d[0]), d[1]];
    }

    expect(
        psv.parseRowsWith(File("test/data/sample.psv").readAsStringSync(), row),
        [
          ["Hello", "World"],
          [-42, "\"fish\""]
        ]);
    expect(
        psv.parseRowsWith("a|b|c\n1|2|3\n", (d, _) {
          return d;
        }),
        [
          ["a", "b", "c"],
          ["1", "2", "3"]
        ]);
  });

  test(
      "dsv(\"|\").parseRows(string, row) skips rows if row returns null or undefined",
      () {
    row(d, i) {
      return [d, null, null, false][i];
    }

    expect(psv.parseRowsWith("field\n42\n\n\n", row), [
      ["field"],
      false
    ]);
    expect(
        psv.parseRowsWith("a|b|c\n1|2|3\n2|3|4", (d, i) {
          return i.isOdd ? null : d;
        }),
        [
          ["a", "b", "c"],
          ["2", "3", "4"]
        ]);
  });

  test(
      "dsv(\"|\").parseRows(string, row) invokes row(d, i) for each row d, in order",
      () {
    final rows = [];
    psv.parseRowsWith("a\n1\n2\n3\n4", (d, i) {
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

  test("dsv(\"|\").format(array) takes an array of objects as input", () {
    expect(
        psv.format([
          {"a": 1, "b": 2, "c": 3}
        ]),
        "a|b|c\n1|2|3");
  });

  test(
      "dsv(\"|\").format(array) escapes field names and values containing delimiters",
      () {
    expect(
        psv.format([
          {"foo|bar": true}
        ]),
        "\"foo|bar\"\ntrue");
    expect(
        psv.format([
          {"field": "foo|bar"}
        ]),
        "field\n\"foo|bar\"");
  });

  test("dsv(\"|\").format(array) computes the union of all fields", () {
    expect(
        psv.format([
          {"a": 1},
          {"a": 1, "b": 2},
          {"a": 1, "b": 2, "c": 3},
          {"b": 1, "c": 2},
          {"c": 1}
        ]),
        "a|b|c\n1||\n1|2|\n1|2|3\n|1|2\n||1");
  });

  test("dsv(\"|\").format(array) orders fields by first-seen", () {
    expect(
        psv.format([
          {"a": 1, "b": 2},
          {"c": 3, "b": 4},
          {"c": 5, "a": 1, "b": 2}
        ]),
        "a|b|c\n1|2|\n|4|3\n1|2|5");
  });

  test(
      "dsv(\"|\").format(array, columns) observes the specified array of column names",
      () {
    expect(
        psv.format([
          {"a": 1, "b": 2, "c": 3}
        ], [
          "c",
          "b",
          "a"
        ]),
        "c|b|a\n3|2|1");
    expect(
        psv.format([
          {"a": 1, "b": 2, "c": 3}
        ], [
          "c",
          "a"
        ]),
        "c|a\n3|1");
    expect(
        psv.format([
          {"a": 1, "b": 2, "c": 3}
        ], []),
        "\n");
    expect(
        psv.format([
          {"a": 1, "b": 2, "c": 3}
        ], [
          "d"
        ]),
        "d\n");
  });

  test(
      "dsv(\"|\").formatRows(array) takes an array of array of string as input",
      () {
    expect(
        psv.formatRows([
          ["a", "b", "c"],
          ["1", "2", "3"]
        ]),
        "a|b|c\n1|2|3");
  });

  test("dsv(\"|\").formatRows(array) separates lines using Unix newline", () {
    expect(psv.formatRows([[], []]), "\n");
  });

  test("dsv(\"|\").formatRows(array) does not strip whitespace", () {
    expect(
        psv.formatRows([
          ["a ", " b", "c"],
          ["1", "2", "3 "]
        ]),
        "a | b|c\n1|2|3 ");
  });

  test("dsv(\"|\").formatRows(array) does not quote simple values", () {
    expect(
        psv.formatRows([
          ["a"],
          [1]
        ]),
        "a\n1");
  });

  test("dsv(\"|\").formatRows(array) escapes double quotes", () {
    expect(
        psv.formatRows([
          ["\"fish\""]
        ]),
        "\"\"\"fish\"\"\"");
  });

  test("dsv(\"|\").formatRows(array) escapes Unix newlines", () {
    expect(
        psv.formatRows([
          ["new\nline"]
        ]),
        "\"new\nline\"");
  });

  test("dsv(\"|\").formatRows(array) escapes Windows newlines", () {
    expect(
        psv.formatRows([
          ["new\rline"]
        ]),
        "\"new\rline\"");
  });

  test("dsv(\"|\").formatRows(array) escapes values containing delimiters", () {
    expect(
        psv.formatRows([
          ["oxford|tab"]
        ]),
        "\"oxford|tab\"");
  });

  test("dsv(\"|\").formatRow(array) takes a single array of string as input",
      () {
    expect(psv.formatRow(["a", "b", "c"]), "a|b|c");
  });
}

List<T> toList<T>((T, {T columns}) pair) {
  return [pair.$1, pair.columns];
}
