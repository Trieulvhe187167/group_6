package model;

import java.util.Date;

/**
 * Data Transfer Object for check-in information displayed on calendar
 */
public class CheckInCalendarDTO {
    private int id;
    private int reservationId;
    private int roomId;
    private String roomNumber;
    private String customerName;
    private String idType;
    private String idNumber;
    private Date checkInTime;
    private Date estimatedCheckOutTime;

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

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
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

    public Date getCheckInTime() {
        return checkInTime;
    }

    public void setCheckInTime(Date checkInTime) {
        this.checkInTime = checkInTime;
    }

    public Date getEstimatedCheckOutTime() {
        return estimatedCheckOutTime;
    }

    public void setEstimatedCheckOutTime(Date estimatedCheckOutTime) {
        this.estimatedCheckOutTime = estimatedCheckOutTime;
    }
    
    // Helper methods for calculating hours for display
    public int getCheckInHour() {
        if (checkInTime == null) return 0;
       return checkInTime.toInstant()
                .atZone(java.time.ZoneId.systemDefault())
                .getHour();
    }
    
    public int getCheckOutHour() {
            if (estimatedCheckOutTime == null) return 13; // default end of required check-out window
        return estimatedCheckOutTime.toInstant()
                .atZone(java.time.ZoneId.systemDefault())
                .getHour();
    }
} 