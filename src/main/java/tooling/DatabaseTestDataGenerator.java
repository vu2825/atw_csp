package tooling;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.Random;
import java.util.Set;

public class DatabaseTestDataGenerator {

    private static final String DEFAULT_JDBC_URL = "jdbc:mysql://localhost:3306/thanh_toan?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&allowPublicKeyRetrieval=true&useSSL=false";
    private static final String DEFAULT_DB_USER = "user1";
    private static final String DEFAULT_DB_PASSWORD = "user1123@";

    private static final String[] GENRES = {
            "Action, Adventure",
            "Drama, Mystery",
            "Comedy, Family",
            "Documentary",
            "Sci-Fi, Thriller",
            "Animation, Fantasy"
    };

    private static final String[] DIRECTORS = {
            "Avery Stone",
            "Morgan Reed",
            "Jamie Harper",
            "Riley Brooks",
            "Taylor Quinn"
    };

    private static final String[] PUBLISHERS = {
            "Northwind Studio",
            "Blue Harbor Media",
            "Atlas Pictures",
            "Cedar Lane Films"
    };

    private static final String[] REVIEW_OPENERS = {
            "Well paced",
            "Surprisingly engaging",
            "Easy to follow",
            "Solid production",
            "Worth revisiting"
    };

    private static final String[] REVIEW_CLOSERS = {
            "for seeded test coverage.",
            "for repeatable QA runs.",
            "for integration verification.",
            "for regression scenarios.",
            "for local data setup."
    };

    public static void main(String[] args) throws Exception {
        Config config = Config.fromArgs(args);
        Report report = new DatabaseTestDataGenerator().generate(config);
        System.out.println(report.toConsoleOutput());
    }

    public Report generate(Config config) throws SQLException {
        Objects.requireNonNull(config, "config must not be null");
        validateCounts(config);

        try (Connection connection = openConnection(config)) {
            connection.setAutoCommit(false);
            try {
                ensureUserExists(connection, config.userId());

                List<Integer> allVideoIds = loadVideoIds(connection);
                List<Integer> insertedVideoIds = insertVideos(connection, config.videos(), config.seed(), allVideoIds);
                int insertedRatings = insertRatings(connection, config.ratings(), config.seed(), config.userId(), allVideoIds);
                int insertedWatchlist = insertUserVideoLinks(connection, "watchlist", "added_at", config.watchlist(), config.seed(), config.userId(), allVideoIds);
                int insertedHistory = insertHistory(connection, config.history(), config.seed(), config.userId(), allVideoIds);

                List<String> verificationFailures = verify(connection);
                connection.commit();

                return new Report(
                        insertedVideoIds.size(),
                        insertedRatings,
                        insertedWatchlist,
                        insertedHistory,
                        verificationFailures);
            } catch (SQLException | RuntimeException ex) {
                connection.rollback();
                throw ex;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    private Connection openConnection(Config config) throws SQLException {
        return DriverManager.getConnection(config.jdbcUrl(), config.dbUser(), config.dbPassword());
    }

    private void validateCounts(Config config) {
        if (config.videos() < 0 || config.ratings() < 0 || config.watchlist() < 0 || config.history() < 0) {
            throw new IllegalArgumentException("Counts must be zero or greater.");
        }
    }

    private void ensureUserExists(Connection connection, int userId) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement("SELECT COUNT(*) FROM users WHERE id = ?")) {
            statement.setInt(1, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                resultSet.next();
                if (resultSet.getInt(1) != 1) {
                    throw new IllegalArgumentException("User not found: " + userId);
                }
            }
        }
    }

    private List<Integer> loadVideoIds(Connection connection) throws SQLException {
        List<Integer> videoIds = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement("SELECT id FROM videos ORDER BY id");
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                videoIds.add(resultSet.getInt(1));
            }
        }
        return videoIds;
    }

    private List<Integer> insertVideos(Connection connection, int count, long seed, List<Integer> allVideoIds) throws SQLException {
        List<Integer> insertedIds = new ArrayList<>();
        if (count == 0) {
            return insertedIds;
        }

        Random random = new Random(seed ^ 0x5DEECE66DL);
        String sql = "INSERT INTO videos(title, genre, poster_url, url_video_360P, url_video_480P, duration, director, published_by, published_at, created_at) "
                + "VALUES(?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";

        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            for (int index = 0; index < count; index++) {
                int sequence = allVideoIds.size() + index + 1;
                String slug = String.format(Locale.ROOT, "%08x", random.nextInt());
                statement.setString(1, "Synthetic Video " + sequence + " " + slug);
                statement.setString(2, GENRES[random.nextInt(GENRES.length)]);
                statement.setString(3, "https://example.test/posters/video-" + sequence + ".jpg");
                statement.setString(4, "https://example.test/videos/video-" + sequence + "-360p.mp4");
                statement.setString(5, "https://example.test/videos/video-" + sequence + "-480p.mp4");
                statement.setTime(6, buildDuration(random));
                statement.setString(7, DIRECTORS[random.nextInt(DIRECTORS.length)]);
                statement.setString(8, PUBLISHERS[random.nextInt(PUBLISHERS.length)]);
                statement.executeUpdate();

                try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int videoId = generatedKeys.getInt(1);
                        insertedIds.add(videoId);
                        allVideoIds.add(videoId);
                    }
                }
            }
        }
        return insertedIds;
    }

    private int insertRatings(Connection connection, int count, long seed, int userId, List<Integer> videoIds) throws SQLException {
        if (count == 0) {
            return 0;
        }
        if (videoIds.isEmpty()) {
            throw new IllegalArgumentException("At least one video must exist before generating ratings.");
        }

        Random random = new Random(seed ^ 0x13579BDFL);
        String sql = "INSERT INTO rating_reviews(rating, comment, user_id, video_id, created_at, updated_at) VALUES(?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            for (int index = 0; index < count; index++) {
                int rating = 1 + random.nextInt(5);
                int videoId = videoIds.get(random.nextInt(videoIds.size()));
                statement.setInt(1, rating);
                statement.setString(2, buildComment(random, rating, index));
                statement.setInt(3, userId);
                statement.setInt(4, videoId);
                statement.addBatch();
            }
            return statement.executeBatch().length;
        }
    }

    private int insertUserVideoLinks(Connection connection, String tableName, String timestampColumn, int count, long seed, int userId, List<Integer> videoIds) throws SQLException {
        if (count == 0) {
            return 0;
        }

        List<Integer> availableVideoIds = selectAvailableVideoIds(connection, tableName, userId, videoIds, count, seed);
        String sql = "INSERT INTO " + tableName + "(user_id, video_id, " + timestampColumn + ") VALUES(?, ?, CURRENT_TIMESTAMP)";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            for (int videoId : availableVideoIds) {
                statement.setInt(1, userId);
                statement.setInt(2, videoId);
                statement.addBatch();
            }
            return statement.executeBatch().length;
        }
    }

    private int insertHistory(Connection connection, int count, long seed, int userId, List<Integer> videoIds) throws SQLException {
        if (count == 0) {
            return 0;
        }

        List<Integer> availableVideoIds = selectAvailableVideoIds(connection, "history", userId, videoIds, count, seed ^ 0x2468ACE0L);
        Random random = new Random(seed ^ 0x7F4A7C15L);
        String sql = "INSERT INTO history(user_id, video_id, progress_seconds, last_watched_at) VALUES(?, ?, ?, CURRENT_TIMESTAMP)";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            for (int videoId : availableVideoIds) {
                statement.setInt(1, userId);
                statement.setInt(2, videoId);
                statement.setInt(3, 30 + random.nextInt(3300));
                statement.addBatch();
            }
            return statement.executeBatch().length;
        }
    }

    private List<Integer> selectAvailableVideoIds(Connection connection, String tableName, int userId, List<Integer> videoIds, int count, long seed) throws SQLException {
        if (videoIds.isEmpty()) {
            throw new IllegalArgumentException("At least one video must exist before generating " + tableName + " rows.");
        }

        Set<Integer> usedVideoIds = new HashSet<>();
        String sql = "SELECT video_id FROM " + tableName + " WHERE user_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    usedVideoIds.add(resultSet.getInt(1));
                }
            }
        }

        List<Integer> candidates = new ArrayList<>();
        for (int videoId : videoIds) {
            if (!usedVideoIds.contains(videoId)) {
                candidates.add(videoId);
            }
        }
        shuffle(candidates, seed);

        if (candidates.size() < count) {
            throw new IllegalArgumentException("Not enough unused videos to generate " + count + " " + tableName + " rows for user " + userId + ". Available slots: " + candidates.size());
        }
        return new ArrayList<>(candidates.subList(0, count));
    }

    private List<String> verify(Connection connection) throws SQLException {
        List<String> checks = new ArrayList<>();
        checks.add("watchlist.user_id orphan count = " + orphanCount(connection, "watchlist", "user_id", "users"));
        checks.add("watchlist.video_id orphan count = " + orphanCount(connection, "watchlist", "video_id", "videos"));
        checks.add("history.user_id orphan count = " + orphanCount(connection, "history", "user_id", "users"));
        checks.add("history.video_id orphan count = " + orphanCount(connection, "history", "video_id", "videos"));
        checks.add("rating_reviews.user_id orphan count = " + orphanCount(connection, "rating_reviews", "user_id", "users"));
        checks.add("rating_reviews.video_id orphan count = " + orphanCount(connection, "rating_reviews", "video_id", "videos"));
        return checks;
    }

    private int orphanCount(Connection connection, String childTable, String foreignKeyColumn, String parentTable) throws SQLException {
        String sql = "SELECT COUNT(*) FROM " + childTable + " child LEFT JOIN " + parentTable + " parent ON parent.id = child." + foreignKeyColumn + " WHERE parent.id IS NULL";
        try (PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            resultSet.next();
            return resultSet.getInt(1);
        }
    }

    private String buildComment(Random random, int rating, int index) {
        return REVIEW_OPENERS[random.nextInt(REVIEW_OPENERS.length)]
                + " rating=" + rating
                + " sample=" + (index + 1)
                + " " + REVIEW_CLOSERS[random.nextInt(REVIEW_CLOSERS.length)];
    }

    private Time buildDuration(Random random) {
        int minutes = 10 + random.nextInt(140);
        int seconds = random.nextInt(60);
        return Time.valueOf(LocalTime.of(minutes / 60, minutes % 60, seconds));
    }

    private void shuffle(List<Integer> values, long seed) {
        Random random = new Random(seed);
        for (int index = values.size() - 1; index > 0; index--) {
            int swapIndex = random.nextInt(index + 1);
            Integer current = values.get(index);
            values.set(index, values.get(swapIndex));
            values.set(swapIndex, current);
        }
    }

    public record Config(
            String jdbcUrl,
            String dbUser,
            String dbPassword,
            int videos,
            int ratings,
            int watchlist,
            int history,
            long seed,
            int userId) {

        public static Config fromArgs(String[] args) {
            String jdbcUrl = envOrDefault("WEB_RATING_DB_URL", DEFAULT_JDBC_URL);
            String dbUser = envOrDefault("WEB_RATING_DB_USER", DEFAULT_DB_USER);
            String dbPassword = envOrDefault("WEB_RATING_DB_PASSWORD", DEFAULT_DB_PASSWORD);
            int videos = 0;
            int ratings = 0;
            int watchlist = 0;
            int history = 0;
            long seed = 42L;
            int userId = 2;

            for (int index = 0; index < args.length; index++) {
                String arg = args[index];
                if ("--help".equals(arg)) {
                    throw new IllegalArgumentException(usage());
                }
                String value = requireValue(args, index);
                switch (arg) {
                    case "--jdbcUrl" -> jdbcUrl = value;
                    case "--dbUser" -> dbUser = value;
                    case "--dbPassword" -> dbPassword = value;
                    case "--videos" -> videos = parseInt(arg, value);
                    case "--ratings" -> ratings = parseInt(arg, value);
                    case "--watchlist" -> watchlist = parseInt(arg, value);
                    case "--history" -> history = parseInt(arg, value);
                    case "--seed" -> seed = parseLong(arg, value);
                    case "--userId" -> userId = parseInt(arg, value);
                    default -> throw new IllegalArgumentException("Unknown argument: " + arg + System.lineSeparator() + usage());
                }
                index++;
            }

            return new Config(jdbcUrl, dbUser, dbPassword, videos, ratings, watchlist, history, seed, userId);
        }

        private static String requireValue(String[] args, int index) {
            if (index + 1 >= args.length) {
                throw new IllegalArgumentException("Missing value for " + args[index] + System.lineSeparator() + usage());
            }
            return args[index + 1];
        }

        private static int parseInt(String name, String value) {
            try {
                return Integer.parseInt(value);
            } catch (NumberFormatException ex) {
                throw new IllegalArgumentException("Invalid integer for " + name + ": " + value, ex);
            }
        }

        private static long parseLong(String name, String value) {
            try {
                return Long.parseLong(value);
            } catch (NumberFormatException ex) {
                throw new IllegalArgumentException("Invalid long for " + name + ": " + value, ex);
            }
        }

        private static String envOrDefault(String key, String defaultValue) {
            String value = System.getenv(key);
            return value == null || value.isBlank() ? defaultValue : value;
        }

        public static String usage() {
            return "Usage: --videos <count> --ratings <count> --watchlist <count> --history <count> [--seed <long>] [--userId <id>] [--jdbcUrl <url>] [--dbUser <user>] [--dbPassword <password>]";
        }
    }

    public record Report(
            int insertedVideos,
            int insertedRatings,
            int insertedWatchlist,
            int insertedHistory,
            List<String> verificationFailures) {

        public String toConsoleOutput() {
            StringBuilder builder = new StringBuilder();
            builder.append("Generated database test data").append(System.lineSeparator());
            builder.append("videos=").append(insertedVideos).append(System.lineSeparator());
            builder.append("ratings=").append(insertedRatings).append(System.lineSeparator());
            builder.append("watchlist=").append(insertedWatchlist).append(System.lineSeparator());
            builder.append("history=").append(insertedHistory).append(System.lineSeparator());
            builder.append("verification:").append(System.lineSeparator());
            for (String line : verificationFailures) {
                builder.append(" - ").append(line).append(System.lineSeparator());
            }
            return builder.toString().trim();
        }
    }
}
