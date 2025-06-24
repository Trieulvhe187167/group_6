package model;

import java.util.Date;

public class PendingChange {
    private int id;
    private int userId;
    private int initiatedBy;
    private String changeType;
    private String originalEmail;
    private String originalPhone;
    private String newEmail;
    private String newPhone;
    private String newPasswordHash;
    private String changeReason;
    private String verificationToken;
    private Date tokenExpiry;
    private String status;
    private boolean notificationSent;
    private boolean reminderSent;
    private int reminderCount;
    private Date approvedAt;
    private boolean approvedByEmail;
    private Date rejectedAt;
    private String rejectionReason;
    private Date createdAt;
    private Date updatedAt;
    
    // User information (for display)
    private String userName;
    private String userRole;
    private String initiatedByName;
    
    // Constructors
    public PendingChange() {}
    
    public PendingChange(int userId, int initiatedBy, String changeType) {
        this.userId = userId;
        this.initiatedBy = initiatedBy;
        this.changeType = changeType;
        this.status = "PENDING";
        this.createdAt = new Date();
        this.updatedAt = new Date();
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public int getInitiatedBy() { return initiatedBy; }
    public void setInitiatedBy(int initiatedBy) { this.initiatedBy = initiatedBy; }
    
    public String getChangeType() { return changeType; }
    public void setChangeType(String changeType) { this.changeType = changeType; }
    
    public String getOriginalEmail() { return originalEmail; }
    public void setOriginalEmail(String originalEmail) { this.originalEmail = originalEmail; }
    
    public String getOriginalPhone() { return originalPhone; }
    public void setOriginalPhone(String originalPhone) { this.originalPhone = originalPhone; }
    
    public String getNewEmail() { return newEmail; }
    public void setNewEmail(String newEmail) { this.newEmail = newEmail; }
    
    public String getNewPhone() { return newPhone; }
    public void setNewPhone(String newPhone) { this.newPhone = newPhone; }
    
    public String getNewPasswordHash() { return newPasswordHash; }
    public void setNewPasswordHash(String newPasswordHash) { this.newPasswordHash = newPasswordHash; }
    
    public String getChangeReason() { return changeReason; }
    public void setChangeReason(String changeReason) { this.changeReason = changeReason; }
    
    public String getVerificationToken() { return verificationToken; }
    public void setVerificationToken(String verificationToken) { this.verificationToken = verificationToken; }
    
    public Date getTokenExpiry() { return tokenExpiry; }
    public void setTokenExpiry(Date tokenExpiry) { this.tokenExpiry = tokenExpiry; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public boolean isNotificationSent() { return notificationSent; }
    public void setNotificationSent(boolean notificationSent) { this.notificationSent = notificationSent; }
    
    public boolean isReminderSent() { return reminderSent; }
    public void setReminderSent(boolean reminderSent) { this.reminderSent = reminderSent; }
    
    public int getReminderCount() { return reminderCount; }
    public void setReminderCount(int reminderCount) { this.reminderCount = reminderCount; }
    
    public Date getApprovedAt() { return approvedAt; }
    public void setApprovedAt(Date approvedAt) { this.approvedAt = approvedAt; }
    
    public boolean isApprovedByEmail() { return approvedByEmail; }
    public void setApprovedByEmail(boolean approvedByEmail) { this.approvedByEmail = approvedByEmail; }
    
    public Date getRejectedAt() { return rejectedAt; }
    public void setRejectedAt(Date rejectedAt) { this.rejectedAt = rejectedAt; }
    
    public String getRejectionReason() { return rejectionReason; }
    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }
    
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    
    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
    
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    
    public String getUserRole() { return userRole; }
    public void setUserRole(String userRole) { this.userRole = userRole; }
    
    public String getInitiatedByName() { return initiatedByName; }
    public void setInitiatedByName(String initiatedByName) { this.initiatedByName = initiatedByName; }
    
    // Utility methods
    public boolean isExpired() {
        return tokenExpiry != null && tokenExpiry.before(new Date());
    }
    
    public boolean isPending() {
        return "PENDING".equals(status) && !isExpired();
    }
    
    public String getChangeTypeDisplayName() {
        switch (changeType) {
            case "EMAIL": return "Email Address";
            case "PHONE": return "Phone Number";
            case "PASSWORD": return "Password";
            case "PROFILE": return "Profile Information";
            default: return changeType;
        }
    }
    
    public String getStatusBadgeClass() {
        switch (status) {
            case "PENDING": return "badge-warning";
            case "APPROVED": return "badge-success";
            case "REJECTED": return "badge-danger";
            case "EXPIRED": return "badge-secondary";
            default: return "badge-light";
        }
    }
    
    public long getHoursUntilExpiry() {
        if (tokenExpiry == null) return 0;
        long diffMs = tokenExpiry.getTime() - System.currentTimeMillis();
        return Math.max(0, diffMs / (1000 * 60 * 60));
    }
}