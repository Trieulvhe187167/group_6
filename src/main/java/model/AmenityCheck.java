package model;

/**
 * Model for amenity check item during check-in
 */
public class AmenityCheck {
    private int amenityId;
    private boolean present;
    
    public int getAmenityId() { 
        return amenityId; 
    }
    
    public void setAmenityId(int amenityId) { 
        this.amenityId = amenityId; 
    }
    
    public boolean isPresent() { 
        return present; 
    }
    
    public void setPresent(boolean present) { 
        this.present = present; 
    }
} 