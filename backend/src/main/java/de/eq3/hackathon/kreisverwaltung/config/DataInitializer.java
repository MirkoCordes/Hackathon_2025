package de.eq3.hackathon.kreisverwaltung.config;

import de.eq3.hackathon.kreisverwaltung.entity.Certificate;
import de.eq3.hackathon.kreisverwaltung.entity.Datasource;
import de.eq3.hackathon.kreisverwaltung.entity.User;
import de.eq3.hackathon.kreisverwaltung.repository.DatasourceRepository;
import de.eq3.hackathon.kreisverwaltung.repository.UserRepository;
import lombok.RequiredArgsConstructor;

import java.util.List;

import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final DatasourceRepository datasourceRepository;

    @Override
    public void run(String... args) throws Exception {
        // Create default admin user if not exists
        if (!userRepository.existsByUsername("admin")) {
            User admin = new User();
            admin.setUsername("admin");
            admin.setEmail("admin@datenraum.de");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setRole(User.Role.ADMIN);
            admin.setEnabled(true);

            userRepository.save(admin);
            System.out.println("✅ Default admin user created: admin / admin123");
        }

        // Create default test user if not exists
        if (!userRepository.existsByUsername("testuser")) {
            User testUser = new User();
            testUser.setUsername("testuser");
            testUser.setEmail("test@datenraum.de");
            testUser.setPassword(passwordEncoder.encode("test123"));
            testUser.setRole(User.Role.USER);
            testUser.setEnabled(true);
            userRepository.save(testUser);
            System.out.println("✅ Default test user created: testuser / test123");
        }

        // Create default datasources if none exist
        if (datasourceRepository.count() == 0) {
            // Beispiel 1: Öffentliche Verkehrsdaten
            Datasource verkehrsdaten = new Datasource();
            verkehrsdaten.setTitle("Verkehrsströme Landkreis Leer");
            verkehrsdaten.setDescription(
                    "Tägliche Verkehrszählungen an Hauptverkehrsstraßen im Landkreis Leer. Enthält Daten über Fahrzeugfrequenz, Durchschnittsgeschwindigkeit und Verkehrsaufkommen.");
            verkehrsdaten.setCategory(Datasource.Category.GOVERNMENT);
            verkehrsdaten.setDataFormat(Datasource.DataFormat.CSV);
            verkehrsdaten.setAccessLevel(Datasource.AccessLevel.PUBLIC);
            verkehrsdaten.setContactEmail("verkehr@lkleer.de");
            verkehrsdaten.setContactName("Amt für Straßen und Verkehr");
            verkehrsdaten.setOrganization("Landkreis Leer");
            verkehrsdaten.setDataUrl("https://opendata.lkleer.de/verkehr/daily-counts.csv");
            verkehrsdaten.setUpdateFrequency("Täglich");
            verkehrsdaten.setLicenseType("CC0 - Public Domain");
            verkehrsdaten.setRequiresCertificate(false);
            verkehrsdaten.setDataSensitivity(Datasource.DataSensitivity.PUBLIC);
            verkehrsdaten.getTags().addAll(List.of("Verkehr", "Mobilität", "Ostfriesland", "Öffentlich"));
            verkehrsdaten.getAdditionalMetadata().put("Messstandorte", "15 Zählstellen");
            verkehrsdaten.getAdditionalMetadata().put("Zeitraum", "Seit 2020");

            // Beispiel 2: Umweltdaten mit Zertifikat
            Datasource umweltdaten = new Datasource();
            umweltdaten.setTitle("Grundwasser-Messwerte Aurich");
            umweltdaten.setDescription(
                    "Kontinuierliche Überwachung der Grundwasserqualität und -stände im Landkreis Aurich. Enthält sensible Daten über Nitratbelastung und Schadstoffe.");
            umweltdaten.setCategory(Datasource.Category.GOVERNMENT);
            umweltdaten.setDataFormat(Datasource.DataFormat.REST_API);
            umweltdaten.setAccessLevel(Datasource.AccessLevel.RESTRICTED);
            umweltdaten.setContactEmail("umwelt@aurich.de");
            umweltdaten.setContactName("Dr. Maria Schmidt");
            umweltdaten.setOrganization("Landkreis Aurich - Umweltamt");
            umweltdaten.setDataUrl("https://api.aurich.de/umwelt/groundwater");
            umweltdaten.setDocumentationUrl("https://docs.aurich.de/umwelt-api");
            umweltdaten.setUpdateFrequency("Stündlich");
            umweltdaten.setLicenseType("Behördenlizenz");
            umweltdaten.setRequiresCertificate(true);
            umweltdaten.setDataSensitivity(Datasource.DataSensitivity.RESTRICTED);
            umweltdaten.getRequiredCertificateTypes().addAll(List.of(
                    Certificate.CertificateType.GOVERNMENT_ENVIRONMENT,
                    Certificate.CertificateType.RESEARCH_ENVIRONMENTAL));
            umweltdaten.setCertificateRequirements("Umwelt-Behördenzertifikat oder Umweltforschung erforderlich");
            umweltdaten.getTags().addAll(List.of("Umwelt", "Grundwasser", "Nitrat", "Forschung", "Sensibel"));
            umweltdaten.getAdditionalMetadata().put("Messstellen", "45 Brunnen");
            umweltdaten.getAdditionalMetadata().put("Parameter", "pH, Nitrat, Schwermetalle, Pestizide");

            // Beispiel 3: Wirtschaftsdaten
            Datasource wirtschaftsdaten = new Datasource();
            wirtschaftsdaten.setTitle("Tourismusstatistik Wittmund");
            wirtschaftsdaten.setDescription(
                    "Übernachtungszahlen, Gästeankunfte und touristische Kennzahlen für den Landkreis Wittmund. Wichtig für Tourismusförderung und Regionalplanung.");
            wirtschaftsdaten.setCategory(Datasource.Category.BUSINESS);
            wirtschaftsdaten.setDataFormat(Datasource.DataFormat.EXCEL);
            wirtschaftsdaten.setAccessLevel(Datasource.AccessLevel.PUBLIC);
            wirtschaftsdaten.setContactEmail("tourismus@wittmund.de");
            wirtschaftsdaten.setContactName("Wirtschaftsförderung Wittmund");
            wirtschaftsdaten.setOrganization("Landkreis Wittmund");
            wirtschaftsdaten.setUpdateFrequency("Monatlich");
            wirtschaftsdaten.setLicenseType("CC-BY 4.0");
            wirtschaftsdaten.setRequiresCertificate(false);
            wirtschaftsdaten.setDataSensitivity(Datasource.DataSensitivity.PUBLIC);
            wirtschaftsdaten.getTags().addAll(List.of("Tourismus", "Wirtschaft", "Statistik", "Wittmund"));

            // Beispiel 4: Gesundheitsdaten (sehr sensibel)
            Datasource gesundheitsdaten = new Datasource();
            gesundheitsdaten.setTitle("Anonymisierte Krankenhausstatistik Emden");
            gesundheitsdaten.setDescription(
                    "Anonymisierte Daten zu Behandlungsfällen, Kapazitätsauslastung und epidemiologischen Trends im Klinikum Emden. Streng anonymisiert nach DSGVO.");
            gesundheitsdaten.setCategory(Datasource.Category.GOVERNMENT);
            gesundheitsdaten.setDataFormat(Datasource.DataFormat.JSON);
            gesundheitsdaten.setAccessLevel(Datasource.AccessLevel.RESTRICTED);
            gesundheitsdaten.setContactEmail("statistik@klinikum-emden.de");
            gesundheitsdaten.setContactName("Prof. Dr. Hans Mueller");
            gesundheitsdaten.setOrganization("Klinikum Emden");
            gesundheitsdaten.setUpdateFrequency("Monatlich");
            gesundheitsdaten.setLicenseType("Medizinische Forschungslizenz");
            gesundheitsdaten.setRequiresCertificate(true);
            gesundheitsdaten.setDataSensitivity(Datasource.DataSensitivity.CLASSIFIED);
            gesundheitsdaten.getRequiredCertificateTypes().addAll(List.of(
                    Certificate.CertificateType.GOVERNMENT_HEALTH,
                    Certificate.CertificateType.RESEARCH_HEALTH,
                    Certificate.CertificateType.PROFESSIONAL_DOCTOR));
            gesundheitsdaten
                    .setCertificateRequirements("Nur für Gesundheitsbehörden, medizinische Forschung oder Ärzte");
            gesundheitsdaten.getTags().addAll(List.of("Gesundheit", "Epidemiologie", "Anonymisiert", "Forschung"));

            // Beispiel 5: NGO-Transparenzdaten
            Datasource transparenzdaten = new Datasource();
            transparenzdaten.setTitle("Lobbyisten-Register Ostfriesland");
            transparenzdaten.setDescription(
                    "Öffentliches Register aller registrierten Lobbyisten und deren Aktivitäten in den Landkreisen Ostfrieslands. Für Transparenz in der Politik.");
            transparenzdaten.setCategory(Datasource.Category.CIVIL_SOCIETY);
            transparenzdaten.setDataFormat(Datasource.DataFormat.CSV);
            transparenzdaten.setAccessLevel(Datasource.AccessLevel.PUBLIC);
            transparenzdaten.setContactEmail("info@transparenz-ostfriesland.de");
            transparenzdaten.setContactName("Bürgerinitiative Transparenz");
            transparenzdaten.setOrganization("Transparenz Ostfriesland e.V.");
            transparenzdaten.setUpdateFrequency("Wöchentlich");
            transparenzdaten.setLicenseType("CC-BY 4.0");
            transparenzdaten.setRequiresCertificate(false);
            transparenzdaten.setDataSensitivity(Datasource.DataSensitivity.PUBLIC);
            transparenzdaten.getTags().addAll(List.of("Transparenz", "Politik", "Lobbyismus", "Bürgerbeteiligung"));

            datasourceRepository
                    .saveAll(List.of(verkehrsdaten, umweltdaten, wirtschaftsdaten, gesundheitsdaten, transparenzdaten));
            System.out.println("✅ Default datasources created: 5 realistische Beispiel-Datenquellen");
        }
    }
}