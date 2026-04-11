package data;

import bussines.TopUp;
import types.TopUpRequestTypes;
import javax.sql.DataSource;
import java.sql.*;
import java.util.*;

public class TopUpDB {
	private final DataSource ds;

	public TopUpDB(DataSource ds) {
		if (ds == null)
			throw new IllegalArgumentException("DataSource cannot be null");
		this.ds = ds;
	}

	public List<TopUp> getAll() throws SQLException {
		String sql = "SELECT id, user_id, amount, status, created_at, updated_at "
				+ "FROM topup_requests ORDER BY created_at DESC";
		List<TopUp> list = new ArrayList<>();
		try (Connection conn = ds.getConnection();
				PreparedStatement ps = conn.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				TopUp t = new TopUp(); 
				t.setId(rs.getInt("id"));
				t.setUserId(rs.getInt("user_id"));

				t.setAmount(rs.getBigDecimal("amount").doubleValue());
				t.setStatus(TopUpRequestTypes.fromDb(rs.getString("status")));
				t.setCreatedAt(rs.getTimestamp("created_at"));
				t.setUpdatedAt(rs.getTimestamp("updated_at"));
				list.add(t);
			}
		}
		return list;
	}

	public TopUp getById(int id) throws SQLException {
		String sql = "SELECT id, user_id, amount, status, created_at, updated_at " + "FROM topup_requests WHERE id = ?";
		try (Connection conn = ds.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, id);
			try (ResultSet rs = ps.executeQuery()) {
				return rs.next() ? map(rs) : null;
			}
		}
	}

	public List<TopUp> getByUserId(int userId) throws SQLException {
		String sql = "SELECT id, user_id, amount, status, created_at, updated_at "
				+ "FROM topup_requests WHERE user_id = ? ORDER BY created_at DESC";
		List<TopUp> list = new ArrayList<>();
		try (Connection conn = ds.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, userId);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next())
					list.add(map(rs));
			}
		}
		return list;
	}

	public void insertTopUp(int userId, double amount) throws SQLException {
		String sql = "INSERT INTO topup_requests (user_id, amount, status, created_at, updated_at) "
				+ "VALUES (?, ?, 'pending', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
		try (Connection conn = ds.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, userId);
			ps.setDouble(2, amount);
			ps.executeUpdate();
		}
	}

	public List<TopUp> search(String status, String q) throws SQLException {
		StringBuilder sb = new StringBuilder(
				"SELECT id, user_id, amount, status, created_at, updated_at FROM topup_requests WHERE 1=1 ");
		List<Object> params = new ArrayList<>();

		if (status != null && !status.isBlank()) {
			sb.append(" AND status = ? ");
			params.add(status.toLowerCase(java.util.Locale.ROOT));
		}
		if (q != null && !q.isBlank()) {

			try {
				int n = Integer.parseInt(q.trim());
				sb.append(" AND (id = ? OR user_id = ?) ");
				params.add(n);
				params.add(n);
			} catch (NumberFormatException ignore) {

			}
		}
		sb.append(" ORDER BY created_at DESC ");

		List<TopUp> list = new ArrayList<>();
		try (Connection conn = ds.getConnection(); PreparedStatement ps = conn.prepareStatement(sb.toString())) {
			for (int i = 0; i < params.size(); i++) {
				Object p = params.get(i);
				if (p instanceof Integer)
					ps.setInt(i + 1, (Integer) p);
				else
					ps.setString(i + 1, p.toString());
			}
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					TopUp t = new TopUp();
					t.setId(rs.getInt("id"));
					t.setUserId(rs.getInt("user_id"));
					t.setAmount(rs.getBigDecimal("amount").doubleValue());
					t.setStatus(TopUpRequestTypes.fromDb(rs.getString("status")));
					t.setCreatedAt(rs.getTimestamp("created_at"));
					t.setUpdatedAt(rs.getTimestamp("updated_at"));
					list.add(t);
				}
			}
		}
		return list;
	}

	public void updateStatus(int id, TopUpRequestTypes status) throws SQLException {
		String sql = "UPDATE topup_requests SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
		try (Connection conn = ds.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setString(1, status.toDb());
			ps.setInt(2, id);
			ps.executeUpdate();
		}
	}

	public void delete(int id) throws SQLException {
		String sql = "DELETE FROM topup_requests WHERE id = ?";
		try (Connection conn = ds.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, id);
			ps.executeUpdate();
		}
	}

	public boolean updateStatusIfPending(int id, TopUpRequestTypes newStatus) throws SQLException {
		String sql = "UPDATE topup_requests " + "SET status = ?, updated_at = CURRENT_TIMESTAMP "
				+ "WHERE id = ? AND status = 'pending'";
		try (Connection conn = ds.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setString(1, newStatus.toDb()); // "accept" | "discard"
			ps.setInt(2, id);
			int rows = ps.executeUpdate();
			return rows > 0;
		}
	}

	private static TopUp map(ResultSet rs) throws SQLException {
		TopUp t = new TopUp();
		t.setId(rs.getInt("id"));
		t.setUserId(rs.getInt("user_id"));
		t.setAmount(rs.getDouble("amount"));
		t.setStatus(TopUpRequestTypes.fromDb(rs.getString("status")));
		t.setCreatedAt(rs.getTimestamp("created_at"));
		t.setUpdatedAt(rs.getTimestamp("updated_at"));

		return t;
	}
}
