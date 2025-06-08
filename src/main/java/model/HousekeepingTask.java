package model;

import java.sql.Timestamp;

public class HousekeepingTask {
    private int id;
    private int roomId;
    private int assignedTo;
    private String status;
    private String notes;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Additional fields for display
    private String roomNumber;
    private String roomTypeName;
    private String assignedToName;
    private String roomStatus;
    
    // Constructors
    public HousekeepingTask() {}
    
    public HousekeepingTask(int roomId, int assignedTo, String status, String notes) {
        this.roomId = roomId;
        this.assignedTo = assignedTo;
        this.status = status;
        this.notes = notes;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getRoomId() {
        return roomId;
    }
    
    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }
    
    public int getAssignedTo() {
        return assignedTo;
    }
    
    public void setAssignedTo(int assignedTo) {
        this.assignedTo = assignedTo;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getNotes() {
        return notes;
    }
    
    public void setNotes(String notes) {
        this.notes = notes;
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
    
    public String getRoomNumber() {
        return roomNumber;
    }
    
    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }
    
    public String getRoomTypeName() {
        return roomTypeName;
    }
    
    public void setRoomTypeName(String roomTypeName) {
        this.roomTypeName = roomTypeName;
    }
    
    public String getAssignedToName() {
        return assignedToName;
    }
    
    public void setAssignedToName(String assignedToName) {
        this.assignedToName = assignedToName;
    }
    
    public String getRoomStatus() {
        return roomStatus;
    }
    
    public void setRoomStatus(String roomStatus) {
        this.roomStatus = roomStatus;
    }
    
    // Helper methods
    public String getStatusDisplayName() {
        if (status == null) return "";
        switch (status) {
            case "PENDING": return "Pending";
            case "IN_PROGRESS": return "In Progress";
            case "DONE": return "Completed";
            default: return status;
        }
    }
    
    public String getStatusBadgeClass() {
        if (status == null) return "badge-secondary";
        switch (status) {
            case "PENDING": return "badge-warning";
            case "IN_PROGRESS": return "badge-info";
            case "DONE": return "badge-success";
            default: return "badge-secondary";
        }
    }
    
    public String getRoomStatusBadgeClass() {
        if (roomStatus == null) return "badge-secondary";
        switch (roomStatus) {
            case "AVAILABLE": return "badge-success";
            case "OCCUPIED": return "badge-danger";
            case "MAINTENANCE": return "badge-warning";
            case "DIRTY": return "badge-warning";
            default: return "badge-secondary";
        }
    }
    
    public boolean canBeAssigned() {
        return !"DONE".equals(status);
    }
    
    public boolean canChangeStatus() {
        return true; // All tasks can have their status changed
    }
}