allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory = rootProject.layout.projectDirectory.dir("../build")

subprojects {
project.layout.buildDirectory = rootProject.layout.buildDirectory.get().dir(project.name)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
