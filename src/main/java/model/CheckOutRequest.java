package model;

import java.util.List;

public class CheckOutRequest {
    private int reservationId;
    private String roomCondition;
    private String damageDescription;
    private double damageCharges;
    private List<AmenityUsage> amenitiesUsage;
    private String paymentMethod;
    private String checkOutNotes;
    
    // Getters and setters
    public int getReservationId() { return reservationId; }
    public void setReservationId(int reservationId) { this.reservationId = reservationId; }
    
    public String getRoomCondition() { return roomCondition; }
    public void setRoomCondition(String roomCondition) { this.roomCondition = roomCondition; }
    
    public String getDamageDescription() { return damageDescription; }
    public void setDamageDescription(String damageDescription) { this.damageDescription = damageDescription; }
    
    public double getDamageCharges() { return damageCharges; }
    public void setDamageCharges(double damageCharges) { this.damageCharges = damageCharges; }
    
    public List<AmenityUsage> getAmenitiesUsage() { return amenitiesUsage; }
    public void setAmenitiesUsage(List<AmenityUsage> amenitiesUsage) { this.amenitiesUsage = amenitiesUsage; }
    
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    
    public String getCheckOutNotes() { return checkOutNotes; }
    public void setCheckOutNotes(String checkOutNotes) { this.checkOutNotes = checkOutNotes; }
} 