package model;

import java.util.Date;
import java.util.List;

/**
 * Model for check-in request data from client
 */
public class CheckInRequest {
    private int reservationId;
    private String idType;
    private String idNumber;
    private int additionalGuests;
    private double securityDeposit;
    private int keyCards;
    private String keyCardNumbers;
    private String checkInNotes;
    private String specialRequests;
    private Date estimatedCheckOutTime;
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
    
    public String getSpecialRequests() {
        return specialRequests;
    }
    
    public void setSpecialRequests(String specialRequests) {
        this.specialRequests = specialRequests;
    }
    
    public Date getEstimatedCheckOutTime() {
        return estimatedCheckOutTime;
    }
    
    public void setEstimatedCheckOutTime(Date estimatedCheckOutTime) {
        this.estimatedCheckOutTime = estimatedCheckOutTime;
    }
    
    public List<AmenityCheck> getAmenities() { 
        return amenities; 
    }
    
    public void setAmenities(List<AmenityCheck> amenities) { 
        this.amenities = amenities; 
    }
} 