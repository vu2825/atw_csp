package controller;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import bussines.User;
import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/user-controller")
public class UserController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Resource(name = "jdbc/loginDB")
    private DataSource dataSource;

    @Override
    public void init() {
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

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            boolean ok = deleteUser(request);
            if (!response.isCommitted()) {
                response.sendRedirect(request.getContextPath() + "/admin/user-controller");
            }
            return;
        }

        // Filter / Sort / Search
        String role = nz(request.getParameter("role"));
        String sort = nz(request.getParameter("sort"));
        String q    = nz(request.getParameter("q"));

        request.setAttribute("role", role);
        request.setAttribute("sort", sort);
        request.setAttribute("q", q);

        listUsers(request, response, role, sort, q);
    }

    private void listUsers(HttpServletRequest request, HttpServletResponse response,
                           String role, String sort, String q)
            throws ServletException, IOException {

        List<User> users = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        StringBuilder base = new StringBuilder(
            " FROM users WHERE 1=1"
        );
        base.append(" AND isAdmin = 0");

        // Filter role
        if ("premium".equalsIgnoreCase(role)) {
            base.append(" AND isPremium = ?");
            params.add(true);
        }

        if (!q.isBlank()) {
            String like = "%" + q.trim().toLowerCase() + "%";
            base.append(" AND (LOWER(username) LIKE ? OR LOWER(email) LIKE ?)");
            params.add(like);
            params.add(like);
        }

        String orderBy = " ORDER BY id DESC";
        if ("wallet_asc".equalsIgnoreCase(sort)) {
            orderBy = " ORDER BY wallet ASC, id DESC";
        } else if ("wallet_desc".equalsIgnoreCase(sort)) {
            orderBy = " ORDER BY wallet DESC, id DESC";
        }

        String dataSql = "SELECT id, username, email, wallet, isAdmin, isPremium"
                       + base.toString()
                       + orderBy;

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(dataSql)) {

            bindParams(ps, params);

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
            request.setAttribute("error", "Không thể tải danh sách người dùng: " + e.getMessage());
        }

        request.setAttribute("userList", users);
        request.getRequestDispatcher("/admin/user-list.jsp").forward(request, response);
    }

    private boolean deleteUser(HttpServletRequest request) {
        // ❌ IDOR: No authorization check, any user can delete any other user
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isBlank()) return false;

        int id = Integer.parseInt(idStr);
        final String hardDeleteSql = "DELETE FROM users WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(hardDeleteSql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!response.isCommitted()) {
            response.sendRedirect(request.getContextPath() + "/admin/user-controller");
        }
    }

    // Helpers
    private static String nz(String s) { return s == null ? "" : s; }

    private static int bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        int idx = 1;
        for (Object v : params) {
            if (v instanceof String)       ps.setString(idx++, (String) v);
            else if (v instanceof Boolean) ps.setBoolean(idx++, (Boolean) v);
            else if (v instanceof Integer) ps.setInt(idx++, (Integer) v);
            else if (v instanceof Long)    ps.setLong(idx++, (Long) v);
            else if (v instanceof Double)  ps.setDouble(idx++, (Double) v);
            else                           ps.setObject(idx++, v);
        }
        return idx;
    }
}
