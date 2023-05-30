import 'dart:core';

class Shared {
  /// jst1stMillisecondsSinceEpoch = docIdFromLocalTime
  /// @param date: any datetime at local time (timezone of the device)
  /// calculate from the date a local datetime equal to 00:00 AM JST 1st day of
  /// the month then get milliseconds from epoch
  /// Purpose: we want docId the same between timezones
  /// We choose JST because we already have users there
  /// expect
  /// ```
  ///   Jun 2022 = 1654009200000
  ///   May 2022 = 1651330800000
  ///   Apr 2022 = 1648738800000
  ///   Mar 2022 = 1646060400000
  /// ```
  /// In @date: the time is always
  /// ```
  ///   12:00:00 JST (12h at noon, 12:00:00PM)
  ///   10:00:00AM UTC+7
  /// ```
  /// Intentionally support: GMT+7, GTM+9 without DST
  /// Don't support DST
  /// When you travel to another timezone during DST period,
  /// please don't use the app
  /// Please use it when you back to your original timezone
  static String jst1stMillisecondsSinceEpoch(DateTime localTime) {
    var offset = localTime.timeZoneOffset.inMilliseconds - 9 * 3600 * 1000;
    var local1st = DateTime(localTime.year, localTime.month, 1, 0);
    var jst = local1st.add(Duration(milliseconds: offset));
    return jst.millisecondsSinceEpoch.toString();
  }

  /// In: any datetime in a month
  /// Out: the 1st of the month at 00:00
  static DateTime getOneMonthAgo(DateTime date) {
    if (date.month == DateTime.january) {
      return DateTime(date.year - 1, DateTime.december);
    }
    return DateTime(date.year, date.month - 1);
  }

  /// In: any datetime in a month
  /// Out: the 1st of the month at 00:00
  static DateTime getOneMonthNext(DateTime date) {
    if (date.month == DateTime.december) {
      return DateTime(date.year + 1, DateTime.january);
    }
    return DateTime(date.year, date.month + 1);
  }

  static String docIdFromLocalTime(DateTime localTime) {
    return jst1stMillisecondsSinceEpoch(localTime);
  }
}
