# === Gemalto SDK (gempcsc) ===

# Keep Gemalto Reader classes
-keep class com.gemalto.gempcsc.GemPCSC_Reader { *; }
-keep class com.gemalto.gempcsc.IGemPCSC$Stub { *; }
-keep class com.gemalto.gempcsc.IGemPCSC { *; }

# Prevent warnings for Gemalto SDK
-dontwarn com.gemalto.**

# === SecureMetric SDK (myID.aar) ===

# Keep all classes under these namespaces
-keep class com.securemetric.reader.myid.** { *; }
-keep class com.securemetric.myidreader.** { *; }

# Keep License-related classes and members
-keep class com.securemetric.reader.myid.License { *; }
-keep class com.securemetric.reader.myid.License$LicenseInfo { *; }
-keepclassmembers class com.securemetric.reader.myid.License$LicenseInfo {
    <methods>;
}
-keepclassmembers class com.securemetric.reader.myid.License {
    <methods>;
}

# Prevent warnings for SecureMetric SDK
-dontwarn com.securemetric.reader.myid.**
-dontwarn com.securemetric.myidreader.**

# === Your SDK classes (mykad_sdk) ===
-keep class com.example.mykad_sdk.** { *; }
-dontwarn com.example.mykad_sdk.**

# === Flutter MainActivity ===
-keep class com.pppa.bancian.MainActivity { *; }

# === AIDL & Android Services (Safe Reflection Usage) ===

# Keep AIDL interfaces and classes
-keep interface **.IGemPCSC
-keep class * implements android.os.IInterface { *; }

# Keep service connection classes and callbacks
-keep class * {
    void onServiceConnected(android.content.ComponentName, android.os.IBinder);
}
-keep class * extends android.app.Service { *; }

# === Reflection Support ===

# Keep public constructors
-keepclassmembers class * {
    public <init>(...);
}

# Keep all annotations (runtime usage)
-keepattributes *Annotation*

# Keep members marked with @Keep
-keepclassmembers class * {
    @android.annotation.Keep *;
}

# === JNI & Native Methods ===
-keepclasseswithmembernames class * {
    native <methods>;
}

# === Optional Debugging ===
-keepattributes SourceFile,LineNumberTable

# === Flutter Support ===

# Flutter engine internals and split components
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# Flutter Play Core plugin
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.**

# Flutter embedding & JNI
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# === General Safe Fallback ===

# Keep all inner class members (helps avoid MissingMethod errors)
-keepclassmembers class * {
    *;
}
