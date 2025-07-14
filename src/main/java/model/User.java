package model;

import java.sql.Timestamp;
import java.util.Date;
import java.util.Objects;

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
    
    private transient String formattedDateOfBirth;
    private transient String formattedHireDate;
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
    
    // Fixed VIP methods to be consistent
    public boolean isVIP() {
        return isVIP;
    }
    
    public void setVIP(boolean isVIP) {
        this.isVIP = isVIP;
    }
    
    // Deprecated - use isVIP() instead
    @Deprecated
    public boolean getIsVIP() {
        return isVIP();
    }
    
    // Deprecated - use setVIP() instead
    @Deprecated
    public void setIsVIP(boolean isVIP) {
        setVIP(isVIP);
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
      // Getters and setters
    public String getFormattedDateOfBirth() {
        if (formattedDateOfBirth != null) {
            return formattedDateOfBirth;
        } else if (dateOfBirth != null) {
            return new java.text.SimpleDateFormat("yyyy-MM-dd").format(dateOfBirth);
        }
        return "";
    }
    
    public void setFormattedDateOfBirth(String formattedDateOfBirth) {
        this.formattedDateOfBirth = formattedDateOfBirth;
    }
    
    public String getFormattedHireDate() {
        if (formattedHireDate != null) {
            return formattedHireDate;
        } else if (hireDate != null) {
            return new java.text.SimpleDateFormat("yyyy-MM-dd").format(hireDate);
        }
        return "";
    }
    
    public void setFormattedHireDate(String formattedHireDate) {
        this.formattedHireDate = formattedHireDate;
    }
    
    // NEW: Validation methods
    public boolean isValidEmail() {
        return email != null && email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    }
    
    public boolean isValidPhone() {
        return phone == null || phone.isEmpty() || phone.matches("^0\\d{9}$");
    }
    
    public boolean isValidUsername() {
        return username != null && username.matches("^[a-zA-Z0-9_]{3,20}$");
    }
    
    // NEW: Age calculation
    public int getAge() {
        if (dateOfBirth == null) return 0;
        
        long ageInMillis = System.currentTimeMillis() - dateOfBirth.getTime();
        return (int) (ageInMillis / (365L * 24 * 60 * 60 * 1000));
    }
    
    public boolean isAdult() {
        return getAge() >= 18;
    }
    
    // NEW: Years of service for employees
    public int getYearsOfService() {
        if (hireDate == null || !isEmployee()) return 0;
        
        long serviceInMillis = System.currentTimeMillis() - hireDate.getTime();
        return (int) (serviceInMillis / (365L * 24 * 60 * 60 * 1000));
    }
    
    // NEW: Formatted dates
    public String getFormattedCreatedAt() {
        if (createdAt == null) return "";
        return new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(createdAt);
    }
    
 
    public String getFormattedLastVisit() {
        if (lastVisit == null) return "Never";
        return new java.text.SimpleDateFormat("dd/MM/yyyy").format(lastVisit);
    }
    
    // NEW: Auto-calculate membership level based on points
    public String getCalculatedMembershipLevel() {
        if (loyaltyPoints >= 10000) return "PLATINUM";
        else if (loyaltyPoints >= 5000) return "GOLD";
        else if (loyaltyPoints >= 1000) return "SILVER";
        else return "BRONZE";
    }
    
    // NEW: Calculate loyalty points to next level
    public int getPointsToNextLevel() {
        if (loyaltyPoints >= 10000) return 0; // Already at highest level
        else if (loyaltyPoints >= 5000) return 10000 - loyaltyPoints;
        else if (loyaltyPoints >= 1000) return 5000 - loyaltyPoints;
        else return 1000 - loyaltyPoints;
    }
    
    public String getNextMembershipLevel() {
        if (loyaltyPoints >= 10000) return null; // Already at highest level
        else if (loyaltyPoints >= 5000) return "PLATINUM";
        else if (loyaltyPoints >= 1000) return "GOLD";
        else return "SILVER";
    }
    
    // NEW: Full address formatting
    public String getFullAddress() {
        StringBuilder sb = new StringBuilder();
        if (address != null && !address.trim().isEmpty()) {
            sb.append(address);
        }
        if (city != null && !city.trim().isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(city);
        }
        if (country != null && !country.trim().isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(country);
        }
        return sb.length() > 0 ? sb.toString() : "Not provided";
    }
    
    // NEW: Check for missing critical information
    public boolean hasMissingCriticalInfo() {
        if (isCustomer()) {
            return email == null || email.trim().isEmpty() ||
                   idType == null || idNumber == null || idNumber.trim().isEmpty();
        } else if (isEmployee()) {
            return email == null || email.trim().isEmpty() ||
                   department == null || department.trim().isEmpty();
        }
        return email == null || email.trim().isEmpty();
    }
    
    // NEW: Get warning messages for missing info
    public String getMissingInfoWarning() {
        if (!hasMissingCriticalInfo()) return null;
        
        StringBuilder warning = new StringBuilder("Missing: ");
        boolean first = true;
        
        if (email == null || email.trim().isEmpty()) {
            warning.append("Email");
            first = false;
        }
        
        if (isCustomer()) {
            if (idType == null) {
                if (!first) warning.append(", ");
                warning.append("ID Type");
                first = false;
            }
            if (idNumber == null || idNumber.trim().isEmpty()) {
                if (!first) warning.append(", ");
                warning.append("ID Number");
            }
        } else if (isEmployee()) {
            if (department == null || department.trim().isEmpty()) {
                if (!first) warning.append(", ");
                warning.append("Department");
            }
        }
        
        return warning.toString();
    }
    
    // NEW: Clone method for creating copies
    public User clone() {
        User clone = new User();
        clone.id = this.id;
        clone.username = this.username;
        clone.fullName = this.fullName;
        clone.email = this.email;
        clone.phone = this.phone;
        clone.role = this.role;
        clone.status = this.status;
        clone.createdAt = this.createdAt;
        clone.updatedAt = this.updatedAt;
        
        // Customer details
        clone.idType = this.idType;
        clone.idNumber = this.idNumber;
        clone.dateOfBirth = this.dateOfBirth;
        clone.gender = this.gender;
        clone.address = this.address;
        clone.city = this.city;
        clone.country = this.country;
        clone.loyaltyPoints = this.loyaltyPoints;
        clone.membershipLevel = this.membershipLevel;
        clone.isVIP = this.isVIP;
        
        // Employee details
        clone.department = this.department;
        clone.hireDate = this.hireDate;
        clone.salary = this.salary;
        
        // Statistics
        clone.totalBookings = this.totalBookings;
        clone.completedBookings = this.completedBookings;
        clone.totalSpent = this.totalSpent;
        clone.lastVisit = this.lastVisit;
        
        return clone;
    }
    
    // NEW: equals and hashCode methods
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        User user = (User) o;
        return id == user.id && Objects.equals(username, user.username);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(id, username);
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
                ", isVIP=" + isVIP +
                ", loyaltyPoints=" + loyaltyPoints +
                ", yearsOfService=" + getYearsOfService() +
                ", profileCompletion=" + getProfileCompletionPercentage() + "%" +
                '}';
    }
}