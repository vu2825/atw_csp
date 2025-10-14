package data;

import model.Movie;
import javax.sql.DataSource;
import java.sql.*;
import java.util.*;

public class WatchlistDAO {
  private final DataSource ds;
  public WatchlistDAO(DataSource ds){ this.ds = ds; }

  // Lấy watchlist theo user
  public List<Movie> findByUser(int userId) throws SQLException {
    String sql =
        "SELECT v.id            AS vid, " +
        "       v.title         AS vtitle, " +
        "       YEAR(v.published_at) AS vyear, " +
        "       COALESCE(v.url_video_360P, v.url_video_480P, v.url_video) AS vposter " +
        "FROM watchlist w " +
        "JOIN videos v ON v.id = w.video_id " +
        "WHERE w.user_id = ? " +            // <--- dùng placeholder
        "ORDER BY w.added_at DESC";

    List<Movie> list = new ArrayList<>();
    try (Connection cn = ds.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {

      ps.setInt(1, userId);                 // <--- truyền userId vào ?

      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          Movie m = new Movie();
          m.setId(rs.getInt("vid"));
          m.setTitle(rs.getString("vtitle"));

          Integer yearObj = (Integer) rs.getObject("vyear");
          m.setYear(yearObj != null ? yearObj : 0);

          m.setPosterUrl(rs.getString("vposter"));
          list.add(m);
        }
      }
    }
    return list;
  }

  // Thêm video vào watchlist
  public void add(int userId, int videoId) throws SQLException {
    // Khuyên: thêm UNIQUE (user_id, video_id) ở DB, có thể dùng INSERT IGNORE nếu muốn tránh trùng
    String sql = "INSERT INTO watchlist(user_id, video_id, added_at) VALUES(?,?,NOW())";
    try (Connection cn = ds.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {
      ps.setInt(1, userId);
      ps.setInt(2, videoId);
      ps.executeUpdate();
    }
  }

  // Xóa video khỏi watchlist
  public void remove(int userId, int videoId) throws SQLException {
    String sql = "DELETE FROM watchlist WHERE user_id=? AND video_id=?";
    try (Connection cn = ds.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {
      ps.setInt(1, userId);
      ps.setInt(2, videoId);
      ps.executeUpdate();
    }
  }
}
