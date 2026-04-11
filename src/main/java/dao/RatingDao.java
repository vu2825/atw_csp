package dao;

import bussines.RatingSummary;
import jakarta.annotation.Resource;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.*;
import java.util.*; 

public class RatingDao {
    @Resource(lookup = "java:comp/env/jdbc/loginDB")
    private DataSource injected;       

    private DataSource ds;

    public RatingDao() {
        // Dùng được cả khi bạn tự new RatingDao() trong Servlet
        if (injected != null) { ds = injected; return; }
        try {
            InitialContext ic = new InitialContext();
            ds = (DataSource) ic.lookup("java:comp/env/jdbc/loginDB");
        } catch (NamingException e) {
            throw new RuntimeException("JNDI not found: jdbc/loginDB", e);
        }
    }

    public RatingSummary summary(String videoId) throws Exception {
        String sql =
            "SELECT AVG(rating) AS avg_rating, " +
            "       COUNT(*) AS total_reviews, " +
            "       SUM(rating=5) s5, SUM(rating=4) s4, SUM(rating=3) s3, " +
            "       SUM(rating=2) s2, SUM(rating=1) s1 " +
            "FROM thanh_toan.rating_reviews WHERE video_id = ?";

        try (Connection cn = ds.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, videoId);
            try (ResultSet rs = ps.executeQuery()) {
                RatingSummary r = new RatingSummary();
                if (rs.next()) {
                    r.setAvg(rs.getDouble("avg_rating"));
                    r.setCount(rs.getInt("total_reviews"));
                    Map<Integer,Integer> dist = new HashMap<>();
                    dist.put(5, rs.getInt("s5"));
                    dist.put(4, rs.getInt("s4"));
                    dist.put(3, rs.getInt("s3"));
                    dist.put(2, rs.getInt("s2"));
                    dist.put(1, rs.getInt("s1"));
                    r.setDist(dist);
                }
                return r;
            }
        }
    }

    public static class ReviewView {
  private int id, rating; private String comment, username; private Timestamp created_at;
  public int getId(){return id;} public void setId(int v){id=v;}
  public int getRating(){return rating;} public void setRating(int v){rating=v;}
  public String getComment(){return comment;} public void setComment(String v){comment=v;}
  public String getUsername(){return username;} public void setUsername(String v){username=v;}
  public Timestamp getCreated_at(){return created_at;} public void setCreated_at(Timestamp v){created_at=v;}
}


    public List<ReviewView> listByVideoId(int videoId) throws Exception {
    String sql =
        "SELECT r.id, r.rating, r.comment, r.created_at, " +
        "       COALESCE(u.username, CONCAT('User#', r.user_id)) AS username " +
        "FROM thanh_toan.rating_reviews r " +
        "LEFT JOIN thanh_toan.users u ON u.id = r.user_id " + 
        "WHERE r.video_id = ? " +
        "ORDER BY r.created_at DESC";

    try (Connection cn = ds.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {
        ps.setInt(1, videoId);
        try (ResultSet rs = ps.executeQuery()) {
            List<ReviewView> out = new ArrayList<>();
            while (rs.next()) {
                ReviewView v = new ReviewView();
                v.setId(rs.getInt("id"));
                v.setRating(rs.getInt("rating"));
                v.setComment(rs.getString("comment"));
                v.setCreated_at(rs.getTimestamp("created_at"));
                v.setUsername(rs.getString("username"));
                out.add(v);
            }
            return out;
        }
    }
}

}
