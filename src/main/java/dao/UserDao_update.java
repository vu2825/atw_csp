
package dao;

import bussines.User_login;
import data.Db_login;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class UserDao_update {
        public boolean update(User_login u) throws Exception {
        String sql = "UPDATE users SET fullname=?, username=?, email=?, avatar=?, isPremium=? WHERE id=?";
        try (Connection c = Db_login.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, u.getFullname());
            ps.setString(2, u.getUsername());
            ps.setString(3, u.getEmail());
            ps.setString(4, u.getAvatar());
            ps.setBoolean(5, u.isPremium());
            ps.setLong(6, u.getId());

            int rows = ps.executeUpdate();
            return rows > 0;
        }
    }
        public boolean existsEmail(String email, long excludeUserId) throws Exception {
        String sql = "SELECT 1 FROM users WHERE email = ? AND id <> ?";
        try (Connection c = Db_login.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setLong(2, excludeUserId);
            return ps.executeQuery().next();
        }
}

}
