package tooling;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.List;
import org.junit.jupiter.api.Test;

class DatabaseTestDataGeneratorTest {

    @Test
    void shouldParseCliArguments() {
        DatabaseTestDataGenerator.Config config = DatabaseTestDataGenerator.Config.fromArgs(new String[] {
                "--videos", "4",
                "--ratings", "6",
                "--watchlist", "2",
                "--history", "1",
                "--seed", "99",
                "--userId", "5",
                "--jdbcUrl", "jdbc:mysql://localhost:3306/thanh_toan",
                "--dbUser", "tester",
                "--dbPassword", "secret"
        });

        assertEquals(4, config.videos());
        assertEquals(6, config.ratings());
        assertEquals(2, config.watchlist());
        assertEquals(1, config.history());
        assertEquals(99L, config.seed());
        assertEquals(5, config.userId());
        assertEquals("jdbc:mysql://localhost:3306/thanh_toan", config.jdbcUrl());
        assertEquals("tester", config.dbUser());
        assertEquals("secret", config.dbPassword());
    }

    @Test
    void shouldRenderConsoleSummary() {
        DatabaseTestDataGenerator.Report report = new DatabaseTestDataGenerator.Report(
                3,
                4,
                2,
                1,
                List.of("watchlist.user_id orphan count = 0"));

        String output = report.toConsoleOutput();

        assertTrue(output.contains("videos=3"));
        assertTrue(output.contains("ratings=4"));
        assertTrue(output.contains("watchlist=2"));
        assertTrue(output.contains("history=1"));
        assertTrue(output.contains("watchlist.user_id orphan count = 0"));
    }
}
