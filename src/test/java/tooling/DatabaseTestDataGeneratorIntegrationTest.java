package tooling;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers(disabledWithoutDocker = true)
class DatabaseTestDataGeneratorIntegrationTest {

    @Container
    static final MySQLContainer<?> MYSQL = new MySQLContainer<>("mysql:8.0.36")
            .withDatabaseName("thanh_toan")
            .withUsername("user1")
            .withPassword("user1123@");

    @BeforeEach
    void resetSchema() throws Exception {
        try (Connection connection = openConnection()) {
            executeStatements(connection, List.of(
                    "DROP VIEW IF EXISTS topup_request",
                    "DROP TABLE IF EXISTS users_subscription",
                    "DROP TABLE IF EXISTS topup_requests",
                    "DROP TABLE IF EXISTS rating_reviews",
                    "DROP TABLE IF EXISTS history",
                    "DROP TABLE IF EXISTS watchlist",
                    "DROP TABLE IF EXISTS videos",
                    "DROP TABLE IF EXISTS users"));
            executeStatements(connection, loadSchemaStatements());
        }
    }

    @Test
    void shouldGenerateRequestedRowsAndVerifyRelations() throws Exception {
        DatabaseTestDataGenerator generator = new DatabaseTestDataGenerator();
        DatabaseTestDataGenerator.Config config = new DatabaseTestDataGenerator.Config(
                MYSQL.getJdbcUrl(),
                MYSQL.getUsername(),
                MYSQL.getPassword(),
                3,
                4,
                2,
                2,
                12345L,
                2);

        DatabaseTestDataGenerator.Report report = generator.generate(config);

        assertEquals(3, report.insertedVideos());
        assertEquals(4, report.insertedRatings());
        assertEquals(2, report.insertedWatchlist());
        assertEquals(2, report.insertedHistory());
        assertFalse(report.verificationFailures().isEmpty());
        assertTrue(report.verificationFailures().stream().allMatch(line -> line.endsWith("= 0")));

        try (Connection connection = openConnection()) {
            assertEquals(4, countRows(connection, "videos"));
            assertEquals(5, countRows(connection, "rating_reviews"));
            assertEquals(3, countRows(connection, "watchlist"));
            assertEquals(3, countRows(connection, "history"));
            assertEquals(1, countRows(connection, "topup_requests"));
            assertEquals(1, countRows(connection, "users_subscription"));
            assertEquals(new BigDecimal("120.00"), userWallet(connection, 2));
            assertEquals(0, orphanCount(connection, "watchlist", "user_id", "users"));
            assertEquals(0, orphanCount(connection, "watchlist", "video_id", "videos"));
            assertEquals(0, orphanCount(connection, "history", "user_id", "users"));
            assertEquals(0, orphanCount(connection, "history", "video_id", "videos"));
            assertEquals(0, orphanCount(connection, "rating_reviews", "user_id", "users"));
            assertEquals(0, orphanCount(connection, "rating_reviews", "video_id", "videos"));
        }
    }

    @Test
    void shouldFailWhenUniqueVideoSlotsAreInsufficient() {
        DatabaseTestDataGenerator generator = new DatabaseTestDataGenerator();
        DatabaseTestDataGenerator.Config config = new DatabaseTestDataGenerator.Config(
                MYSQL.getJdbcUrl(),
                MYSQL.getUsername(),
                MYSQL.getPassword(),
                0,
                0,
                1,
                1,
                7L,
                2);

        IllegalArgumentException error = assertThrows(IllegalArgumentException.class, () -> generator.generate(config));

        assertTrue(error.getMessage().contains("Not enough unused videos"));
    }

    private static Connection openConnection() throws SQLException {
        return DriverManager.getConnection(MYSQL.getJdbcUrl(), MYSQL.getUsername(), MYSQL.getPassword());
    }

    private static List<String> loadSchemaStatements() throws IOException {
        List<String> statements = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        for (String rawLine : Files.readAllLines(Path.of("docker/mysql/init/01-init.sql"))) {
            String line = rawLine.trim();
            if (line.isEmpty() || line.startsWith("--") || line.startsWith("USE ")) {
                continue;
            }
            current.append(rawLine).append('\n');
            if (line.endsWith(";")) {
                String statement = current.toString().trim();
                statements.add(statement.substring(0, statement.length() - 1));
                current.setLength(0);
            }
        }
        return statements;
    }

    private static void executeStatements(Connection connection, List<String> statements) throws SQLException {
        try (Statement statement = connection.createStatement()) {
            for (String sql : statements) {
                statement.execute(sql);
            }
        }
    }

    private static int countRows(Connection connection, String tableName) throws SQLException {
        try (Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery("SELECT COUNT(*) FROM " + tableName)) {
            resultSet.next();
            return resultSet.getInt(1);
        }
    }

    private static BigDecimal userWallet(Connection connection, int userId) throws SQLException {
        try (Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery("SELECT wallet FROM users WHERE id = " + userId)) {
            resultSet.next();
            return resultSet.getBigDecimal(1);
        }
    }

    private static int orphanCount(Connection connection, String tableName, String foreignKeyColumn, String parentTable) throws SQLException {
        String sql = "SELECT COUNT(*) FROM " + tableName + " child LEFT JOIN " + parentTable + " parent ON parent.id = child."
                + foreignKeyColumn + " WHERE parent.id IS NULL";
        try (Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(sql)) {
            resultSet.next();
            return resultSet.getInt(1);
        }
    }
}
