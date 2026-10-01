allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.set(file("${project.projectDir}/../build"))
subprojects {
    if (project.projectDir.path.startsWith(rootProject.projectDir.path)) {
        project.layout.buildDirectory.set(file("${rootProject.layout.buildDirectory.get()}/${project.name}"))
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
