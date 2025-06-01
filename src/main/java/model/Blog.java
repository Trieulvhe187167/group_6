package model;

import java.sql.Timestamp;
import java.util.List;

public class Blog {
    private int id;
    private String title;
    private String slug;
    private String content;
    private String imageUrl;
    private int authorId;
    private String authorName;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private int commentCount;
    private List<String> tags;
    private String status;

    // Constructor mặc định
    public Blog() {
        this.commentCount = 0;
    }

    // Constructor đầy đủ
    public Blog(int id, String title, String slug, String content, String imageUrl, 
                int authorId, String authorName, Timestamp createdAt, Timestamp updatedAt, 
                int commentCount, String status) {
        this.id = id;
        this.title = title;
        this.slug = slug;
        this.content = content;
        this.imageUrl = imageUrl;
        this.authorId = authorId;
        this.authorName = authorName;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.commentCount = commentCount;
        this.status = status;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getSlug() {
        return slug;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public int getAuthorId() {
        return authorId;
    }

    public void setAuthorId(int authorId) {
        this.authorId = authorId;
    }

    public String getAuthorName() {
        return authorName;
    }

    public void setAuthorName(String authorName) {
        this.authorName = authorName;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public int getCommentCount() {
        return commentCount;
    }

    public void setCommentCount(int commentCount) {
        this.commentCount = commentCount;
    }

    public List<String> getTags() {
        return tags;
    }

    public void setTags(List<String> tags) {
        this.tags = tags;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    // toString method for debugging
    @Override
    public String toString() {
        return "Blog{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", slug='" + slug + '\'' +
                ", authorName='" + authorName + '\'' +
                ", createdAt=" + createdAt +
                ", commentCount=" + commentCount +
                ", status='" + status + '\'' +
                '}';
    }
}