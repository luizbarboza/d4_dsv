import 'package:d4_dsv/d4_dsv.dart';
import 'package:test/test.dart';

void main() {
  test("autoType(object) detects numbers", () {
    expect(autoType({"foo": "4.2"}), {"foo": 4.2});
    expect(autoType({"foo": "04.2"}), {"foo": 4.2});
    expect(autoType({"foo": "-4.2"}), {"foo": -4.2});
    expect(autoType({"foo": "1e4"}), {"foo": 10000});
  });

  test("autoType(object) detects NaN", () {
    expect((autoType({"foo": "NaN"}))["foo"], isNaN);
  });

  test("autoType(object) detects dates", () {
    expect(autoType({"foo": "2018-01-01"}),
        {"foo": DateTime.parse("2018-01-01T00:00:00.000")});
  });

  test("autoType(object) detects extended years", () {
    expect(autoType({"foo": "-010001-01-01T00:00:00Z"}),
        {"foo": DateTime.parse("-010001-01-01T00:00:00Z")});
    expect(autoType({"foo": "+010001-01-01T00:00:00Z"}),
        {"foo": DateTime.parse("+010001-01-01T00:00:00Z")});
  });

  test("autoType(object) detects date-times", () {
    expect(autoType({"foo": "2018-01-01T00:00"}),
        {"foo": DateTime.parse("2018-01-01T00:00:00.000")});
    expect(autoType({"foo": "2018-01-01T00:00+00:00"}),
        {"foo": DateTime.parse("2018-01-01T00:00:00.000Z")});
    expect(autoType({"foo": "2018-01-01T00:00-00:00"}),
        {"foo": DateTime.parse("2018-01-01T00:00:00.000Z")});
  });

  test("autoType(object) detects booleans", () {
    expect(autoType({"foo": "true"}), {"foo": true});
    expect(autoType({"foo": "false"}), {"foo": false});
  });

  test("autoType(object) detects null", () {
    expect(autoType({"foo": ""}), {"foo": null});
  });

  test("autoType(object) detects strings", () {
    expect(autoType({"foo": "yes"}), {"foo": "yes"});
    expect(autoType({"foo": "no"}), {"foo": "no"});
    expect(autoType({"foo": "01/01/2018"}), {"foo": "01/01/2018"});
    expect(autoType({"foo": "January 1, 2018"}), {"foo": "January 1, 2018"});
    expect(autoType({"foo": "1,431"}), {"foo": "1,431"});
    expect(autoType({"foo": "\$1.00"}), {"foo": "\$1.00"});
    expect(autoType({"foo": "(1.00)"}), {"foo": "(1.00)"});
    expect(autoType({"foo": "Nan"}), {"foo": "Nan"});
    expect(autoType({"foo": "True"}), {"foo": "True"});
    expect(autoType({"foo": "False"}), {"foo": "False"});
    expect(autoType({"foo": "TRUE"}), {"foo": "TRUE"});
    expect(autoType({"foo": "FALSE"}), {"foo": "FALSE"});
    expect(autoType({"foo": "NAN"}), {"foo": "NAN"});
    expect(autoType({"foo": "nan"}), {"foo": "nan"});
    expect(autoType({"foo": "NA"}), {"foo": "NA"});
    expect(autoType({"foo": "na"}), {"foo": "na"});
  });

  test("autoType(object) ignores leading and trailing whitespace", () {
    expect(autoType({"foo": " 4.2 "}), {"foo": 4.2});
    expect(autoType({"foo": " -4.2 "}), {"foo": -4.2});
    expect(autoType({"foo": " 1e4 "}), {"foo": 10000});
    expect(autoType({"foo": " 2018-01-01 "}),
        {"foo": DateTime.parse("2018-01-01T00:00:00.000")});
    expect(autoType({"foo": " 2018-01-01T00:00Z "}),
        {"foo": DateTime.parse("2018-01-01T00:00:00.000Z")});
    expect((autoType({"foo": " NaN "}))["foo"], isNaN);
    expect(autoType({"foo": " true "}), {"foo": true});
    expect(autoType({"foo": " "}), {"foo": null});
  });
}
