package types;

public class DashboardStats {
    private int totalUsers;
    private int totalVideos;

    public DashboardStats() {}
    public DashboardStats(int totalUsers, int totalVideos) {
        this.totalUsers = totalUsers;
        this.totalVideos = totalVideos;
    }

    public int getTotalUsers() { return totalUsers; }
    public void setTotalUsers(int totalUsers) { this.totalUsers = totalUsers; }

    public int getTotalVideos() { return totalVideos; }
    public void setTotalVideos(int totalVideos) { this.totalVideos = totalVideos; }
}
