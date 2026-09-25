allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.set(file("${project.projectDir}/../build"))
subprojects {
    project.layout.buildDirectory.set(file("${rootProject.layout.buildDirectory.get()}/${project.name}"))
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    // Relying on kotlin.jvm.target.validation.mode=warning in gradle.properties
}
