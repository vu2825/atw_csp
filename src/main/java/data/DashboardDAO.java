package data;

import types.DashboardStats;
import java.sql.*;

public class DashboardDAO {

    private Connection getConnection() throws SQLException {
        String url = "jdbc:mysql://mysql:3306/thanh_toan?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&allowPublicKeyRetrieval=true&useSSL=false";
        String user = "user1"; 
        String password = "user1123@"; 

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }

        Connection conn = DriverManager.getConnection(url, user, password);
        System.out.println("✅ Đã kết nối tới database: " + conn.getCatalog());
        return conn;
    }

    public DashboardStats getDashboardStats() {
        DashboardStats stats = new DashboardStats();
        try (Connection conn = getConnection()) {

            PreparedStatement psUsers = conn.prepareStatement("SELECT COUNT(*) FROM users");
            ResultSet rsUsers = psUsers.executeQuery();
            if (rsUsers.next()) stats.setTotalUsers(rsUsers.getInt(1));
            System.out.println("👥 Tổng user: " + stats.getTotalUsers());

            PreparedStatement psVideos = conn.prepareStatement("SELECT COUNT(*) FROM videos");
            ResultSet rsVideos = psVideos.executeQuery();
            if (rsVideos.next()) stats.setTotalVideos(rsVideos.getInt(1));
            System.out.println("🎬 Tổng video: " + stats.getTotalVideos());

        } catch (SQLException e) {
            System.out.println("❌ Lỗi khi truy vấn: " + e.getMessage());
        }
        return stats;
    }
}
