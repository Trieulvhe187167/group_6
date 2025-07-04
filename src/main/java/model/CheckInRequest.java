package model;

import java.util.Date;
import java.util.List;
import com.google.gson.annotations.SerializedName;

/**
 * Model for check-in request data from client
 */
public class CheckInRequest {
    private int reservationId;
    private String idType;
    private String idNumber;
    private int additionalGuests;
    private String specialRequests;
    private double securityDeposit;
    private int keyCards;
    private String keyCardNumbers;
    private String checkInNotes;
    private String estimatedCheckOutTime;  // String format from form
    private List<AmenityCheck> amenities;
    
    // Getters and setters
    public int getReservationId() { 
        return reservationId; 
    }
    
    public void setReservationId(int reservationId) { 
        this.reservationId = reservationId; 
    }
    
    public String getIdType() { 
        return idType; 
    }
    
    public void setIdType(String idType) { 
        this.idType = idType; 
    }
    
    public String getIdNumber() { 
        return idNumber; 
    }
    
    public void setIdNumber(String idNumber) { 
        this.idNumber = idNumber; 
    }
    
    public int getAdditionalGuests() { 
        return additionalGuests; 
    }
    
    public void setAdditionalGuests(int additionalGuests) { 
        this.additionalGuests = additionalGuests; 
    }
    
    public String getSpecialRequests() {
        return specialRequests;
    }
    
    public void setSpecialRequests(String specialRequests) {
        this.specialRequests = specialRequests;
    }
    
    public double getSecurityDeposit() { 
        return securityDeposit; 
    }
    
    public void setSecurityDeposit(double securityDeposit) { 
        this.securityDeposit = securityDeposit; 
    }
    
    public int getKeyCards() { 
        return keyCards; 
    }
    
    public void setKeyCards(int keyCards) { 
        this.keyCards = keyCards; 
    }
    
    public String getKeyCardNumbers() { 
        return keyCardNumbers; 
    }
    
    public void setKeyCardNumbers(String keyCardNumbers) { 
        this.keyCardNumbers = keyCardNumbers; 
    }
    
    public String getCheckInNotes() { 
        return checkInNotes; 
    }
    
    public void setCheckInNotes(String checkInNotes) { 
        this.checkInNotes = checkInNotes; 
    }
    
    public Date getEstimatedCheckOutTime() {
        // Convert string to Date if needed
        if (estimatedCheckOutTime != null && !estimatedCheckOutTime.isEmpty()) {
            try {
                // Parse the ISO format datetime string from the form
                // Format: yyyy-MM-ddTHH:mm
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                System.out.println("Parsing datetime: " + estimatedCheckOutTime);
                return sdf.parse(estimatedCheckOutTime);
            } catch (Exception e) {
                System.out.println("Error parsing estimated checkout time: " + e.getMessage());
                e.printStackTrace();
                // Try alternative format
                try {
                    System.out.println("Trying alternative date format...");
                    java.text.SimpleDateFormat sdf2 = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    return sdf2.parse(estimatedCheckOutTime);
                } catch (Exception e2) {
                    e2.printStackTrace();
                    return null;
                }
            }
        }
        return null;
    }
    
    public void setEstimatedCheckOutTime(String estimatedCheckOutTime) {
        this.estimatedCheckOutTime = estimatedCheckOutTime;
    }
    
    public List<AmenityCheck> getAmenities() { 
        return amenities; 
    }
    
    public void setAmenities(List<AmenityCheck> amenities) { 
        this.amenities = amenities; 
    }
    
    @Override
    public String toString() {
        return "CheckInRequest{" +
                "reservationId=" + reservationId +
                ", idType='" + idType + '\'' +
                ", idNumber='" + idNumber + '\'' +
                ", additionalGuests=" + additionalGuests +
                ", specialRequests='" + specialRequests + '\'' +
                ", securityDeposit=" + securityDeposit +
                ", keyCards=" + keyCards +
                ", keyCardNumbers='" + keyCardNumbers + '\'' +
                ", checkInNotes='" + checkInNotes + '\'' +
                ", estimatedCheckOutTime='" + estimatedCheckOutTime + '\'' +
                ", amenities=" + (amenities != null ? amenities.size() : 0) +
                '}';
    }
} 