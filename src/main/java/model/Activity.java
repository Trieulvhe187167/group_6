package model;


import java.sql.Timestamp;

public class Activity {
    private int id;
    private String type;
    private Integer reservationId;
    private int userId;
    private String description;
    private Double amount;
    private Timestamp timestamp;
    private String ipAddress;
    
    // Additional fields for display
    private String userName;
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }
    
    public Integer getReservationId() {
        return reservationId;
    }
    
    public void setReservationId(Integer reservationId) {
        this.reservationId = reservationId;
    }
    
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public Double getAmount() {
        return amount;
    }
    
    public void setAmount(Double amount) {
        this.amount = amount;
    }
    
    public Timestamp getTimestamp() {
        return timestamp;
    }
    
    public void setTimestamp(Timestamp timestamp) {
        this.timestamp = timestamp;
    }
    
    public String getIpAddress() {
        return ipAddress;
    }
    
    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }
    
    public String getUserName() {
        return userName;
    }
    
    public void setUserName(String userName) {
        this.userName = userName;
    }
    
    // Helper method to get formatted activity type
    public String getTypeDisplayName() {
        if (type == null) return "";
        switch (type) {
            case "CHECK_IN": return "Check In";
            case "CHECK_OUT": return "Check Out";
            case "RESERVATION_CREATE": return "New Reservation";
            case "RESERVATION_UPDATE": return "Reservation Updated";
            case "PAYMENT_RECEIVED": return "Payment Received";
            case "SERVICE_ADDED": return "Service Added";
            default: return type;
        }
    }
    
    // Helper method to get activity icon
    public String getTypeIcon() {
        if (type == null) return "fa-info-circle";
        switch (type) {
            case "CHECK_IN": return "fa-sign-in-alt";
            case "CHECK_OUT": return "fa-sign-out-alt";
            case "RESERVATION_CREATE": return "fa-calendar-plus";
            case "RESERVATION_UPDATE": return "fa-calendar-check";
            case "PAYMENT_RECEIVED": return "fa-money-bill-wave";
            case "SERVICE_ADDED": return "fa-concierge-bell";
            default: return "fa-info-circle";
        }
    }
}