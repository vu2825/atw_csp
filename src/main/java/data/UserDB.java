package data;

import java.beans.Statement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import bussines.User;
import service.TopUpRequest;
import types.TopUpRequestTypes;

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
					user.setIsAdmin(rs.getBoolean("isAdmin"));
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return user; // Trả về User hoặc null nếu không tìm thấy
	}

	public void updateWallet(double newWallet, int userId) {
		try (Connection conn = dataSource.getConnection();
				PreparedStatement ps = conn.prepareStatement("UPDATE users SET wallet = ? WHERE id = ?")) {
			ps.setDouble(1, newWallet);
			ps.setInt(2, userId);
			ps.executeUpdate();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public void sendAddCredit(double amount, int userId) throws SQLException {
		try (Connection conn = dataSource.getConnection();
				PreparedStatement ps = conn
						.prepareStatement("INSERT INTO topup_requests (user_id, amount, status) VALUES (?,?,?)")) {

			ps.setInt(1, userId);
			ps.setDouble(2, amount); // dùng DECIMAL/BigDecimal cho tiền
			ps.setString(3, "pending"); // khớp enum/lược đồ

			ps.executeUpdate(); // INSERT dùng executeUpdate

		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public List<TopUpRequest> findPendingRequestOfUser(int userId) {
		List<TopUpRequest> list = new ArrayList<>();

		String sql = "SELECT id, user_id, amount, status, created_at "
				+ "FROM topup_request WHERE user_id = ? AND status = 'pending'";

		try (Connection conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setInt(1, userId);

			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					TopUpRequest r = new TopUpRequest();
					r.setId(rs.getInt("id"));
					r.setUser_id(rs.getInt("user_id"));
					r.setAmount(rs.getDouble("amount"));
					r.setStatus(TopUpRequestTypes.fromDb(rs.getString("status")));
					r.setCreated_at(Date.from(rs.getTimestamp("created_at").toInstant())); // or LocalDateTime
					list.add(r);
				}
			}
		} catch (SQLException e) {
			// log and/or rethrow as needed
			e.printStackTrace();
		}
		return list;
	}
	
	public List<TopUpRequest> findAcceptRequestOfUser(int userId) {
		List<TopUpRequest> list = new ArrayList<>();

		String sql = "SELECT id, user_id, amount, status, created_at "
				+ "FROM topup_request WHERE user_id = ? AND status = 'accept'";

		try (Connection conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setInt(1, userId);

			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					TopUpRequest r = new TopUpRequest();
					r.setId(rs.getInt("id"));
					r.setUser_id(rs.getInt("user_id"));
					r.setAmount(rs.getDouble("amount"));
					r.setStatus(TopUpRequestTypes.fromDb(rs.getString("status")));
					r.setCreated_at(Date.from(rs.getTimestamp("created_at").toInstant())); // or LocalDateTime
					list.add(r);
				}
			}
		} catch (SQLException e) {
			// log and/or rethrow as needed
			e.printStackTrace();
		}
		return list;
	}
	
	public List<TopUpRequest> findDiscardRequestOfUser(int userId) {
		List<TopUpRequest> list = new ArrayList<>();

		String sql = "SELECT id, user_id, amount, status, created_at "
				+ "FROM topup_request WHERE user_id = ? AND status = 'discard'";

		try (Connection conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setInt(1, userId);

			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					TopUpRequest r = new TopUpRequest();
					r.setId(rs.getInt("id"));
					r.setUser_id(rs.getInt("user_id"));
					r.setAmount(rs.getDouble("amount"));
					r.setStatus(TopUpRequestTypes.fromDb(rs.getString("status")));
					r.setCreated_at(Date.from(rs.getTimestamp("created_at").toInstant())); // or LocalDateTime
					list.add(r);
				}
			}
		} catch (SQLException e) {
			// log and/or rethrow as needed
			e.printStackTrace();
		}
		return list;
	}
	
	public List<TopUpRequest> findAllTopupsOfUser(int userId) {
	    List<TopUpRequest> list = new ArrayList<>();
	    String sql = "SELECT id, user_id, amount, status, created_at, updated_at " +
	                 "FROM topup_requests WHERE user_id = ? ORDER BY created_at DESC";

	    try (Connection conn = dataSource.getConnection();
	         PreparedStatement ps = conn.prepareStatement(sql)) {
	        
	        ps.setInt(1, userId);
	        try (ResultSet rs = ps.executeQuery()) {
	            while (rs.next()) {
	                TopUpRequest r = new TopUpRequest();
	                r.setId(rs.getInt("id"));
	                r.setUser_id(rs.getInt("user_id"));
	                r.setAmount(rs.getDouble("amount"));
	                r.setStatus(TopUpRequestTypes.fromDb(rs.getString("status")));
	                r.setCreated_at(Date.from(rs.getTimestamp("created_at").toInstant()));
	                r.setUpdated_at(Date.from(rs.getTimestamp("updated_at").toInstant()));
	                list.add(r);
	            }
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return list;
	}

}
