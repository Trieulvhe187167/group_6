package service;

import model.PendingChange;
import model.User;
import dal.VerificationDAO;
import util.SecureMailUtil;
import jakarta.mail.MessagingException;
import java.util.Map;
import java.util.HashMap;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

public class EmailService {
    
    private final String BASE_URL = "http://localhost:9999"; // Configure as needed
    private VerificationDAO verificationDAO = new VerificationDAO();
    
public boolean sendChangeRequestEmail(PendingChange change, User user) {
        try {
            String subject = "🔐 Action Required: Confirm Your Account Information Change";
            String emailBody = buildChangeRequestEmail(change, user);
            
            SecureMailUtil.sendHtmlEmail(user.getEmail(), subject, emailBody);
            verificationDAO.updateNotificationStatus(change.getId(), true, false);
            
            System.out.println("Change request email sent successfully to: " + user.getEmail());
            return true;
            
        } catch (Exception e) {
            System.err.println("Failed to send change request email to: " + user.getEmail());
            e.printStackTrace();
            verificationDAO.updateNotificationStatus(change.getId(), false, false);
            return false;
        }
    }
    
    public boolean sendReminderEmail(PendingChange change, User user) {
        try {
            String subject = "⏰ Reminder: Pending Account Information Change";
            String emailBody = buildReminderEmail(change, user);
            
            SecureMailUtil.sendHtmlEmail(user.getEmail(), subject, emailBody);
            verificationDAO.updateNotificationStatus(change.getId(), true, true);
            
            System.out.println("Reminder email sent successfully to: " + user.getEmail());
            return true;
            
        } catch (Exception e) {
            System.err.println("Failed to send reminder email to: " + user.getEmail());
            e.printStackTrace();
            verificationDAO.updateNotificationStatus(change.getId(), false, true);
            return false;
        }
    }
    
    public boolean sendApprovalConfirmationEmail(PendingChange change, User user) {
        try {
            String subject = "✅ Your Account Information Has Been Updated";
            String emailBody = buildApprovalEmail(change, user);
            
            SecureMailUtil.sendHtmlEmail(user.getEmail(), subject, emailBody);
            
            System.out.println("Approval confirmation email sent successfully to: " + user.getEmail());
            return true;
            
        } catch (Exception e) {
            System.err.println("Failed to send approval confirmation email to: " + user.getEmail());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean sendRejectionNotificationEmail(PendingChange change, User user, String reason) {
        try {
            String subject = "❌ Account Change Request Rejected";
            String emailBody = buildRejectionEmail(change, user, reason);
            
            SecureMailUtil.sendHtmlEmail(user.getEmail(), subject, emailBody);
            
            System.out.println("Rejection notification email sent successfully to: " + user.getEmail());
            return true;
            
        } catch (Exception e) {
            System.err.println("Failed to send rejection notification email to: " + user.getEmail());
            e.printStackTrace();
            return false;
        }
    }
    
      private String buildChangeRequestEmail(PendingChange change, User user) {
        // 🔥 URL ENCODE TOKEN ĐỂ TRÁNH LỖI
        String encodedToken = "";
        try {
            encodedToken = URLEncoder.encode(change.getVerificationToken(), "UTF-8");
        } catch (Exception e) {
            encodedToken = change.getVerificationToken();
        }
        
        String verificationLink = BASE_URL + "/verify-change?token=" + encodedToken;
        String rejectLink = BASE_URL + "/verify-change?token=" + encodedToken + "&action=reject";
        
        // Rest of the method remains the same...
        Map<String, String> variables = new HashMap<>();
        variables.put("{USER_NAME}", user.getFullName());
        variables.put("{ADMIN_NAME}", change.getInitiatedByName());
        variables.put("{CHANGE_TYPE}", change.getChangeTypeDisplayName());
        variables.put("{OLD_VALUE}", getOldValue(change));
        variables.put("{NEW_VALUE}", getNewValue(change));
        variables.put("{REASON}", change.getChangeReason() != null ? change.getChangeReason() : "Administrative update");
        variables.put("{VERIFICATION_LINK}", verificationLink);
        variables.put("{REJECT_LINK}", rejectLink);
        variables.put("{EXPIRY_DATE}", change.getTokenExpiry().toString());
        variables.put("{EXPIRY_HOURS}", String.valueOf(change.getHoursUntilExpiry()));
        
        String template = """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Account Change Request</title>
                <style>
                    body { 
                        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                        line-height: 1.6; 
                        color: #333; 
                        margin: 0; 
                        padding: 0; 
                        background-color: #f4f4f4;
                    }
                    .container { 
                        max-width: 600px; 
                        margin: 0 auto; 
                        background: white; 
                        border-radius: 10px; 
                        overflow: hidden;
                        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                    }
                    .header { 
                        background: linear-gradient(135deg, #5a2b81, #8e44ad); 
                        color: white; 
                        padding: 30px 20px; 
                        text-align: center; 
                    }
                    .header h1 { 
                        margin: 0; 
                        font-size: 24px; 
                    }
                    .content { 
                        padding: 30px 20px; 
                    }
                    .change-details { 
                        background: #f8f9fa; 
                        border-left: 4px solid #5a2b81; 
                        padding: 20px; 
                        margin: 20px 0; 
                        border-radius: 5px; 
                    }
                    .change-table { 
                        width: 100%; 
                        border-collapse: collapse; 
                        margin: 15px 0; 
                    }
                    .change-table td { 
                        padding: 10px; 
                        border-bottom: 1px solid #eee; 
                    }
                    .change-table td:first-child { 
                        font-weight: bold; 
                        width: 40%; 
                        color: #5a2b81; 
                    }
                    .button-group { 
                        text-align: center; 
                        margin: 30px 0; 
                    }
                    .btn { 
                        display: inline-block; 
                        padding: 12px 24px; 
                        margin: 0 10px; 
                        text-decoration: none; 
                        border-radius: 6px; 
                        font-weight: bold; 
                        font-size: 16px; 
                        transition: all 0.3s ease;
                    }
                    .btn-approve { 
                        background: #28a745; 
                        color: white; 
                    }
                    .btn-approve:hover { 
                        background: #218838; 
                    }
                    .btn-reject { 
                        background: #dc3545; 
                        color: white; 
                    }
                    .btn-reject:hover { 
                        background: #c82333; 
                    }
                    .warning { 
                        background: #fff3cd; 
                        border: 1px solid #ffeaa7; 
                        color: #856404; 
                        padding: 15px; 
                        border-radius: 5px; 
                        margin: 20px 0; 
                    }
                    .footer { 
                        background: #f8f9fa; 
                        padding: 20px; 
                        text-align: center; 
                        color: #6c757d; 
                        font-size: 14px; 
                    }
                    .expiry-badge {
                        background: #ffc107;
                        color: #212529;
                        padding: 4px 8px;
                        border-radius: 4px;
                        font-size: 12px;
                        font-weight: bold;
                    }
                    @media (max-width: 600px) {
                        .container { margin: 10px; }
                        .content { padding: 20px 15px; }
                        .btn { display: block; margin: 10px 0; }
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>🔐 Account Change Request</h1>
                        <p style="margin: 10px 0 0 0; opacity: 0.9;">Secure verification required</p>
                    </div>
                    
                    <div class="content">
                        <p>Dear <strong>{USER_NAME}</strong>,</p>
                        <p>An administrator (<strong>{ADMIN_NAME}</strong>) has requested to change your account information.</p>
                        
                        <div class="change-details">
                            <h3 style="margin-top: 0; color: #5a2b81;">📋 Change Details</h3>
                            <table class="change-table">
                                <tr>
                                    <td>Change Type:</td>
                                    <td><strong>{CHANGE_TYPE}</strong></td>
                                </tr>
                                <tr>
                                    <td>Current Value:</td>
                                    <td>{OLD_VALUE}</td>
                                </tr>
                                <tr>
                                    <td>Requested Value:</td>
                                    <td><strong>{NEW_VALUE}</strong></td>
                                </tr>
                                <tr>
                                    <td>Reason:</td>
                                    <td>{REASON}</td>
                                </tr>
                                <tr>
                                    <td>Expires in:</td>
                                    <td><span class="expiry-badge">{EXPIRY_HOURS} hours</span></td>
                                </tr>
                            </table>
                        </div>
                        
                        <div class="button-group">
                            <a href="{VERIFICATION_LINK}" class="btn btn-approve">
                                ✅ APPROVE CHANGE
                            </a>
                            <a href="{REJECT_LINK}" class="btn btn-reject">
                                ❌ REJECT CHANGE
                            </a>
                        </div>
                        
                        <div class="warning">
                            <strong>🛡️ Security Notice:</strong> 
                            Only approve this change if you requested it or trust the administrator who initiated it.
                            If you did not expect this change, please <strong>reject it immediately</strong> and contact our support team.
                        </div>
                        
                        <p style="font-size: 14px; color: #6c757d;">
                            <strong>Note:</strong> This verification link will expire on {EXPIRY_DATE}.<br>
                            If you don't take action, the request will be automatically rejected.
                        </p>
                    </div>
                    
                    <div class="footer">
                        <p><strong>Luxury Hotel Management System</strong></p>
                        <p>This is an automated security email. Please do not reply directly to this message.</p>
                        <p>If you need assistance, please contact our support team.</p>
                    </div>
                </div>
            </body>
            </html>
            """;
        
        return replaceTemplateVariables(template, variables);
    }
    
    private String buildReminderEmail(PendingChange change, User user) {
        String verificationLink = BASE_URL + "/verify-change?token=" + change.getVerificationToken();
        
        Map<String, String> variables = new HashMap<>();
        variables.put("{USER_NAME}", user.getFullName());
        variables.put("{CHANGE_TYPE}", change.getChangeTypeDisplayName());
        variables.put("{VERIFICATION_LINK}", verificationLink);
        variables.put("{EXPIRY_DATE}", change.getTokenExpiry().toString());
        variables.put("{EXPIRY_HOURS}", String.valueOf(change.getHoursUntilExpiry()));
        
        String template = """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Reminder: Pending Account Change</title>
                <style>
                    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f4f4f4; }
                    .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
                    .header { background: linear-gradient(135deg, #ffc107, #ff8f00); color: #212529; padding: 30px 20px; text-align: center; }
                    .content { padding: 30px 20px; }
                    .btn { display: inline-block; padding: 12px 24px; background: #5a2b81; color: white; text-decoration: none; border-radius: 6px; font-weight: bold; }
                    .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #6c757d; font-size: 14px; }
                    .urgent { background: #fff3cd; border: 1px solid #ffeaa7; color: #856404; padding: 15px; border-radius: 5px; margin: 20px 0; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>⏰ Reminder: Pending Account Change</h1>
                        <p style="margin: 10px 0 0 0; opacity: 0.9;">Action required before expiration</p>
                    </div>
                    
                    <div class="content">
                        <p>Dear <strong>{USER_NAME}</strong>,</p>
                        <p>You have a pending request to change your <strong>{CHANGE_TYPE}</strong> that requires your approval.</p>
                        
                        <div class="urgent">
                            <strong>⚠️ Time Sensitive:</strong> This request will expire in <strong>{EXPIRY_HOURS} hours</strong>.
                            Please review and approve or reject this change before {EXPIRY_DATE}.
                        </div>
                        
                        <div style="text-align: center; margin: 30px 0;">
                            <a href="{VERIFICATION_LINK}" class="btn">REVIEW CHANGE REQUEST</a>
                        </div>
                        
                        <p style="font-size: 14px; color: #6c757d;">
                            If you don't take action, this request will be automatically rejected when it expires.
                        </p>
                    </div>
                    
                    <div class="footer">
                        <p><strong>Luxury Hotel Management System</strong></p>
                        <p>This is an automated reminder. Please do not reply to this email.</p>
                    </div>
                </div>
            </body>
            </html>
            """;
        
        return replaceTemplateVariables(template, variables);
    }
    
    private String buildApprovalEmail(PendingChange change, User user) {
        Map<String, String> variables = new HashMap<>();
        variables.put("{USER_NAME}", user.getFullName());
        variables.put("{CHANGE_TYPE}", change.getChangeTypeDisplayName());
        variables.put("{NEW_VALUE}", getNewValue(change));
        
        String template = """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Account Information Updated</title>
                <style>
                    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f4f4f4; }
                    .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
                    .header { background: linear-gradient(135deg, #28a745, #20c997); color: white; padding: 30px 20px; text-align: center; }
                    .content { padding: 30px 20px; }
                    .success-box { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; border-radius: 5px; margin: 20px 0; }
                    .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #6c757d; font-size: 14px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>✅ Account Information Updated</h1>
                        <p style="margin: 10px 0 0 0; opacity: 0.9;">Change successfully applied</p>
                    </div>
                    
                    <div class="content">
                        <p>Dear <strong>{USER_NAME}</strong>,</p>
                        <p>Your <strong>{CHANGE_TYPE}</strong> has been successfully updated as requested.</p>
                        
                        <div class="success-box">
                            <strong>✅ Updated Successfully</strong><br>
                            Your new {CHANGE_TYPE}: <strong>{NEW_VALUE}</strong>
                        </div>
                        
                        <p>The change is now active and you can use your updated information immediately.</p>
                        
                        <p style="font-size: 14px; color: #6c757d;">
                            <strong>Security Note:</strong> If you did not approve this change, please contact our support team immediately.
                        </p>
                    </div>
                    
                    <div class="footer">
                        <p><strong>Luxury Hotel Management System</strong></p>
                        <p>This is an automated confirmation. Please do not reply to this email.</p>
                    </div>
                </div>
            </body>
            </html>
            """;
        
        return replaceTemplateVariables(template, variables);
    }
    
    private String buildRejectionEmail(PendingChange change, User user, String reason) {
        Map<String, String> variables = new HashMap<>();
        variables.put("{USER_NAME}", user.getFullName());
        variables.put("{CHANGE_TYPE}", change.getChangeTypeDisplayName());
        variables.put("{REJECTION_REASON}", reason);
        
        String template = """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Account Change Request Rejected</title>
                <style>
                    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f4f4f4; }
                    .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
                    .header { background: linear-gradient(135deg, #dc3545, #c82333); color: white; padding: 30px 20px; text-align: center; }
                    .content { padding: 30px 20px; }
                    .rejection-box { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 15px; border-radius: 5px; margin: 20px 0; }
                    .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #6c757d; font-size: 14px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>❌ Change Request Rejected</h1>
                        <p style="margin: 10px 0 0 0; opacity: 0.9;">No changes were made to your account</p>
                    </div>
                    
                    <div class="content">
                        <p>Dear <strong>{USER_NAME}</strong>,</p>
                        <p>The request to change your <strong>{CHANGE_TYPE}</strong> has been rejected.</p>
                        
                        <div class="rejection-box">
                            <strong>Rejection Reason:</strong><br>
                            {REJECTION_REASON}
                        </div>
                        
                        <p>No changes have been made to your account. Your current information remains unchanged.</p>
                        
                        <p style="font-size: 14px; color: #6c757d;">
                            If you believe this rejection was made in error, please contact our support team for assistance.
                        </p>
                    </div>
                    
                    <div class="footer">
                        <p><strong>Luxury Hotel Management System</strong></p>
                        <p>This is an automated notification. Please do not reply to this email.</p>
                    </div>
                </div>
            </body>
            </html>
            """;
        
        return replaceTemplateVariables(template, variables);
    }
    
    private String replaceTemplateVariables(String template, Map<String, String> variables) {
        String result = template;
        for (Map.Entry<String, String> entry : variables.entrySet()) {
            result = result.replace(entry.getKey(), entry.getValue() != null ? entry.getValue() : "");
        }
        return result;
    }
    
    private String getOldValue(PendingChange change) {
        switch (change.getChangeType()) {
            case "EMAIL": 
                return change.getOriginalEmail() != null ? change.getOriginalEmail() : "Not set";
            case "PHONE": 
                return change.getOriginalPhone() != null ? change.getOriginalPhone() : "Not set";
            case "PASSWORD": 
                return "••••••••";
            default: 
                return "N/A";
        }
    }
    
    private String getNewValue(PendingChange change) {
        switch (change.getChangeType()) {
            case "EMAIL": 
                return change.getNewEmail();
            case "PHONE": 
                return change.getNewPhone() != null ? change.getNewPhone() : "Remove phone number";
            case "PASSWORD": 
                return "••••••••";
            default: 
                return "N/A";
        }
    }
}