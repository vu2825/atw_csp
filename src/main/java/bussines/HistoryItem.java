package bussines;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class HistoryItem {
  private int id;
  private int userId;
  private int videoId;
  private int progressSeconds;
  private LocalDateTime lastWatchedAt;

  private String title;
  private String duration;

  private String posterUrl;

  private String videoUrl;

  public int getId() { return id; }
  public void setId(int id) { this.id = id; }

  public int getUserId() { return userId; }
  public void setUserId(int userId) { this.userId = userId; }

  public int getVideoId() { return videoId; }
  public void setVideoId(int videoId) { this.videoId = videoId; }

  public int getProgressSeconds() { return progressSeconds; }
  public void setProgressSeconds(int progressSeconds) { this.progressSeconds = progressSeconds; }

  public LocalDateTime getLastWatchedAt() { return lastWatchedAt; }
  public void setLastWatchedAt(LocalDateTime lastWatchedAt) { this.lastWatchedAt = lastWatchedAt; }

  public String getTitle() { return title; }
  public void setTitle(String title) { this.title = title; }

  public String getDuration() { return duration; }
  public void setDuration(String duration) { this.duration = duration; }

  public String getPosterUrl() { return posterUrl; }
  public void setPosterUrl(String posterUrl) { this.posterUrl = posterUrl; }

  public String getVideoUrl() { return videoUrl; }
  public void setVideoUrl(String videoUrl) { this.videoUrl = videoUrl; }

  public String getLastWatchedAtDisplay() {
    if (lastWatchedAt == null) return "";
    return lastWatchedAt.format(DateTimeFormatter.ofPattern("HH:mm:ss dd/MM/yyyy"));
  }
}
