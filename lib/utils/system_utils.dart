import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

///
/// 系统、设备相关信息的工具类
///

class SystemUtils {

  static PackageInfo _packageInfo;

  static Future<PackageInfo> getPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
    return _packageInfo;
  }

  static String appName() {
    return _packageInfo.appName;
  }

  static String packageName() {
    return _packageInfo.packageName;
  }

  static String version() {
    return _packageInfo.version;
  }

  static String buildNumber() {
    return _packageInfo.buildNumber;
  }

  /// ----------- 屏幕分辨率 ----------

  static MediaQueryData _queryData;

  static MediaQueryData getMediaQueryData(BuildContext context) {
    _queryData = MediaQuery.of(context);
    return _queryData;
  }

  static double getStatusHeight(BuildContext context) {
    if (_queryData == null) {
      _queryData = MediaQuery.of(context);
    }
    return _queryData.padding.top;
  }

  static double getWidth(BuildContext context) {
    if (_queryData == null) {
      _queryData = MediaQuery.of(context);
    }
    return _queryData.size.width;
  }

  static double getHeight(BuildContext context) {
    if (_queryData == null) {
      _queryData = MediaQuery.of(context);
    }
    return _queryData.size.height;
  }

  static double getPixel(BuildContext context) {
    if (_queryData == null) {
      _queryData = MediaQuery.of(context);
    }
    return _queryData.devicePixelRatio;
  }

}