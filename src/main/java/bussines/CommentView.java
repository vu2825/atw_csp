package bussines;

import java.sql.Timestamp;

public class CommentView {
    private String userName;
    private int stars;
    private String content;
    private Timestamp createdAt;

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public int getStars() { return stars; }
    public void setStars(int stars) { this.stars = stars; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
