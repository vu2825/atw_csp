package bussines;

public class Movie {
    private int id;
    private String title;
    private int year;
    private String genre;
    private String poster;
    private String src;
    private String duration;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }
    public String getGenre() { return genre; }
    public void setGenre(String genre) { this.genre = genre; }
    public String getPoster() { return poster; }
    public void setPoster(String poster) { this.poster = poster; }
    public String getSrc() { return src; }
    public void setSrc(String src) { this.src = src; }
    public String getDuration() { return duration; }
    public void setDuration(String duration) { this.duration = duration; }
}