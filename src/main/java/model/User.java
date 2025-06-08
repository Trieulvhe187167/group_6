package model;

import java.sql.Timestamp;

public class User {
    private int id;
    private String username;
    private String password; // Chỉ dùng khi tạo mới hoặc đổi password
    private String fullName;
    private String email;
    private String phone;
    private String role;
    private boolean status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private int totalBookings;
    
    // Constructors
    public User() {}
    
    public User(String username, String password, String fullName, String email, String phone, String role) {
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.role = role;
        this.status = true;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
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
    
    public String getRole() {
        return role;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
    
    public boolean isStatus() {
        return status;
    }
    
    public void setStatus(boolean status) {
        this.status = status;
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
    
    public int getTotalBookings() {
        return totalBookings;
    }
    
    public void setTotalBookings(int totalBookings) {
        this.totalBookings = totalBookings;
    }
    
    // Helper methods
    public String getRoleDisplayName() {
        if (role == null) return "";
        switch (role) {
            case "ADMIN": return "Administrator";
            case "RECEPTIONIST": return "Receptionist";
            case "HOUSEKEEPER": return "Housekeeper";
            case "GUEST": return "Guest";
            case "INACTIVE": return "Inactive";
            default: return role;
        }
    }
    
    public String getRoleBadgeClass() {
        if (role == null) return "badge-secondary";
        switch (role) {
            case "ADMIN": return "badge-danger";
            case "RECEPTIONIST": return "badge-primary";
            case "HOUSEKEEPER": return "badge-info";
            case "GUEST": return "badge-success";
            case "INACTIVE": return "badge-secondary";
            default: return "badge-secondary";
        }
    }
    
    public String getStatusDisplayName() {
        return status ? "Active" : "Inactive";
    }
    
    public String getStatusBadgeClass() {
        return status ? "badge-success" : "badge-secondary";
    }
    
    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", fullName='" + fullName + '\'' +
                ", email='" + email + '\'' +
                ", phone='" + phone + '\'' +
                ", role='" + role + '\'' +
                ", status=" + status +
                ", totalBookings=" + totalBookings +
                '}';
    }
}