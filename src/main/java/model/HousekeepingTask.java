/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author admin
 */
public class HousekeepingTask {
    String roomNum;//RoomsId
    String status;//Housekeepingtask
    String Notes;//Housekeepingtask
    String UserName;//users   

    public HousekeepingTask(String roomNum, String status, String Notes, String UserName) {
        this.roomNum = roomNum;
        this.status = status;
        this.Notes = Notes;
        this.UserName = UserName;
    }
    
    
    
    public HousekeepingTask() {
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

    public String getUserName() {
        return UserName;
    }

    public void setUserName(String UserName) {
        this.UserName = UserName;
    }

    
}
