package bussines;

public class Video {
    private int id;
    private String title;
    private String duration;
    private String director;
    private String urlVideo360p;
    private String urlVideo480p;
    private String publishedAt;
    private String publishedBy;
    private String updatedBy;
    private String createdAt;
    private String genre;
    private String posterUrl; 

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDuration() { return duration; }
    public void setDuration(String duration) { this.duration = duration; }

    public String getDirector() { return director; }
    public void setDirector(String director) { this.director = director; }

    public String getUrlVideo360p() { return urlVideo360p; }
    public void setUrlVideo360p(String urlVideo360p) { this.urlVideo360p = urlVideo360p; }

    public String getUrlVideo480p() { return urlVideo480p; }
    public void setUrlVideo480p(String urlVideo480p) { this.urlVideo480p = urlVideo480p; }

    public String getPublishedAt() { return publishedAt; }
    public void setPublishedAt(String publishedAt) { this.publishedAt = publishedAt; }

    public String getPublishedBy() { return publishedBy; }
    public void setPublishedBy(String publishedBy) { this.publishedBy = publishedBy; }

    public String getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(String updatedBy) { this.updatedBy = updatedBy; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    public String getGenre() { return genre; }
    public void setGenre(String genre) { this.genre = genre; }

    public String getPosterUrl() { return posterUrl; }
    public void setPosterUrl(String posterUrl) { this.posterUrl = posterUrl; }
}

