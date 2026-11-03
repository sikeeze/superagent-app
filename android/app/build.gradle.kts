plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.superagent.superagent"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // Signing rilis dibaca dari file properti LOKAL (S-02: keystore tidak
    // boleh di repositori). Lihat android/signing.properties.example.
    val signingProps = rootProject.file("signing.properties")
    val hasSigning = signingProps.exists()

    if (hasSigning) {
        val props = java.util.Properties()
        props.load(signingProps.inputStream())
        signingConfigs {
            create("release") {
                keyAlias = props.getProperty("keyAlias")
                keyPassword = props.getProperty("keyPassword")
                storeFile = file(props.getProperty("storeFile"))
                storePassword = props.getProperty("storePassword")
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.superagent.superagent"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing dengan debug keys bila file properti tidak ada.
            if (hasSigning) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
