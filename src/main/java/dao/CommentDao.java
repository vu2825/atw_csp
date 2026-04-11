package dao;

import bussines.CommentView;
import jakarta.annotation.Resource;
import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CommentDao {
    @Resource(lookup="java:comp/env/jdbc/loginDB")
    private DataSource ds;

    public List<CommentView> listByMovie(String videoId, int limit) throws Exception {
        String sql =
                "SELECT rr.comment, rr.rating, rr.created_at, u.username " +
                        "FROM thanh_toan.rating_reviews rr " +
                        "JOIN thanh_toan.users u ON u.id = rr.user_id " +
                        "WHERE rr.video_id = ? " +
                        "ORDER BY rr.created_at DESC " +
                        "LIMIT ?";
        List<CommentView> out = new ArrayList<>();
        try (Connection cn = ds.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, videoId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CommentView c = new CommentView();
                    c.setUserName(rs.getString("username"));
                    c.setStars(rs.getInt("rating"));
                    c.setContent(rs.getString("comment"));
                    c.setCreatedAt(rs.getTimestamp("created_at"));
                    out.add(c);
                }
            }
        }
        return out;
    }
}
