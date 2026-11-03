plugins {
    id("java")
    application
}

group = "com.xpromus"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.java-websocket:Java-WebSocket:1.6.0")
    testImplementation(platform("org.junit:junit-bom:6.0.0"))
    testImplementation("org.junit.jupiter:junit-jupiter")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

tasks.test {
    useJUnitPlatform()
}

application {
    // Default: com.xpromus.Main (raw frame printing)
    // Simple server: ./gradlew run -PmainClass=com.xpromus.SimpleServer
    mainClass.set(providers.gradleProperty("mainClass").orElse("com.xpromus.Main"))
}