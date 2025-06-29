package model;


import java.sql.Timestamp;

public class Service {
    private int id;
    private String name;
    private String description;
    private String category;
    private double price;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private int createdBy;
    
    // Additional field for active status
    private boolean isActive;
    
    // Constructors
    public Service() {}
    
    public Service(String name, String description, String category, double price) {
        this.name = name;
        this.description = description;
        this.category = category;
        this.price = price;
        this.status = "ACTIVE";
        this.isActive = true;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    
    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
    
    // Additional getter and setter for isActive
    public boolean isActive() { return isActive; }
    public void setActive(boolean isActive) { this.isActive = isActive; }
    
    // Helper methods
    public String getCategoryDisplayName() {
        if (category == null) return "";
        switch (category) {
            case "SPA": return "Spa & Wellness";
            case "TRANSPORT": return "Transportation";
            case "LAUNDRY": return "Laundry & Dry Cleaning";
            case "DINING": return "Dining";
            case "ROOM_SERVICE": return "Room Service";
            default: return category;
        }
    }
    
    public String getStatusBadgeClass() {
        if (status == null) return "badge-secondary";
        switch (status) {
            case "ACTIVE": return "badge-success";
            case "INACTIVE": return "badge-danger";
            default: return "badge-secondary";
        }
    }
}