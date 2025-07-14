package model;


import java.sql.Timestamp;

public class RoomAmenity {
    private int id;
    private String name;
    private String description;
    private String category;
    private boolean isChargeable;
    private double unitPrice;
    private String status;
    private int quantity;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private int createdBy;
    
    // Constructors
    public RoomAmenity() {}
    
    public RoomAmenity(String name, String category, boolean isChargeable, double unitPrice) {
        this.name = name;
        this.category = category;
        this.isChargeable = isChargeable;
        this.unitPrice = unitPrice;
        this.status = "ACTIVE";
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
    
    public boolean getIsChargeable() { return isChargeable; }
    public void setIsChargeable(boolean isChargeable) { this.isChargeable = isChargeable; }
    
    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    
    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
    
    // Helper methods
    public String getCategoryDisplayName() {
        if (category == null) return "";
        switch (category) {
            case "MINIBAR": return "Minibar";
            case "AMENITY": return "Room Amenity";
            case "ELECTRONICS": return "Electronics";
            case "BATHROOM": return "Bathroom";
            case "FURNITURE": return "Furniture";
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