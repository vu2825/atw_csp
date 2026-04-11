# Annex — Java Spring Boot (Enterprise Rules)

**Purpose:** This Annex supplements your Universal Project Rules with a technology-specific rule set for Spring Boot. It contains policies, a catalog of commonly-used enterprise libraries, guidance for correct usage, risk notes, configuration examples, CI/PR enforcement, and a reviewer checklist. This Annex does not replace the core rules — exceptions must be recorded in an ADR.

---

## Metadata

```yaml
name: Annex-Java-SpringBoot
version: 1.0
owner: Platform/Java-Team
scope: server-side microservices / monoliths using Spring Boot
status: draft
approved-by: <architect-name>
review-cadence: 6 months
```

---

## 1. Scope & Applicability

- Applies to all Java backend repositories using Spring Boot inside the organization.
- Any exception to this Annex must have an ADR (Architectural Decision Record) and a named owner responsible for the exception.
- Goals: **safety, observability, testability, avoiding framework leakage into the domain layer, and upgradeability.**

---

## 2. Catalog of Common Libraries & Usage Guidance

Each listed library includes: _When to use_, _Recommended configuration_, _Risks / notes_.

### 2.1 Spring Boot / Spring Framework

- **When to use:** Core framework for services.
- **Recommendations:** Use the Spring Boot BOM (dependencyManagement) to pin versions. Use official starters such as `spring-boot-starter-web`, `spring-boot-starter-data-jpa`, `spring-boot-starter-actuator`, `spring-boot-starter-security`, and `spring-boot-starter-validation`.
- **Risks:** Major upgrades may introduce breaking changes — plan and test upgrades on staging.

### 2.2 Lombok

- **When to use:** Reduce boilerplate for DTOs, VOs and value objects.
- **Recommendations:** Allow only `@Getter`, `@Setter` (with caution), `@RequiredArgsConstructor`, `@Builder`, `@Value` for DTO/VO classes. Ensure annotation processing is enabled in IDE and CI.
- **Forbidden / Notes:** Do not use `@Data` on JPA entities. If Lombok is used on entities, require `@NoArgsConstructor(access = AccessLevel.PROTECTED)` and `@EqualsAndHashCode(onlyExplicitlyIncluded = true)` — include only the primary key or a stable business id. Avoid `@ToString` that prints relationships.

### 2.3 JPA / Hibernate / Spring Data JPA

- **When to use:** Persistence layer implementation.
- **Recommendations:** Separate Domain Model and Persistence Model — the domain model must not depend on JPA. Keep transactions short. Use Flyway or Liquibase for migrations and keep migration scripts in VCS.
- **Risks:** Lazy-loading issues, equals/hashCode pitfalls, and N+1 queries — use profiling and integration tests to detect problems.

### 2.4 MapStruct

- **When to use:** Compile-time DTO ↔ Entity mapping.
- **Recommendations:** Prefer MapStruct for mapping to benefit from generated code and performance. Add unit tests for mappers; use hand-written mappers for complex logic.
- **Benefits:** Fast mapping and readable generated code.

### 2.5 Jackson

- **When to use:** JSON serialization/deserialization.
- **Recommendations:** Provide a central `ObjectMapper` bean, register `JavaTimeModule` for `java.time` types, and configure `FAIL_ON_UNKNOWN_PROPERTIES` according to your API contract policy (fail-fast vs. tolerant). Maintain clear API versioning strategy.

### 2.6 Spring Security

- **When to use:** Authentication & authorization.
- **Recommendations:** Centralize security configuration using `HttpSecurity` DSL and a single `SecurityConfig`. Store secrets in Vault/KMS — never commit them. Use `bcrypt` or `argon2` for password hashing and rotate keys periodically.
- **Risks:** Misconfiguration can expose sensitive endpoints — include security integration tests.

### 2.7 WebClient vs RestTemplate

- **When to use:** Outbound HTTP clients.
- **Recommendations:** Prefer `WebClient` for new non-blocking/reactive code. For existing blocking codebases, `RestTemplate` may be used temporarily but plan migration to `WebClient` if adopting a reactive stack.

### 2.8 Spring Cloud (Config, Gateway, Discovery)

- **When to use:** When centralized configuration, routing, or service discovery is required.
- **Recommendations:** Pin Spring Cloud module versions, standardize which modules are used across teams, and run integration tests for config and discovery components. Avoid mixing discovery implementations within the same environment.

### 2.9 Messaging: spring-kafka, spring-amqp

- **When to use:** Asynchronous messaging and event-driven architectures.
- **Recommendations:** Use a schema registry (Avro/Protobuf/JSON Schema) with a compatibility policy. Define producer/consumer contracts and use retries, idempotency, and dead-letter queues for robustness.

### 2.10 Observability: Actuator, Micrometer, OpenTelemetry

- **When to use:** Monitoring and distributed tracing.
- **Recommendations:** Enable Actuator (health, metrics, info). Use Micrometer with Prometheus or OTLP exporters. Propagate trace context and record business metrics (p50/p95/p99). Prefer OpenTelemetry for tracing integrations.

### 2.11 Resilience: Resilience4j

- **When to use:** Circuit-breakers, retries, bulkheads, and rate-limiting.
- **Recommendations:** Configure resilience policies via externalized configuration and test failure modes with integration or chaos tests.

### 2.12 Testing Libraries: JUnit 5, Mockito, Testcontainers, WireMock

- **Recommendations:** Unit tests for domain logic; integration tests using Testcontainers for databases and message brokers; use WireMock for external HTTP dependencies. Prefer contract tests for public APIs.

### 2.13 Build & Quality Tools: Maven/Gradle, SpotBugs, Checkstyle, PMD, Dependabot

- **Recommendations:** Enforce static analysis and vulnerability scanning in CI. Perform license checks and dependency update workflows.

---

## 3. Detailed Rules (Normative)

### 3.1 Architecture & Layering

- Apply the Inward Dependency Rule: domain must not import Spring or Jackson types.
- Suggested package structure:

```
com.company.service
  ├── domain
  ├── application
  ├── ports
  ├── adapters
  ├── config
  └── infra
```

- Controllers should be thin adapters; application/service layer performs orchestration; domain contains business invariants and rules.

### 3.2 Dependency Injection & Construction

- Use constructor injection exclusively; avoid field injection.
- Use `@Configuration` classes for complex bean wiring.

### 3.3 Configuration & Secrets

- Externalize configuration via profiles and a secrets store (Vault/KMS or Spring Cloud Config). No secrets in source control.
- Use typed `@ConfigurationProperties` classes with `@Validated` for robust configuration handling.

### 3.4 Transactions

- Keep `@Transactional` at the service/application boundary and keep transaction scopes minimal. Document isolation and propagation choices via ADRs when necessary.

### 3.5 Logging & Error Handling

- Use `slf4j` + Logback (or the org's centralized logging solution). Produce structured logs (key/value) that include `correlationId` and `traceId`.
- Provide a global exception handler that returns a standardized error response `{ code, message, correlationId, timestamp }` and maps errors to appropriate HTTP statuses.

### 3.6 DTOs & Mapping

- Never expose JPA entities through external APIs. Use DTOs for all external boundaries.
- Use MapStruct for mappings and write unit tests for mapper edge cases.

### 3.7 Lombok Policy (Firm)

- **Allowed:** `@Getter`, `@Setter` (with care), `@RequiredArgsConstructor`, `@Builder`, `@Value` for DTOs/VOs.
- **Forbidden:** `@Data` on JPA entities.
- **If Lombok is used on entities:** require `@NoArgsConstructor(access = AccessLevel.PROTECTED)` and `@EqualsAndHashCode(onlyExplicitlyIncluded = true)` including only PK/business id fields. Avoid `@ToString` producing relationship output.

**Safe entity example (Lombok + JPA):**

```java
@Entity
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class User {
    @Id @GeneratedValue
    @EqualsAndHashCode.Include
    private Long id;

    private String email;

    // avoid including collections in equals/hashCode
}
```

### 3.8 Persistence & Migrations

- Enforce DB migrations in VCS using Flyway or Liquibase. No manual ad-hoc changes. Migration scripts must be reviewed via PR.

### 3.9 Observability & Health

- Expose actuator health and metrics endpoints; protect sensitive actuator endpoints.
- Use Micrometer for metrics, avoid high-cardinality tags, and export to the organizational standard (Prometheus/OTLP).
- Integrate distributed tracing via OpenTelemetry and ensure trace context propagation for inbound and outbound calls.

### 3.10 Testing

- Unit tests should focus on pure domain logic without framework dependencies.
- Integration tests should use Testcontainers for DB and messaging dependencies and WireMock for external HTTP services.
- Apply consumer-driven contract testing where appropriate for public APIs.

---

## 4. Enforcement (CI / PR)

**Mandatory CI gates:**

1. License & vulnerability scan must pass.
2. Build succeeds and unit tests pass; static analysis (SpotBugs/PMD/Checkstyle) must pass.
3. Validate annotation processing (ensure generated sources for MapStruct/Lombok are present).
4. Contract tests for public APIs (consumer-driven contracts) when applicable.
5. Observability checklist: new endpoints must either expose metrics/traces or be explicitly exempted with an ADR.

**PR template must require:**

- A library proposal (name, version, owner, purpose, ROI, rollback plan) for every new dependency.
- An ADR for cross-cutting changes or policy exceptions.

**Automated lint rules to add:**

- Fail PRs that contain `@Data` classes in `entity` packages.
- Lint rules to ensure DTOs are not annotated as JPA entities.

---

## 5. Snippets & Examples

### MapStruct mapper

```java
@Mapper(componentModel = "spring")
public interface UserMapper {
    UserDto toDto(UserEntity entity);
    UserEntity toEntity(UserDto dto);
}
```

### WebClient basic usage

```java
@Component
public class MyClient {
  private final WebClient webClient;

  public MyClient(WebClient.Builder builder) {
    this.webClient = builder.baseUrl("https://api.svc").build();
  }

  public Mono<MyResponse> get() {
    return webClient.get().uri("/v1/x").retrieve().bodyToMono(MyResponse.class);
  }
}
```

---

## 6. PR checklist (Author & Reviewer)

- [ ] Library proposal included (name, version, owner, ROI, rollback plan).
- [ ] ADR created if change affects cross-cutting concerns.
- [ ] Tests: unit + mapping tests + integration tests for infra changes.
- [ ] Logging: structured logs and correlationId present.
- [ ] Observability: metrics/traces added for new endpoints.
- [ ] Security: secrets not in repo; security review done.
- [ ] Lombok policy followed (no `@Data` on entities).
- [ ] equals/hashCode on entities reviewed (no collection compare).
- [ ] CI: build & static analysis pass.

---

## 7. Governance & Versioning

- Owner: `Platform/Java-Team` is responsible for the BOM & upgrade cadence.
- Review cadence: every 6 months or on major Spring Boot release.
- Deprecation: require ADR + migration plan; support compatibility for at least one major version cycle.

---

## 8. Decision matrix (summary)

- If a library affects runtime characteristics (startup time, memory): require performance benchmarks and a staging canary rollout.
- If a library affects API contract or database schema: require contract tests and a formal migration plan.
- If a library touches security/cryptography: require a security review.

---

## 9. References & Further Reading

- Lombok + JPA pitfalls & best practices (external guides).
- MapStruct mapping best practices.
- Spring Boot & OpenTelemetry integration guides.
- Testcontainers integration testing patterns.

---

_End of document._
