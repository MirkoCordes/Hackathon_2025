package de.eq3.hackathon.kreisverwaltung.config;

import de.eq3.hackathon.kreisverwaltung.entity.User;
import de.eq3.hackathon.kreisverwaltung.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

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
    }
}