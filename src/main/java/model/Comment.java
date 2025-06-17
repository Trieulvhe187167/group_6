package model;


import java.sql.Timestamp;

public class Comment {
    private int id;
    private int blogId;
    private String authorName;
    private String email;
    private String content;
    private String status;
    private Timestamp createdAt;
    
    // Constructors
    public Comment() {}
    
    public Comment(int blogId, String authorName, String email, String content) {
        this.blogId = blogId;
        this.authorName = authorName;
        this.email = email;
        this.content = content;
        this.status = "PENDING";
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getBlogId() {
        return blogId;
    }
    
    public void setBlogId(int blogId) {
        this.blogId = blogId;
    }
    
    public String getAuthorName() {
        return authorName;
    }
    
    public void setAuthorName(String authorName) {
        this.authorName = authorName;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}