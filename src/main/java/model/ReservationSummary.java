package model;

import java.sql.Date;
import java.sql.Timestamp;

public class ReservationSummary {
    private int id;
    private String customerName;
    private String customerPhone;
    private String customerEmail;
    private String roomNumber;
    private String roomTypeName;
    private Date checkIn;
    private Date checkOut;
    private Timestamp checkInTime;
    private Timestamp checkOutTime;
    private String status;
    private double totalAmount;
    private Timestamp createdAt;
    private String specialRequests;
    private int numberOfCustomers;
    private boolean checkedIn;
    private boolean checkedOut;
    private boolean late;
    private String paymentStatus;
    private int roomId;
    private String inspectionStatus;
    private double additionalCharges;
    
    // Payment-related fields
    private double amountPaid;
    private double balance;
    private boolean depositPaid;
    
    // Constructors
    public ReservationSummary() {}
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getCustomerName() {
        return customerName;
    }
    
    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }
    
    public String getCustomerPhone() {
        return customerPhone;
    }
    
    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }
    
    public String getCustomerEmail() {
        return customerEmail;
    }
    
    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
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
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
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
        return late;
    }
    
    public void setLate(boolean late) {
        this.late = late;
    }
    
    public String getPaymentStatus() {
        return paymentStatus;
    }
    
    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }
    
    public int getRoomId() {
        return roomId;
    }
    
    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }
    
    // Calculate number of nights between check-in and check-out
    public int getNights() {
        if (checkIn != null && checkOut != null) {
            return (int) ((checkOut.getTime() - checkIn.getTime()) / (1000 * 60 * 60 * 24));
        }
        return 0;
    }
    
    // Alias for getCheckIn() to maintain consistency
    public Date getCheckInDate() {
        return checkIn;
    }
    public void setInspectionStatus(String inspectionStatus) {
        this.inspectionStatus = inspectionStatus;
    }
    
    public double getAdditionalCharges() {
        return additionalCharges;
    }
    
    public void setAdditionalCharges(double additionalCharges) {
        this.additionalCharges = additionalCharges;
    }
    
    // Payment-related getters and setters
    public double getAmountPaid() {
        return amountPaid;
    }
    
    public void setAmountPaid(double amountPaid) {
        this.amountPaid = amountPaid;
    }
    
    public double getBalance() {
        return balance;
    }
    
    public void setBalance(double balance) {
        this.balance = balance;
    }
    
    public boolean isDepositPaid() {
        return depositPaid;
    }
    
    public void setDepositPaid(boolean depositPaid) {
        this.depositPaid = depositPaid;
    }
    
    // Utility methods
    public boolean canCheckOut() {
        return checkedIn && !checkedOut && 
               ("APPROVED".equals(inspectionStatus) || "COMPLETED".equals(inspectionStatus));
    }
    
    public boolean needsInspection() {
        return checkedIn && !checkedOut && 
               (inspectionStatus == null || "PENDING".equals(inspectionStatus));
    }

        public boolean getIsLate() {
        return isLate();
        }

    // New getters and setters for time fields
    public Timestamp getCheckInTime() {
        return checkInTime;
    }
    
    public void setCheckInTime(Timestamp checkInTime) {
        this.checkInTime = checkInTime;
    }
    
    public Timestamp getCheckOutTime() {
        return checkOutTime;
    }
    
    public void setCheckOutTime(Timestamp checkOutTime) {
        this.checkOutTime = checkOutTime;
    }
    
    // Format check-in hour for display
    public int getCheckInHour() {
        if (checkInTime != null) {
            return new java.util.Date(checkInTime.getTime()).getHours();
        }
        return 12; // Default check-in time if not specified
    }
    
    // Format check-out hour for display
    public int getCheckOutHour() {
        if (checkOutTime != null) {
            return new java.util.Date(checkOutTime.getTime()).getHours();
        }
        return 12; // Default check-out time if not specified

    }
}
