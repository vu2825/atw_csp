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
  private int year;
  private String genre;
  private String poster;

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

  public int getYear() { return year; }
  public void setYear(int year) { this.year = year; }

  public String getGenre() { return genre; }
  public void setGenre(String genre) { this.genre = genre; }

  public String getPoster() { return poster; }
  public void setPoster(String poster) { this.poster = poster; }

  public String getLastWatchedAtDisplay() {
    if (lastWatchedAt == null) return "";
    return lastWatchedAt.format(DateTimeFormatter.ofPattern("HH:mm:ss dd/MM/yyyy"));
  }
}
