package model;

import java.sql.Timestamp;
import java.util.Date;

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
    
    // Customer Details (from CustomerDetails table)
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
    
    // Employee Details (from EmployeeDetails table)
    private String department;
    private Date hireDate;
    private double salary;
    
    // Statistics and calculated fields
    private int totalBookings; // For customers: total bookings made, For employees: total bookings created
    private int completedBookings; // Only for customers
    private double totalSpent; // Only for customers
    private Date lastVisit; // Only for customers
    
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
    
    // Basic getters and setters
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
    
    // Customer Details getters and setters
    public String getIdType() {
        return idType;
    }
    
    public void setIdType(String idType) {
        this.idType = idType;
    }
    
    public String getIdNumber() {
        return idNumber;
    }
    
    public void setIdNumber(String idNumber) {
        this.idNumber = idNumber;
    }
    
    public Date getDateOfBirth() {
        return dateOfBirth;
    }
    
    public void setDateOfBirth(Date dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }
    
    public String getGender() {
        return gender;
    }
    
    public void setGender(String gender) {
        this.gender = gender;
    }
    
    public String getAddress() {
        return address;
    }
    
    public void setAddress(String address) {
        this.address = address;
    }
    
    public String getCity() {
        return city;
    }
    
    public void setCity(String city) {
        this.city = city;
    }
    
    public String getCountry() {
        return country;
    }
    
    public void setCountry(String country) {
        this.country = country;
    }
    
    public int getLoyaltyPoints() {
        return loyaltyPoints;
    }
    
    public void setLoyaltyPoints(int loyaltyPoints) {
        this.loyaltyPoints = loyaltyPoints;
    }
    
    public String getMembershipLevel() {
        return membershipLevel;
    }
    
    public void setMembershipLevel(String membershipLevel) {
        this.membershipLevel = membershipLevel;
    }
    
    public boolean getIsVIP() {
        return isVIP;
    }
    
    public void setIsVIP(boolean isVIP) {
        this.isVIP = isVIP;
    }
    
    // Employee Details getters and setters
    public String getDepartment() {
        return department;
    }
    
    public void setDepartment(String department) {
        this.department = department;
    }
    
    public Date getHireDate() {
        return hireDate;
    }
    
    public void setHireDate(Date hireDate) {
        this.hireDate = hireDate;
    }
    
    public double getSalary() {
        return salary;
    }
    
    public void setSalary(double salary) {
        this.salary = salary;
    }
    
    // Statistics getters and setters
    public int getTotalBookings() {
        return totalBookings;
    }
    
    public void setTotalBookings(int totalBookings) {
        this.totalBookings = totalBookings;
    }
    
    public int getCompletedBookings() {
        return completedBookings;
    }
    
    public void setCompletedBookings(int completedBookings) {
        this.completedBookings = completedBookings;
    }
    
    public double getTotalSpent() {
        return totalSpent;
    }
    
    public void setTotalSpent(double totalSpent) {
        this.totalSpent = totalSpent;
    }
    
    public Date getLastVisit() {
        return lastVisit;
    }
    
    public void setLastVisit(Date lastVisit) {
        this.lastVisit = lastVisit;
    }
    
    // Helper methods for display
    public String getRoleDisplayName() {
        if (role == null) return "";
        switch (role) {
            case "ADMIN": return "Administrator";
            case "RECEPTIONIST": return "Receptionist";
            case "HOUSEKEEPER": return "Housekeeper";
            case "ROOM_INSPECTOR": return "Room Inspector";
            case "CUSTOMER": return "Customer";    
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
            case "ROOM_INSPECTOR": return "badge-warning";
            case "CUSTOMER": return "badge-success";
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
    
    // Customer specific helper methods
    public String getMembershipBadgeClass() {
        if (membershipLevel == null) return "badge-secondary";
        switch (membershipLevel.toUpperCase()) {
            case "PLATINUM": return "badge-dark";
            case "GOLD": return "badge-warning";
            case "SILVER": return "badge-info";
            case "BRONZE": return "badge-secondary";
            default: return "badge-secondary";
        }
    }
    
    public String getGenderDisplayName() {
        if (gender == null) return "Not specified";
        switch (gender.toUpperCase()) {
            case "MALE": return "Male";
            case "FEMALE": return "Female";
            case "OTHER": return "Other";
            default: return gender;
        }
    }
    
    public String getIdTypeDisplayName() {
        if (idType == null) return "Not provided";
        switch (idType) {
            case "PASSPORT": return "Passport";
            case "ID_CARD": return "ID Card";
            case "DRIVER_LICENSE": return "Driver License";
            default: return idType;
        }
    }
    
    // Employee specific helper methods
    public String getFormattedSalary() {
        if (salary > 0) {
            return String.format("%,.0f₫", salary);
        }
        return "Not specified";
    }
    
    public String getFormattedTotalSpent() {
        if (totalSpent > 0) {
            return String.format("%,.0f₫", totalSpent);
        }
        return "0₫";
    }
    
    public boolean isCustomer() {
        return "CUSTOMER".equals(role);
    }
    
    public boolean isEmployee() {
        return role != null && (role.equals("ADMIN") || role.equals("RECEPTIONIST") || 
                               role.equals("HOUSEKEEPER") || role.equals("ROOM_INSPECTOR"));
    }
    
    public boolean isAdmin() {
        return "ADMIN".equals(role);
    }
    
    public boolean isReceptionist() {
        return "RECEPTIONIST".equals(role);
    }
    
    public boolean isHousekeeper() {
        return "HOUSEKEEPER".equals(role);
    }
    
    public boolean isRoomInspector() {
        return "ROOM_INSPECTOR".equals(role);
    }
    
    // Customer loyalty level check
    public boolean isVIPCustomer() {
        return isVIP || "PLATINUM".equals(membershipLevel) || totalSpent > 50000000 || totalBookings >= 10;
    }
    
    public String getLoyaltyDescription() {
        if (isVIPCustomer()) {
            return "VIP Customer - Premium Benefits";
        } else if ("GOLD".equals(membershipLevel)) {
            return "Gold Member - Special Privileges";
        } else if ("SILVER".equals(membershipLevel)) {
            return "Silver Member - Bonus Points";
        } else {
            return "Bronze Member - Welcome Benefits";
        }
    }
    
    // Get user's initial for avatar
    public String getInitial() {
        if (fullName != null && !fullName.isEmpty()) {
            return fullName.substring(0, 1).toUpperCase();
        }
        return "U";
    }
    
    // Check if user has complete profile
    public boolean hasCompleteProfile() {
        if (isCustomer()) {
            return fullName != null && email != null && phone != null && 
                   idType != null && idNumber != null;
        } else if (isEmployee()) {
            return fullName != null && email != null && department != null;
        }
        return fullName != null && email != null;
    }
    
    // Get profile completion percentage
    public int getProfileCompletionPercentage() {
        int total = 0;
        int completed = 0;
        
        // Basic fields
        total += 3; // fullName, email, phone
        if (fullName != null && !fullName.trim().isEmpty()) completed++;
        if (email != null && !email.trim().isEmpty()) completed++;
        if (phone != null && !phone.trim().isEmpty()) completed++;
        
        if (isCustomer()) {
            total += 4; // idType, idNumber, dateOfBirth, gender
            if (idType != null) completed++;
            if (idNumber != null && !idNumber.trim().isEmpty()) completed++;
            if (dateOfBirth != null) completed++;
            if (gender != null) completed++;
        } else if (isEmployee()) {
            total += 2; // department, hireDate
            if (department != null && !department.trim().isEmpty()) completed++;
            if (hireDate != null) completed++;
        }
        
        return total > 0 ? (completed * 100) / total : 0;
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
                ", membershipLevel='" + membershipLevel + '\'' +
                ", department='" + department + '\'' +
                '}';
    }
}