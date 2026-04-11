package data;

import bussines.HistoryItem;
import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HistoryDAO {
    private final DataSource ds;

    public HistoryDAO(DataSource ds) {
        this.ds = ds;
    }


    public List<HistoryItem> findByUser(int userId) throws SQLException {

        String sql = """
            SELECT h.id,
                   h.user_id,
                   h.video_id,
                   h.progress_seconds,
                   h.last_watched_at,
                   v.title,
                   v.duration,
                   v.poster_url AS poster_url
            FROM history h
            JOIN videos v ON v.id = h.video_id
            WHERE h.user_id = ?
            ORDER BY h.last_watched_at DESC
        """;

        List<HistoryItem> list = new ArrayList<>();
        try (Connection cn = ds.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HistoryItem h = new HistoryItem();
                    h.setId(rs.getInt("id"));
                    h.setUserId(rs.getInt("user_id"));
                    h.setVideoId(rs.getInt("video_id"));
                    h.setProgressSeconds(rs.getInt("progress_seconds"));

                    Timestamp ts = rs.getTimestamp("last_watched_at");
                    if (ts != null) h.setLastWatchedAt(ts.toLocalDateTime());

                    h.setTitle(rs.getString("title"));
                    h.setDuration(rs.getString("duration"));

                    h.setPosterUrl(rs.getString("poster_url"));

                    list.add(h);
                }
            }
        }
        return list;
    }

    public int deleteByIdForUser(int id, int userId) throws SQLException {
        String sql = "DELETE FROM history WHERE id = ? AND user_id = ?";
        try (Connection cn = ds.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate();
        }
    }

    public void upsertProgress(int userId, int videoId, int progressSeconds) throws SQLException {
        String update = """
            UPDATE history 
            SET progress_seconds = ?, last_watched_at = CURRENT_TIMESTAMP
            WHERE user_id = ? AND video_id = ?
        """;

        String insert = """
            INSERT INTO history(user_id, video_id, progress_seconds, last_watched_at)
            VALUES(?, ?, ?, CURRENT_TIMESTAMP)
        """;

        try (Connection cn = ds.getConnection()) {
            cn.setAutoCommit(false);
            try (PreparedStatement psU = cn.prepareStatement(update)) {
                psU.setInt(1, progressSeconds);
                psU.setInt(2, userId);
                psU.setInt(3, videoId);

                int n = psU.executeUpdate();
                if (n == 0) { 
                    try (PreparedStatement psI = cn.prepareStatement(insert)) {
                        psI.setInt(1, userId);
                        psI.setInt(2, videoId);
                        psI.setInt(3, progressSeconds);
                        psI.executeUpdate();
                    }
                }
                cn.commit();
            } catch (SQLException e) {
                cn.rollback();
                throw e;
            } finally {
                cn.setAutoCommit(true);
            }
        }
    }
}
