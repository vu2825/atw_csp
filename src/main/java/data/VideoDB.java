package data;

import bussines.Video;
import java.sql.*;
import java.util.*;

public class VideoDB {

    private static final String URL = "jdbc:mysql://mysql:3306/thanh_toan?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&allowPublicKeyRetrieval=true&useSSL=false";
    private static final String USER = "user1";
    private static final String PASS = "user1123@";

    private static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("❌ Không tìm thấy MySQL JDBC Driver. Hãy kiểm tra mysql-connector-j.jar.", e);
        }
        return DriverManager.getConnection(URL, USER, PASS);
    }

    public static void testConnection() {
        try (Connection con = getConnection()) {
            System.out.println("✅ Kết nối MySQL thành công!");
        } catch (SQLException e) {
            System.err.println("❌ Kết nối MySQL thất bại: " + e.getMessage());
        }
    }

    public static List<String> getSuggestions(String query) {
        List<String> suggestions = new ArrayList<>();
        if (query == null || query.trim().isEmpty()) return suggestions;

        String sql = "SELECT title FROM videos WHERE title LIKE ? LIMIT 10";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + query.trim() + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String title = rs.getString("title");
                    if (title != null && !title.isEmpty()) {
                        suggestions.add(title);
                    }
                }
            }
            System.out.println("🔍 Gợi ý cho '" + query + "': " + suggestions); 
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("❌ Lỗi trong getSuggestions: " + e.getMessage());
        }
        return suggestions;
    }

    public static List<Video> getAllVideos() {
        List<Video> list = new ArrayList<>();
        String sql = "SELECT id, title, genre, url_video_480P, published_by, published_at, poster_url FROM videos";
        try (Connection con = getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Video v = new Video();
                v.setId(rs.getInt("id"));
                v.setTitle(rs.getString("title"));
                v.setGenre(rs.getString("genre"));
                v.setUrlVideo480p(rs.getString("url_video_480P"));
                v.setPublishedBy(rs.getString("published_by"));
                v.setPublishedAt(rs.getString("published_at"));
                v.setPosterUrl(rs.getString("poster_url"));
                list.add(v);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static List<Video> getVideosByGenre(String genre) {
        List<Video> list = new ArrayList<>();
        if (genre == null || genre.trim().isEmpty()) return getAllVideos();

        String sql = "SELECT id, title, genre, url_video_480P, published_by, published_at, poster_url FROM videos WHERE genre LIKE ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + genre + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Video v = new Video();
                    v.setId(rs.getInt("id"));
                    v.setTitle(rs.getString("title"));
                    v.setGenre(rs.getString("genre"));
                    v.setUrlVideo480p(rs.getString("url_video_480P"));
                    v.setPublishedBy(rs.getString("published_by"));
                    v.setPublishedAt(rs.getString("published_at"));
                    v.setPosterUrl(rs.getString("poster_url"));
                    list.add(v);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public static List<String> getAllGenres() {
        Set<String> set = new TreeSet<>();
        String sql = "SELECT genre FROM videos";
        try (Connection con = getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                String g = rs.getString("genre");
                if (g != null && !g.isEmpty()) {
                    String[] arr = g.split(",");
                    for (String s : arr) {
                        if (!s.trim().isEmpty()) set.add(s.trim());
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return new ArrayList<>(set);
    }

    public static List<Video> searchVideos(String query) {
        List<Video> results = new ArrayList<>();
        if (query == null || query.trim().isEmpty()) return results;

        String sql = "SELECT id, title, genre, url_video_480P, published_by, published_at, poster_url FROM videos WHERE title LIKE ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + query.trim() + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Video v = new Video();
                    v.setId(rs.getInt("id"));
                    v.setTitle(rs.getString("title"));
                    v.setGenre(rs.getString("genre"));
                    v.setUrlVideo480p(rs.getString("url_video_480P"));
                    v.setPublishedBy(rs.getString("published_by"));
                    v.setPublishedAt(rs.getString("published_at"));
                    v.setPosterUrl(rs.getString("poster_url"));
                    results.add(v);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return results;
    }
}
