-dontnote android.net.http.**
-dontnote com.google.**
-dontnote org.apache.http.**
-dontnote kotlin.**
-dontwarn kotlin.**

#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep,includedescriptorclasses class io.flutter.plugins.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }