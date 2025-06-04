/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Timestamp;

/**
 *
 * @author admin
 */
public class HousekeepingTask {
    int id;
    String roomNum;//RoomsId
    String status;//Housekeepingtask
    String Notes;//Housekeepingtask
    String AssignedcToID;//users
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public HousekeepingTask() {
    }

    public HousekeepingTask(int id, String roomNum, String status, String Notes, String AssignedcToID, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.roomNum = roomNum;
        this.status = status;
        this.Notes = Notes;
        this.AssignedcToID = AssignedcToID;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    
    public String getRoomNum() {
        return roomNum;
    }

    public void setRoomNum(String roomNum) {
        this.roomNum = roomNum;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNotes() {
        return Notes;
    }

    public void setNotes(String Notes) {
        this.Notes = Notes;
    }

    public String getAssignedcToID() {
        return AssignedcToID;
    }

    public void setAssignedcToID(String AssignedcToID) {
        this.AssignedcToID = AssignedcToID;
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
    
}
