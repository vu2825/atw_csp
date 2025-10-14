package controller;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.util.ArrayList;
import java.util.List;

import bussines.Movie;

@WebServlet("/admin/movie-controller")
public class MovieController extends HttpServlet {

    // ✅ Khi người dùng truy cập GET
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        System.out.println("=== MOVIE CONTROLLER - ACTION: " + action + " ===");
        
        if ("manage".equals(action)) {
            // Hiển thị trang quản lý phim
            showMovieManagement(request, response);
        } else if ("delete".equals(action)) {
            // Xóa phim
            deleteMovie(request, response);
        } else {
            // Mặc định: hiển thị trang upload phim
            System.out.println("✓ Showing upload page (default)");
            RequestDispatcher dispatcher = request.getRequestDispatcher("/admin/upload-movie.jsp");
            dispatcher.forward(request, response);
        }
    }

    // ✅ Khi người dùng nhấn nút "Upload" (POST form)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // --- Nhận dữ liệu từ form ---
        String title = request.getParameter("movieTitle");
        String posterUrl = request.getParameter("posterUrl");
        String[] genres = request.getParameterValues("movieGenre");
        String resolution = request.getParameter("movieResolution");
        String videoUrl = request.getParameter("videoUrl");
        String publishedBy = request.getParameter("publishedBy");
        String duration = request.getParameter("durationMinutes");
        String director = request.getParameter("director");

        System.out.println("=== UPLOAD MOVIE ===");
        System.out.println("Title: " + title);
        System.out.println("Director: " + director);
        System.out.println("Resolution: " + resolution);

        // --- Gộp thể loại thành chuỗi ---
        String genreStr = (genres != null) ? String.join(", ", genres) : "";

        try {
            // --- Kết nối database ---
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://websql12.mysql.database.azure.com:3306/thanh_toan",
                    "user1", "user1123@"
            );

            // Nếu người dùng chỉ nhập HH:MM thì thêm giây vào
            if (duration != null && duration.length() == 5) {
                duration += ":00";
            }

            // --- Câu lệnh SQL không còn cột price ---
            String sql = ("360".equals(resolution))
                    ? "INSERT INTO videos (title, genre, poster_url, url_video_360P, duration, director, published_by, created_at) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)"
                    : "INSERT INTO videos (title, genre, poster_url, url_video_480P, duration, director, published_by, created_at) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, title);
            ps.setString(2, genreStr);
            ps.setString(3, posterUrl);
            ps.setString(4, videoUrl);
            ps.setTime(5, java.sql.Time.valueOf(duration));
            ps.setString(6, director);
            ps.setString(7, publishedBy);

            int rows = ps.executeUpdate();
            System.out.println("✓ Rows affected: " + rows);

            // --- Phản hồi ---
            if (rows > 0) {
                response.sendRedirect(request.getContextPath() + "/admin/movie-controller?action=manage&success=upload");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/upload-movie.jsp?error=true");
            }

            conn.close();

        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().println("<h3 style='color:red;'>SQL Error: " + e.getMessage() + "</h3>");
        } catch (ClassNotFoundException e) {
            response.getWriter().println("<h3 style='color:red;'>JDBC Driver not found!</h3>");
        } catch (Exception e) {
            response.getWriter().println("<h3 style='color:red;'>Error: " + e.getMessage() + "</h3>");
        }
    }

    // 🔧 PHƯƠNG THỨC: Hiển thị trang quản lý phim
    private void showMovieManagement(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== SHOWING MOVIE MANAGEMENT ===");
        
        try {
            List<Movie> movies = getAllMoviesWithFilter(request);
            request.setAttribute("movies", movies);
            
            // Thông báo thành công nếu có
            String success = request.getParameter("success");
            if ("upload".equals(success)) {
                request.setAttribute("successMessage", "✅ Phim đã được thêm thành công!");
            } else if ("delete".equals(success)) {
                request.setAttribute("successMessage", "✅ Phim đã được xóa thành công!");
            }
            
            System.out.println("✓ Forwarding to movie-management.jsp with " + movies.size() + " movies");
            RequestDispatcher dispatcher = request.getRequestDispatcher("/admin/movie-management.jsp");
            dispatcher.forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi database: " + e.getMessage());
            RequestDispatcher dispatcher = request.getRequestDispatcher("/admin/movie-management.jsp");
            dispatcher.forward(request, response);
        }
    }

    // 🔧 PHƯƠNG THỨC: Lấy danh sách phim với bộ lọc
    private List<Movie> getAllMoviesWithFilter(HttpServletRequest request) throws SQLException {
        List<Movie> movies = new ArrayList<>();
        
        String sort = request.getParameter("sort");
        String search = request.getParameter("q");
        
        System.out.println("=== GETTING MOVIES FROM DATABASE ===");
        System.out.println("Sort: " + sort);
        System.out.println("Search: " + search);
        
        // Build SQL query với debug
        StringBuilder sql = new StringBuilder(
            "SELECT id, title, director, duration, published_by, created_at FROM videos WHERE 1=1"
        );
        
        // Search filter
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (title LIKE ? OR director LIKE ?)");
            System.out.println("✓ Adding search filter: " + search);
        }
        
        // Sort order
        if ("oldest".equals(sort)) {
            sql.append(" ORDER BY created_at ASC");
            System.out.println("✓ Sort: oldest first");
        } else if ("title_asc".equals(sort)) {
            sql.append(" ORDER BY title ASC");
            System.out.println("✓ Sort: title A-Z");
        } else if ("title_desc".equals(sort)) {
            sql.append(" ORDER BY title DESC");
            System.out.println("✓ Sort: title Z-A");
        } else {
            sql.append(" ORDER BY created_at DESC"); // default: newest first
            System.out.println("✓ Sort: newest first (default)");
        }
        
        System.out.println("✓ Final SQL: " + sql.toString());
        
        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://websql12.mysql.database.azure.com:3306/thanh_toan",
                "user1", "user1123@");
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                String searchTerm = "%" + search.trim() + "%";
                ps.setString(paramIndex++, searchTerm);
                ps.setString(paramIndex++, searchTerm);
                System.out.println("✓ Search parameters: " + searchTerm);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                int count = 0;
                while (rs.next()) {
                    Movie movie = new Movie();
                    movie.setId(rs.getInt("id"));
                    movie.setTitle(rs.getString("title"));
                    movie.setGenre(rs.getString("director"));
                    movie.setDuration(rs.getString("duration"));
                    
                    movies.add(movie);
                    count++;
                    
                    System.out.println("✓ Movie " + count + ": ID=" + movie.getId() + 
                                     ", Title=" + movie.getTitle() + 
                                     ", Director=" + movie.getGenre());
                }
                
                System.out.println("✓ TOTAL MOVIES FOUND: " + count);
                
                if (count == 0) {
                    System.out.println("⚠️ WARNING: No movies found in database!");
                    // Test database connection
                    testDatabaseConnection(conn);
                }
            }
        } catch (SQLException e) {
            System.err.println("✗ DATABASE ERROR: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
        
        return movies;
    }

    // 🔧 PHƯƠNG THỨC: Test database connection
    private void testDatabaseConnection(Connection conn) throws SQLException {
        System.out.println("=== DATABASE CONNECTION TEST ===");
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as total FROM videos")) {
            
            if (rs.next()) {
                int total = rs.getInt("total");
                System.out.println("✓ Videos table exists, total rows: " + total);
            }
            
            // Check table structure
            try (ResultSet tables = conn.getMetaData().getTables(null, null, "videos", new String[]{"TABLE"})) {
                if (tables.next()) {
                    System.out.println("✓ Videos table found in database");
                } else {
                    System.out.println("✗ Videos table NOT FOUND in database!");
                }
            }
            
        } catch (SQLException e) {
            System.err.println("✗ Database test failed: " + e.getMessage());
        }
    }

    // 🔧 PHƯƠNG THỨC: Xóa phim
    private void deleteMovie(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        System.out.println("=== DELETING MOVIE ID: " + idStr + " ===");
        
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/movie-controller?action=manage");
            return;
        }

        try (Connection conn = DriverManager.getConnection(
                "jdbc:mysql://websql12.mysql.database.azure.com:3306/thanh_toan",
                "user1", "user1123@");
             PreparedStatement ps = conn.prepareStatement("DELETE FROM videos WHERE id = ?")) {

            ps.setInt(1, Integer.parseInt(idStr));
            int rows = ps.executeUpdate();

            System.out.println("✓ Delete operation - Rows affected: " + rows);

            if (rows > 0) {
                response.sendRedirect(request.getContextPath() + "/admin/movie-controller?action=manage&success=delete");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/movie-controller?action=manage&error=delete_failed");
            }

        } catch (Exception e) {
            System.err.println("✗ Delete error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/movie-controller?action=manage&error=delete_error");
        }
    }
}