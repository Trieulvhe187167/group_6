package model;

import java.sql.Date;
import java.sql.Timestamp;

public class Reservation {
    // Core fields
    private int id;
    private int userId;
    private Integer groupBookingId;
    private Integer createdBy;
    private int roomId;
    private Date checkIn;
    private Date checkOut;
    private String status;
    private double totalAmount;
    private String notes;
    private String specialRequests;
    private int numberOfGuests;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Additional fields for display purposes
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private String guestName;
    private String guestEmail;
    private String guestPhone;
    private String roomNumber;
    private String roomTypeName;
    private String createdByName;
    private int nights;
    private boolean checkedIn;
    private boolean checkedOut;
    private boolean isLate;
    private String paymentStatus;
    private double amountPaid;
    
    // Constructors
    public Reservation() {}
    
    public Reservation(int userId, int roomId, Date checkIn, Date checkOut, String status, double totalAmount) {
        this.userId = userId;
        this.roomId = roomId;
        this.checkIn = checkIn;
        this.checkOut = checkOut;
        this.status = status;
        this.totalAmount = totalAmount;
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
    
    public Integer getGroupBookingId() {
        return groupBookingId;
    }
    
    public void setGroupBookingId(Integer groupBookingId) {
        this.groupBookingId = groupBookingId;
    }
    
    public Integer getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }
    
    public int getRoomId() {
        return roomId;
    }
    
    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }
    
    public Date getCheckIn() {
        return checkIn;
    }
    
    public void setCheckIn(Date checkIn) {
        this.checkIn = checkIn;
    }
    
    public Date getCheckOut() {
        return checkOut;
    }
    
    public void setCheckOut(Date checkOut) {
        this.checkOut = checkOut;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public double getTotalAmount() {
        return totalAmount;
    }
    
    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }
    
    public String getNotes() {
        return notes;
    }
    
    public void setNotes(String notes) {
        this.notes = notes;
    }
    
    public String getSpecialRequests() {
        return specialRequests;
    }
    
    public void setSpecialRequests(String specialRequests) {
        this.specialRequests = specialRequests;
    }
    
    public int getNumberOfGuests() {
        return numberOfGuests;
    }
    
    public void setNumberOfGuests(int numberOfGuests) {
        this.numberOfGuests = numberOfGuests;
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
    
    // Customer fields (compatibility with version 1)
    public String getCustomerName() {
        return customerName != null ? customerName : guestName;
    }
    
    public void setCustomerName(String customerName) {
        this.customerName = customerName;
        // Also set guestName for compatibility
        if (this.guestName == null) {
            this.guestName = customerName;
        }
    }
    
    public String getCustomerEmail() {
        return customerEmail != null ? customerEmail : guestEmail;
    }
    
    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
        // Also set guestEmail for compatibility
        if (this.guestEmail == null) {
            this.guestEmail = customerEmail;
        }
    }
    
    public String getCustomerPhone() {
        return customerPhone != null ? customerPhone : guestPhone;
    }
    
    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
        // Also set guestPhone for compatibility
        if (this.guestPhone == null) {
            this.guestPhone = customerPhone;
        }
    }
    
    // Guest fields (compatibility with version 2)
    public String getGuestName() {
        return guestName != null ? guestName : customerName;
    }
    
    public void setGuestName(String guestName) {
        this.guestName = guestName;
        // Also set customerName for compatibility
        if (this.customerName == null) {
            this.customerName = guestName;
        }
    }
    
    public String getGuestEmail() {
        return guestEmail != null ? guestEmail : customerEmail;
    }
    
    public void setGuestEmail(String guestEmail) {
        this.guestEmail = guestEmail;
        // Also set customerEmail for compatibility
        if (this.customerEmail == null) {
            this.customerEmail = guestEmail;
        }
    }
    
    public String getGuestPhone() {
        return guestPhone != null ? guestPhone : customerPhone;
    }
    
    public void setGuestPhone(String guestPhone) {
        this.guestPhone = guestPhone;
        // Also set customerPhone for compatibility
        if (this.customerPhone == null) {
            this.customerPhone = guestPhone;
        }
    }
    
    // Room info
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
    
    public String getCreatedByName() {
        return createdByName;
    }
    
    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }
    
    public int getNights() {
        return nights;
    }
    
    public void setNights(int nights) {
        this.nights = nights;
    }
    
    public boolean isCheckedIn() {
        return checkedIn;
    }
    
    public void setCheckedIn(boolean checkedIn) {
        this.checkedIn = checkedIn;
    }
    
    public boolean isCheckedOut() {
        return checkedOut;
    }
    
    public void setCheckedOut(boolean checkedOut) {
        this.checkedOut = checkedOut;
    }
    
    public boolean isLate() {
        return isLate;
    }
    
    public void setLate(boolean isLate) {
        this.isLate = isLate;
    }
    
    public String getPaymentStatus() {
        return paymentStatus;
    }
    
    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }
    
    public double getAmountPaid() {
        return amountPaid;
    }
    
    public void setAmountPaid(double amountPaid) {
        this.amountPaid = amountPaid;
    }
    
    // Helper methods
    public String getStatusDisplayName() {
        if (status == null) return "";
        switch (status.toUpperCase()) {
            case "PENDING": return "Pending";
            case "CONFIRMED": return "Confirmed";
            case "CANCELLED": return "Cancelled";
            case "COMPLETED": return "Completed";
            default: return status;
        }
    }
    
    public String getStatusBadgeClass() {
        if (status == null) return "badge-secondary";
        switch (status.toUpperCase()) {
            case "PENDING": return "badge-warning";
            case "CONFIRMED": return "badge-success";
            case "CANCELLED": return "badge-danger";
            case "COMPLETED": return "badge-info";
            default: return "badge-secondary";
        }
    }
    
    public boolean isPending() {
        return "PENDING".equalsIgnoreCase(status);
    }
    
    public boolean isConfirmed() {
        return "CONFIRMED".equalsIgnoreCase(status);
    }
    
    public boolean isCancelled() {
        return "CANCELLED".equalsIgnoreCase(status);
    }
    
    public boolean isCompleted() {
        return "COMPLETED".equalsIgnoreCase(status);
    }
    
    // Calculate nights based on check-in and check-out dates
    public int calculateNights() {
        if (checkIn != null && checkOut != null) {
            long diffInMillies = checkOut.getTime() - checkIn.getTime();
            int calculatedNights = (int) (diffInMillies / (1000 * 60 * 60 * 24));
            // Update the nights field
            this.nights = calculatedNights;
            return calculatedNights;
        }
        return 0;
    }
    
    @Override
    public String toString() {
        return "Reservation{" +
                "id=" + id +
                ", userId=" + userId +
                ", roomId=" + roomId +
                ", checkIn=" + checkIn +
                ", checkOut=" + checkOut +
                ", status='" + status + '\'' +
                ", totalAmount=" + totalAmount +
                ", customerName='" + getCustomerName() + '\'' +
                ", roomNumber='" + roomNumber + '\'' +
                ", numberOfGuests=" + numberOfGuests +
                ", nights=" + nights +
                '}';
    }
}