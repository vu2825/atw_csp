package data;

import bussines.Movie;
import javax.sql.DataSource;
import java.sql.*;
import java.util.*;

public class WatchlistDAO {
  private final DataSource ds;
  public WatchlistDAO(DataSource ds) { this.ds = ds; }

  public List<Movie> findByUser(int userId) throws SQLException {
    String sql =
        "SELECT v.id AS vid, " +
        "       v.title AS vtitle, " +
        "       YEAR(v.published_at) AS vyear, " +
        "       v.poster_url AS vsrc " + 
        "FROM thanh_toan.watchlist w " +
        "JOIN thanh_toan.videos v ON v.id = w.video_id " +
        "WHERE w.user_id = ? " +
        "ORDER BY w.added_at DESC";

    List<Movie> list = new ArrayList<>();
    try (Connection cn = ds.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {

      ps.setInt(1, userId);

      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          Movie m = new Movie();
          m.setId(rs.getInt("vid"));
          m.setTitle(rs.getString("vtitle"));

          int y = rs.getInt("vyear");
          if (rs.wasNull()) y = 0;
          m.setYear(y);

          m.setSrc(rs.getString("vsrc"));  
          list.add(m);
        }
      }
    }
    return list;
  }

  public void add(int userId, int videoId) throws SQLException {
    String sql = "INSERT INTO thanh_toan.watchlist(user_id, video_id, added_at) VALUES(?,?,NOW())";
    try (Connection cn = ds.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {
      ps.setInt(1, userId);
      ps.setInt(2, videoId);
      ps.executeUpdate();
    }
  }

  public void remove(int userId, int videoId) throws SQLException {
    String sql = "DELETE FROM thanh_toan.watchlist WHERE user_id=? AND video_id=?";
    try (Connection cn = ds.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {
      ps.setInt(1, userId);
      ps.setInt(2, videoId);
      ps.executeUpdate();
    }
  }
}
