package controller;

import java.io.IOException;
import java.sql.*;
import javax.sql.DataSource;

import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import bussines.User_login;

@WebServlet(name="ReviewServlet", urlPatterns={"/review"})
public class ReviewServlet extends HttpServlet {

    @Resource(lookup = "java:comp/env/jdbc/loginDB") 
    private DataSource ds;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        User_login user = (session != null) ? (User_login) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String videoId = req.getParameter("videoId"); 
        String comment = req.getParameter("comment");
        String ratingStr = req.getParameter("rating");
        String redirect = req.getParameter("redirect"); 

        int rating = 0;
        try { rating = Integer.parseInt(ratingStr); } catch (Exception ignore) {}
        if (rating < 1) rating = 1;
        if (rating > 5) rating = 5;
        if (comment != null) comment = comment.trim();
        if (comment == null || comment.isEmpty() || videoId == null || videoId.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu dữ liệu.");
            return;
        }

        try (Connection cn = ds.getConnection()) {

            String sql =
                    "INSERT INTO thanh_toan.rating_reviews (rating, comment, user_id, video_id, created_at, updated_at) " +
                            "VALUES (?, ?, ?, ?, NOW(), NOW())";
            try (PreparedStatement ps = cn.prepareStatement(sql)) {
                ps.setInt(1, rating);
                ps.setString(2, comment);
                ps.setLong(3, user.getId());     
                ps.setString(4, videoId);       
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        if (redirect == null || redirect.isBlank()) {
            redirect = "watch?slug=" + videoId; 
        }
        resp.sendRedirect(req.getContextPath() + "/" + redirect);
    }
}
