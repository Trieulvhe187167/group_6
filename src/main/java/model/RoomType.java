/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;
import java.util.Date;

/**
 *
 * @author ASUS
 */
public class RoomType {
    private int id;
    private String name;
    private String description;
    private BigDecimal basePrice;
    private String imageUrl;
    private int capacity;
    private String status;
    private Date createdAt;
    private Date updatedAt;
    
    // Transient field to store available room count (not persisted in database)
    private transient int availableRoomCount;
    
    // Transient fields for feedback statistics
    private transient double averageRating;
    private transient int reviewCount;

    public RoomType() {
    }

    public RoomType(String name, String description, BigDecimal basePrice, String imageUrl, int capacity) {
        this.name = name;
        this.description = description;
        this.basePrice = basePrice;
        this.imageUrl = imageUrl;
        this.capacity = capacity;
    }

    public RoomType(int id, String name, String description, BigDecimal basePrice, String imageUrl, int capacity, String status, Date createdAt, Date updatedAt) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.basePrice = basePrice;
        this.imageUrl = imageUrl;
        this.capacity = capacity;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public BigDecimal getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(BigDecimal basePrice) {
        this.basePrice = basePrice;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    /**
     * Get the number of available rooms for this room type
     * This is a transient field set during search operations
     * @return number of available rooms
     */
    public int getAvailableRoomCount() {
        return availableRoomCount;
    }

    /**
     * Set the number of available rooms for this room type
     * @param availableRoomCount number of available rooms
     */
    public void setAvailableRoomCount(int availableRoomCount) {
        this.availableRoomCount = availableRoomCount;
    }
 public double getAverageRating() {
        return averageRating;
    }

    public void setAverageRating(double averageRating) {
        this.averageRating = averageRating;
    }

    public int getReviewCount() {
        return reviewCount;
    }

    public void setReviewCount(int reviewCount) {
        this.reviewCount = reviewCount;
    }
    /**
     * Check if this room type has any available rooms
     * @return true if there are available rooms
     */
    public boolean hasAvailableRooms() {
        return availableRoomCount > 0;
    }

    /**
     * Get formatted message about room availability
     * @return availability message
     */
    public String getAvailabilityMessage() {
        if (availableRoomCount == 0) {
            return "No rooms available";
        } else if (availableRoomCount == 1) {
            return "Only 1 room left!";
        } else if (availableRoomCount <= 3) {
            return "Only " + availableRoomCount + " rooms left!";
        } else {
            return availableRoomCount + " rooms available";
        }
    }

    // Additional getter for compatibility with double-based calculations
    public double getBasePriceAsDouble() {
        return basePrice != null ? basePrice.doubleValue() : 0.0;
    }

    // Helper method for display purposes
    public String getFormattedPrice() {
        if (basePrice == null) return "0₫";
        return String.format("%,.0f₫", basePrice.doubleValue());
    }

    // Helper method to check if room type is active
    public boolean isActive() {
        return "active".equalsIgnoreCase(status);
    }

    // Helper method for capacity display
    public String getCapacityDisplay() {
        if (capacity <= 1) {
            return capacity + " person";
        } else {
            return capacity + " people";
        }
    }

    // Helper method for status badge class (for frontend display)
    public String getStatusBadgeClass() {
        if (status == null) return "badge-secondary";
        switch (status.toLowerCase()) {
            case "active":
                return "badge-success";
            case "inactive":
                return "badge-secondary";
            case "maintenance":
                return "badge-warning";
            default:
                return "badge-secondary";
        }
    }

    // Helper method for status display name
    public String getStatusDisplayName() {
        if (status == null) return "Unknown";
        switch (status.toLowerCase()) {
            case "active":
                return "Active";
            case "inactive":
                return "Inactive";
            case "maintenance":
                return "Under Maintenance";
            default:
                return status;
        }
    }

    // Method to get shortened description for display
    public String getShortDescription() {
        if (description == null || description.length() <= 100) {
            return description;
        }
        return description.substring(0, 100) + "...";
    }

    // Method to check if this room type has any rooms
    public boolean hasRooms() {
        // This would need to be set by the service/DAO layer
        // You can add a field 'private int roomCount' and its getter/setter
        return true; // Default implementation
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        RoomType roomType = (RoomType) obj;
        return id == roomType.id;
    }

    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }

    @Override
    public String toString() {
        return "RoomType{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", basePrice=" + basePrice +
                ", capacity=" + capacity +
                ", status='" + status + '\'' +
                ", availableRoomCount=" + availableRoomCount +
                '}';
    }
}