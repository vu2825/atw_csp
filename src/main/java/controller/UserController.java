package controller;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import bussines.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/admin/user-controller")
public class UserController extends HttpServlet {

    // ---- Kết nối DB ----
    private Connection getConnection() throws SQLException, ClassNotFoundException {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(
                "jdbc:mysql://websql12.mysql.database.azure.com:3306/thanh_toan?sslMode=REQUIRED&useUnicode=true&characterEncoding=UTF-8",
                "user1",
                "user1123@"
        );
    }

    // ---- GET: list / delete + filter/sort/search ----
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // action=delete?id=...
        String action = request.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            deleteUser(request, response);
            return;
        }

        // Filter / Sort / Search
        String role = request.getParameter("role");   // "", "premium", "admin"
        String sort = request.getParameter("sort");   // "", "wallet_asc", "wallet_desc"
        String q    = request.getParameter("q");      // keyword username/email

        // Giữ lại để render lại form
        request.setAttribute("role", role);
        request.setAttribute("sort", sort);
        request.setAttribute("q", q);

        listUsers(request, response, role, sort, q);
    }

    // ---- Liệt kê người dùng (có filter/sort/search) ----
    private void listUsers(HttpServletRequest request, HttpServletResponse response,
                           String role, String sort, String q)
            throws ServletException, IOException {

        List<User> users = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT id, username, email, wallet, isAdmin, isPremium FROM users WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();

        // Filter theo role
        if (role != null) {
            if ("premium".equalsIgnoreCase(role)) {
                sql.append(" AND isPremium = ?");
                params.add(true);
            } else if ("admin".equalsIgnoreCase(role)) {
                sql.append(" AND isAdmin = ?");
                params.add(true);
            }
        }

        // Search theo username/email (không phân biệt hoa thường)
        if (q != null && !q.trim().isEmpty()) {
            String like = "%" + q.trim().toLowerCase() + "%";
            sql.append(" AND (LOWER(username) LIKE ? OR LOWER(email) LIKE ?)");
            params.add(like);
            params.add(like);
        }

        // Sort
        if ("wallet_asc".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY wallet ASC, id DESC");
        } else if ("wallet_desc".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY wallet DESC, id DESC");
        } else {
            sql.append(" ORDER BY id DESC");
        }

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            // Bind params an toàn
            for (int i = 0; i < params.size(); i++) {
                Object v = params.get(i);
                if (v instanceof String) ps.setString(i + 1, (String) v);
                else if (v instanceof Boolean) ps.setBoolean(i + 1, (Boolean) v);
                else if (v instanceof Integer) ps.setInt(i + 1, (Integer) v);
                else if (v instanceof Double) ps.setDouble(i + 1, (Double) v);
                else ps.setObject(i + 1, v);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setUsername(rs.getString("username"));
                    u.setEmail(rs.getString("email"));
                    u.setWallet(rs.getDouble("wallet"));
                    u.setIsAdmin(rs.getBoolean("isAdmin"));
                    u.setIsPremium(rs.getBoolean("isPremium"));
                    users.add(u);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("userList", users);
        request.getRequestDispatcher("/admin/user-list.jsp").forward(request, response);
    }

    // ---- Xoá người dùng ----
    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/user-controller");
            return;
        }

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE id = ?")) {
            ps.setInt(1, Integer.parseInt(idStr));
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/admin/user-controller");
    }

    // ---- POST: không dùng để thêm/sửa ở phiên bản này ----
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Chỉ redirect về list
        response.sendRedirect(request.getContextPath() + "/admin/user-controller");
    }
}
