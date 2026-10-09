import java.util.Base64

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Values passed with --dart-define / --dart-define-from-file reach Gradle as the
// "dart-defines" property (comma-separated, each base64 of "KEY=value"). Reading them here
// keeps one source of truth (config/dev.json) for both the Dart code and the native
// Facebook SDK. Environment variables of the same name are the fallback (e.g. CI).
val dartDefines: Map<String, String> =
    (project.findProperty("dart-defines") as String?)
        ?.split(",")
        ?.mapNotNull { encoded ->
            runCatching { String(Base64.getDecoder().decode(encoded)) }.getOrNull()
                ?.split("=", limit = 2)
                ?.takeIf { it.size == 2 }
                ?.let { it[0] to it[1] }
        }
        ?.toMap()
        ?: emptyMap()

fun buildSetting(name: String): String = dartDefines[name] ?: System.getenv(name) ?: ""

// Meta SDK identifiers. Not secrets (Meta embeds them in every app), but per-environment.
// The SDK refuses to start without an app id, so an unconfigured build gets a placeholder
// and the app itself refuses Instagram / Facebook sign-in (MetaSignIn.isConfigured).
val facebookAppId = buildSetting("FACEBOOK_APP_ID").ifEmpty { "0" }
val facebookClientToken = buildSetting("FACEBOOK_CLIENT_TOKEN").ifEmpty { "not-configured" }

android {
    namespace = "com.xeasify.xeasify_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    buildFeatures {
        // The Facebook SDK ids below are generated string resources (resValue).
        resValues = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.xeasify.xeasify_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        resValue("string", "facebook_app_id", facebookAppId)
        resValue("string", "facebook_client_token", facebookClientToken)
        resValue("string", "fb_login_protocol_scheme", "fb$facebookAppId")
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
