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

@WebServlet("/movie-detail")
public class MovieDetailServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Authentication check - sử dụng system của nhóm
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        User_login user = (User_login) session.getAttribute("user");
        System.out.println("✓ Accessing movie detail - User: " + user.getUsername());

        try {
            int movieId = Integer.parseInt(req.getParameter("id"));
            Movie movie = getMovieById(movieId);
            
            if (movie == null) {
                resp.sendError(404, "Movie not found");
                return;
            }
            
            req.setAttribute("movie", movie);
            req.getRequestDispatcher("/movie-detail.jsp").forward(req, resp);
            
        } catch (NumberFormatException e) {
            resp.sendError(400, "Invalid movie ID");
        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(500, "Database error");
        }
    }

    private Movie getMovieById(int movieId) throws SQLException {
        Movie movie = null;
        // Lấy thêm trường duration và poster_url từ database
        String sql = "SELECT id, title, director, duration, url_video_360P, url_video_480P, poster_url FROM videos WHERE id = ?";
        
        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://websql12.mysql.database.azure.com:3306/thanh_toan",
                "user1", "user1123@");
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    movie = new Movie();
                    movie.setId(rs.getInt("id"));
                    movie.setTitle(rs.getString("title"));
                    movie.setGenre(rs.getString("director")); // Dùng director làm genre
                    
                    // Lấy duration từ database
                    String duration = rs.getString("duration");
                    movie.setDuration(duration);
                
                    movie.setSrc(rs.getString("url_video_360P"));
                    
                    // LẤY POSTER_URL TỪ DATABASE
                    String posterUrl = rs.getString("poster_url");
                    movie.setPoster(posterUrl);
                }
            }
        }
        return movie;
    }
}