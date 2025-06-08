package model;

public class Room {
    private int id;
    private String roomNumber;
    private int roomTypeId;
    private String status;
    
    // Additional fields for display
    private String roomTypeName;
    private double basePrice;
    private int capacity;
    private String roomTypeDescription;
    private String imageUrl;
    
    // Constructors
    public Room() {}
    
    public Room(String roomNumber, int roomTypeId, String status) {
        this.roomNumber = roomNumber;
        this.roomTypeId = roomTypeId;
        this.status = status;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getRoomNumber() {
        return roomNumber;
    }
    
    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }
    
    public int getRoomTypeId() {
        return roomTypeId;
    }
    
    public void setRoomTypeId(int roomTypeId) {
        this.roomTypeId = roomTypeId;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getRoomTypeName() {
        return roomTypeName;
    }
    
    public void setRoomTypeName(String roomTypeName) {
        this.roomTypeName = roomTypeName;
    }
    
    public double getBasePrice() {
        return basePrice;
    }
    
    public void setBasePrice(double basePrice) {
        this.basePrice = basePrice;
    }
    
    public int getCapacity() {
        return capacity;
    }
    
    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }
    
    public String getRoomTypeDescription() {
        return roomTypeDescription;
    }
    
    public void setRoomTypeDescription(String roomTypeDescription) {
        this.roomTypeDescription = roomTypeDescription;
    }
    
    public String getImageUrl() {
        return imageUrl;
    }
    
    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
    
    // Helper methods
    public String getStatusDisplayName() {
        if (status == null) return "";
        switch (status) {
            case "AVAILABLE": return "Available";
            case "OCCUPIED": return "Occupied";
            case "MAINTENANCE": return "Maintenance";
            case "DIRTY": return "Dirty";
            default: return status;
        }
    }
    
    public String getStatusBadgeClass() {
        if (status == null) return "badge-secondary";
        switch (status) {
            case "AVAILABLE": return "badge-success";
            case "OCCUPIED": return "badge-danger";
            case "MAINTENANCE": return "badge-warning";
            case "DIRTY": return "badge-warning";
            default: return "badge-secondary";
        }
    }
    
    public boolean isAvailable() {
        return "AVAILABLE".equals(status);
    }
    
    public boolean isOccupied() {
        return "OCCUPIED".equals(status);
    }
    
    public boolean needsCleaning() {
        return "DIRTY".equals(status);
    }
    
    public boolean isUnderMaintenance() {
        return "MAINTENANCE".equals(status);
    }
}