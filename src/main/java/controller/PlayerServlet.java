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

@WebServlet("/watch")
public class PlayerServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Authentication check - sử dụng system của nhóm
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
            
            // Mặc định chất lượng 360P nếu không có tham số
            if (quality == null || quality.isEmpty()) {
                quality = "360";
            }

            // SỬA LỖI Ở ĐÂY: Dùng getIsPremium() thay vì isPremium()
            if (!user.isPremium() && "480".equals(quality)) {
                quality = "360"; // Mặc định về 360P nếu không phải premium
                req.setAttribute("qualityMessage", "🔒 Cần nâng cấp tài khoản Premium để xem chất lượng 480P");
            }

            Movie movie = findMovieById(videoId, quality);

            if (movie == null) { 
                resp.sendError(404, "Movie not found"); 
                return; 
            }

            // Thêm thông tin chất lượng vào request
            req.setAttribute("selectedQuality", quality);
            req.setAttribute("movie", movie);
            req.setAttribute("user", user);

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

    private Movie findMovieById(int videoId, String quality) {
        Movie movie = null;
        String sql = "";
        
        // Chọn cột dựa trên chất lượng
        if ("480".equals(quality)) {
            sql = "SELECT id, title, url_video_480P as src FROM videos WHERE id = ?";
        } else {
            sql = "SELECT id, title, url_video_360P as src FROM videos WHERE id = ?";
        }
        
        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://websql12.mysql.database.azure.com:3306/thanh_toan",
                "user1", "user1123@");
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, videoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    movie = new Movie();
                    movie.setId(rs.getInt("id"));
                    movie.setTitle(rs.getString("title"));
                    
                    // Convert Google Drive link to embed URL
                    String driveUrl = rs.getString("src");
                    String embedUrl = convertToEmbedUrl(driveUrl);
                    movie.setSrc(embedUrl);
                }
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return movie;
    }

    private String convertToEmbedUrl(String driveUrl) {
        if (driveUrl == null) return null;
        
        // Convert Google Drive share link to embed URL
        // Example: https://drive.google.com/file/d/FILE_ID/view?usp=sharing
        // To: https://drive.google.com/file/d/FILE_ID/preview
        
        if (driveUrl.contains("drive.google.com")) {
            if (driveUrl.contains("/file/d/")) {
                String fileId = extractFileId(driveUrl);
                if (fileId != null) {
                    return "https://drive.google.com/file/d/" + fileId + "/preview";
                }
            }
        }
        return driveUrl; // Return original if can't convert
    }

    private String extractFileId(String driveUrl) {
        try {
            // Extract file ID from Google Drive URL
            // Pattern: /file/d/FILE_ID/view
            int start = driveUrl.indexOf("/file/d/") + 8;
            int end = driveUrl.indexOf("/", start);
            if (end == -1) {
                end = driveUrl.indexOf("?", start);
            }
            if (end == -1) {
                end = driveUrl.length();
            }
            return driveUrl.substring(start, end);
        } catch (Exception e) {
            return null;
        }
    }
}