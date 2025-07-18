/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;
import java.util.Date;

/**
 *
 * @author ASUS
 */
public class RoomAmenityDTO {

    private int id;
    private int roomId;
    private String roomNumber;
    private String name;
    private String description;
    private boolean isChargeable;
    private BigDecimal unitPrice;
    private Date createdAt;
    private String formAction;

    public RoomAmenityDTO() {
    }

    public RoomAmenityDTO(int id, int roomId, String roomNumber, String name, String description, boolean isChargeable, BigDecimal unitPrice, Date createdAt) {
        this.id = id;
        this.roomId = roomId;
        this.roomNumber = roomNumber;
        this.name = name;
        this.description = description;
        this.isChargeable = isChargeable;
        this.unitPrice = unitPrice;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isIsChargeable() {
        return isChargeable;
    }

    public boolean getIsChargeable() {
        return isChargeable;
    }

    public void setIsChargeable(boolean isChargeable) {
        this.isChargeable = isChargeable;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public String getFormAction() {
        return formAction;
    }

    public void setFormAction(String formAction) {
        this.formAction = formAction;
    }

    
}
