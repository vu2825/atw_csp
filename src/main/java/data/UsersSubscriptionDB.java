package data;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.sql.DataSource;
import java.sql.Timestamp;

import bussines.UsersSubscription;
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
		String sql = "INSERT INTO users_subscription " + "(user_id, plan, price, started_at, expires_at, status) "
				+ "VALUES (?,?,?,?,?,?)";
		try (Connection conn = dataSource.getConnection();
				PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {

			ps.setInt(1, s.getUser_id());
			ps.setString(2, s.getPlan());
			// if model holds double dollars, convert to cents
			double cents = s.getPrice();
			ps.setDouble(3, cents);

			ps.setTimestamp(4, new Timestamp(s.getStarted_at().getTime()));
			ps.setTimestamp(5, new Timestamp(s.getExpires_at().getTime()));
			ps.setString(6, s.getStatus().toDb()); // "active"/"expired"/"canceled"

			ps.executeUpdate();

		}
	}

	public UsersSubscription getSubscriptionForUser(int userId) {
		UsersSubscription s = null;
		String sql = "SELECT id,user_id,plan,price_cents,started_at,expires_at,status,created_at,updated_at "
				+ "FROM users_subscription WHERE user_id=? AND status='active' LIMIT 1";
		try (Connection conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, userId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					s = new UsersSubscription();
					s.setId(rs.getInt("id"));
					s.setUser_id(rs.getInt("user_id"));
					s.setPlan(rs.getString("plan"));

					double cents = rs.getDouble("price");
					s.setPrice(cents);

					Timestamp st = rs.getTimestamp("started_at");
					Timestamp ex = rs.getTimestamp("expires_at");
					if (st != null)
						s.setStarted_at(new java.util.Date(st.getTime()));
					if (ex != null)
						s.setExpires_at(new java.util.Date(ex.getTime()));

					s.setStatus(SubscriptionStatus.fromDb(rs.getString("status")));
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return s;
	}

}
