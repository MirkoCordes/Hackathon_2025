package de.eq3.hackathon.kreisverwaltung.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.Components;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI datenraumOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Datenraum Ostfriesland API")
                        .description("""
                                REST API für den digitalen Datenraum Ostfriesland - eine zentrale Plattform
                                für verfügbare und gewünschte Datenquellen aus Verwaltung, Wirtschaft,
                                Wissenschaft und Zivilgesellschaft.

                                ## Features:
                                - 🗂️ **Datenkatalog**: Suche und Filterung von Datenquellen
                                - 📜 **Zertifikatsverwaltung**: Upload und Prüfung von Zugangszertifikaten
                                - 🔐 **Zugangskontrolle**: Rollenbasierte Berechtigung für sensible Daten
                                - 📋 **Antragsmanagement**: Beantragung und Genehmigung von Datenzugängen

                                ## Authentifizierung:
                                Die meisten Endpoints benötigen einen JWT-Token. Loggen Sie sich zunächst
                                über `/api/auth/login` ein und verwenden Sie den erhaltenen Token.

                                ## Test-Credentials:
                                - **Admin**: `admin` / `admin123`
                                - **User**: `testuser` / `test123`
                                """)
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("Hackathon Team Ostfriesland")
                                .email("info@datenraum-ostfriesland.de")
                                .url("https://github.com/MirkoCordes/Hackathon_2025"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")))
                .addSecurityItem(new SecurityRequirement().addList("Bearer Authentication"))
                .components(new Components()
                        .addSecuritySchemes("Bearer Authentication",
                                new SecurityScheme()
                                        .type(SecurityScheme.Type.HTTP)
                                        .scheme("bearer")
                                        .bearerFormat("JWT")
                                        .description("JWT Token für die Authentifizierung. " +
                                                "Format: 'Bearer <your-jwt-token>'")));
    }
}