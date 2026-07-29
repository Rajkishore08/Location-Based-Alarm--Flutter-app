# Flutter & Android Proguard Rules for Release APK Stability
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.google.firebase.**
-dontwarn io.flutter.plugins.**
