package model;


import java.sql.Timestamp;
import java.util.Date;

public class CheckInDetail {
    private int id;
    private int reservationId;
    private String idType;
    private String idNumber;
    private int additionalGuests;
    private String specialRequests;
    private double securityDeposit;
    private int keyCards;
    private String keyCardNumbers;
    private String checkInNotes;
    private Timestamp checkInTime;
    private Date estimatedCheckOutTime;
    private int checkInBy;
    
    // Additional fields for display
    private String checkInByName;
    
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
    
    public Timestamp getCheckInTime() {
        return checkInTime;
    }
    
    public void setCheckInTime(Timestamp checkInTime) {
        this.checkInTime = checkInTime;
    }
    
    public int getCheckInBy() {
        return checkInBy;
    }
    
    public void setCheckInBy(int checkInBy) {
        this.checkInBy = checkInBy;
    }
    
    public String getCheckInByName() {
        return checkInByName;
    }
    
    public void setCheckInByName(String checkInByName) {
        this.checkInByName = checkInByName;
    }
    
    public Date getEstimatedCheckOutTime() {
        return estimatedCheckOutTime;
    }
    
    public void setEstimatedCheckOutTime(Date estimatedCheckOutTime) {
        this.estimatedCheckOutTime = estimatedCheckOutTime;
    }
}