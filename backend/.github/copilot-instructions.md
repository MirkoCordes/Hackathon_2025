# Copilot Instructions: Datenraum Ostfriesland Backend

## Project Overview
This is a Spring Boot 3.5.6 backend for a hackathon project creating a "Datenraum" (data space) for East Frisia (Ostfriesland) - a digital platform serving as a catalog for data sources from government, business, science, and civil society. The system enables users to search for available data sources, post data needs, and manage certificate-based access to sensitive data.

## Architecture & Key Components

### Authentication & Security
- **JWT-based authentication** with 24-hour tokens
- **Role-based access**: `USER`, `ADMIN`, `DATA_PROVIDER` (see `User.Role` enum)
- **Security endpoints**: All `/api/auth/**` and `/api/public/**` are public, everything else requires authentication
- **Default credentials**: `admin/admin123` and `testuser/test123` (auto-created by `DataInitializer`)

### Technology Stack
- **Spring Boot 3.5.6** with Java 17
- **H2 in-memory database** for development (`jdbc:h2:mem:datenraum`)
- **Spring Security** with JWT tokens (JJWT 0.12.3)
- **Spring Data JPA** with Hibernate
- **Lombok** for boilerplate reduction
- **Maven** as build tool

### Package Structure
```
de.eq3.hackathon.kreisverwaltung/
├── config/          # Security, data initialization
├── controller/      # REST endpoints
├── dto/            # Data transfer objects
├── entity/         # JPA entities
├── repository/     # Data access layer
├── security/       # JWT utilities, filters
└── service/        # Business logic
```

## Development Patterns & Conventions

### Controller Patterns
- Use `@RestController` with `@RequestMapping("/api/...")` 
- Return `ResponseEntity<?>` for consistent HTTP responses
- Authentication info via `SecurityContextHolder.getContext().getAuthentication()`
- Example: See `HelloController` for authenticated vs public endpoint patterns

### Entity Patterns
- Implement `UserDetails` for security integration (like `User` entity)
- Use Lombok `@Data`, `@NoArgsConstructor`, `@AllArgsConstructor`
- JPA annotations: `@Entity`, `@Table(name = "...")`, `@GeneratedValue(strategy = GenerationType.IDENTITY)`

### Security Configuration
- JWT filter chain in `SecurityConfig` with CORS enabled for development
- H2 console enabled at `/h2-console` (development only)
- JWT secret/expiration configured in `application.properties`

### Database & JPA
- H2 console: `http://localhost:8080/h2-console` (URL: `jdbc:h2:mem:datenraum`, user: `sa`, password: `password`)
- DDL auto-generation: `create-drop` mode for development
- SQL logging enabled for debugging

## Key Development Commands

### Running the Application
```bash
# Start the application
./mvnw spring-boot:run
# Or on Windows
mvnw.cmd spring-boot:run

# The app runs on http://localhost:8080
# H2 Console: http://localhost:8080/h2-console
```

### Testing Endpoints
```bash
# Public endpoint (no auth required)
curl http://localhost:8080/api/public/hello

# Register a user
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"newuser","email":"user@test.com","password":"password123"}'

# Login to get JWT token
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Authenticated endpoint (requires Bearer token)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" http://localhost:8080/api/hello
```

## Hackathon-Specific Context
Building features for:
- **Data catalog interface** - search/filter data sources and needs
- **Certificate & access management** - upload/manage certificates for sensitive data access
- **Public data needs** - users can post what data they need, others can respond
- **Role-based permissions** - control access to sensitive data sources

## Extension Points
- Add new entities in `entity/` package following `User` pattern
- Create DTOs for request/response objects in `dto/` package
- Implement repositories extending `JpaRepository` in `repository/` package  
- Add business logic in `service/` package with `@Service` annotation
- Create REST endpoints in `controller/` package following existing patterns
- Extend `User.Role` enum for additional user types (e.g., `CERTIFICATE_AUTHORITY`)

## Important Notes
- Tests are currently skipped (`<skipTests>true</skipTests>`)
- Spring AI dependencies are commented out but prepared for future AI integration
- CORS is configured to allow all origins for hackathon development
- Database is wiped on restart (H2 in-memory with `create-drop`)