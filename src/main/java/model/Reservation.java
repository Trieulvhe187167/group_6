package model;

import java.sql.Date;
import java.sql.Timestamp;

public class Reservation {
    // Core fields
    private int id;
    private int userId;
    private Integer groupBookingId;
    private Integer createdBy;
    private Integer roomId;  // Changed to Integer to allow null when room not assigned
    private Integer roomTypeId; // Store the requested room type
    private Date checkIn;
    private Date checkOut;
    private String status;
    private Double totalAmount;
    private String notes;
    private String specialRequests;
    private int numberOfCustomers;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private String userFullName;
    private String userEmail;

    private String roomName;    
    
    // Additional fields for display purposes
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private String roomNumber;
    private String roomTypeName;
    private String createdByName;
    private int nights;
    private boolean checkedIn;
    private boolean checkedOut;
    private boolean isLate;
    private String paymentStatus;
    private double amountPaid;
    
    // Deposit-related fields
private Double depositAmount;
private Date depositPaidDate;
private String depositStatus; // PENDING, PAID, REFUNDED

// Thêm field basePrice
private double basePrice;

    // Constructors
    public Reservation() {}
    
    public Reservation(int userId, Integer roomId, Date checkIn, Date checkOut, String status, Double totalAmount) {
        this.userId = userId;
        this.roomId = roomId;
        this.checkIn = checkIn;
        this.checkOut = checkOut;
        this.status = status;
        this.totalAmount = totalAmount;
    }
    
    // Constructor for reservations without room assignment
    public Reservation(int userId, int roomTypeId, Date checkIn, Date checkOut, String status, Double totalAmount) {
        this.userId = userId;
        this.roomTypeId = roomTypeId;
        this.roomId = null; // No room assigned yet
        this.checkIn = checkIn;
        this.checkOut = checkOut;
        this.status = status;
        this.totalAmount = totalAmount;
    }
    
    // Getters and Setters
    public String getUserFullName() {
    return userFullName;
}

public void setUserFullName(String userFullName) {
    this.userFullName = userFullName;
}

public String getUserEmail() {
    return userEmail;
}

public void setUserEmail(String userEmail) {
    this.userEmail = userEmail;
}

public String getRoomNumber() {
    return roomNumber;
}

public void setRoomNumber(String roomNumber) {
    this.roomNumber = roomNumber;
}

public String getRoomName() {
    return roomName;
}

public void setRoomName(String roomName) {
    this.roomName = roomName;
}

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
    
    public Integer getRoomId() {
        return roomId;
    }
    
    public void setRoomId(Integer roomId) {
        this.roomId = roomId;
    }
    
    public Integer getRoomTypeId() {
        return roomTypeId;
    }
    
    public void setRoomTypeId(Integer roomTypeId) {
        this.roomTypeId = roomTypeId;
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
    
    public Double getTotalAmount() {
        return totalAmount;
    }
    
    public void setTotalAmount(Double totalAmount) {
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
    
    public int getNumberOfCustomers() {
        return numberOfCustomers;
    }
    
    public void setNumberOfCustomers(int numberOfCustomers) {
        this.numberOfCustomers = numberOfCustomers;
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
    
    // Additional display fields
    public String getCustomerName() {
        return customerName;
    }
    
    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }
    
    public String getCustomerEmail() {
        return customerEmail;
    }
    
    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
    }
    
    public String getCustomerPhone() {
        return customerPhone;
    }
    
    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
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
    // Getters and Setters for deposit fields
public Double getDepositAmount() {
    return depositAmount;
}

public void setDepositAmount(Double depositAmount) {
    this.depositAmount = depositAmount;
}

public Date getDepositPaidDate() {
    return depositPaidDate;
}

public void setDepositPaidDate(Date depositPaidDate) {
    this.depositPaidDate = depositPaidDate;
}

public String getDepositStatus() {
    return depositStatus;
}

public void setDepositStatus(String depositStatus) {
    this.depositStatus = depositStatus;
}

// Helper methods for deposit
public boolean hasDepositPaid() {
    return "PAID".equals(depositStatus) && depositAmount != null && depositAmount > 0;
}

public boolean isDepositRefunded() {
    return "REFUNDED".equals(depositStatus);
}

public double getRemainingBalance() {
    if (totalAmount == null) return 0;
    if (depositAmount == null) return totalAmount;
    return totalAmount - depositAmount;
}

public double getDepositPercentage() {
    if (totalAmount == null || totalAmount == 0) return 0;
    if (depositAmount == null) return 0;
    return (depositAmount / totalAmount) * 100;
}

// Getters and Setters for basePrice
public double getBasePrice() {
    return basePrice;
}

public void setBasePrice(double basePrice) {
    this.basePrice = basePrice;
}

    // Helper methods
    public String getStatusDisplayName() {
        if (status == null) return "";
        switch (status.toUpperCase()) {
            case "PENDING": return "Pending";
            case "CONFIRMED": return "Confirmed";
            case "CANCELLED": return "Cancelled";
            case "COMPLETED": return "Completed";
            case "CHECKED_IN": return "Checked In";
            case "CHECKED_OUT": return "Checked Out";
            case "NO_SHOW": return "No Show";
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
            case "CHECKED_IN": return "badge-primary";
            case "CHECKED_OUT": return "badge-secondary";
            case "NO_SHOW": return "badge-dark";
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
    
    public boolean isCheckedInStatus() {
        return "CHECKED_IN".equalsIgnoreCase(status);
    }
    
    public boolean isCheckedOutStatus() {
        return "CHECKED_OUT".equalsIgnoreCase(status);
    }
    
    public boolean isNoShow() {
        return "NO_SHOW".equalsIgnoreCase(status);
    }
    
    // Check if room is assigned
    public boolean hasRoomAssigned() {
        return roomId != null && roomId > 0;
    }
    
    // Check if reservation needs room assignment
    public boolean needsRoomAssignment() {
        return !hasRoomAssigned() && (isPending() || isConfirmed());
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
    
    // Check if check-in date is today
    public boolean isCheckInToday() {
        if (checkIn == null) return false;
        Date today = new Date(System.currentTimeMillis());
        return checkIn.equals(today);
    }
    
    // Check if check-out date is today
    public boolean isCheckOutToday() {
        if (checkOut == null) return false;
        Date today = new Date(System.currentTimeMillis());
        return checkOut.equals(today);
    }
    
    // Get a display string for room info
    public String getRoomDisplay() {
        if (hasRoomAssigned()) {
            return roomNumber != null ? roomNumber : "Room #" + roomId;
        } else {
            return "Not Assigned";
        }
    }
    
    // Get formatted total amount
    public String getFormattedTotalAmount() {
        return String.format("%,.0f VND", totalAmount);
    }
    
    @Override
    public String toString() {
        return "Reservation{" +
                "id=" + id +
                ", userId=" + userId +
                ", roomId=" + roomId +
                ", roomTypeId=" + roomTypeId +
                ", checkIn=" + checkIn +
                ", checkOut=" + checkOut +
                ", status='" + status + '\'' +
                ", totalAmount=" + totalAmount +
                ", customerName='" + customerName + '\'' +
                ", roomNumber='" + roomNumber + '\'' +
                ", roomTypeName='" + roomTypeName + '\'' +
                ", numberOfCustomers=" + numberOfCustomers +
                ", nights=" + nights +
                '}';
    }
}

   

