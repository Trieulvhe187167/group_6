package model;

import java.sql.Timestamp;

public class Event {
    private int id;
    private String title;
    private String description;
    private String location;
    private Timestamp startAt;  // Đổi từ Date sang Timestamp
    private Timestamp endAt;    // Đổi từ Date sang Timestamp
    private String status;
    private String imageUrl;
    private Integer createdBy;  // Thêm field này
    private Timestamp createdAt; // Thêm field này
    private Timestamp updatedAt; // Thêm field này
    
    // Constructor mặc định
    public Event() {
    }
    
    // Getters & setters
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
    
    public String getDescription() { 
        return description; 
    }
    
    public void setDescription(String description) { 
        this.description = description; 
    }
    
    public String getLocation() { 
        return location; 
    }
    
    public void setLocation(String location) { 
        this.location = location; 
    }
    
    public Timestamp getStartAt() { 
        return startAt; 
    }
    
    public void setStartAt(Timestamp startAt) { 
        this.startAt = startAt; 
    }
    
    public Timestamp getEndAt() { 
        return endAt; 
    }
    
    public void setEndAt(Timestamp endAt) { 
        this.endAt = endAt; 
    }
    
    public String getStatus() { 
        return status; 
    }
    
    public void setStatus(String status) { 
        this.status = status; 
    }
    
    public String getImageUrl() { 
        return imageUrl; 
    }
    
    public void setImageUrl(String imageUrl) { 
        this.imageUrl = imageUrl; 
    }
    
    public Integer getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
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
    
    @Override
    public String toString() {
        return "Event{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", location='" + location + '\'' +
                ", startAt=" + startAt +
                ", endAt=" + endAt +
                ", status='" + status + '\'' +
                '}';
    }
}