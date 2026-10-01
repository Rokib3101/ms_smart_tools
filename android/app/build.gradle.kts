import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.mssmarttools.app"
    compileSdk = 36
    buildToolsVersion = "36.0.0"
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        jvmToolchain(17)
    }

    buildFeatures {
        resValues = true
    }

    defaultConfig {
        applicationId = "com.mssmarttools.app"
        minSdk = 24 // Updated for better library support
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions.add("app")
    productFlavors {
        create("calculator") {
            dimension = "app"
            applicationId = "com.mssmarttools.calculator"
            resValue("string", "app_name", "MS Calculator")
        }
        create("finance") {
            dimension = "app"
            applicationId = "com.mssmarttools.finance"
            resValue("string", "app_name", "MS Finance")
        }
        create("image") {
            dimension = "app"
            applicationId = "com.mssmarttools.image"
            resValue("string", "app_name", "MS Image")
        }
        create("full") {
            dimension = "app"
            applicationId = "com.mssmarttools.app"
            resValue("string", "app_name", "MS Smart Tools")
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = true
        }
    }
}

flutter {
    source = "../.."
}