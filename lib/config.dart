///
/// 配置工具类
///

enum Env {DEBUG, RELEASE}

class Config {
  static const String BUGLY_ANDROID_APP_ID = "66300941b6";
  static const String BUGLY_IOS_APP_ID = "d59c7b2495";

  static const String DEFAULT_LANGUAGE = "zh";
  static const int ASSET_PAGE_STYLE = 1;

  static const Env env = Env.RELEASE;
  static bool get debug{
    switch(env){
      case Env.DEBUG:
        return true;
      case Env.RELEASE:
        return false;
      default:
        return true;
    }
  }
}