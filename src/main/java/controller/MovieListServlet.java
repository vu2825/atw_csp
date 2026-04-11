package controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import bussines.Movie;
import bussines.User_login;

@WebServlet("/movies")
public class MovieListServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("=== ACCESSING MOVIES LIST ===");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            System.out.println("✗ No session - Redirecting to login");
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        User_login user = (User_login) session.getAttribute("user");
        System.out.println("✓ User authenticated: " + user.getUsername());

        try {

            testDatabaseConnection();
            
            List<Movie> movies = getAllMovies();
            System.out.println("✓ Found " + movies.size() + " movies");
            
            req.setAttribute("movies", movies);
            req.getRequestDispatcher("/movie-list.jsp").forward(req, resp);
            
        } catch (SQLException e) {
            System.err.println("✗ DATABASE ERROR: " + e.getMessage());
            e.printStackTrace();
            String debugInfo = "Database Error! Details: " + e.getMessage() + 
                               "\nURL: jdbc:mysql://mysql:3306/thanh_toan" + 
                               "\nUser: user1" + 
                               "\nPassword: user1123@" + 
                               "\nStack Trace: " + java.util.Arrays.toString(e.getStackTrace());
            req.setAttribute("error", debugInfo);
            req.getRequestDispatcher("/movie-list.jsp").forward(req, resp);
        } catch (Exception e) {
            System.err.println("✗ UNEXPECTED ERROR: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("error", "System Error: " + e.toString() + "\nDetails: " + java.util.Arrays.toString(e.getStackTrace()));
            req.getRequestDispatcher("/movie-list.jsp").forward(req, resp);
        }
    }

    private void testDatabaseConnection() throws SQLException {
        System.out.println("Testing database connection...");
        String url = "jdbc:mysql://mysql:3306/thanh_toan?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&allowPublicKeyRetrieval=true&useSSL=false";
        String user = "user1";
        
        try (Connection conn = DriverManager.getConnection(url, user, "user1123@")) {
            System.out.println("✓ Database connection SUCCESS");

            DatabaseMetaData meta = conn.getMetaData();
            ResultSet tables = meta.getTables(null, null, "videos", new String[]{"TABLE"});
            if (tables.next()) {
                System.out.println("✓ Videos table exists");
            } else {
                System.out.println("✗ Videos table NOT FOUND");
            }
            
        } catch (SQLException e) {
            System.err.println("✗ Database connection FAILED: " + e.getMessage());
            throw e;
        }
    }

    private List<Movie> getAllMovies() throws SQLException {
        List<Movie> movies = new ArrayList<>();
        System.out.println("Fetching all movies from database...");

        String sql = "SELECT id, title, genre, published_by, duration, created_at, poster_url FROM videos ORDER BY created_at DESC";
        
        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://mysql:3306/thanh_toan?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&allowPublicKeyRetrieval=true&useSSL=false",
                "user1", "user1123@");
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Movie movie = new Movie();
                movie.setId(rs.getInt("id"));
                movie.setTitle(rs.getString("title"));
                movie.setGenre(rs.getString("genre"));

                String posterUrl = rs.getString("poster_url");
                movie.setPoster(posterUrl);
                
                movies.add(movie);
                System.out.println("✓ Added movie: " + movie.getTitle() + 
                    " (ID: " + movie.getId() + 
                    ", genre: " + movie.getGenre() + 
                    ", Poster: " + (posterUrl != null ? "Yes" : "No") + ")");
            }
        }
        return movies;
    }
}
