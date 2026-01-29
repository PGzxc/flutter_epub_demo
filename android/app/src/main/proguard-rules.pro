# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# InAppWebView
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }
-keep class * extends com.pichillilorenzo.flutter_inappwebview.** { *; }
-keepclassmembers class com.pichillilorenzo.flutter_inappwebview.** { *; }

# JavaScript Interface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# WebView JavaScript Bridge
-keep class android.webkit.JavascriptInterface { *; }
-keep class android.webkit.WebView { *; }
-keep class android.webkit.WebViewClient { *; }
-keep class android.webkit.WebChromeClient { *; }
-keep class android.webkit.WebSettings { *; }

# WebView
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
}
-keepclassmembers class * extends android.webkit.WebChromeClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
}

# File access
-keep class java.io.** { *; }
-keep class java.nio.** { *; }

# Don't obfuscate file paths and URIs
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Preserve annotations
-keepattributes *Annotation*

# Preserve enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Preserve native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserve Kotlin metadata
-keep class kotlin.Metadata {
    *;
}

# Preserve certain classes from being obfuscated
-keep class com.pgzxc.flutter_epub_demo.** { *; }
