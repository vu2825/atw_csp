package dao;

import bussines.User_login;
import data.Db_login;

import java.sql.*;

public class UserDao_login {

    public User_login findByUsernameOrEmail(String loginId) throws Exception {
        // ✅ Dùng PreparedStatement với placeholder
        String sql = "SELECT id, fullname, email, username, password, avatar, wallet, isAdmin, isPremium " +
                "FROM users WHERE username=? OR email=? LIMIT 1";
        try (Connection c = Db_login.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, loginId);
            ps.setString(2, loginId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next())
                    return null;
                User_login u = new User_login();
                u.setId(rs.getLong("id"));
                u.setFullname(rs.getString("fullname"));
                u.setEmail(rs.getString("email"));
                u.setUsername(rs.getString("username"));
                u.setPassword(rs.getString("password"));
                u.setAvatar(rs.getString("avatar"));
                u.setWallet(rs.getDouble("wallet"));
                u.setAdmin(rs.getBoolean("isAdmin"));
                u.setPremium(rs.getBoolean("isPremium"));
                return u;
            }
        }
    }

    public boolean existsEmail(String email) throws Exception {
        String sql = "SELECT 1 FROM users WHERE email=? LIMIT 1";
        try (Connection c = Db_login.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean existsUsername(String username) throws Exception {
        String sql = "SELECT 1 FROM users WHERE username=? LIMIT 1";
        try (Connection c = Db_login.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public long create(User_login u) throws Exception {
        String sql = "INSERT INTO users (fullname, email, username, password, avatar, wallet, isAdmin, isPremium) " +
                "VALUES (?,?,?,?,?,?,?,?)";
        try (Connection c = Db_login.getConnection();
                PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, u.getFullname());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getUsername());
            ps.setString(4, u.getPassword());
            ps.setString(5, u.getAvatar());
            ps.setDouble(6, u.getWallet());
            ps.setBoolean(7, u.isAdmin());
            ps.setBoolean(8, u.isPremium());
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                return keys.next() ? keys.getLong(1) : 0L;
            }
        }
    }

    public int updatePasswordByUsername(String username, String newPassword) throws Exception {
        String sql = "UPDATE users SET password=? WHERE username=?";
        try (Connection c = Db_login.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, newPassword);
            ps.setString(2, username);
            return ps.executeUpdate();
        }
    }
}
