# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-keep class io.flutter.plugin.editing.** { *; }

# Firestore
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.firebase.storage.** { *; }


# GetX
-keep class getx.** { *; }
-dontwarn getx.**

# Prevent R8 from removing unused classes
-keepattributes Signature
-keepattributes *Annotation*

# Flutter and Dart
-keep class io.flutter.** { *; }
-keep class dart.** { *; }
-dontwarn io.flutter.**

# Flutter fonts and assets
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keepclassmembers class * {
    @io.flutter.embedding.engine.dart.DartEntrypoint <methods>;
}

# Font rendering
-keep class android.graphics.** { *; }
-keep class android.text.** { *; }
-keep class androidx.core.content.res.FontResourcesParserCompat** { *; }

# Screen utils and responsive design
-keep class flutter_screenutil.** { *; }
-dontwarn flutter_screenutil.**

# Custom fonts (SF Pro Display)
-keep class androidx.core.provider.FontsContractCompat** { *; }
-keep class android.support.v4.provider.FontsContractCompat** { *; }

# Google Fonts
-keep class com.google.fonts.** { *; }
-dontwarn com.google.fonts.**
-keep class com.google.android.gms.fonts.** { *; }

# Font fallbacks and system fonts
-keep class android.graphics.Typeface** { *; }
-keep class android.graphics.fonts.** { *; }

# Asset loading
-keepnames class * extends android.os.Parcelable
-keepclassmembers class * extends android.os.Parcelable {
    static ** CREATOR;
}

# R8 specific for fonts
-keep class **.R
-keep class **.R$*
-keepclassmembers class **.R$* {
    public static <fields>;
}