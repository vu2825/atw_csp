# Enterprise Java AI Agent — Master Rule Set

> Version 2.0 | Optimized for AI Code Generation Agents
> **This document is the single source of truth. No exceptions. No excuses.**

---

## 0. AI AGENT BEHAVIOR PROTOCOL (READ THIS FIRST)

> This section is unique to AI agents. It defines HOW you operate before writing a single line of code.

### 0.1 Technology Stack Declaration

You are working on a **Java 21 / Spring Boot 3.x** enterprise codebase.

| Technology      | Version               | Notes                                                 |
| :-------------- | :-------------------- | :---------------------------------------------------- |
| Java            | 21 (LTS)              | Virtual Threads, Records, Sealed                      |
| Spring Boot     | 3.2.x                 | Native AOT compatible                                 |
| Spring Security | 6.x                   | SecurityFilterChain (no WebSecurityConfigurerAdapter) |
| JPA / Hibernate | 6.x                   | Jakarta EE (not javax)                                |
| Lombok          | Latest stable         | See Section 6.4 for allowed usage                     |
| MapStruct       | 1.5.x                 | Preferred mapper                                      |
| Flyway          | 9.x                   | Mandatory for schema migration                        |
| Testcontainers  | 1.19.x                | Mandatory for integration tests                       |
| OpenAPI         | springdoc-openapi 2.x | Contract-first                                        |

> **CRITICAL**: Never use `javax.*` imports. Always use `jakarta.*` (Spring Boot 3+ / Jakarta EE 10).

### 0.2 The AI Agent Workflow (Mandatory Steps)

When given ANY coding task, you MUST follow this sequence:

```
STEP 1: UNDERSTAND
  └─ Identify the Layer (Domain / Application / Interface / Infrastructure)
  └─ Identify what business rule is being implemented
  └─ Ask clarifying questions IF the requirement is ambiguous (see 0.3)

STEP 2: PLAN (verbalize before coding)
  └─ State: "This belongs in [Layer] because [reason]"
  └─ List all classes you will create/modify
  └─ Identify if Domain Events are needed
  └─ Identify if Value Objects are needed for primitives

STEP 3: IMPLEMENT
  └─ Write Domain objects first (innermost layer)
  └─ Write Application layer second
  └─ Write Interface/Infrastructure last

STEP 4: VERIFY (self-checklist — run mentally before outputting)
  └─ [ ] No primitive obsession — wrapped in Value Objects?
  └─ [ ] No @Autowired fields — constructor injection only?
  └─ [ ] No business logic in Controller?
  └─ [ ] No Spring annotations in Domain layer?
  └─ [ ] Transactions start at Application Service, not Domain?
  └─ [ ] FetchType.LAZY on all relationships?
  └─ [ ] Unit test included for Domain logic?
  └─ [ ] Error cases handled (not swallowed)?

STEP 5: EXPLAIN
  └─ Briefly justify architectural decisions made
  └─ Flag any trade-offs or TODOs
```

### 0.3 Clarification Policy

**Ask BEFORE coding** when:

- Business rule is unclear ("what happens if order has 0 items?")
- The data model has ambiguous ownership ("does User own Address, or is Address shared?")
- External system behavior is undefined

**DO NOT ask** when:

- The answer is deterministic from these rules (e.g., "use constructor injection" — always)
- It's an implementation detail you can decide (e.g., method naming following conventions)

### 0.4 Conflict Resolution Priority

When two rules appear to conflict, apply this priority order:

```
1. Security (never compromise)
2. Correctness / Data Integrity
3. Architecture Boundaries (Inward Dependency Rule)
4. Stability / Determinism
5. Explicitness / Clarity
6. Performance
```

### 0.5 Output Format Rules

Every code response must include:

1. **Architectural placement**: "This class goes in `[module]/[layer]/[package]`"
2. **Why**: One-sentence justification for each major decision
3. **Code**: Clean, complete, compilable
4. **Test**: At minimum, a unit test for the core logic (unless trivial CRUD)
5. **Warnings**: Any known limitations, TODOs, or potential issues

---

## 1. CORE PRINCIPLES (NON-NEGOTIABLE)

### 1.1 Clarity Over Cleverness

Code is read ten times more often than it is written.

- **Rule**: If you cannot explain your code to a junior engineer in 5 minutes, rewrite it.
- **Prohibited**: "Clever" one-liners, obscure bitwise operations, implicit side-effects, "Magic" framework behavior that is not documented.
- **Preferred**: Verbose, explicit, intention-revealing names.

### 1.2 Correctness Over Convenience

We do not take shortcuts that compromise data integrity or strictness.

- **Rule**: Never silence a checked exception without handling it. Never return `null` where an `Optional` or Result type is expected.
- **Prohibited**: `catch (Exception e) { e.printStackTrace(); }`, passing raw `String` for domain IDs.

### 1.3 Stability Over Speed

A fast system that crashes or produces incorrect data is worthless.

- **Rule**: Optimize for **Mean Time To Recovery (MTTR)** and **Determinism**.
- **Prohibited**: Race conditions, unconstrained thread pools, unbounded queues.

### 1.4 Explicitness Over Magic

- **Rule**: We prefer explicit configuration. We want to know exactly what beans are created and why.
- **Prohibited**: Excessive AOP that hides control flow. Auto-configuration overuse without documentation.

---

## 2. ARCHITECTURE BOUNDARIES

### 2.1 The Inward Dependency Rule (The Golden Rule)

**Dependencies must always point INWARD.**

```
[ Web / UI ] ──▶ [ Application ] ──▶ [ Domain ] ◀── [ Infrastructure ]
```

- **Domain**: Knows NOTHING about Application, Infrastructure, or Web.
- **Application**: Knows only about the Domain.
- **Infrastructure**: Knows about Application and Domain (to implement interfaces defined there).

> This rule is enforced automatically by ArchUnit tests (see Section 12.4).

### 2.2 Canonical Package Structure

Every module follows this exact structure. No deviations.

```
com.company.{service-name}/
├── domain/
│   ├── model/                  # Entities, Value Objects
│   │   ├── {Aggregate}.java
│   │   └── vo/                 # Value Objects
│   ├── event/                  # Domain Events
│   ├── repository/             # Repository Interfaces (ports)
│   ├── service/                # Domain Services (pure logic)
│   └── exception/              # Domain-specific exceptions
│
├── application/
│   ├── usecase/                # One class per use case
│   ├── dto/
│   │   ├── command/            # Input DTOs
│   │   └── response/           # Output DTOs
│   ├── mapper/                 # MapStruct interfaces
│   └── port/                   # Input ports (optional, for strict hexagonal)
│
├── adapter/
│   ├── web/
│   │   ├── controller/         # REST Controllers
│   │   └── advice/             # @ControllerAdvice
│   ├── messaging/              # Kafka/RabbitMQ consumers & producers
│   └── scheduler/              # Scheduled jobs
│
└── infrastructure/
    ├── persistence/
    │   ├── entity/             # JPA @Entity classes
    │   ├── repository/         # Spring Data JPA interfaces + Impl
    │   └── mapper/             # JPA Entity <-> Domain mapper
    ├── client/                 # External HTTP/gRPC clients
    └── config/                 # Spring @Configuration classes
```

### 2.3 Layer Definitions & Responsibilities

#### A. Domain Layer (The Core)

- **Purpose**: Business logic that exists independently of any framework.
- **Contents**: Entities, Value Objects, Domain Services, Repository Interfaces, Domain Events, Domain Exceptions.
- **Dependencies**: **ZERO framework dependencies**. Pure Java. No Spring, No Hibernate, No Jackson.
  - _Allowed_: `java.util`, `java.time`, `java.util.function`, foundational utilities (Apache Commons — sparingly).
- **Rule**: Entities encapsulate their own invariants. Not bags of getters/setters.

#### B. Application Layer (The Orchestrator)

- **Purpose**: Orchestrates domain objects to fulfill a user intent. One Use Case class per business action.
- **Contents**: Use Cases, DTOs (Commands & Responses), Mappers.
- **Dependencies**: Domain Layer only.
- **Rule**: **ZERO business logic**. The Application layer asks the Domain, never decides itself.
  - Pattern: `Fetch → Validate (via Domain) → Execute (via Domain) → Persist → Publish Event`

#### C. Adapter/Interface Layer (The Ports)

- **Purpose**: Entry and exit points. Translate external protocols to Application commands.
- **Contents**: REST Controllers, Message Consumers, Schedulers.
- **Dependencies**: Application Layer.
- **Rule**: Dumb translation only. No `if/else` business logic. No direct domain access.

#### D. Infrastructure Layer (The Detail)

- **Purpose**: Implementations of everything the Application and Domain need.
- **Contents**: JPA Repositories, External Clients, Spring Configuration.
- **Dependencies**: Application Layer, Domain Layer (implements interfaces defined there).
- **Rule**: This is the ONLY place where `@Entity`, `@Table`, `@Repository`, `@Service` (Spring), `@Configuration` appear in bulk.

---

## 3. NAMING CONVENTIONS (AI MUST FOLLOW EXACTLY)

### 3.1 Class Naming

| Type                    | Convention                     | Example                                                 |
| :---------------------- | :----------------------------- | :------------------------------------------------------ |
| Entity                  | Noun                           | `Order`, `Customer`, `Product`                          |
| Value Object            | Noun (descriptive)             | `EmailAddress`, `Money`, `OrderId`                      |
| Domain Service          | Noun + "Service"/"Policy"      | `PricingPolicy`, `DiscountService`                      |
| Repository Interface    | Entity + "Repository"          | `OrderRepository`                                       |
| Use Case (Application)  | Verb + Noun + "UseCase"        | `PlaceOrderUseCase`, `RegisterCustomerUseCase`          |
| Application Service     | Noun + "Service"               | `OrderService` (only if multiple use cases share state) |
| REST Controller         | Noun + "Controller"            | `OrderController`                                       |
| JPA Entity              | Noun + "Entity"                | `OrderEntity`, `CustomerEntity`                         |
| JPA Repository (Spring) | Entity + "JpaRepository"       | `OrderJpaRepository`                                    |
| Repository Impl         | Entity + "RepositoryImpl"      | `OrderRepositoryImpl`                                   |
| Command DTO             | Verb + Noun + "Command"        | `PlaceOrderCommand`, `UpdateEmailCommand`               |
| Response DTO            | Noun + "Response" or "Summary" | `OrderResponse`, `CustomerSummary`                      |
| Domain Event            | Noun + Past Tense Verb         | `OrderPlaced`, `CustomerRegistered`                     |
| Exception               | Noun + "Exception"             | `InsufficientFundsException`                            |
| Mapper (MapStruct)      | Source + "Mapper"              | `OrderMapper`, `CustomerMapper`                         |
| Config class            | Noun + "Config"                | `SecurityConfig`, `KafkaConfig`                         |

### 3.2 Method Naming

| Action                 | Prefix               | Example                            |
| :--------------------- | :------------------- | :--------------------------------- |
| Retrieve single        | `find`               | `findById()`, `findByEmail()`      |
| Retrieve collection    | `findAll`            | `findAllByStatus()`                |
| Check existence        | `exists`             | `existsByEmail()`                  |
| State change on Entity | Verb (imperative)    | `place()`, `cancel()`, `approve()` |
| Validation             | `validate`           | `validatePaymentMethod()`          |
| Factory method         | `of` / `create`      | `Money.of(100, Currency.USD)`      |
| Boolean check          | `is` / `has` / `can` | `isExpired()`, `hasItems()`        |

### 3.3 Package Naming

- Always lowercase, no underscores.
- Follow the canonical structure in Section 2.2 exactly.
- Never create packages outside the defined structure without ADR justification.

---

## 4. THE TYPE SYSTEM: YOUR FIRST DEFENSE

### 4.1 Primitive Obsession is Forbidden

Using primitives (`String`, `int`, `long`) for domain concepts is a failure of modeling.

- **The Anti-Pattern**:

  ```java
  // What is string1? Email? Name? ID? What is double — cents? dollars? euros?
  public void process(String id, String email, double amount) { ... }
  ```

- **The Strict Rule**: Wrap domain concepts in **Value Objects**.
  ```java
  public void process(OrderId id, EmailAddress email, Money amount) { ... }
  ```

### 4.2 Java Records (Standard for Immutable Data)

Use `record` for DTOs, Value Objects, Event Messages, and Map Keys.

```java
// Value Object with validation in compact constructor
public record EmailAddress(String value) {
    public EmailAddress {
        Objects.requireNonNull(value, "Email cannot be null");
        if (!value.matches("^[^@]+@[^@]+\\.[^@]+$")) {
            throw new DomainValidationException("Invalid email: " + value);
        }
        value = value.toLowerCase().trim(); // normalize
    }

    public static EmailAddress of(String raw) {
        return new EmailAddress(raw);
    }
}
```

```java
// ID Value Object — always wrap raw IDs
public record OrderId(UUID value) {
    public OrderId {
        Objects.requireNonNull(value, "OrderId cannot be null");
    }

    public static OrderId generate() {
        return new OrderId(UUID.randomUUID());
    }

    public static OrderId of(String raw) {
        try {
            return new OrderId(UUID.fromString(raw));
        } catch (IllegalArgumentException e) {
            throw new DomainValidationException("Invalid OrderId format: " + raw);
        }
    }
}
```

### 4.3 Sealed Classes (Standard for Closed Hierarchies)

Use for: Result types, Domain Events, Finite State Machines.

```java
public sealed interface PaymentResult permits PaymentResult.Success, PaymentResult.Failure, PaymentResult.Pending {

    record Success(String transactionId, Instant processedAt) implements PaymentResult {}
    record Failure(String reason, ErrorCode code) implements PaymentResult {}
    record Pending(Duration estimatedEta) implements PaymentResult {}
}
```

```java
// Exhaustive switch — compiler guarantees all cases covered. No 'default' needed.
String userMessage = switch (result) {
    case PaymentResult.Success s -> "Payment confirmed: " + s.transactionId();
    case PaymentResult.Failure f -> "Payment failed: " + f.reason();
    case PaymentResult.Pending p -> "Processing, ETA: " + p.estimatedEta().toMinutes() + "m";
};
```

### 4.4 Money Handling (CRITICAL)

**Never use `double` or `float` for monetary values.** Use `BigDecimal` wrapped in a `Money` Value Object.

```java
public record Money(BigDecimal amount, Currency currency) {

    public Money {
        Objects.requireNonNull(amount, "Amount cannot be null");
        Objects.requireNonNull(currency, "Currency cannot be null");
        if (amount.compareTo(BigDecimal.ZERO) < 0) {
            throw new DomainValidationException("Money amount cannot be negative");
        }
        amount = amount.setScale(2, RoundingMode.HALF_UP);
    }

    public static Money of(BigDecimal amount, Currency currency) {
        return new Money(amount, currency);
    }

    public Money add(Money other) {
        assertSameCurrency(other);
        return new Money(this.amount.add(other.amount), this.currency);
    }

    public Money subtract(Money other) {
        assertSameCurrency(other);
        var result = this.amount.subtract(other.amount);
        if (result.compareTo(BigDecimal.ZERO) < 0) {
            throw new InsufficientFundsException(this, other);
        }
        return new Money(result, this.currency);
    }

    private void assertSameCurrency(Money other) {
        if (!this.currency.equals(other.currency)) {
            throw new CurrencyMismatchException(this.currency, other.currency);
        }
    }
}
```

---

## 5. DOMAIN MODELING

### 5.1 Entities vs. Value Objects

| Aspect     | Entity                                  | Value Object                        |
| :--------- | :-------------------------------------- | :---------------------------------- |
| Identity   | Has unique ID (persists across changes) | No ID; defined by attributes        |
| Mutability | Mutable (state changes over lifetime)   | Immutable                           |
| Equality   | By ID only                              | By all fields (Records handle this) |
| Example    | `Order`, `Customer`, `Product`          | `Money`, `EmailAddress`, `Address`  |

### 5.2 Rich Domain Model (Non-Negotiable)

**The Anti-Pattern (Anemic Model)**:

```java
// BAD: Entity is a data bag. Logic scattered in service.
class Order {
    List<LineItem> items;
    public List<LineItem> getItems() { return items; } // exposes internals
}

class OrderService {
    void addItem(Order order, LineItem item) {
        if (order.getItems().size() >= 10) throw new RuntimeException(); // logic detached from data
        order.getItems().add(item);
    }
}
```

**The Correct Pattern (Rich Model)**:

```java
// GOOD: Entity owns and protects its invariants.
public class Order {
    private final OrderId id;
    private final List<LineItem> items = new ArrayList<>();
    private OrderStatus status;

    // Factory method — controlled creation
    public static Order create(CustomerId customerId) {
        var order = new Order(OrderId.generate(), customerId);
        order.registerEvent(new OrderCreated(order.id, customerId, Instant.now()));
        return order;
    }

    public void addItem(Product product, Quantity quantity) {
        ensureStatus(OrderStatus.DRAFT);
        if (items.size() >= 10) {
            throw new OrderItemLimitExceededException(id, 10);
        }
        items.add(LineItem.of(product, quantity));
    }

    public void place() {
        ensureStatus(OrderStatus.DRAFT);
        if (items.isEmpty()) {
            throw new EmptyOrderException(id);
        }
        this.status = OrderStatus.PLACED;
        registerEvent(new OrderPlaced(id, calculateTotal(), Instant.now()));
    }

    private void ensureStatus(OrderStatus required) {
        if (this.status != required) {
            throw new InvalidOrderStateException(id, required, this.status);
        }
    }
}
```

**Rule**: **Tell, Don't Ask.** Tell the object to do something; don't ask for its data to do it yourself.

### 5.3 Domain Events Pattern

```java
// 1. Domain Event (past tense, immutable)
public record OrderPlaced(
    OrderId orderId,
    Money totalAmount,
    Instant occurredAt
) implements DomainEvent {}

// 2. Base class for event registration (Domain layer)
public abstract class AggregateRoot {
    private final List<DomainEvent> domainEvents = new ArrayList<>();

    protected void registerEvent(DomainEvent event) {
        domainEvents.add(event);
    }

    public List<DomainEvent> pullDomainEvents() {
        var events = List.copyOf(domainEvents);
        domainEvents.clear();
        return events;
    }
}

// 3. Application Service publishes the events
@Service
@RequiredArgsConstructor
public class PlaceOrderUseCase {
    private final OrderRepository orderRepository;
    private final ApplicationEventPublisher eventPublisher;

    @Transactional
    public OrderResponse execute(PlaceOrderCommand command) {
        var order = orderRepository.findById(command.orderId())
            .orElseThrow(() -> new OrderNotFoundException(command.orderId()));

        order.place(); // Domain logic

        orderRepository.save(order);

        order.pullDomainEvents().forEach(eventPublisher::publishEvent); // Publish after save

        return orderMapper.toResponse(order);
    }
}
```

---

## 6. JAVA LANGUAGE SUBSET

### 6.1 Allowed and Encouraged

- **`var`**: Use for local variables where type is obvious from the right-hand side.
  - `var users = new ArrayList<User>();` ✅
  - `var result = userRepository.findById(id);` ✅ (type is clear from method name)
  - `var x = getValue();` ❌ (type of `x` is ambiguous)

- **Streams**: Use for data processing chains. Keep readable. If a stream exceeds 5 lines, extract a private method.

- **`Optional`**: Return types ONLY. Never for arguments or fields.

- **Text Blocks**: Use for multi-line strings (SQL, JSON templates, log messages).

  ```java
  var query = """
      SELECT o.id, o.status, c.name
      FROM orders o
      JOIN customers c ON o.customer_id = c.id
      WHERE o.status = :status
      """;
  ```

- **Virtual Threads (Java 21)**: Prefer for I/O-bound services.
  ```java
  // In config
  @Bean
  public AsyncTaskExecutor applicationTaskExecutor() {
      return new TaskExecutorAdapter(Executors.newVirtualThreadPerTaskExecutor());
  }
  ```

### 6.2 Disallowed / Caution

| Feature             | Status                      | Reason                                       |
| :------------------ | :-------------------------- | :------------------------------------------- |
| Reflection          | FORBIDDEN in business logic | Use only in framework/infra code             |
| `null`              | AVOID                       | Use `Optional` or `@NonNull`/`@Nullable`     |
| `synchronized`      | FORBIDDEN                   | Use `java.util.concurrent` (ReentrantLock)   |
| Checked Exceptions  | Sparingly                   | Prefer RuntimeExceptions or Result types     |
| `@SuppressWarnings` | Caution                     | Document WHY explicitly above the annotation |
| Raw types           | FORBIDDEN                   | `List list` → `List<User> users`             |

---

## 7. THE SPRING ECOSYSTEM: RULES OF ENGAGEMENT

### 7.1 Dependency Injection

- **Constructor Injection ONLY**. All dependencies must be `final`.
- **Tool**: `@RequiredArgsConstructor` from Lombok.
- **Forbidden**: `@Autowired` on fields, setter injection.

```java
// CORRECT
@Service
@RequiredArgsConstructor
@Slf4j
public class RegisterCustomerUseCase {
    private final CustomerRepository customerRepository;
    private final EmailService emailService;
    private final CustomerMapper customerMapper;
    // ...
}
```

### 7.2 Component Stereotypes — Use Correctly

| Annotation        | Layer          | Purpose                               |
| :---------------- | :------------- | :------------------------------------ |
| `@Service`        | Application    | Use Case orchestrators (Tx live here) |
| `@RestController` | Adapter/Web    | REST endpoints                        |
| `@Repository`     | Infrastructure | DB access implementations             |
| `@Component`      | Infrastructure | Generic utility, infra beans          |
| `@Configuration`  | Infrastructure | Bean definitions                      |

**NEVER** put `@Service` on a Domain object.

### 7.3 Configuration Management

```java
// WRONG: Scattered @Value — no type safety, no IDE support
@Value("${app.payment.timeout-ms}")
private int timeout; // is this milliseconds or seconds??

// CORRECT: Typed, grouped, validated at startup
@ConfigurationProperties(prefix = "app.payment")
public record PaymentConfig(
    Duration timeout,
    int maxRetries,
    String gatewayUrl
) {}
```

Register in `application.yml`:

```yaml
app:
  payment:
    timeout: PT5S # ISO-8601, auto-converted to Duration
    max-retries: 3
    gateway-url: ${PAYMENT_GATEWAY_URL} # Injected from env at runtime
```

### 7.4 Lombok Policy (Sharp Knife Rules)

| Annotation                     | Status       | Notes                                      |
| :----------------------------- | :----------- | :----------------------------------------- |
| `@Getter`                      | ✅ Allowed   | DTOs, simple classes                       |
| `@Builder`                     | ✅ Allowed   | DTOs, test builders                        |
| `@RequiredArgsConstructor`     | ✅ Allowed   | Services, use with `final` fields          |
| `@Slf4j`                       | ✅ Allowed   | Any class needing logging                  |
| `@Value`                       | ✅ Allowed   | Immutable DTOs (not Spring's @Value!)      |
| `@Data` on Entity              | ❌ FORBIDDEN | Breaks `equals/hashCode` on mutable fields |
| `@ToString` on Entity          | ❌ FORBIDDEN | Infinite recursion on Lazy Loading         |
| `@AllArgsConstructor`          | ❌ FORBIDDEN | Bypasses validation in constructors        |
| `@EqualsAndHashCode` on Entity | ❌ FORBIDDEN | Must implement manually, based on ID       |

---

## 8. PERSISTENCE & DATA ACCESS

### 8.1 JPA Entity Rules

JPA Entities are **NOT Domain Entities**. They are persistence-layer objects that map to tables.

```java
// Infrastructure layer: com.company.service.infrastructure.persistence.entity
@Entity
@Table(name = "orders")
@Getter                     // Lombok allowed here
@NoArgsConstructor(access = AccessLevel.PROTECTED) // JPA requires no-arg, but protect it
public class OrderEntity {

    @Id
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @Column(name = "customer_id", nullable = false)
    private UUID customerId;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private OrderStatus status;

    @OneToMany(
        mappedBy = "order",
        cascade = CascadeType.ALL,
        orphanRemoval = true,
        fetch = FetchType.LAZY   // LAZY IS LAW
    )
    private List<LineItemEntity> items = new ArrayList<>();

    @Version
    private Long version; // Optimistic locking — ALWAYS include on aggregate roots

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @LastModifiedDate
    @Column(name = "updated_at")
    private Instant updatedAt;
}
```

### 8.2 Repository Pattern

```java
// Domain Layer: defines the contract (interface only)
// com.company.service.domain.repository
public interface OrderRepository {
    Optional<Order> findById(OrderId id);
    List<Order> findAllByCustomerId(CustomerId customerId);
    Order save(Order order);
    void delete(OrderId id);
    boolean existsById(OrderId id);
}

// Infrastructure Layer: implements the contract
// com.company.service.infrastructure.persistence.repository
@Repository
@RequiredArgsConstructor
public class OrderRepositoryImpl implements OrderRepository {
    private final OrderJpaRepository jpaRepository;
    private final OrderEntityMapper entityMapper;

    @Override
    public Optional<Order> findById(OrderId id) {
        return jpaRepository.findById(id.value())
            .map(entityMapper::toDomain);
    }

    @Override
    public Order save(Order order) {
        var entity = entityMapper.toEntity(order);
        return entityMapper.toDomain(jpaRepository.save(entity));
    }
}
```

### 8.3 Transaction Boundaries

- Transactions begin and end at **Application Service** methods.
- `@Transactional(readOnly = true)` by default on class level.
- Override with `@Transactional` (write) at method level.

```java
@Service
@Transactional(readOnly = true)  // default for all methods
@RequiredArgsConstructor
public class OrderQueryService {

    public OrderResponse findById(OrderId id) { ... }  // uses readOnly

    @Transactional  // override for writes
    public OrderResponse placeOrder(PlaceOrderCommand command) { ... }
}
```

**Short Transactions Rule**:

- ❌ `Open Tx → Call External API (3s) → Save to DB`
- ✅ `Call External API → Open Tx → Save to DB`

### 8.4 N+1 Detection

Use `JOIN FETCH` or `@EntityGraph` to avoid N+1 queries. Use `p6spy` in `local` profile.

```java
@Query("SELECT o FROM OrderEntity o JOIN FETCH o.items WHERE o.customerId = :customerId")
List<OrderEntity> findAllWithItemsByCustomerId(@Param("customerId") UUID customerId);
```

### 8.5 Database Migrations (Flyway)

- Every schema change is a versioned SQL file. No exceptions.
- **Naming**: `V{version}__{description}.sql` (e.g., `V1__create_orders_table.sql`)
- **FORBIDDEN**: `spring.jpa.hibernate.ddl-auto=update` in any non-local environment.
- Migrations are **append-only**. Never modify an already-applied migration.

---

## 9. CONCURRENCY & ASYNC

### 9.1 Virtual Threads (Java 21 — Preferred Approach)

```java
@Configuration
public class AsyncConfig {

    @Bean(name = "virtualThreadExecutor")
    public Executor virtualThreadExecutor() {
        return Executors.newVirtualThreadPerTaskExecutor();
    }

    // Enable virtual threads for Spring MVC
    @Bean
    public TomcatProtocolHandlerCustomizer<?> virtualThreadTomcatCustomizer() {
        return handler -> handler.setExecutor(Executors.newVirtualThreadPerTaskExecutor());
    }
}
```

**Caveat**: Avoid `synchronized` inside virtual threads (causes pinning). Use `ReentrantLock` instead.

### 9.2 CompletableFuture for Parallel Calls

```java
// Fetch user and orders in parallel
var userFuture = CompletableFuture.supplyAsync(
    () -> userRepository.findById(userId), virtualThreadExecutor);
var ordersFuture = CompletableFuture.supplyAsync(
    () -> orderRepository.findAllByUserId(userId), virtualThreadExecutor);

var result = userFuture
    .thenCombine(ordersFuture, (user, orders) -> new UserDashboard(user, orders))
    .exceptionally(ex -> {
        log.error("Failed to build dashboard for user {}", userId, ex);
        throw new DashboardUnavailableException(userId, ex);
    })
    .join();
```

### 9.3 Thread Safety Rules

- **Spring Singletons must be stateless**. No mutable instance fields.
- **Immutability** is the best synchronization strategy.
- `ConcurrentHashMap` over `HashMap` for shared state.
- Never use `ThreadLocal` without cleaning up in `finally`.

---

## 10. API LAYER

### 10.1 Controller Design (Dumb Adapter Rule)

Controllers are **dumb**. Their only job:

1. Deserialize request
2. Validate inputs (`@Valid`)
3. Call Application Use Case
4. Map result to response DTO
5. Return HTTP response with correct status code

```java
@RestController
@RequestMapping("/v1/orders")
@RequiredArgsConstructor
@Tag(name = "Orders", description = "Order management endpoints")
public class OrderController {

    private final PlaceOrderUseCase placeOrderUseCase;
    private final GetOrderUseCase getOrderUseCase;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Place a new order")
    public OrderResponse placeOrder(
        @Valid @RequestBody PlaceOrderRequest request,
        @AuthenticationPrincipal Jwt jwt
    ) {
        var command = PlaceOrderCommand.of(request, CustomerId.of(jwt.getSubject()));
        return placeOrderUseCase.execute(command);
    }

    @GetMapping("/{orderId}")
    public OrderResponse getOrder(@PathVariable String orderId) {
        return getOrderUseCase.execute(OrderId.of(orderId));
    }
}
```

### 10.2 Input Validation

Use Jakarta Bean Validation (`@Valid`) in Controllers + custom validators for domain rules:

```java
public record PlaceOrderRequest(
    @NotNull(message = "Customer ID is required")
    @Pattern(regexp = "^[0-9a-f-]{36}$", message = "Invalid customer ID format")
    String customerId,

    @NotEmpty(message = "Order must have at least one item")
    @Size(max = 10, message = "Order cannot exceed 10 items")
    List<@Valid OrderItemRequest> items
) {}
```

### 10.3 Global Error Handling (RFC 7807)

```java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(DomainValidationException.class)
    @ResponseStatus(HttpStatus.UNPROCESSABLE_ENTITY)
    public ProblemDetail handleDomainValidation(DomainValidationException ex) {
        var problem = ProblemDetail.forStatusAndDetail(
            HttpStatus.UNPROCESSABLE_ENTITY, ex.getMessage());
        problem.setType(URI.create("error/validation-failed"));
        problem.setTitle("Validation Failed");
        return problem;
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ProblemDetail handleNotFound(ResourceNotFoundException ex) {
        return ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, ex.getMessage());
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ProblemDetail handleUnexpected(Exception ex, HttpServletRequest request) {
        log.error("Unhandled exception for request {}", request.getRequestURI(), ex);
        // NEVER leak stack trace to client
        return ProblemDetail.forStatusAndDetail(
            HttpStatus.INTERNAL_SERVER_ERROR, "An unexpected error occurred");
    }
}
```

### 10.4 API Versioning & Stability

- Use **URI versioning**: `/v1/orders`, `/v2/orders`
- Breaking changes require a **new version**.
- **Additive changes** (new optional fields) are backward-compatible — allowed in same version.
- Deprecate versions with `@Deprecated` in OpenAPI + response header: `Deprecation: true`

---

## 11. SECURITY

### 11.1 Authentication & Authorization

- **Protocol**: OAuth2 / OIDC with JWT Bearer Tokens.
- **Identity Provider**: Keycloak / Auth0 / Okta (never roll your own auth).
- **Stateless**: Validate JWT signature at the gateway or filter level. No server-side sessions.

```java
@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
            .csrf(AbstractHttpConfigurer::disable)          // Stateless JWT — no CSRF needed
            .sessionManagement(s -> s.sessionCreationPolicy(STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/actuator/health/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/v1/products/**").permitAll()
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()))
            .build();
    }
}
```

### 11.2 Secrets Management

- **The Cardinal Sin**: Committing any secret to Git.
- **Rule**: All secrets injected at runtime via Environment Variables or HashiCorp Vault.
- **Prevention**: `git-secrets` or `truffleHog` in pre-commit hooks.
- **Rotation**: System must support key rotation without redeployment.

### 11.3 OWASP Defenses

| Threat          | Defense                                                                     |
| :-------------- | :-------------------------------------------------------------------------- |
| SQL Injection   | JPA/Prepared Statements only. NEVER string concatenation in queries.        |
| XSS             | Sanitize inputs. Enable CSP header.                                         |
| Vulnerable Deps | OWASP Dependency Check + Snyk in CI/CD pipeline.                            |
| Mass Assignment | Use specific Command DTOs, never expose domain objects to HTTP layer.       |
| IDOR            | Validate that the authenticated user owns the resource before returning it. |

---

## 12. OBSERVABILITY

### 12.1 The "Shippable" Rule

**A feature is NOT done until it is observable.**
No logging = doesn't exist. No metrics = can't be alerted on. No tracing = can't be debugged.

### 12.2 Structured Logging (JSON)

```java
// application.yml
logging:
  pattern:
    console: "%d{ISO8601} [%X{traceId},%X{spanId}] %-5level %logger{36} - %msg%n"

// In code — ALWAYS use SLF4J via @Slf4j
@Slf4j
public class PlaceOrderUseCase {

    public OrderResponse execute(PlaceOrderCommand command) {
        log.info("Placing order for customer={} itemCount={}",
            command.customerId(), command.items().size());
        // ...
        log.info("Order placed successfully orderId={} total={}",
            order.getId(), order.getTotal());
    }
}
```

**Log Level Rules**:

- `ERROR`: Actionable failure requiring immediate attention.
- `WARN`: Recoverable failure (e.g., retry succeeded, rate limit hit).
- `INFO`: Lifecycle events (startup, job completion, significant state changes).
- `DEBUG`: Developer context (request details, intermediate state). OFF in production.
- **FORBIDDEN**: `System.out.println`, `e.printStackTrace()`.

### 12.3 Metrics (Micrometer)

```java
@Service
@RequiredArgsConstructor
public class PlaceOrderUseCase {
    private final MeterRegistry meterRegistry;

    public OrderResponse execute(PlaceOrderCommand command) {
        return meterRegistry.timer("orders.place",
                "customer_tier", command.customerTier().name()) // bounded tag
            .record(() -> doPlaceOrder(command));
    }
}
```

**RED Method** (minimum metrics per endpoint):

- **R**ate: `orders.place.count`
- **E**rrors: `orders.place.errors`
- **D**uration: `orders.place.duration` (p50, p95, p99)

**Cardinality Warning**: NEVER use user IDs, email addresses, or free-form URLs as metric tags. Only bounded values (status codes, enum values, fixed tiers).

### 12.4 Distributed Tracing

- Tool: OpenTelemetry + Zipkin / Jaeger
- Propagate `traceparent` header across all HTTP and Kafka calls.
- Ensure Spring Boot auto-configuration picks up Micrometer Tracing.

### 12.5 Health Checks

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health, info, metrics, prometheus
  endpoint:
    health:
      show-details: when-authorized
      probes:
        enabled: true # /actuator/health/liveness + /actuator/health/readiness
```

---

## 13. TESTING STRATEGY

### 13.1 The Test Pyramid

```
          ┌─────────────────────┐
          │  E2E / Contract     │  Few — slow, expensive
          ├─────────────────────┤
          │   Integration       │  Some — real DB via Testcontainers
          ├─────────────────────┤
          │      Unit           │  Many — fast, focused on Domain
          └─────────────────────┘
```

### 13.2 Unit Tests (Domain Logic Focus)

```java
class OrderTest {

    @Test
    void should_add_item_successfully_when_order_is_draft() {
        // Arrange
        var order = Order.create(CustomerId.generate());
        var product = ProductFixture.aProduct().withPrice(Money.of(new BigDecimal("10.00"), USD)).build();

        // Act
        order.addItem(product, Quantity.of(2));

        // Assert
        assertThat(order.getItems()).hasSize(1);
        assertThat(order.calculateTotal()).isEqualTo(Money.of(new BigDecimal("20.00"), USD));
    }

    @Test
    void should_throw_when_adding_item_to_non_draft_order() {
        // Arrange
        var order = aPlacedOrder(); // test fixture

        // Act & Assert
        assertThatThrownBy(() -> order.addItem(anyProduct(), Quantity.of(1)))
            .isInstanceOf(InvalidOrderStateException.class)
            .hasMessageContaining("PLACED");
    }
}
```

**Test naming**: `should_{expectedBehavior}_when_{condition}()`

### 13.3 Integration Tests (Testcontainers — Real DB)

```java
@SpringBootTest
@Testcontainers
@Transactional
class OrderRepositoryImplTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine");

    @DynamicPropertySource
    static void configureDataSource(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired
    private OrderRepository orderRepository;

    @Test
    void should_persist_and_retrieve_order() { ... }
}
```

**Rule**: Use **real Postgres** (via Testcontainers). NEVER H2 for integration tests — H2 behaves differently and hides real bugs.

### 13.4 Architecture Tests (ArchUnit)

```java
@AnalyzeClasses(packages = "com.company.service")
class ArchitectureTest {

    @ArchTest
    static final ArchRule domain_has_no_framework_dependencies =
        noClasses().that().resideInAPackage("..domain..")
            .should().dependOnClassesThat()
            .resideInAnyPackage("org.springframework..", "jakarta.persistence..");

    @ArchTest
    static final ArchRule application_does_not_depend_on_infrastructure =
        noClasses().that().resideInAPackage("..application..")
            .should().dependOnClassesThat()
            .resideInAPackage("..infrastructure..");

    @ArchTest
    static final ArchRule controllers_must_not_access_domain_directly =
        noClasses().that().resideInAPackage("..adapter.web..")
            .should().dependOnClassesThat()
            .resideInAPackage("..domain..");
}
```

### 13.5 Test Fixtures (Builder Pattern)

```java
// Use builder-style fixtures for readability
public class OrderFixture {
    public static OrderBuilder anOrder() {
        return new OrderBuilder()
            .withId(OrderId.generate())
            .withCustomerId(CustomerId.generate())
            .withStatus(OrderStatus.DRAFT);
    }

    public static Order aPlacedOrder() {
        return anOrder().withStatus(OrderStatus.PLACED).build();
    }
}
```

---

## 14. MAINTENANCE & EVOLUTION

### 14.1 Refactoring Discipline

- **Boy Scout Rule**: Leave code cleaner than you found it.
- **Trigger**: Method > 50 lines → extract. Copy-paste detected → extract.
- **Safety**: Write characterization tests first if none exist.

### 14.2 Handling Legacy Code

- **Sprout Method**: Add new logic in new methods, call from old.
- **Wrap Method**: Wrap old methods, add new behavior around them.
- **Strangler Fig**: Gradually replace the old system piece by piece.

### 14.3 Deprecation Policy

```java
/**
 * @deprecated Use {@link RegisterCustomerUseCase} instead.
 * Will be removed in version 3.0.
 */
@Deprecated(forRemoval = true, since = "2.5")
public class OldRegistrationService { ... }
```

---

## 15. ARCHITECTURAL DECISIONS (ADR)

For every significant decision, write an ADR in `/docs/adr/`.

```markdown
# ADR-001: Use Virtual Threads over WebFlux

## Status

Accepted

## Context

Our service is I/O-bound (DB + external APIs). We need high concurrency.
Options: Spring WebFlux (Reactive) or Virtual Threads (Project Loom).

## Decision

Use Virtual Threads (Java 21).

## Consequences

- ✅ Blocking code style — simpler, lower learning curve
- ✅ Same performance as Reactive for I/O-bound workloads
- ❌ Avoid synchronized blocks (pinning issue) — use ReentrantLock
- ❌ Not suitable for CPU-bound workloads (use platform threads there)
```

---

## 16. GOVERNANCE

### 16.1 Library Adoption Matrix

Every external dependency is a liability.

| Criterion   | Weight | Question                                     |
| :---------- | :----- | :------------------------------------------- |
| **Value**   | 40%    | Does this save > 1 week of effort?           |
| **Cost**    | 20%    | High learning curve? Heavy runtime overhead? |
| **Risk**    | 20%    | Maintained? Last commit < 3 months?          |
| **License** | 20%    | Apache 2.0 / MIT? (GPL is **banned**)        |

**Threshold**: Score < 70% → **REJECT**.

### 16.2 ROI for Architectural Changes

$$ROI = (\text{Hours Saved} \times \text{Hourly Rate}) - (\text{Integration Cost} + \text{Ongoing Maintenance Cost})$$

If ROI ≤ 0: do not proceed. "It's interesting" is not a business reason.

---

## 17. AI AGENT QUICK-REFERENCE CHECKLIST

Before submitting any code output, run this mentally:

### Architecture

- [ ] Correct layer for every class?
- [ ] No outward dependency violations?
- [ ] Domain has zero framework imports?

### Type Safety

- [ ] No primitive obsession? (`String` for IDs, `double` for money)
- [ ] Value Objects created for all domain concepts?
- [ ] Records used for DTOs and VOs?

### Spring

- [ ] Constructor injection with `final` fields?
- [ ] No `@Autowired` on fields?
- [ ] `@Transactional` at Application Service, not Domain?

### Persistence

- [ ] `FetchType.LAZY` on all relationships?
- [ ] `@Version` on aggregate root entities?
- [ ] No `ddl-auto=update` outside local profile?
- [ ] Flyway migration included for schema changes?

### API

- [ ] Controller is a dumb adapter (no business logic)?
- [ ] `@Valid` on request bodies?
- [ ] RFC 7807 error format in `@ControllerAdvice`?
- [ ] No stack trace leaked to client?

### Observability

- [ ] Meaningful log statements at correct levels?
- [ ] No `System.out.println`?
- [ ] Metrics for new endpoints (RED method)?

### Testing

- [ ] Unit test for Domain logic?
- [ ] Test naming: `should_X_when_Y()`?
- [ ] ArchUnit tests cover new packages?

---

## 18. CLOSING MANDATE

> **"An Architect builds for the person who has to fix the system at 3 AM."**

| If it is...                 | Then...                |
| :-------------------------- | :--------------------- |
| Clever                      | Kill it                |
| Implicit                    | Make it explicit       |
| Not tested                  | It doesn't exist       |
| Leaking framework to Domain | Rejected               |
| Touching `null` directly    | Rejected               |
| Using `double` for money    | Rejected immediately   |
| Without a domain event      | Check if one is needed |
| Faster but less correct     | Stability wins         |

**This is the way.**
