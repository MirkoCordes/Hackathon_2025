package de.eq3.hackathon.kreisverwaltung.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;
import java.nio.file.Paths;

@Configuration
public class StaticResourceConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Absoluter Pfad zum externen Frontend-Verzeichnis
        Path externalDir = Paths.get("../flutter_frontend/build/web").toAbsolutePath().normalize();

        registry.addResourceHandler("/**")
                .addResourceLocations("file:" + externalDir + "/")
                .setCachePeriod(0); // Optional: Deaktiviert Caching für Entwicklungszwecke
    }
}
