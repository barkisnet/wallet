# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /Users/ecomsh/Library/Android/sdk/tools/proguard/proguard-android.txt
# You can edit the include path and order by bobo the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}


#【jar包所在地址】
#-injars  androidtest.jar
#【输出地址】
#-outjars  out

# 指定代码的压缩级别
-optimizationpasses 7
# 包明不混合大小写
-dontusemixedcaseclassnames
# 不去忽略非公共的库类
-dontskipnonpubliclibraryclasses
-dontskipnonpubliclibraryclassmembers
# 优化 不优化输入的类文件
-dontoptimize
# 预校验
-dontpreverify
# 混淆时是否记录日志
-verbose
# 忽略警告
-ignorewarnings

#####################记录生成的日志数据,gradle build时在本项目根目录输出################
#apk 包内所有 class 的内部结构
-dump class_files.txt
#未混淆的类和成员
-printseeds seeds.txt
#列出从 apk 中删除的代码
-printusage unused.txt
#混淆前后的映射
-printmapping mapping.txt

#项目里面包含的包也不能混淆
-keep class androidx.** {*;}
-dontwarn androidx.**
-keep class androidx.test.** {*;}
-dontwarn androidx.test.**
-keep class io.github.ponnamkarthik.toast.fluttertoast.** {*;}
-dontwarn io.github.ponnamkarthik.toast.fluttertoast.**
-keep class de.mintware.barcode_scan.** {*;}
-dontwarn de.mintware.barcode_scan.**
-keep class com.tekartik.sqflite.** {*;}
-dontwarn com.tekartik.sqflite.**
-keep class com.crazecoder.flutterbugly.** {*;}
-dontwarn com.crazecoder.flutterbugly.**
-keep class com.flutter_webview_plugin.** {*;}
-dontwarn com.flutter_webview_plugin.**
-keep class com.baseflow.permissionhandler.** {*;}
-dontwarn com.baseflow.permissionhandler.**
-keep class io.flutter.plugins.imagepicker.** {*;}
-dontwarn io.flutter.plugins.imagepicker.**
-keep class com.crazecoder.openfile.** {*;}
-dontwarn com.crazecoder.openfile.**
-keep class io.flutter.plugins.packageinfo.** {*;}
-dontwarn io.flutter.plugins.packageinfo.**
-keep class io.flutter.plugins.pathprovider.** {*;}
-dontwarn io.flutter.plugins.pathprovider.**
-keep class io.flutter.plugins.sharedpreferences.** {*;}
-dontwarn io.flutter.plugins.sharedpreferences.**

## Flutter wrapper
-keep class io.flutter.app.** { *; }
-dontwarn io.flutter.app.**
-keep class io.flutter.plugin.**  { *; }
-dontwarn io.flutter.plugin.**
-keep class io.flutter.util.**  { *; }
-dontwarn io.flutter.util.**
-keep class io.flutter.view.**  { *; }
-dontwarn io.flutter.view.**
-keep class io.flutter.**  { *; }
-dontwarn io.flutter.**
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.plugins.**
-keep class io.flutter.embedding.** { *;}
-dontwarn io.flutter.embedding.**

# 混淆时所采用的算法
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*

-keepattributes Exceptions, Signature, InnerClasses, EnclosingMethod

-keep public class io.blockchainnetwork.wallet.R$*{ public static final int *; }

-keepclassmembers class * {
    public <init>(org.json.JSONObject);
}

#保持 Serializable 不被混淆
-keepnames class * implements java.io.Serializable
#保持 Parcelable 不被混淆
-keepnames class * implements android.os.Parcelable

#保持 Serializable 不被混淆并且enum 类也不被混淆
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    !private <methods>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

-keepclasseswithmembernames class * {
    native <methods>;
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

-keepclassmembers class * implements android.os.Parcelable {
    public <fields>;
    private <fields>;
}
