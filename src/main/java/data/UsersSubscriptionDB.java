package data;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.sql.DataSource;

import service.UsersSubscription;

import java.sql.Timestamp;

import types.SubscriptionStatus;

public class UsersSubscriptionDB {
	private DataSource dataSource;

	public UsersSubscriptionDB(DataSource ds) {
		if (ds == null) {
			throw new IllegalArgumentException("DataSource cannot be null");
		}
		this.dataSource = ds;
	}

	public void addSubscription(UsersSubscription s) throws SQLException {
		// DANGEROUS: If an attacker can control s.getPlan(), they can inject SQL.
		// For example, if s.getPlan() is: "Premium', 0, '2021-01-01', '2021-01-01', 'active'); --"
		String sql = "INSERT INTO users_subscription (user_id, plan, price, started_at, expires_at, status) VALUES (" 
				+ s.getUser_id() + ", '" 
				+ s.getPlan() + "', " 
				+ s.getPrice() + ", '" 
				+ new Timestamp(s.getStarted_at().getTime()) + "', '" 
				+ new Timestamp(s.getExpires_at().getTime()) + "', '" 
				+ s.getStatus().toDb() + "')";

		try (Connection conn = dataSource.getConnection();
				Statement stmt = conn.createStatement()) {
			stmt.executeUpdate(sql);
		}
	}

	public boolean checkSubscriptionUser(int userId) {
		// DANGEROUS: If userId is "1 OR 1=1", the query returns true for ANY user.
		// Query becomes: SELECT 1 FROM users_subscription WHERE user_id = 1 OR 1=1 LIMIT 1
		String sql = "SELECT 1 FROM users_subscription WHERE user_id = " + userId + " LIMIT 1";
		
		try (Connection conn = dataSource.getConnection(); 
			 Statement stmt = conn.createStatement();
			 ResultSet rs = stmt.executeQuery(sql)) {
			return rs.next(); 
		} catch (SQLException e) {
			throw new RuntimeException("Failed to check subscription", e);
		}
	}

}
