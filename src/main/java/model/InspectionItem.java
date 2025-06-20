/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;
import java.math.BigDecimal;

public class InspectionItem {
    private int id;
    private int inspectionId;
    private String itemName;
    private String itemCategory;
    private int quantity;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;
    private String notes;
    
    // Constructors
    public InspectionItem() {
        this.quantity = 1;
        this.unitPrice = BigDecimal.ZERO;
        this.totalPrice = BigDecimal.ZERO;
    }
    
    // Calculate total price
    public void calculateTotal() {
        this.totalPrice = this.unitPrice.multiply(new BigDecimal(this.quantity));
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getInspectionId() { return inspectionId; }
    public void setInspectionId(int inspectionId) { this.inspectionId = inspectionId; }
    
    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }
    
    public String getItemCategory() { return itemCategory; }
    public void setItemCategory(String itemCategory) { this.itemCategory = itemCategory; }
    
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { 
        this.quantity = quantity;
        calculateTotal();
    }
    
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { 
        this.unitPrice = unitPrice;
        calculateTotal();
    }
    
    public BigDecimal getTotalPrice() { return totalPrice; }
    public void setTotalPrice(BigDecimal totalPrice) { this.totalPrice = totalPrice; }
    
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}