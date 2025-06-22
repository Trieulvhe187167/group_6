package model;

import java.sql.Timestamp;

public class Notification {
    private int id;
    private int userId;
    private Integer reservationId;
    private String type;
    private String message;
    private Timestamp sentAt;
    private String status;
    
    // Additional field for display
    private String recipientName;
    
    // Constructors
    public Notification() {}
    
    public Notification(int userId, String type, String message) {
        this.userId = userId;
        this.type = type;
        this.message = message;
        this.status = "SENT";
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public Integer getReservationId() {
        return reservationId;
    }
    
    public void setReservationId(Integer reservationId) {
        this.reservationId = reservationId;
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    public Timestamp getSentAt() {
        return sentAt;
    }
    
    public void setSentAt(Timestamp sentAt) {
        this.sentAt = sentAt;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getRecipientName() {
        return recipientName;
    }
    
    public void setRecipientName(String recipientName) {
        this.recipientName = recipientName;
    }
    
    // Helper methods
    public String getTypeDisplayName() {
        if (type == null) return "";
        switch (type) {
            case "BOOKING_CONFIRM": return "Booking Confirmation";
            case "CHECKIN_REMINDER": return "Check-in Reminder";
            case "CHECKOUT_REMINDER": return "Check-out Reminder";
            case "PAYMENT_CONFIRM": return "Payment Confirmation";
            case "BOOKING_CANCELLED": return "Booking Cancelled";
            case "SPECIAL_OFFER": return "Special Offer";
            default: return type;
        }
    }
    
    public String getTypeIcon() {
        if (type == null) return "fa-bell";
        switch (type) {
            case "BOOKING_CONFIRM": return "fa-check-circle";
            case "CHECKIN_REMINDER": return "fa-calendar-check";
            case "CHECKOUT_REMINDER": return "fa-calendar-times";
            case "PAYMENT_CONFIRM": return "fa-dollar-sign";
            case "BOOKING_CANCELLED": return "fa-times-circle";
            case "SPECIAL_OFFER": return "fa-gift";
            default: return "fa-bell";
        }
    }
    
    public String getStatusBadgeClass() {
        if (status == null) return "badge-secondary";
        switch (status) {
            case "SENT": return "badge-success";
            case "FAILED": return "badge-danger";
            default: return "badge-secondary";
        }
    }
    
    public boolean isSent() {
        return "SENT".equals(status);
    }
    
    public boolean isFailed() {
        return "FAILED".equals(status);
    }
}