# Keep awesome_notifications classes for release builds
-keep class me.carda.awesome_notifications.** { *; }
-keep class androidx.work.** { *; }
-keep class com.google.firebase.** { *; }

# Keep notification receiver classes
-keep class * extends android.content.BroadcastReceiver
-keep class * extends android.app.Service

# Keep all notification related classes
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Prevent stripping of notification resources
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Awesome Notifications specific rules
-dontwarn me.carda.awesome_notifications.**
-keep class io.flutter.plugins.** { *; }