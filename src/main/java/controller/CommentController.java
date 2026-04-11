package controller;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import bussines.Comment;
import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/comment-controller")
public class CommentController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Resource(name = "jdbc/loginDB")
    private DataSource dataSource;

    @Override
    public void init() {
        // Fallback 
        if (dataSource == null) {
            try {
                InitialContext ic = new InitialContext();
                dataSource = (DataSource) ic.lookup("java:/comp/env/jdbc/loginDB");
            } catch (NamingException e) {
                throw new RuntimeException("Không tìm thấy DataSource jdbc/loginDB", e);
            }
        }
    }

    private Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            deleteComment(request);

            // redirect
            if (!response.isCommitted()) {
                response.sendRedirect(request.getContextPath() + "/admin/comment-controller");
            }
            return;
        }

        String sort = request.getParameter("sort");
        request.setAttribute("sort", sort);

        listComments(request, response, sort);
    }

    private boolean deleteComment(HttpServletRequest request) {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) return false;

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "DELETE FROM thanh_toan.rating_reviews WHERE id = ?")) {
            ps.setInt(1, Integer.parseInt(idStr));
            int rows = ps.executeUpdate();
            System.out.println("Deleted rows = " + rows);
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private void listComments(HttpServletRequest request, HttpServletResponse response, String sort)
            throws ServletException, IOException {

        List<Comment> comments = new ArrayList<>();
        System.out.println("=== listComments() begin ===");

        StringBuilder sql = new StringBuilder(
            "SELECT id, user_id, video_id, comment, rating, created_at, updated_at " +
            "FROM thanh_toan.rating_reviews"
        );

        if ("rating_asc".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY rating ASC, created_at DESC");
        } else if ("rating_desc".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY rating DESC, created_at DESC");
        } else {
            sql.append(" ORDER BY created_at DESC");
        }

        System.out.println("Executing: " + sql);

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString());
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
        if (!response.isCommitted()) {
            response.sendRedirect(request.getContextPath() + "/admin/comment-controller");
        }
    }
}
