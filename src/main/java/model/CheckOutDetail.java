package model;

import java.sql.Date;

public class CheckOutDetail {
    private int id;
    private int reservationId;
    private String roomNumber;
    private String customerName;
    private Date checkIn;
    private Date checkOut;
    private int roomId;
    private int nights;
    private double roomCharges;
    private double serviceCharges;
    private double amountPaid;
    private double securityDeposit;
    private String roomCondition;
    private String damageDescription;
    private double damageCharges;
    private double amenityCharges;
    private double finalAmount;
    private double refundAmount;
    private String paymentMethod;
    private String checkOutNotes;
    private int checkOutBy;
    
    // Getters and setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getReservationId() { return reservationId; }
    public void setReservationId(int reservationId) { this.reservationId = reservationId; }
    
    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    
    public Date getCheckIn() { return checkIn; }
    public void setCheckIn(Date checkIn) { this.checkIn = checkIn; }
    
    public Date getCheckOut() { return checkOut; }
    public void setCheckOut(Date checkOut) { this.checkOut = checkOut; }
    
    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }
    
    public int getNights() { return nights; }
    public void setNights(int nights) { this.nights = nights; }
    
    public double getRoomCharges() { return roomCharges; }
    public void setRoomCharges(double roomCharges) { this.roomCharges = roomCharges; }
    
    public double getServiceCharges() { return serviceCharges; }
    public void setServiceCharges(double serviceCharges) { this.serviceCharges = serviceCharges; }
    
    public double getAmountPaid() { return amountPaid; }
    public void setAmountPaid(double amountPaid) { this.amountPaid = amountPaid; }
    
    public double getSecurityDeposit() { return securityDeposit; }
    public void setSecurityDeposit(double securityDeposit) { this.securityDeposit = securityDeposit; }
    
    public String getRoomCondition() { return roomCondition; }
    public void setRoomCondition(String roomCondition) { this.roomCondition = roomCondition; }
    
    public String getDamageDescription() { return damageDescription; }
    public void setDamageDescription(String damageDescription) { this.damageDescription = damageDescription; }
    
    public double getDamageCharges() { return damageCharges; }
    public void setDamageCharges(double damageCharges) { this.damageCharges = damageCharges; }
    
    public double getAmenityCharges() { return amenityCharges; }
    public void setAmenityCharges(double amenityCharges) { this.amenityCharges = amenityCharges; }
    
    public double getFinalAmount() { return finalAmount; }
    public void setFinalAmount(double finalAmount) { this.finalAmount = finalAmount; }
    
    public double getRefundAmount() { return refundAmount; }
    public void setRefundAmount(double refundAmount) { this.refundAmount = refundAmount; }
    
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    
    public String getCheckOutNotes() { return checkOutNotes; }
    public void setCheckOutNotes(String checkOutNotes) { this.checkOutNotes = checkOutNotes; }
    
    public int getCheckOutBy() { return checkOutBy; }
    public void setCheckOutBy(int checkOutBy) { this.checkOutBy = checkOutBy; }
}