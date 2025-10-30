// 1. TAMBAHKAN IMPORT INI DI BARIS PALING ATAS
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 2. FUNGSI UNTUK MEMBACA local.properties
fun localProperties(): Properties {
    val properties = Properties()
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        properties.load(FileInputStream(localPropertiesFile))
    }
    return properties
}

// 3. BACA PROPERTI FLUTTER (termasuk versionCode dan versionName)
val flutterVersionCode: String? by localProperties()
val flutterVersionName: String? by localProperties()
val flutterRoot: String by localProperties()

android {
    namespace = "com.example.astroview" // Pastikan namespace ini sesuai
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // 4. PERBAIKI SINTAKS DESUGARING (is...Enabled = true)
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets["main"].java.srcDirs("src/main/kotlin")

    defaultConfig {
        applicationId = "com.example.astroview" // Pastikan ini sesuai
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        
        // 5. PERBAIKI SINTAKS VERSION CODE (toInt() ?: 1)
        versionCode =  1
        // 6. PERBAIKI SINTAKS VERSION NAME (?: "1.0")
        versionName = "1.0"
        
        // 7. PERBAIKI SINTAKS MULTIDEX
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(kotlin("stdlib-jdk7"))
    
    // 8. PERBAIKI SINTAKS DEPENDENSI DESUGARING (...)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}