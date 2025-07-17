// Project-level build.gradle.kts

plugins {
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
    id("com.google.gms.google-services") version "4.3.15" apply false // ✅ Firebase plugin
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Custom Build Directory Setup (as you had)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

// ✅ Clean Task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
