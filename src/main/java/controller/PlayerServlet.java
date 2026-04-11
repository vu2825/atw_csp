package controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;

import bussines.Movie;
import bussines.User_login;
import dao.RatingDao;

@WebServlet("/watch")
public class PlayerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Auth
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        User_login user = (User_login) session.getAttribute("user");
        System.out.println("✓ User watching movie: " + user.getUsername());

        try {
            int videoId = Integer.parseInt(req.getParameter("id"));
            String quality = req.getParameter("quality");

            if (quality == null || quality.isEmpty()) {
                quality = "360";
            }

            if (!user.isPremium() && "480".equals(quality)) {
                quality = "360";
                req.setAttribute("qualityMessage", "🔒 Cần nâng cấp tài khoản Premium để xem chất lượng 480P");
            }

            Movie movie = findMovieById(videoId, quality);
            if (movie == null) {
                resp.sendError(404, "Movie not found");
                return;
            }

            try {
                saveToHistory((int) user.getId(), videoId);
            } catch (SQLException e) {
                System.err.println("⚠️ Lỗi khi lưu history: " + e.getMessage());
            }

            req.setAttribute("selectedQuality", quality);
            req.setAttribute("movie", movie);
            req.setAttribute("user", user);

            try {
                RatingDao rdao = new RatingDao();
                req.setAttribute("rating", rdao.summary(String.valueOf(videoId)));
                req.setAttribute("comments", rdao.listByVideoId(videoId));
            } catch (Exception e) {
                e.printStackTrace();
            }

            RequestDispatcher rd = req.getRequestDispatcher("/watch.jsp");
            rd.forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendError(400, "Invalid movie ID");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendError(404, "Not supported");
    }

    private Connection getConn() throws SQLException {
        return DriverManager.getConnection(
                "jdbc:mysql://mysql:3306/thanh_toan?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&allowPublicKeyRetrieval=true&useSSL=false",
                "user1", "user1123@"
        );
    }

    private void saveToHistory(int userId, int videoId) throws SQLException {
        final String sql =
                "INSERT INTO thanh_toan.history (user_id, video_id, last_watched_at) " +
                "VALUES (?, ?, NOW()) " +
                "ON DUPLICATE KEY UPDATE last_watched_at = NOW()";
        try (Connection cn = getConn();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, videoId);
            ps.executeUpdate();
        }
    }

    private Movie findMovieById(int videoId, String quality) {
        Movie movie = null;
        String sql = "480".equals(quality)
                ? "SELECT id, title, url_video_480P AS src FROM videos WHERE id = ?"
                : "SELECT id, title, url_video_360P AS src FROM videos WHERE id = ?";

        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, videoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    movie = new Movie();
                    movie.setId(rs.getInt("id"));
                    movie.setTitle(rs.getString("title"));

                    String driveUrl = rs.getString("src");
                    movie.setSrc(convertToEmbedUrl(driveUrl));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return movie;
    }

    private String convertToEmbedUrl(String driveUrl) {
        if (driveUrl == null) return null;
        if (driveUrl.contains("drive.google.com") && driveUrl.contains("/file/d/")) {
            String fileId = extractFileId(driveUrl);
            if (fileId != null) {
                return "https://drive.google.com/file/d/" + fileId + "/preview";
            }
        }
        return driveUrl;
    }

    private String extractFileId(String driveUrl) {
        try {
            int start = driveUrl.indexOf("/file/d/") + 8;
            int end = driveUrl.indexOf("/", start);
            if (end == -1) end = driveUrl.indexOf("?", start);
            if (end == -1) end = driveUrl.length();
            return driveUrl.substring(start, end);
        } catch (Exception e) {
            return null;
        }
    }
}
