/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;


import java.math.BigDecimal;

public class RoomDamage {
    private int id;
    private int inspectionId;
    private String damageType;
    private String description;
    private BigDecimal estimatedCost;
    private String photoUrl;
    private String severity;
    
    // Constructors
    public RoomDamage() {
        this.estimatedCost = BigDecimal.ZERO;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getInspectionId() { return inspectionId; }
    public void setInspectionId(int inspectionId) { this.inspectionId = inspectionId; }
    
    public String getDamageType() { return damageType; }
    public void setDamageType(String damageType) { this.damageType = damageType; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public BigDecimal getEstimatedCost() { return estimatedCost; }
    public void setEstimatedCost(BigDecimal estimatedCost) { this.estimatedCost = estimatedCost; }
    
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    
    public String getSeverity() { return severity; }
    public void setSeverity(String severity) { this.severity = severity; }
}