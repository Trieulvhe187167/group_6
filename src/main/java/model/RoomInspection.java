/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;


import java.util.Date;
import java.math.BigDecimal;
import java.util.List;

public class RoomInspection {
    private int id;
    private int reservationId;
    private int inspectorId;
    private Date inspectionTime;
    private String roomCondition;
    private int cleanlinessScore;
    private String notes;
    private String photoUrls;
    private String status;
    private Integer approvedBy;
    private Date approvedAt;
    
    // Related objects
    private Reservation reservation;
    private User inspector;
    private User approver;
    private List<InspectionItem> inspectionItems;
    private List<RoomDamage> roomDamages;
    
    // Calculated fields
    private BigDecimal totalItemCharges;
    private BigDecimal totalDamageCharges;
    private BigDecimal totalCharges;
    
    // Constructors
    public RoomInspection() {
        this.inspectionTime = new Date();
        this.status = "PENDING";
        this.totalItemCharges = BigDecimal.ZERO;
        this.totalDamageCharges = BigDecimal.ZERO;
        this.totalCharges = BigDecimal.ZERO;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getReservationId() { return reservationId; }
    public void setReservationId(int reservationId) { this.reservationId = reservationId; }
    
    public int getInspectorId() { return inspectorId; }
    public void setInspectorId(int inspectorId) { this.inspectorId = inspectorId; }
    
    public Date getInspectionTime() { return inspectionTime; }
    public void setInspectionTime(Date inspectionTime) { this.inspectionTime = inspectionTime; }
    
    public String getRoomCondition() { return roomCondition; }
    public void setRoomCondition(String roomCondition) { this.roomCondition = roomCondition; }
    
    public int getCleanlinessScore() { return cleanlinessScore; }
    public void setCleanlinessScore(int cleanlinessScore) { this.cleanlinessScore = cleanlinessScore; }
    
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    
    public String getPhotoUrls() { return photoUrls; }
    public void setPhotoUrls(String photoUrls) { this.photoUrls = photoUrls; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public Integer getApprovedBy() { return approvedBy; }
    public void setApprovedBy(Integer approvedBy) { this.approvedBy = approvedBy; }
    
    public Date getApprovedAt() { return approvedAt; }
    public void setApprovedAt(Date approvedAt) { this.approvedAt = approvedAt; }
    
    public Reservation getReservation() { return reservation; }
    public void setReservation(Reservation reservation) { this.reservation = reservation; }
    
    public User getInspector() { return inspector; }
    public void setInspector(User inspector) { this.inspector = inspector; }
    
    public User getApprover() { return approver; }
    public void setApprover(User approver) { this.approver = approver; }
    
    public List<InspectionItem> getInspectionItems() { return inspectionItems; }
    public void setInspectionItems(List<InspectionItem> inspectionItems) { this.inspectionItems = inspectionItems; }
    
    public List<RoomDamage> getRoomDamages() { return roomDamages; }
    public void setRoomDamages(List<RoomDamage> roomDamages) { this.roomDamages = roomDamages; }
    
    public BigDecimal getTotalItemCharges() { return totalItemCharges; }
    public void setTotalItemCharges(BigDecimal totalItemCharges) { this.totalItemCharges = totalItemCharges; }
    
    public BigDecimal getTotalDamageCharges() { return totalDamageCharges; }
    public void setTotalDamageCharges(BigDecimal totalDamageCharges) { this.totalDamageCharges = totalDamageCharges; }
    
    public BigDecimal getTotalCharges() { return totalCharges; }
    public void setTotalCharges(BigDecimal totalCharges) { this.totalCharges = totalCharges; }
}