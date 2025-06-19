package model;


import java.sql.Timestamp;

public class AmenityUsageLog {
    private int id;
    private int reservationId;
    private int amenityId;
    private String amenityName;
    private String category;
    private int quantity;
    private double unitPrice;
    private double totalPrice;
    private Timestamp usageDate;
    private int recordedBy;
    private String recordedByName;
    private String roomNumber;
    private String guestName;
    private boolean isChargeable;
    
    // Constructors
    public AmenityUsageLog() {}
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getReservationId() { return reservationId; }
    public void setReservationId(int reservationId) { this.reservationId = reservationId; }
    
    public int getAmenityId() { return amenityId; }
    public void setAmenityId(int amenityId) { this.amenityId = amenityId; }
    
    public String getAmenityName() { return amenityName; }
    public void setAmenityName(String amenityName) { this.amenityName = amenityName; }
    
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    
    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }
    
    public double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(double totalPrice) { this.totalPrice = totalPrice; }
    
    public Timestamp getUsageDate() { return usageDate; }
    public void setUsageDate(Timestamp usageDate) { this.usageDate = usageDate; }
    
    public int getRecordedBy() { return recordedBy; }
    public void setRecordedBy(int recordedBy) { this.recordedBy = recordedBy; }
    
    public String getRecordedByName() { return recordedByName; }
    public void setRecordedByName(String recordedByName) { this.recordedByName = recordedByName; }
    
    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    
    public String getGuestName() { return guestName; }
    public void setGuestName(String guestName) { this.guestName = guestName; }
    
    public boolean getIsChargeable() { return isChargeable; }
    public void setIsChargeable(boolean isChargeable) { this.isChargeable = isChargeable; }
    
    // Convenience getters for JSP
    public Timestamp getCheckedAt() { return usageDate; }
    public String getCheckedByName() { return recordedByName; }
    public int getCheckedBy() { return recordedBy; }
}