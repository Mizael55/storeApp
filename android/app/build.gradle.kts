plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.store_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.store_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    signingConfigs {
        create("release") {
            storeFile = file("/Users/mizaelsoler/client-proyect/storeApp/my-release-key.jks")
            storePassword = "19980923"
            keyAlias = "my-key-alias"
            keyPassword = "19980923"
        }
    }
    buildTypes {
        // obtener el buildType "release" con getByName
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            // asignar el signingConfig correcto usando getByName
            signingConfig = signingConfigs.getByName("release")
        }

        // por si quieres cambiar el debug (opcional)
        getByName("debug") {
            // Mantén la configuración por defecto o personaliza si lo necesitas
        }
    
    }
}

flutter {
    source = "../.."
}
