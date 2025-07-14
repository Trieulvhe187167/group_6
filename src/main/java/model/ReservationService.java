package model;

import java.sql.Timestamp;

/**
 * Model class for services ordered with a reservation
 */
public class ReservationService {
    private int id;
    private int reservationId;
    private int serviceId;
    private int quantity;
    private double unitPrice;
    private double totalPrice;
    private String status;
    private String notes;
    private int createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Additional fields for display
    private String serviceName;
    private String serviceCategory;
    
  
     
    public ReservationService() {
        this.quantity = 1;
        this.status = "PENDING";
    }
    
    public ReservationService(int reservationId, int serviceId, int quantity) {
        this();
        this.reservationId = reservationId;
        this.serviceId = serviceId;
        this.quantity = quantity;
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
    
    public int getServiceId() {
        return serviceId;
    }
    
    public void setServiceId(int serviceId) {
        this.serviceId = serviceId;
    }
    
    public int getQuantity() {
        return quantity;
    }
    
    public void setQuantity(int quantity) {
        this.quantity = quantity;
        calculateTotalPrice();
    }
    
    public double getUnitPrice() {
        return unitPrice;
    }
    
    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
        calculateTotalPrice();
    }
    
    public double getTotalPrice() {
        return totalPrice;
    }
    
    public void setTotalPrice(double totalPrice) {
        this.totalPrice = totalPrice;
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
    
    public int getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(int createdBy) {
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
    
    public String getServiceName() {
        return serviceName;
    }
    
    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }
    
    public String getServiceCategory() {
        return serviceCategory;
    }
    
    public void setServiceCategory(String serviceCategory) {
        this.serviceCategory = serviceCategory;
    }
    
    // Helper methods
    private void calculateTotalPrice() {
        this.totalPrice = this.unitPrice * this.quantity;
    }
    
    public String getStatusDisplayName() {
        if (status == null) return "";
        switch (status) {
            case "PENDING": return "Pending";
            case "CONFIRMED": return "Confirmed";
            case "DELIVERED": return "Delivered";
            case "CANCELLED": return "Cancelled";
            default: return status;
        }
    }
    
    public String getStatusBadgeClass() {
        if (status == null) return "badge-secondary";
        switch (status) {
            case "PENDING": return "badge-warning";
            case "CONFIRMED": return "badge-info";
            case "DELIVERED": return "badge-success";
            case "CANCELLED": return "badge-danger";
            default: return "badge-secondary";
        }
    }
    
    @Override
    public String toString() {
        return "ReservationService{" +
                "id=" + id +
                ", reservationId=" + reservationId +
                ", serviceId=" + serviceId +
                ", serviceName='" + serviceName + '\'' +
                ", quantity=" + quantity +
                ", unitPrice=" + unitPrice +
                ", totalPrice=" + totalPrice +
                ", status='" + status + '\'' +
                '}';
    }
}