import 'package:test/test.dart';

import 'package:my_financial/model/_shared.dart';

void main() {
  var wantData2022 = <int, Map<int, int>>{
    2022: {
      1: 1640962800000,
      2: 1643641200000,
      3: 1646060400000,
      4: 1648738800000,
      5: 1651330800000,
      6: 1654009200000,
      7: 1656601200000,
      8: 1659279600000,
      9: 1661958000000,
      10: 1664550000000,
      11: 1667228400000,
      12: 1669820400000,
    },
    2021: {
      1: 1609426800000,
      2: 1612105200000,
      3: 1614524400000,
      4: 1617202800000,
      5: 1619794800000,
      6: 1622473200000,
      7: 1625065200000,
      8: 1627743600000,
      9: 1630422000000,
      10: 1633014000000,
      11: 1635692400000,
      12: 1638284400000,
    }
  };
  test('jst1st0AMEquivalent 2022', () {
    var date = DateTime(2021, 1, 1, 12);
    for (var i = 0; i < 365 * 2; i++) {
      var testDate = date.add(Duration(days: i));
      var actual = Shared.jst1stMillisecondsSinceEpoch(testDate);
      expect(actual,
          equals(wantData2022[testDate.year]![testDate.month].toString()),
          reason: testDate.toString());
    }
  });
}
