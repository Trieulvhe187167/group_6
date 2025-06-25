package model;

import java.sql.Timestamp;

public class Payment {
    private int id;
    private int reservationId;
    private double amount;
    private String method;
    private String status;
    private String transactionId;
    private Timestamp createdAt;
    
    // Additional fields for display
    private String customerName;
    private String roomNumber;
    private String reservationStatus;
    
    // Constructors
    public Payment() {}
    
    public Payment(int reservationId, double amount, String method, String status) {
        this.reservationId = reservationId;
        this.amount = amount;
        this.method = method;
        this.status = status;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getReservationId() {
        return reservationId;
    }
    
    public void setReservationId(int reservationId) {
        this.reservationId = reservationId;
    }
    
    public double getAmount() {
        return amount;
    }
    
    public void setAmount(double amount) {
        this.amount = amount;
    }
    
    public String getMethod() {
        return method;
    }
    
    public void setMethod(String method) {
        this.method = method;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getTransactionId() {
        return transactionId;
    }
    
    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public String getCustomerName() {
        return customerName;
    }
    
    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }
    
    public String getRoomNumber() {
        return roomNumber;
    }
    
    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }
    
    public String getReservationStatus() {
        return reservationStatus;
    }
    
    public void setReservationStatus(String reservationStatus) {
        this.reservationStatus = reservationStatus;
    }
    
    // Helper methods
    public String getMethodDisplayName() {
        if (method == null) return "";
        switch (method) {
            case "CREDIT_CARD": return "Credit Card";
            case "BANK_TRANSFER": return "Bank Transfer";
            case "CASH": return "Cash";
            case "VNPay": return "VNPay";
            case "MoMo": return "MoMo";
            default: return method;
        }
    }
    
    public String getStatusBadgeClass() {
        if (status == null) return "badge-secondary";
        switch (status) {
            case "SUCCESS": return "badge-success";
            case "PENDING": return "badge-warning";
            case "FAILED": return "badge-danger";
            default: return "badge-secondary";
        }
    }
    
    public boolean isSuccess() {
        return "SUCCESS".equals(status);
    }
    
    public boolean isPending() {
        return "PENDING".equals(status);
    }
    
    public boolean isFailed() {
        return "FAILED".equals(status);
    }
}