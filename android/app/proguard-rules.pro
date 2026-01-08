# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.kts.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# Keep data for android.arch.lifecycle and androidx.lifecycle
-keep class * extends androidx.lifecycle.ViewModel { *; }
-keep class * extends androidx.lifecycle.ViewModelStore { *; }
-keep class * extends androidx.lifecycle.LifecycleObserver { *; }
-keep class * extends androidx.lifecycle.LifecycleOwner { *; }

# Keep data for androidx
-keep class androidx.** { *; }
-dontwarn androidx.**

# Keep data for geolocator (Google Play Services)
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.gms.location.** { *; }
-dontwarn com.google.android.gms.**

# Keep data for connectivity_plus
-keep class androidx.core.content.** { *; }
-keep class android.net.** { *; }

# Keep data for image_picker
-keep class androidx.activity.** { *; }
-keep class androidx.fragment.app.** { *; }

# Keep data for flutter_secure_storage
-keep class androidx.security.crypto.** { *; }
-keep class android.security.keystore.** { *; }