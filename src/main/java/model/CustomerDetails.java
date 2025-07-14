package model;


import java.util.Date;

public class CustomerDetails {
    private int id;
    private int userId;
    private String idType;
    private String idNumber;
    private Date dateOfBirth;
    private String gender;
    private String address;
    private String city;
    private String country;
    private int loyaltyPoints;
    private String membershipLevel;
    private boolean isVIP;
    private Date createdAt;
    private Date updatedAt;
    
    // Constructors
    public CustomerDetails() {
        this.loyaltyPoints = 0;
        this.membershipLevel = "BRONZE";
        this.isVIP = false;
        this.createdAt = new Date();
        this.updatedAt = new Date();
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public String getIdType() { return idType; }
    public void setIdType(String idType) { this.idType = idType; }
    
    public String getIdNumber() { return idNumber; }
    public void setIdNumber(String idNumber) { this.idNumber = idNumber; }
    
    public Date getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(Date dateOfBirth) { this.dateOfBirth = dateOfBirth; }
    
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
    
    public int getLoyaltyPoints() { return loyaltyPoints; }
    public void setLoyaltyPoints(int loyaltyPoints) { this.loyaltyPoints = loyaltyPoints; }
    
    public String getMembershipLevel() { return membershipLevel; }
    public void setMembershipLevel(String membershipLevel) { this.membershipLevel = membershipLevel; }
    
    public boolean isVIP() { return isVIP; }
    public void setVIP(boolean VIP) { isVIP = VIP; }
    
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    
    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
}