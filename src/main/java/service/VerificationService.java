package service;

import model.PendingChange;
import model.User;
import dal.VerificationDAO;
import dal.UserDAO;
import util.HashUtil;
import util.OTPUtil;
import java.util.UUID;
import java.util.Calendar;
import java.util.Date;

public class VerificationService {
    
    private VerificationDAO verificationDAO = new VerificationDAO();
    private UserDAO userDAO = new UserDAO();
    private EmailService emailService = new EmailService();
    
    // Initiate email change request
    public boolean requestEmailChange(int userId, String newEmail, int adminId, String reason) {
        try {
            User user = userDAO.getUserById(userId);
            if (user == null) {
                System.err.println("User not found with ID: " + userId);
                return false;
            }
            
            // Create pending change
            PendingChange change = new PendingChange(userId, adminId, "EMAIL");
            change.setNewEmail(newEmail);
            change.setChangeReason(reason);
            change.setVerificationToken(generateSecureToken());
            
            // Set expiry (48 hours)
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.HOUR, 48);
            change.setTokenExpiry(cal.getTime());
            
            // Save to database
            change = verificationDAO.createChangeRequest(change);
            if (change == null) {
                System.err.println("Failed to create change request in database");
                return false;
            }
            
            // Get admin info for email
            User admin = userDAO.getUserById(adminId);
            if (admin != null) {
                change.setInitiatedByName(admin.getFullName());
            }
            
            // Send notification email to original email
            boolean emailSent = emailService.sendChangeRequestEmail(change, user);
            if (!emailSent) {
                System.err.println("Failed to send change request email");
                return false;
            }
            
            System.out.println("Email change request created successfully for user: " + user.getEmail());
            return true;
            
        } catch (Exception e) {
            System.err.println("Error in requestEmailChange: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Initiate phone change request
   public boolean requestPhoneChange(int userId, String newPhone, int adminId, String reason) {
    try {
        System.out.println("Starting phone change request for user ID: " + userId);
        
        User user = userDAO.getUserById(userId);
        if (user == null) {
            System.err.println("User not found with ID: " + userId);
            return false;
        }
        System.out.println("User found: " + user.getEmail());
        
        PendingChange change = new PendingChange(userId, adminId, "PHONE");
        change.setNewPhone(newPhone);
        change.setChangeReason(reason);
        change.setVerificationToken(generateSecureToken());
        
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.HOUR, 48);
        change.setTokenExpiry(cal.getTime());
        
        System.out.println("Saving change request to database...");
        change = verificationDAO.createChangeRequest(change);
        if (change == null) {
            System.err.println("Failed to create phone change request in database");
            return false;
        }
        System.out.println("Change request saved with ID: " + change.getId());
        
        // Get admin info for email
        User admin = userDAO.getUserById(adminId);
        if (admin != null) {
            change.setInitiatedByName(admin.getFullName());
            System.out.println("Admin info added: " + admin.getFullName());
        }
        
        System.out.println("Sending email to: " + user.getEmail());
        boolean emailSent = emailService.sendChangeRequestEmail(change, user);
        if (!emailSent) {
            System.err.println("Failed to send phone change request email");
            return false;
        }
        
        System.out.println("Phone change request completed successfully!");
        return true;
        
    } catch (Exception e) {
        System.err.println("Error in requestPhoneChange: " + e.getMessage());
        e.printStackTrace();
        return false;
    }
}
    
    // Initiate password change request using existing HashUtil
    public boolean requestPasswordChange(int userId, String newPassword, int adminId, String reason) {
        try {
            User user = userDAO.getUserById(userId);
            if (user == null) {
                System.err.println("User not found with ID: " + userId);
                return false;
            }
            
            // Use existing HashUtil instead of custom hashing
            String hashedPassword = HashUtil.hashPassword(newPassword);
            
            PendingChange change = new PendingChange(userId, adminId, "PASSWORD");
            change.setNewPasswordHash(hashedPassword);
            change.setChangeReason(reason);
            change.setVerificationToken(generateSecureToken());
            
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.HOUR, 48);
            change.setTokenExpiry(cal.getTime());
            
            change = verificationDAO.createChangeRequest(change);
            if (change == null) {
                System.err.println("Failed to create password change request in database");
                return false;
            }
            
            // Get admin info for email
            User admin = userDAO.getUserById(adminId);
            if (admin != null) {
                change.setInitiatedByName(admin.getFullName());
            }
            
            boolean emailSent = emailService.sendChangeRequestEmail(change, user);
            if (!emailSent) {
                System.err.println("Failed to send password change request email");
                return false;
            }
            
            System.out.println("Password change request created successfully for user: " + user.getEmail());
            return true;
            
        } catch (Exception e) {
            System.err.println("Error in requestPasswordChange: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Approve change request via email link
    public boolean approveChange(String token) {
        try {
            PendingChange change = verificationDAO.getPendingChangeByToken(token);
            if (change == null) {
                System.err.println("No pending change found for token: " + token);
                return false;
            }
            
            if (change.isExpired()) {
                System.err.println("Change request has expired for token: " + token);
                return false;
            }
            
            // Approve the change
            boolean success = verificationDAO.approveChangeRequest(token);
            
            if (success) {
                // Send confirmation email
                User user = userDAO.getUserById(change.getUserId());
                if (user != null) {
                    emailService.sendApprovalConfirmationEmail(change, user);
                    System.out.println("Change approved and confirmation sent for user: " + user.getEmail());
                } else {
                    System.err.println("User not found after approval for ID: " + change.getUserId());
                }
            } else {
                System.err.println("Failed to approve change in database for token: " + token);
            }
            
            return success;
            
        } catch (Exception e) {
            System.err.println("Error in approveChange: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Reject change request
    public boolean rejectChange(String token, String reason) {
        try {
            PendingChange change = verificationDAO.getPendingChangeByToken(token);
            if (change == null) {
                System.err.println("No pending change found for rejection token: " + token);
                return false;
            }
            
            boolean success = verificationDAO.rejectChangeRequest(token, reason);
            
            if (success) {
                // Send rejection notification email
                User user = userDAO.getUserById(change.getUserId());
                if (user != null) {
                    emailService.sendRejectionNotificationEmail(change, user, reason);
                    System.out.println("Change rejected and notification sent for user: " + user.getEmail());
                }
            } else {
                System.err.println("Failed to reject change in database for token: " + token);
            }
            
            return success;
            
        } catch (Exception e) {
            System.err.println("Error in rejectChange: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Send reminder for pending changes
    public void sendReminders() {
        try {
            // Implementation to find pending changes older than 24 hours and send reminders
            System.out.println("Sending reminders for pending changes...");
            // This would be implemented based on your specific requirements
        } catch (Exception e) {
            System.err.println("Error sending reminders: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    // Cleanup expired tokens
    public int cleanupExpiredTokens() {
        try {
            int cleaned = verificationDAO.cleanupExpiredTokens();
            System.out.println("Cleaned up " + cleaned + " expired verification tokens");
            return cleaned;
        } catch (Exception e) {
            System.err.println("Error cleaning up expired tokens: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }
    
    // Helper method to generate secure tokens using existing OTPUtil
    private String generateSecureToken() {
        // Combine UUID with alphanumeric OTP for extra security
        String uuid = UUID.randomUUID().toString().replace("-", "");
        String otp = OTPUtil.generateAlphanumericOTP();
        long timestamp = System.currentTimeMillis();
        
        return uuid + otp + timestamp;
    }
    
    // Validate change request parameters
    public boolean validateChangeRequest(String changeType, String newValue, int userId) {
        try {
            switch (changeType.toUpperCase()) {
                case "EMAIL":
                    return newValue != null && newValue.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
                case "PHONE":
                    return newValue == null || newValue.isEmpty() || newValue.matches("^0\\d{9}$");
                case "PASSWORD":
                    return newValue != null && newValue.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&+=!]).{8,}$");
                default:
                    return false;
            }
        } catch (Exception e) {
            System.err.println("Error validating change request: " + e.getMessage());
            return false;
        }
    }
    
    // Check if user has pending changes
    public boolean hasPendingChanges(int userId) {
        try {
            return !verificationDAO.getPendingChangesForUser(userId).isEmpty();
        } catch (Exception e) {
            System.err.println("Error checking pending changes for user: " + userId);
            return false;
        }
    }
}