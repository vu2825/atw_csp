package data;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import bussines.User;

import javax.sql.DataSource;

public class UserDB {
	private DataSource dataSource;
	public UserDB(DataSource ds) {
        if (ds == null) {
            throw new IllegalArgumentException("DataSource cannot be null");
        }
        this.dataSource = ds;
    }
	
	// Setter tùy chọn nếu cần thay đổi
    public void setDataSource(DataSource ds) {
        this.dataSource = ds;
    }

	public List<User> getAllUser() {
		List<User> users = new ArrayList<>();
		try (Connection conn = dataSource.getConnection();
				PreparedStatement ps = conn.prepareStatement("SELECT * FROM users");
				ResultSet rs = ps.executeQuery();) {
			while (rs.next()) {
				User user = new User();
				user.setId(rs.getInt("id"));
				user.setUsername(rs.getString("username"));
				user.setEmail(rs.getString("email"));
				user.setWallet(rs.getInt("wallet"));
				user.setIsAdmin(rs.getBoolean("is_admin"));
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return users;
	}

	public User getUserById(int id) {
		User user = null; // Hoặc Optional<User> để best practice
		try (Connection conn = dataSource.getConnection();
				PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE id = ?")) {
			ps.setInt(1, id);
			try (ResultSet rs = ps.executeQuery()) { 
				if (rs.next()) {
					user = new User();
					user.setId(rs.getInt("id"));
					user.setUsername(rs.getString("username"));
					user.setEmail(rs.getString("email"));
					user.setWallet(rs.getInt("wallet"));
					user.setIsAdmin(rs.getBoolean("is_admin"));
				}
			}
		} catch (SQLException e) {
			e.printStackTrace(); 
		}
		return user; // Trả về User hoặc null nếu không tìm thấy
	}
	
	public void updateWallet(double newWallet, int userId ) {
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE users SET wallet = ? WHERE id = ?")) {
            ps.setDouble(1, newWallet);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
