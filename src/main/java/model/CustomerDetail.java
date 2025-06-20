package model;

import java.sql.Date;
import java.util.List;
import java.util.ArrayList;

/**
 * Helper class for customer details used in CustomersServlet
 * Contains detailed information about a customer including booking history and statistics
 */
public class CustomerDetail {
    private String fullName;
    private String email;
    private String phone;
    private Date createdAt;
    private Date lastVisit;
    private int totalStays;
    private double avgNights;
    private double totalSpent;
    private String loyaltyStatus;
    private String notes;
    private List<ReservationSummary> bookingHistory;
    
    // Default constructor
    public CustomerDetail() {
        this.bookingHistory = new ArrayList<>();
        this.totalStays = 0;
        this.avgNights = 0.0;
        this.totalSpent = 0.0;
        this.loyaltyStatus = "Bronze";
    }
    
    // Constructor with basic info
    public CustomerDetail(String fullName, String email, String phone) {
        this();
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
    }
    
    // Getters and setters
    public String getFullName() { 
        return fullName; 
    }
    
    public void setFullName(String fullName) { 
        this.fullName = fullName; 
    }
    
    public String getEmail() { 
        return email; 
    }
    
    public void setEmail(String email) { 
        this.email = email; 
    }
    
    public String getPhone() { 
        return phone; 
    }
    
    public void setPhone(String phone) { 
        this.phone = phone; 
    }
    
    public Date getCreatedAt() { 
        return createdAt; 
    }
    
    public void setCreatedAt(Date createdAt) { 
        this.createdAt = createdAt; 
    }
    
    public Date getLastVisit() { 
        return lastVisit; 
    }
    
    public void setLastVisit(Date lastVisit) { 
        this.lastVisit = lastVisit; 
    }
    
    public int getTotalStays() { 
        return totalStays; 
    }
    
    public void setTotalStays(int totalStays) { 
        this.totalStays = totalStays; 
    }
    
    public double getAvgNights() { 
        return avgNights; 
    }
    
    public void setAvgNights(double avgNights) { 
        this.avgNights = avgNights; 
    }
    
    public double getTotalSpent() { 
        return totalSpent; 
    }
    
    public void setTotalSpent(double totalSpent) { 
        this.totalSpent = totalSpent; 
    }
    
    public String getLoyaltyStatus() { 
        return loyaltyStatus; 
    }
    
    public void setLoyaltyStatus(String loyaltyStatus) { 
        this.loyaltyStatus = loyaltyStatus; 
    }
    
    public String getNotes() { 
        return notes; 
    }
    
    public void setNotes(String notes) { 
        this.notes = notes; 
    }
    
    public List<ReservationSummary> getBookingHistory() { 
        if (bookingHistory == null) {
            bookingHistory = new ArrayList<>();
        }
        return bookingHistory; 
    }
    
    public void setBookingHistory(List<ReservationSummary> bookingHistory) { 
        this.bookingHistory = bookingHistory != null ? bookingHistory : new ArrayList<>(); 
    }
    
    // Helper method to add a booking to history
    public void addBooking(ReservationSummary booking) {
        if (this.bookingHistory == null) {
            this.bookingHistory = new ArrayList<>();
        }
        this.bookingHistory.add(booking);
    }
    
    // Helper method to get loyalty status badge class for UI
    public String getLoyaltyBadgeClass() {
        if (loyaltyStatus == null) return "badge-secondary";
        switch (loyaltyStatus.toLowerCase()) {
            case "vip": return "badge-danger";
            case "gold": return "badge-warning";
            case "silver": return "badge-info";
            case "bronze": return "badge-secondary";
            default: return "badge-secondary";
        }
    }
    
    // Helper method to check if customer is VIP
    public boolean isVIP() {
        return "VIP".equalsIgnoreCase(loyaltyStatus);
    }
    
    // Helper method to format average nights for display
    public String getFormattedAvgNights() {
        return String.format("%.1f", avgNights);
    }
    
    // Helper method to get booking count
    public int getBookingCount() {
        return bookingHistory != null ? bookingHistory.size() : 0;
    }
    
    @Override
    public String toString() {
        return "CustomerDetail{" +
                "fullName='" + fullName + '\'' +
                ", email='" + email + '\'' +
                ", phone='" + phone + '\'' +
                ", createdAt=" + createdAt +
                ", lastVisit=" + lastVisit +
                ", totalStays=" + totalStays +
                ", avgNights=" + avgNights +
                ", totalSpent=" + totalSpent +
                ", loyaltyStatus='" + loyaltyStatus + '\'' +
                ", bookingHistorySize=" + (bookingHistory != null ? bookingHistory.size() : 0) +
                '}';
    }
}