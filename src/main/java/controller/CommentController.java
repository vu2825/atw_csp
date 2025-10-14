package controller;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import bussines.Comment;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/admin/comment-controller")
public class CommentController extends HttpServlet {

    private Connection getConnection() throws SQLException, ClassNotFoundException {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://websql12.mysql.database.azure.com:3306/thanh_toan";
        String user = "user1";
        String password = "user1123@";
        return DriverManager.getConnection(url, user, password);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            deleteComment(request, response);
            return;
        }

        String sort = request.getParameter("sort"); // null | rating_asc | rating_desc
        request.setAttribute("sort", sort);

        listComments(request, response, sort);
    }

    private void deleteComment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect("comment-controller");
            return;
        }

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "DELETE FROM thanh_toan.rating_reviews WHERE id = ?")) {
            ps.setInt(1, Integer.parseInt(idStr));
            int rows = ps.executeUpdate();
            System.out.println("Deleted rows = " + rows);
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("comment-controller");
    }

    private void listComments(HttpServletRequest request, HttpServletResponse response, String sort)
            throws ServletException, IOException {

        List<Comment> comments = new ArrayList<>();
        System.out.println("=== listComments() begin ===");

        try (Connection conn = getConnection()) {

            StringBuilder sql = new StringBuilder(
                "SELECT id, user_id, video_id, comment, rating, created_at, updated_at " +
                "FROM thanh_toan.rating_reviews"
            );

            // Sort logic
            if ("rating_asc".equalsIgnoreCase(sort)) {
                sql.append(" ORDER BY rating ASC, created_at DESC");
            } else if ("rating_desc".equalsIgnoreCase(sort)) {
                sql.append(" ORDER BY rating DESC, created_at DESC");
            } else {
                sql.append(" ORDER BY created_at DESC");
            }

            System.out.println("Executing: " + sql);

            try (PreparedStatement ps = conn.prepareStatement(sql.toString());
                 ResultSet rs = ps.executeQuery()) {
                int count = 0;
                while (rs.next()) {
                    Comment c = new Comment();
                    c.setId(rs.getInt("id"));
                    c.setUserId(rs.getString("user_id"));
                    c.setVideoId(rs.getString("video_id"));
                    c.setComment(rs.getString("comment"));
                    c.setRating(rs.getInt("rating"));
                    c.setCreatedAt(rs.getTimestamp("created_at"));
                    c.setUpdatedAt(rs.getTimestamp("updated_at"));
                    comments.add(c);
                    count++;
                }
                System.out.println("Fetched rows = " + count);
            }

        } catch (Exception e) {
            System.out.println("ERROR in listComments: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "DB error: " + e.getMessage());
            return;
        }

        request.setAttribute("commentList", comments);
        request.getRequestDispatcher("comment-management.jsp").forward(request, response);
        System.out.println("=== listComments() end ===");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("comment-controller");
    }
}
