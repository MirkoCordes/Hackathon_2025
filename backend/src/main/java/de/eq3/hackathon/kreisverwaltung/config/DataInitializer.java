package de.eq3.hackathon.kreisverwaltung.config;

import de.eq3.hackathon.kreisverwaltung.entity.Certificate;
import de.eq3.hackathon.kreisverwaltung.entity.DataAccessRequest;
import de.eq3.hackathon.kreisverwaltung.entity.DataRequest;
import de.eq3.hackathon.kreisverwaltung.entity.Datasource;
import de.eq3.hackathon.kreisverwaltung.entity.User;
import de.eq3.hackathon.kreisverwaltung.repository.CertificateRepository;
import de.eq3.hackathon.kreisverwaltung.repository.DataAccessRequestRepository;
import de.eq3.hackathon.kreisverwaltung.repository.DatasourceRepository;
import de.eq3.hackathon.kreisverwaltung.repository.UserRepository;
import de.eq3.hackathon.kreisverwaltung.repository.DataRequestRepository;
import lombok.RequiredArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final DatasourceRepository datasourceRepository;
    private final CertificateRepository certificateRepository;
    private final DataAccessRequestRepository dataAccessRequestRepository;
        private final DataRequestRepository dataRequestRepository;

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        createUsers();
        createDatasources();
        createCertificates();
                createDataRequests();
        createDataAccessRequests();
    }

    private void createUsers() {
        if (userRepository.count() > 0) {
            return; // Users already exist
        }

        List<User> users = new ArrayList<>();

        // === ADMINS ===
        users.add(createUser("admin", "admin@datenraum.de", "admin123", User.Role.ADMIN,
                "Administrator", "System", "Datenraum Ostfriesland", "System Administrator"));

        users.add(createUser("reviewer", "reviewer@datenraum.de", "review123", User.Role.REVIEWER,
                "Dr. Petra", "Müller", "Datenraum Ostfriesland", "Daten-Reviewer"));

        // === DATA PROVIDERS ===
        users.add(createUser("provider.leer", "data@lkleer.de", "leer123", User.Role.DATA_PROVIDER,
                "Thomas", "Janssen", "Landkreis Leer", "Datenbeauftragte/r"));

        users.add(createUser("provider.aurich", "opendata@aurich.de", "aurich123", User.Role.DATA_PROVIDER,
                "Dr. Maria", "Schmidt", "Landkreis Aurich", "Umweltdatenmanagerin"));

        users.add(createUser("provider.wittmund", "daten@wittmund.de", "witt123", User.Role.DATA_PROVIDER,
                "Klaus", "Meyer", "Landkreis Wittmund", "IT-Leiter"));

        users.add(createUser("provider.emden", "statistik@emden.de", "emden123", User.Role.DATA_PROVIDER,
                "Prof. Dr. Hans", "Mueller", "Stadt Emden", "Statistikleiter"));

        // === RESEARCHERS ===
        users.add(createUser("forscher.uni", "j.hofmann@uni-oldenburg.de", "uni123", User.Role.USER,
                "Prof. Dr. Jürgen", "Hofmann", "Uni Oldenburg", "Umweltforscher"));

        users.add(createUser("forscher.medizin", "s.weber@meduni.de", "med123", User.Role.USER,
                "Dr. Sabine", "Weber", "Medizinische Hochschule", "Epidemiologin"));

        users.add(createUser("forscher.verkehr", "m.richter@verkehr-institut.de", "verkehr123", User.Role.USER,
                "Dipl.-Ing. Marcus", "Richter", "Verkehrsinstitut", "Verkehrsplaner"));

        // === GOVERNMENT USERS ===
        users.add(createUser("behoerde.umwelt", "daten@umwelt-nds.de", "umwelt123", User.Role.USER,
                "Dr. Anne", "Fischer", "Nds. Umweltministerium", "Umweltstatistikerin"));

        users.add(createUser("behoerde.gesundheit", "statistik@gesundheit-nds.de", "gesund123", User.Role.USER,
                "Dr. Michael", "Bauer", "Nds. Gesundheitsministerium", "Gesundheitsstatistiker"));

        users.add(createUser("behoerde.wirtschaft", "daten@mw.niedersachsen.de", "wirtschaft123", User.Role.USER,
                "Lisa", "Schneider", "Nds. Wirtschaftsministerium", "Wirtschaftsanalystin"));

        // === BUSINESS USERS ===
        users.add(createUser("business.tourismus", "data@ostfriesland-tourismus.de", "tour123", User.Role.USER,
                "Sarah", "Krüger", "Ostfriesland Tourismus GmbH", "Marktforscherin"));

        users.add(createUser("business.consulting", "info@data-consult-of.de", "consult123", User.Role.USER,
                "Dr. Frank", "Zimmermann", "Data Consulting Ostfriesland", "Datenanalyst"));

        users.add(createUser("business.energie", "statistik@enercon.de", "energie123", User.Role.USER,
                "Ing. Petra", "Wolff", "Enercon GmbH", "Energieanalystin"));

        // === NGO USERS ===
        users.add(createUser("ngo.umwelt", "daten@nabu-ostfriesland.de", "nabu123", User.Role.USER,
                "Biologin Marina", "Janßen", "NABU Ostfriesland", "Umweltschützerin"));

        users.add(createUser("ngo.transparenz", "info@transparenz-of.de", "trans123", User.Role.USER,
                "Journalist Tim", "Köhler", "Transparenz Ostfriesland e.V.", "Investigativjournalist"));

        users.add(createUser("ngo.sozial", "daten@diakonie-of.de", "sozial123", User.Role.USER,
                "Soziologin Dr. Heike", "Wagner", "Diakonie Ostfriesland", "Sozialforscherin"));

        // === REGULAR USERS ===
        users.add(createUser("testuser", "test@datenraum.de", "test123", User.Role.USER,
                "Max", "Mustermann", "Privatperson", "Bürger"));

        users.add(createUser("student.master", "l.mueller@student.uni.de", "student123", User.Role.USER,
                "Laura", "Müller", "Uni Oldenburg", "Masterstudentin Geographie"));

        users.add(createUser("journalist.nwz", "redaktion@nwz-online.de", "journal123", User.Role.USER,
                "Reporter Jan", "Peters", "Nordwest-Zeitung", "Lokaljournalist"));

        userRepository.saveAll(users);
        System.out.println("✅ Created " + users.size() + " diverse users from different sectors");
    }

    private User createUser(String username, String email, String password, User.Role role,
            String firstName, String lastName, String organization, String jobTitle) {
        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(password));
        user.setRole(role);
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setOrganization(organization);
        user.setJobTitle(jobTitle);
        user.setEnabled(true);
        return user;
    }

    private void createDatasources() {
        if (datasourceRepository.count() > 0) {
            return; // Datasources already exist
        }

        List<Datasource> datasources = new ArrayList<>();

        // === PUBLIC GOVERNMENT DATA ===
        datasources.add(createDatasource(
                "Verkehrsströme Landkreis Leer",
                "Tägliche Verkehrszählungen an Hauptverkehrsstraßen im Landkreis Leer. Enthält Daten über Fahrzeugfrequenz, Durchschnittsgeschwindigkeit und Verkehrsaufkommen zu verschiedenen Tageszeiten.",
                Datasource.Category.GOVERNMENT, Datasource.DataFormat.CSV, Datasource.AccessLevel.PUBLIC,
                "verkehr@lkleer.de", "Amt für Straßen und Verkehr", "Landkreis Leer",
                "https://opendata.lkleer.de/verkehr/daily-counts.csv", null,
                "Täglich", "CC0 - Public Domain", false, null,
                Datasource.DataSensitivity.PUBLIC, null,
                List.of("Verkehr", "Mobilität", "Ostfriesland", "Öffentlich", "Zählstellen"),
                Map.of("Messstandorte", "15 Zählstellen", "Zeitraum", "Seit 2020", "Format", "CSV mit Zeitstempel")));

        datasources.add(createDatasource(
                "Bevölkerungsstatistik Aurich",
                "Demografische Daten des Landkreises Aurich: Altersstruktur, Zu- und Fortzüge, Geburten- und Sterbezahlen. Wichtig für Stadtplanung und soziale Dienste.",
                Datasource.Category.GOVERNMENT, Datasource.DataFormat.JSON, Datasource.AccessLevel.PUBLIC,
                "statistik@aurich.de", "Einwohnermeldeamt Aurich", "Landkreis Aurich",
                "https://api.aurich.de/demographie/stats", "https://docs.aurich.de/demographie-api",
                "Quartalsweise", "CC-BY 4.0", false, null,
                Datasource.DataSensitivity.PUBLIC, null,
                List.of("Demographie", "Bevölkerung", "Statistik", "Planung", "Aurich"),
                Map.of("Aktualisierung", "Quartalsweise", "Granularität", "Ortsteile", "Zeitreihe", "Seit 2010")));

        datasources.add(createDatasource(
                "Windenergie-Anlagen Ostfriesland",
                "Standorte, Leistungsdaten und Betriebsstatistiken aller Windenergieanlagen in Ostfriesland. Öffentliche Daten zur Energiewende-Überwachung.",
                Datasource.Category.GOVERNMENT, Datasource.DataFormat.SHAPEFILE, Datasource.AccessLevel.PUBLIC,
                "energie@ostfriesland.de", "Energieagentur Ostfriesland", "Landkreise Ostfriesland",
                "https://gis.ostfriesland.de/windenergie/anlagen.shp", "https://energie-ostfriesland.de/daten-docs",
                "Monatlich", "CC-BY 4.0", false, null,
                Datasource.DataSensitivity.PUBLIC, null,
                List.of("Windenergie", "Erneuerbare Energie", "GIS", "Ostfriesland", "Klimaschutz"),
                Map.of("Anlagen", "2.847 WEA", "Gesamtleistung", "4.200 MW", "Koordinatensystem", "EPSG:25832")));

        // === RESTRICTED GOVERNMENT DATA ===
        datasources.add(createDatasource(
                "Grundwasser-Messwerte Aurich",
                "Kontinuierliche Überwachung der Grundwasserqualität und -stände im Landkreis Aurich. Enthält sensible Daten über Nitratbelastung, Schwermetalle und Pestizide.",
                Datasource.Category.GOVERNMENT, Datasource.DataFormat.REST_API, Datasource.AccessLevel.RESTRICTED,
                "umwelt@aurich.de", "Dr. Maria Schmidt", "Landkreis Aurich - Umweltamt",
                "https://api.aurich.de/umwelt/groundwater", "https://docs.aurich.de/umwelt-api",
                "Stündlich", "Behördenlizenz", true,
                List.of(Certificate.CertificateType.GOVERNMENT_ENVIRONMENT,
                        Certificate.CertificateType.RESEARCH_ENVIRONMENTAL),
                Datasource.DataSensitivity.RESTRICTED, "Umwelt-Behördenzertifikat oder Umweltforschung erforderlich",
                List.of("Umwelt", "Grundwasser", "Nitrat", "Forschung", "Sensibel", "Wasserschutz"),
                Map.of("Messstellen", "45 Brunnen", "Parameter", "pH, Nitrat, Schwermetalle, Pestizide",
                        "Messintervall", "Stündlich")));

        datasources.add(createDatasource(
                "Polizeiliche Kriminalstatistik Ostfriesland",
                "Anonymisierte Kriminalstatistik der Polizeidirektion Oldenburg für den Bereich Ostfriesland. Enthält Deliktarten, Häufigkeiten und räumliche Verteilung.",
                Datasource.Category.GOVERNMENT, Datasource.DataFormat.DATABASE, Datasource.AccessLevel.RESTRICTED,
                "statistik@polizei-ol.niedersachsen.de", "Kriminalhauptkommissar Werner Janssen",
                "Polizeidirektion Oldenburg",
                "https://secure-api.polizei-nds.de/statistik/ostfriesland", "https://polizei-nds.de/statistik-docs",
                "Monatlich", "Polizeilizenz", true,
                List.of(Certificate.CertificateType.GOVERNMENT_GENERAL, Certificate.CertificateType.RESEARCH_SOCIAL),
                Datasource.DataSensitivity.CONFIDENTIAL, "Behördenzertifikat oder Kriminologie-Forschung erforderlich",
                List.of("Kriminalität", "Sicherheit", "Statistik", "Polizei", "Anonymisiert"),
                Map.of("Deliktgruppen", "15 Kategorien", "Räumliche Auflösung", "Gemeinde-Ebene", "Anonymisierung",
                        "K-Anonymität k=5")));

        // === HIGHLY CLASSIFIED DATA ===
        datasources.add(createDatasource(
                "Anonymisierte Krankenhausstatistik Emden",
                "Streng anonymisierte Daten zu Behandlungsfällen, Kapazitätsauslastung und epidemiologischen Trends im Klinikum Emden. Für medizinische Forschung und Gesundheitsplanung.",
                Datasource.Category.GOVERNMENT, Datasource.DataFormat.JSON, Datasource.AccessLevel.PRIVATE,
                "statistik@klinikum-emden.de", "Prof. Dr. Hans Mueller", "Klinikum Emden",
                "https://secure.klinikum-emden.de/api/statistics", "https://forschung.klinikum-emden.de/docs",
                "Monatlich", "Medizinische Forschungslizenz", true,
                List.of(Certificate.CertificateType.GOVERNMENT_HEALTH, Certificate.CertificateType.RESEARCH_HEALTH,
                        Certificate.CertificateType.PROFESSIONAL_DOCTOR),
                Datasource.DataSensitivity.CLASSIFIED, "Nur für Gesundheitsbehörden, medizinische Forschung oder Ärzte",
                List.of("Gesundheit", "Epidemiologie", "Anonymisiert", "Forschung", "Medizin", "Klinik"),
                Map.of("Behandlungsfälle", "~15.000/Jahr", "Anonymisierung", "HIPAA-konform", "Ethikkommission",
                        "Genehmigt")));

        // === BUSINESS DATA ===
        datasources.add(createDatasource(
                "Tourismusstatistik Wittmund",
                "Detaillierte Übernachtungszahlen, Gästeankunfte und touristische Kennzahlen für den Landkreis Wittmund. Saisonale Trends und Herkunftsländer der Besucher.",
                Datasource.Category.BUSINESS, Datasource.DataFormat.EXCEL, Datasource.AccessLevel.PUBLIC,
                "tourismus@wittmund.de", "Wirtschaftsförderung Wittmund", "Landkreis Wittmund",
                "https://opendata.wittmund.de/tourismus/statistik.xlsx", null,
                "Monatlich", "CC-BY 4.0", false, null,
                Datasource.DataSensitivity.PUBLIC, null,
                List.of("Tourismus", "Wirtschaft", "Statistik", "Wittmund", "Beherbergung"),
                Map.of("Betriebe", "347 Beherbergungsbetriebe", "Betten", "28.450 Betten", "Saison", "April-Oktober")));

        datasources.add(createDatasource(
                "Hafenwirtschaft Emden - Umschlagdaten",
                "Containerumschlag, Fahrzeugverladung und Massengutumschlag im Seehafen Emden. Wichtige Wirtschaftsdaten für Logistik und Regionalplanung.",
                Datasource.Category.BUSINESS, Datasource.DataFormat.CSV, Datasource.AccessLevel.PUBLIC,
                "statistik@seehafen-emden.de", "Hafenwirtschaftsverein Emden", "Seehafen Emden",
                "https://api.emden-port.de/statistics/cargo", "https://emden-port.de/statistik-info",
                "Wöchentlich", "CC-BY-NC 4.0", false, null,
                Datasource.DataSensitivity.PUBLIC, null,
                List.of("Hafen", "Logistik", "Wirtschaft", "Emden", "Umschlag", "Schifffahrt"),
                Map.of("Container", "~1.2M TEU/Jahr", "Fahrzeuge", "~500k Autos/Jahr", "Ranking",
                        "#3 Autohafen Deutschland")));

        datasources.add(createDatasource(
                "Landwirtschaftliche Betriebsdaten Ostfriesland",
                "Anonymisierte Daten zu Betriebsgrößen, Anbaufrüchten, Tierhaltung und Erträgen in der ostfriesischen Landwirtschaft. Nur für zertifizierte Agrarforschung.",
                Datasource.Category.BUSINESS, Datasource.DataFormat.REST_API, Datasource.AccessLevel.RESTRICTED,
                "daten@lwk-niedersachsen.de", "Dr. Agrar Johann Hinrichs", "Landwirtschaftskammer Niedersachsen",
                "https://api.lwk-nds.de/ostfriesland/betriebe", "https://lwk-nds.de/daten-dokumentation",
                "Jährlich", "Agrarlizenz", true,
                List.of(Certificate.CertificateType.RESEARCH_ECONOMIC,
                        Certificate.CertificateType.GOVERNMENT_STATISTICS),
                Datasource.DataSensitivity.CONFIDENTIAL, "Agrarforschung oder Behördliche Statistik erforderlich",
                List.of("Landwirtschaft", "Agrar", "Betriebe", "Ostfriesland", "Anonymisiert"),
                Map.of("Betriebe", "~3.200 Betriebe", "Hauptkulturen", "Grünland, Mais, Getreide", "Tiere",
                        "Rinder, Schweine, Geflügel")));

        // === SCIENTIFIC DATA ===
        datasources.add(createDatasource(
                "Klimadaten Messstation Norderney",
                "Hochauflösende meteorologische Messreihen der DWD-Station Norderney: Temperatur, Niederschlag, Wind, Luftdruck. Für Klimaforschung und Wettervorhersage.",
                Datasource.Category.SCIENCE, Datasource.DataFormat.CSV, Datasource.AccessLevel.PUBLIC,
                "klima@dwd.de", "Dr. Meteorologie Karin Ostermann", "Deutscher Wetterdienst",
                "https://opendata.dwd.de/climate/observations/hourly/norderney", "https://dwd.de/klimadaten-docs",
                "Stündlich", "DWD Open Data Lizenz", false, null,
                Datasource.DataSensitivity.PUBLIC, null,
                List.of("Klima", "Meteorologie", "Norderney", "DWD", "Messreihen", "Wissenschaft"),
                Map.of("Messreihe", "Seit 1891", "Parameter", "12 meteorologische Größen", "Auflösung",
                        "10min/1h/täglich")));

        datasources.add(createDatasource(
                "Wattenmeersediment-Analysen ICBM",
                "Geochemische Analysen von Sedimentproben aus dem Niedersächsischen Wattenmeer. Schwermetalle, organische Schadstoffe, Nährstoffe. Für Meeresforschung.",
                Datasource.Category.SCIENCE, Datasource.DataFormat.DATABASE, Datasource.AccessLevel.RESTRICTED,
                "sediment@icbm.de", "Prof. Dr. Meereschemie Ingrid Kröncke", "ICBM Oldenburg",
                "https://data.icbm.de/waddensea/sediments", "https://icbm.de/sediment-database-docs",
                "Halbjährlich", "Wissenschaftslizenz", true,
                List.of(Certificate.CertificateType.RESEARCH_ENVIRONMENTAL,
                        Certificate.CertificateType.RESEARCH_UNIVERSITY),
                Datasource.DataSensitivity.RESTRICTED, "Meeresforschung oder Universitäre Umweltforschung erforderlich",
                List.of("Wattenmeer", "Sediment", "Meeresforschung", "Geochemie", "ICBM", "Schadstoffe"),
                Map.of("Probenpunkte", "156 Stationen", "Parameter", "35 chemische Parameter", "Zeitreihe",
                        "Seit 1995")));

        // === NGO/CIVIL SOCIETY DATA ===
        datasources.add(createDatasource(
                "Lobbyisten-Register Ostfriesland",
                "Öffentliches Register aller registrierten Lobbyisten und deren Aktivitäten in den Landkreisen Ostfrieslands. Für mehr Transparenz in der Politik.",
                Datasource.Category.CIVIL_SOCIETY, Datasource.DataFormat.CSV, Datasource.AccessLevel.PUBLIC,
                "info@transparenz-ostfriesland.de", "Bürgerinitiative Transparenz", "Transparenz Ostfriesland e.V.",
                "https://transparenz-of.de/data/lobbyisten.csv", "https://transparenz-of.de/dokumentation",
                "Wöchentlich", "CC-BY 4.0", false, null,
                Datasource.DataSensitivity.PUBLIC, null,
                List.of("Transparenz", "Politik", "Lobbyismus", "Bürgerbeteiligung", "Demokratie"),
                Map.of("Lobbyisten", "127 registrierte Personen", "Themen", "Energie, Verkehr, Tourismus", "Update",
                        "Bei Neuanmeldungen")));

        datasources.add(createDatasource(
                "Vogelzugbeobachtungen NABU Ostfriesland",
                "Systematische Beobachtungsdaten zum Vogelzug entlang der ostfriesischen Küste. Artenzahlen, Zugzeiten, Rastplätze. Für Naturschutz und Forschung.",
                Datasource.Category.CIVIL_SOCIETY, Datasource.DataFormat.JSON, Datasource.AccessLevel.PUBLIC,
                "daten@nabu-ostfriesland.de", "Biologin Marina Janßen", "NABU Ostfriesland",
                "https://nabu-ostfriesland.de/api/vogelzug", "https://nabu-ostfriesland.de/daten-info",
                "Täglich während Zugzeit", "CC-BY-SA 4.0", false, null,
                Datasource.DataSensitivity.PUBLIC, null,
                List.of("Vogelzug", "Naturschutz", "Biodiversität", "NABU", "Ornithologie", "Küste"),
                Map.of("Beobachtungsplätze", "23 Stationen", "Arten", "~280 Vogelarten", "Freiwillige",
                        "45 Beobachter*innen")));

        datasources.add(createDatasource(
                "Soziale Hilfeleistungen Diakonie Ostfriesland",
                "Anonymisierte Statistiken zu sozialen Hilfeleistungen, Beratungsfällen und gesellschaftlichen Trends. Für Sozialforschung und Hilfsplanung.",
                Datasource.Category.CIVIL_SOCIETY, Datasource.DataFormat.EXCEL, Datasource.AccessLevel.RESTRICTED,
                "daten@diakonie-of.de", "Soziologin Dr. Heike Wagner", "Diakonie Ostfriesland",
                "https://diakonie-of.de/statistik/hilfeleistungen", null,
                "Quartalsweise", "Sozialforschungslizenz", true,
                List.of(Certificate.CertificateType.NGO_SOCIAL, Certificate.CertificateType.RESEARCH_SOCIAL),
                Datasource.DataSensitivity.CONFIDENTIAL, "Sozialforschung oder NGO-Zertifikat erforderlich",
                List.of("Soziales", "Hilfeleistungen", "Anonymisiert", "Diakonie", "Gesellschaft"),
                Map.of("Beratungsfälle", "~8.500/Jahr", "Hilfebereiche", "12 Kategorien", "Anonymisierung",
                        "Streng nach DSGVO")));

        datasourceRepository.saveAll(datasources);
        System.out.println("✅ Created " + datasources.size() + " comprehensive datasources across all sectors");
    }

    private Datasource createDatasource(String title, String description, Datasource.Category category,
            Datasource.DataFormat dataFormat, Datasource.AccessLevel accessLevel,
            String contactEmail, String contactName, String organization,
            String dataUrl, String documentationUrl, String updateFrequency,
            String licenseType, boolean requiresCertificate,
            List<Certificate.CertificateType> requiredCertTypes,
            Datasource.DataSensitivity dataSensitivity, String certificateRequirements,
            List<String> tags, Map<String, String> metadata) {
        Datasource ds = new Datasource();
        ds.setTitle(title);
        ds.setDescription(description);
        ds.setCategory(category);
        ds.setDataFormat(dataFormat);
        ds.setAccessLevel(accessLevel);
        ds.setContactEmail(contactEmail);
        ds.setContactName(contactName);
        ds.setOrganization(organization);
        ds.setDataUrl(dataUrl);
        ds.setDocumentationUrl(documentationUrl);
        ds.setUpdateFrequency(updateFrequency);
        ds.setLicenseType(licenseType);
        ds.setRequiresCertificate(requiresCertificate);
        if (requiredCertTypes != null) {
            ds.setRequiredCertificateTypes(requiredCertTypes);
        }
        ds.setDataSensitivity(dataSensitivity);
        ds.setCertificateRequirements(certificateRequirements);
        if (tags != null) {
            ds.getTags().addAll(tags);
        }
        if (metadata != null) {
            ds.getAdditionalMetadata().putAll(metadata);
        }
        return ds;
    }

    private void createCertificates() {
        if (certificateRepository.count() > 0) {
            return; // Certificates already exist
        }

        // Get some users for certificate assignments
        User forscher = userRepository.findByUsername("forscher.uni").orElse(null);
        User mediziner = userRepository.findByUsername("forscher.medizin").orElse(null);
        User umweltBehoerde = userRepository.findByUsername("behoerde.umwelt").orElse(null);
        User gesundheitsBehoerde = userRepository.findByUsername("behoerde.gesundheit").orElse(null);
        User business = userRepository.findByUsername("business.consulting").orElse(null);
        User ngoUmwelt = userRepository.findByUsername("ngo.umwelt").orElse(null);
        User ngoSozial = userRepository.findByUsername("ngo.sozial").orElse(null);
        User journalist = userRepository.findByUsername("journalist.nwz").orElse(null);

        List<Certificate> certificates = new ArrayList<>();

        if (forscher != null) {
            certificates.add(createCertificate(forscher, Certificate.CertificateType.RESEARCH_ENVIRONMENTAL,
                    "Umweltforschung-Zertifikat Uni Oldenburg",
                    "Prof. Dr. Jürgen Hofmann - Berechtigung für Umweltdatenanalyse",
                    Certificate.Status.APPROVED, "env_cert_hofmann_2024.pdf"));

            certificates.add(createCertificate(forscher, Certificate.CertificateType.RESEARCH_UNIVERSITY,
                    "Universitäts-Forschungszertifikat", "Allgemeine Forschungsberechtigung Universität Oldenburg",
                    Certificate.Status.APPROVED, "uni_cert_hofmann_2024.pdf"));
        }

        if (mediziner != null) {
            certificates.add(createCertificate(mediziner, Certificate.CertificateType.RESEARCH_HEALTH,
                    "Medizinische Forschungsberechtigung", "Dr. Sabine Weber - Epidemiologische Studien",
                    Certificate.Status.APPROVED, "med_research_weber_2024.pdf"));

            certificates.add(createCertificate(mediziner, Certificate.CertificateType.PROFESSIONAL_DOCTOR,
                    "Ärztekammer-Zertifikat", "Approbation und Facharztzertifikat Epidemiologie",
                    Certificate.Status.APPROVED, "aerzte_cert_weber_2024.pdf"));
        }

        if (umweltBehoerde != null) {
            certificates.add(createCertificate(umweltBehoerde, Certificate.CertificateType.GOVERNMENT_ENVIRONMENT,
                    "Behörden-Umweltzertifikat", "Dr. Anne Fischer - Niedersächsisches Umweltministerium",
                    Certificate.Status.APPROVED, "gov_env_fischer_2024.pdf"));

            certificates.add(createCertificate(umweltBehoerde, Certificate.CertificateType.GOVERNMENT_GENERAL,
                    "Allgemeine Behördenberechtigung", "Ministerielle Datenzugangsberechtigung",
                    Certificate.Status.APPROVED, "gov_general_fischer_2024.pdf"));
        }

        if (gesundheitsBehoerde != null) {
            certificates.add(createCertificate(gesundheitsBehoerde, Certificate.CertificateType.GOVERNMENT_HEALTH,
                    "Gesundheitsbehörden-Zertifikat", "Dr. Michael Bauer - Nds. Gesundheitsministerium",
                    Certificate.Status.APPROVED, "gov_health_bauer_2024.pdf"));
        }

        if (business != null) {
            certificates.add(createCertificate(business, Certificate.CertificateType.BUSINESS_CONSULTING,
                    "Beratungsunternehmen-Zertifikat", "Dr. Frank Zimmermann - Zertifizierte Datenanalyse",
                    Certificate.Status.APPROVED, "business_consult_zimmermann_2024.pdf"));

            certificates.add(createCertificate(business, Certificate.CertificateType.PROFESSIONAL_CONSULTANT,
                    "Professioneller Berater-Nachweis", "IHK-zertifizierte Unternehmensberatung",
                    Certificate.Status.UNDER_REVIEW, "prof_consultant_zimmermann_2024.pdf"));
        }

        if (ngoUmwelt != null) {
            certificates.add(createCertificate(ngoUmwelt, Certificate.CertificateType.NGO_ENVIRONMENTAL,
                    "NGO Umweltschutz-Zertifikat", "Marina Janßen - NABU Ostfriesland Naturschutzarbeit",
                    Certificate.Status.APPROVED, "ngo_env_janssen_2024.pdf"));
        }

        if (ngoSozial != null) {
            certificates.add(createCertificate(ngoSozial, Certificate.CertificateType.NGO_SOCIAL,
                    "NGO Soziale Arbeit-Zertifikat", "Dr. Heike Wagner - Diakonie Sozialforschung",
                    Certificate.Status.APPROVED, "ngo_social_wagner_2024.pdf"));
        }

        if (journalist != null) {
            certificates.add(createCertificate(journalist, Certificate.CertificateType.PROFESSIONAL_JOURNALIST,
                    "Presseausweis und Journalisten-Zertifikat",
                    "Jan Peters - Nordwest-Zeitung Investigativjournalismus",
                    Certificate.Status.PENDING, "journalist_peters_2024.pdf"));
        }

        // Some additional certificates with different statuses
        User student = userRepository.findByUsername("student.master").orElse(null);
        if (student != null) {
            certificates.add(createCertificate(student, Certificate.CertificateType.RESEARCH_UNIVERSITY,
                    "Studierenden-Forschungsberechtigung", "Laura Müller - Masterarbeit Geographie",
                    Certificate.Status.UNDER_REVIEW, "student_cert_mueller_2024.pdf"));
        }

        User energieBusiness = userRepository.findByUsername("business.energie").orElse(null);
        if (energieBusiness != null) {
            certificates.add(createCertificate(energieBusiness, Certificate.CertificateType.BUSINESS_ENVIRONMENTAL,
                    "Energieunternehmen Umwelt-Zertifikat", "Ing. Petra Wolff - Enercon Umweltdatenanalyse",
                    Certificate.Status.EXPIRED, "business_env_wolff_2023.pdf"));
        }

        certificateRepository.saveAll(certificates);
        System.out.println("✅ Created " + certificates.size() + " certificates with various statuses and types");
    }

    private Certificate createCertificate(User user, Certificate.CertificateType type, String fileName,
            String description, Certificate.Status status, String filePath) {
        Certificate cert = new Certificate();
        cert.setUser(user);
        cert.setType(type);
        cert.setFileName(fileName);
        cert.setDescription(description);
        cert.setStatus(status);
        cert.setFilePath("/certificates/" + filePath);
        cert.setFileType("application/pdf");
        cert.setFileSize(1024L * (150 + (long) (Math.random() * 500))); // 150-650 KB
        cert.setUploadedAt(LocalDateTime.now().minusDays((long) (Math.random() * 90))); // Random date within last 90
                                                                                        // days

        if (status == Certificate.Status.APPROVED) {
            cert.setReviewedAt(cert.getUploadedAt().plusDays((long) (Math.random() * 7 + 1))); // Reviewed 1-7 days
                                                                                               // after upload
            cert.setReviewedBy("reviewer");
            cert.setValidUntil(LocalDateTime.now().plusMonths(12)); // Valid for 1 year
        } else if (status == Certificate.Status.UNDER_REVIEW) {
            cert.setReviewedBy("reviewer");
            cert.setReviewNotes("Dokument wird derzeit geprüft. Weitere Nachweise erforderlich.");
        } else if (status == Certificate.Status.EXPIRED) {
            cert.setReviewedAt(cert.getUploadedAt().plusDays(2));
            cert.setReviewedBy("reviewer");
            cert.setValidUntil(LocalDateTime.now().minusDays(30)); // Expired 30 days ago
        } else if (status == Certificate.Status.REJECTED) {
            cert.setReviewedAt(cert.getUploadedAt().plusDays(3));
            cert.setReviewedBy("reviewer");
            cert.setReviewNotes("Zertifikat entspricht nicht den Anforderungen. Bitte korrektes Dokument einreichen.");
        }

        return cert;
    }

    private void createDataAccessRequests() {
        if (dataAccessRequestRepository.count() > 0) {
            return; // Requests already exist
        }

        // Get some datasources and users with certificates
        List<Datasource> restrictedDatasources = datasourceRepository.findAll().stream()
                .filter(ds -> ds.getRequiresCertificate())
                .toList();

        List<Certificate> approvedCertificates = certificateRepository.findAll().stream()
                .filter(cert -> cert.getStatus() == Certificate.Status.APPROVED)
                .toList();

        if (restrictedDatasources.isEmpty() || approvedCertificates.isEmpty()) {
            System.out.println("⚠️ Not enough datasources or certificates for access requests");
            return;
        }

        List<DataAccessRequest> requests = new ArrayList<>();

        // Create various access requests with different statuses
        for (int i = 0; i < Math.min(8, approvedCertificates.size() * restrictedDatasources.size() / 2); i++) {
            Certificate cert = approvedCertificates.get(i % approvedCertificates.size());
            Datasource ds = restrictedDatasources.get(i % restrictedDatasources.size());

            // Check if certificate type matches datasource requirements
            if (ds.getRequiredCertificateTypes().contains(cert.getType())) {
                DataAccessRequest request = createAccessRequest(cert.getUser(), ds, cert,
                        generateRequestReason(ds, cert.getUser()),
                        generateIntendedUse(ds, cert.getUser()),
                        i % 5); // Different statuses

                if (request != null) {
                    requests.add(request);
                }
            }
        }

        // Add some specific interesting requests
        addSpecificAccessRequests(requests, restrictedDatasources, approvedCertificates);

        dataAccessRequestRepository.saveAll(requests);
        System.out.println("✅ Created " + requests.size() + " data access requests with various statuses");
    }

        private void createDataRequests() {
                if (dataAccessRequestRepository.count() > 0) {
                        // We already seed access requests which are related; avoid duplicating
                }

                // Find some example users
                User researcher = userRepository.findByUsername("forscher.uni").orElse(null);
                User journalist = userRepository.findByUsername("journalist.nwz").orElse(null);
                User ngo = userRepository.findByUsername("ngo.umwelt").orElse(null);

                List<DataRequest> requests = new ArrayList<>();

                if (researcher != null) {
                        requests.add(createDataRequest(
                                        "Aktuelle Verkehrsdaten für Modellierung",
                                        "Ich benötige aggregierte Verkehrszählungen (Stunde/Tag) für die letzten 2 Jahre im Landkreis Leer zur Kalibrierung eines Verkehrssimulationsmodells.",
                                        Datasource.Category.GOVERNMENT,
                                        DataRequest.Priority.HIGH,
                                        researcher,
                                        "j.hofmann@uni-oldenburg.de",
                                        "Statistische Analyse für Masterarbeit",
                                        Datasource.DataFormat.CSV,
                                        "Landkreis Leer",
                                        "2023-2024",
                                        "< 1GB",
                                        DataRequest.UpdateFrequency.MONTHLY));

                        requests.add(createDataRequest(
                                        "Klimadaten Norderney - Langzeit",
                                        "Zeitreihen (stündlich) der DWD Messstation Norderney für die letzten 30 Jahre, inkl. Temperatur, Niederschlag und Wind.",
                                        Datasource.Category.SCIENCE,
                                        DataRequest.Priority.MEDIUM,
                                        researcher,
                                        "j.hofmann@uni-oldenburg.de",
                                        "Langzeit-Klimaanalyse",
                                        Datasource.DataFormat.CSV,
                                        "Norderney",
                                        "1995-2024",
                                        "~5GB",
                                        DataRequest.UpdateFrequency.ONE_TIME));
                }

                if (journalist != null) {
                        requests.add(createDataRequest(
                                        "Lobbyistenkontakte Ostfriesland",
                                        "Liste der registrierten Lobbyisten und Aktivitäten der letzten 12 Monate für eine investigative Recherche.",
                                        Datasource.Category.CIVIL_SOCIETY,
                                        DataRequest.Priority.MEDIUM,
                                        journalist,
                                        "redaktion@nwz-online.de",
                                        "Recherche und Artikelserie",
                                        Datasource.DataFormat.CSV,
                                        "Ostfriesland",
                                        "letzte 12 Monate",
                                        "< 100MB",
                                        DataRequest.UpdateFrequency.ON_DEMAND));
                }

                if (ngo != null) {
                        requests.add(createDataRequest(
                                        "Vogelzug-Detaildaten",
                                        "Fehleruntersuchung: detaillierte Beobachtungsreihen (Zeitstempel, Art, Anzahl) für Rastplätze an der Küste.",
                                        Datasource.Category.CIVIL_SOCIETY,
                                        DataRequest.Priority.LOW,
                                        ngo,
                                        "daten@nabu-ostfriesland.de",
                                        "Naturschutz-Auswertung",
                                        Datasource.DataFormat.JSON,
                                        "Küstenabschnitt Ostfriesland",
                                        "Saisonabhängig",
                                        "< 200MB",
                                        DataRequest.UpdateFrequency.WEEKLY));
                }

                        // Persist created requests using DataRequestRepository (autowired)
                        if (!requests.isEmpty()) {
                                try {
                                        dataRequestRepository.saveAll(requests);
                                        System.out.println("✅ Created " + requests.size() + " example DataRequest entries");
                                } catch (Exception e) {
                                        System.out.println("⚠️ Failed to save example DataRequest entries: " + e.getMessage());
                                }
                        } else {
                                System.out.println("ℹ️ No example DataRequest entries to create");
                        }
        }

        private DataRequest createDataRequest(String title, String description, Datasource.Category category,
                        DataRequest.Priority priority, User user, String contactEmail, String intendedUse,
                        Datasource.DataFormat preferredFormat, String geographicScope, String timeScope, String dataSize,
                        DataRequest.UpdateFrequency updateFrequency) {
                DataRequest req = new DataRequest();
                req.setTitle(title);
                req.setDescription(description);
                req.setCategory(category);
                req.setPriority(priority);
                req.setStatus(DataRequest.Status.OPEN);
                req.setUser(user);
                req.setContactEmail(contactEmail);
                req.setIntendedUse(intendedUse);
                req.setPreferredFormat(preferredFormat);
                req.setGeographicScope(geographicScope);
                req.setTimeScope(timeScope);
                req.setDataSize(dataSize);
                req.setUpdateFrequency(updateFrequency);
                req.setCreatedAt(LocalDateTime.now().minusDays((long) (Math.random() * 30)));
                return req;
        }

    private DataAccessRequest createAccessRequest(User user, Datasource datasource, Certificate certificate,
            String requestReason, String intendedUse, int statusVariant) {
        DataAccessRequest request = new DataAccessRequest();
        request.setUser(user);
        request.setDatasource(datasource);
        request.setCertificate(certificate);
        request.setRequestReason(requestReason);
        request.setIntendedUse(intendedUse);
        request.setRequestedAt(LocalDateTime.now().minusDays((long) (Math.random() * 30))); // Within last 30 days

        switch (statusVariant) {
            case 0: // APPROVED
                request.setStatus(DataAccessRequest.Status.APPROVED);
                request.setReviewedAt(request.getRequestedAt().plusDays((long) (Math.random() * 5 + 1)));
                request.setReviewedBy("reviewer");
                request.setAccessGrantedUntil(LocalDateTime.now().plusMonths(6));
                request.setReviewNotes("Antrag bewilligt. Zugang für 6 Monate gewährt.");
                break;
            case 1: // PENDING
                request.setStatus(DataAccessRequest.Status.PENDING);
                break;
            case 2: // UNDER_REVIEW
                request.setStatus(DataAccessRequest.Status.UNDER_REVIEW);
                request.setReviewedBy("reviewer");
                request.setReviewNotes("Antrag wird geprüft. Zusätzliche Informationen angefordert.");
                break;
            case 3: // REJECTED
                request.setStatus(DataAccessRequest.Status.REJECTED);
                request.setReviewedAt(request.getRequestedAt().plusDays((long) (Math.random() * 7 + 2)));
                request.setReviewedBy("reviewer");
                request.setReviewNotes(
                        "Antrag abgelehnt. Verwendungszweck entspricht nicht den Datennutzungsbestimmungen.");
                break;
            case 4: // EXPIRED
                request.setStatus(DataAccessRequest.Status.EXPIRED);
                request.setReviewedAt(request.getRequestedAt().plusDays(1));
                request.setReviewedBy("reviewer");
                request.setAccessGrantedUntil(LocalDateTime.now().minusDays(10)); // Expired 10 days ago
                request.setReviewNotes("Zugang war gewährt, ist aber abgelaufen.");
                break;
        }

        return request;
    }

    private String generateRequestReason(Datasource datasource, User user) {
        String[] reasons = {
                "Für wissenschaftliche Auswertung im Rahmen meiner Forschungsarbeit zu " + datasource.getTitle(),
                "Benötigt für statistische Analyse und Trendauswertung in " + user.getOrganization(),
                "Zur Erstellung einer Expertise über regionale Entwicklungen in Ostfriesland",
                "Für Vergleichsstudien mit anderen Regionen im Rahmen des Forschungsprojekts",
                "Zur Validierung bestehender Modelle und Prognosen",
                "Benötigt für Machbarkeitsstudie und Politikberatung",
                "Für die Entwicklung von Handlungsempfehlungen und Strategien"
        };
        return reasons[(int) (Math.random() * reasons.length)];
    }

    private String generateIntendedUse(Datasource datasource, User user) {
        String[] uses = {
                "Statistische Auswertung und Visualisierung für wissenschaftliche Publikation",
                "Integration in Forschungsdatenbank und Korrelationsanalyse mit anderen Datensätzen",
                "Erstellung von Berichten und Präsentationen für " + user.getOrganization(),
                "Entwicklung von Prognosemodellen und Szenarioanalysen",
                "Benchmarking und Vergleichsanalysen mit nationalen/internationalen Daten",
                "Qualitätsprüfung und Validierung bestehender Studien",
                "Grundlage für Politikempfehlungen und strategische Planungen"
        };
        return uses[(int) (Math.random() * uses.length)];
    }

    private void addSpecificAccessRequests(List<DataAccessRequest> requests,
            List<Datasource> restrictedDatasources,
            List<Certificate> approvedCertificates) {
        // Add some specific interesting requests that demonstrate different scenarios

        // Find specific datasources
        Datasource grundwasserDS = restrictedDatasources.stream()
                .filter(ds -> ds.getTitle().contains("Grundwasser"))
                .findFirst().orElse(null);

        Datasource gesundheitsDS = restrictedDatasources.stream()
                .filter(ds -> ds.getTitle().contains("Krankenhaus"))
                .findFirst().orElse(null);

        // Find specific certificates
        Certificate umweltCert = approvedCertificates.stream()
                .filter(cert -> cert.getType() == Certificate.CertificateType.GOVERNMENT_ENVIRONMENT)
                .findFirst().orElse(null);

        Certificate healthCert = approvedCertificates.stream()
                .filter(cert -> cert.getType() == Certificate.CertificateType.RESEARCH_HEALTH)
                .findFirst().orElse(null);

        // Create specific requests
        if (grundwasserDS != null && umweltCert != null) {
            DataAccessRequest envRequest = createAccessRequest(
                    umweltCert.getUser(), grundwasserDS, umweltCert,
                    "Dringender Datenbedarf für die Bewertung der Nitratbelastung im Rahmen der EU-Wasserrahmenrichtlinie. Aktuelle Messwerte werden für den Bericht an die EU-Kommission benötigt.",
                    "Statistische Auswertung der Nitrattrends, räumliche Verteilungsanalyse und Bewertung der Zielerreichung nach WRRL. Daten werden in anonymisierter Form in EU-Bericht integriert.",
                    0 // APPROVED
            );
            if (envRequest != null)
                requests.add(envRequest);
        }

        if (gesundheitsDS != null && healthCert != null) {
            DataAccessRequest healthRequest = createAccessRequest(
                    healthCert.getUser(), gesundheitsDS, healthCert,
                    "Epidemiologische Studie zu regionalen Gesundheitstrends im Rahmen des DFG-Forschungsprojekts 'Gesundheitsmonitoring ländlicher Raum'. IRB-Genehmigung liegt vor.",
                    "Anonymisierte Trendanalyse von Behandlungsfällen nach Altersgruppen und Diagnosegruppen. Korrelation mit soziodemographischen Indikatoren. Publikation in peer-reviewed Journal geplant.",
                    2 // UNDER_REVIEW
            );
            if (healthRequest != null)
                requests.add(healthRequest);
        }
    }
}