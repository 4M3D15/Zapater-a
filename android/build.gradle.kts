buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2' // Usa una versión compatible
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.6.21' // Versión de Kotlin
        classpath 'com.google.gms:google-services:4.3.10' // Si usas Firebase
    }
}
