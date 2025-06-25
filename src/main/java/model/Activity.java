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
    private String roomNumber;
    
    // Constructors
    public Activity() {
        this.timestamp = new Timestamp(System.currentTimeMillis());
    }
    
    public Activity(String type, int userId, String description) {
        this();
        this.type = type;
        this.userId = userId;
        this.description = description;
    }
    
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
    
    public String getRoomNumber() {
        return roomNumber;
    }
    
    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }
    
    // Helper methods
    public String getTypeDisplayName() {
        if (type == null) return "";
        switch (type) {
            case "LOGIN": return "User Login";
            case "LOGOUT": return "User Logout";
            case "RESERVATION_CREATE": return "Reservation Created";
            case "RESERVATION_UPDATE": return "Reservation Updated";
            case "RESERVATION_CANCEL": return "Reservation Cancelled";
            case "PAYMENT_RECEIVE": return "Payment Received";
            case "PAYMENT_REFUND": return "Payment Refunded";
            case "CHECKIN": return "Guest Check-in";
            case "CHECKOUT": return "Guest Check-out";
            case "ROOM_CLEAN": return "Room Cleaned";
            case "ROOM_INSPECT": return "Room Inspected";
            case "SERVICE_ADDED": return "Service Added";
            case "SERVICE_COMPLETED": return "Service Completed";
            default: return type;
        }
    }
    
    public String getTypeIcon() {
        if (type == null) return "fa-circle";
        switch (type) {
            case "LOGIN": return "fa-sign-in-alt";
            case "LOGOUT": return "fa-sign-out-alt";
            case "RESERVATION_CREATE": return "fa-calendar-plus";
            case "RESERVATION_UPDATE": return "fa-calendar-alt";
            case "RESERVATION_CANCEL": return "fa-calendar-times";
            case "PAYMENT_RECEIVE": return "fa-dollar-sign text-success";
            case "PAYMENT_REFUND": return "fa-undo text-warning";
            case "CHECKIN": return "fa-door-open text-primary";
            case "CHECKOUT": return "fa-door-closed text-info";
            case "ROOM_CLEAN": return "fa-broom text-success";
            case "ROOM_INSPECT": return "fa-clipboard-check";
            case "SERVICE_ADDED": return "fa-concierge-bell";
            case "SERVICE_COMPLETED": return "fa-check-circle text-success";
            default: return "fa-circle";
        }
    }
    
    public String getTypeBadgeClass() {
        if (type == null) return "badge-secondary";
        if (type.startsWith("PAYMENT")) return "badge-success";
        if (type.startsWith("RESERVATION")) return "badge-primary";
        if (type.startsWith("ROOM")) return "badge-info";
        if (type.startsWith("SERVICE")) return "badge-warning";
        return "badge-secondary";
    }
}