package controller;

import service.VerificationService;
import dal.VerificationDAO;
import dal.UserDAO;
import model.User;
import model.PendingChange;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ChangeRequestServlet", urlPatterns = {"/admin/change-request"})
public class ChangeRequestServlet extends HttpServlet {
    
    private VerificationService verificationService = new VerificationService();
    private VerificationDAO verificationDAO = new VerificationDAO();
    private UserDAO userDAO = new UserDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        try {
            switch (action) {
                case "list":
                    showPendingChanges(request, response);
                    break;
                case "form":
                    showChangeRequestForm(request, response);
                    break;
                default:
                    showPendingChanges(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "An error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin-dashboard");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        try {
            switch (action) {
                case "request-email-change":
                    requestEmailChange(request, response);
                    break;
                case "request-phone-change":
                    requestPhoneChange(request, response);
                    break;
                case "request-password-change":
                    requestPasswordChange(request, response);
                    break;
                case "send-reminder":
                    sendReminder(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin/change-request");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "An error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/change-request");
        }
    }
    
    private void showPendingChanges(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<PendingChange> pendingChanges = verificationDAO.getPendingChangesPaginated(1, 50);
        
        // Calculate statistics
        int pendingCount = 0, approvedToday = 0, expiredCount = 0, totalThisMonth = 0;
        java.util.Date today = new java.util.Date();
        
        for (PendingChange change : pendingChanges) {
            if ("PENDING".equals(change.getStatus())) pendingCount++;
            if ("APPROVED".equals(change.getStatus()) && isSameDay(change.getApprovedAt(), today)) approvedToday++;
            if ("EXPIRED".equals(change.getStatus()) || "REJECTED".equals(change.getStatus())) expiredCount++;
            if (isSameMonth(change.getCreatedAt(), today)) totalThisMonth++;
        }
        
        request.setAttribute("pendingChanges", pendingChanges);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("approvedToday", approvedToday);
        request.setAttribute("expiredCount", expiredCount);
        request.setAttribute("totalThisMonth", totalThisMonth);
        
        request.setAttribute("pageTitle", "Pending Change Requests");
        request.setAttribute("contentPage", "/jsp/admin/pending-changes.jsp");
        request.setAttribute("activePage", "change-requests");
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void showChangeRequestForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int userId = Integer.parseInt(request.getParameter("userId"));
        String changeType = request.getParameter("type");
        String userType = request.getParameter("userType");
        
        User targetUser;
        if ("customer".equals(userType)) {
            targetUser = userDAO.getCustomerByIdWithDetails(userId);
        } else {
            targetUser = userDAO.getEmployeeByIdWithDetails(userId);
        }
        
        if (targetUser == null) {
            request.getSession().setAttribute("error", "User not found!");
            response.sendRedirect(request.getContextPath() + "/admin/" + userType);
            return;
        }
        
        request.setAttribute("targetUser", targetUser);
        request.setAttribute("changeType", changeType);
        request.setAttribute("userType", userType);
        request.setAttribute("pageTitle", "Request " + changeType.substring(0, 1).toUpperCase() + changeType.substring(1) + " Change");
        request.setAttribute("contentPage", "/jsp/admin/change-request-form.jsp");
        request.setAttribute("activePage", userType);
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
 private void requestEmailChange(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    int userId = Integer.parseInt(request.getParameter("userId"));
    String userType = request.getParameter("userType");
    String newEmail = request.getParameter("newEmail");
    String reason = request.getParameter("reason");
    
    // 🔥 THÊM DEBUG LOG
    System.out.println("📧 Processing email change request:");
    System.out.println("   User ID: " + userId);
    System.out.println("   User Type: " + userType);
    System.out.println("   New Email: " + newEmail);
    System.out.println("   Reason: " + reason);
    
    User currentAdmin = (User) request.getSession().getAttribute("user");
    
    boolean success = verificationService.requestEmailChange(userId, newEmail, currentAdmin.getId(), reason);
    
    // 🔥 LOG KẾT QUẢ
    System.out.println("   Result: " + (success ? "SUCCESS" : "FAILED"));
    
    if (success) {
        request.getSession().setAttribute("success", "Email change verification has been sent to the user's current email address!");
    } else {
        request.getSession().setAttribute("error", "Failed to send email change request! Please check the logs.");
    }
    
        String redirectPath = userType.equals("customer") ? "customers" : "staff";
    response.sendRedirect(request.getContextPath() + "/admin/" + redirectPath + 
                         "?action=view&id=" + userId + "&verificationSent=true");
}

private void requestPhoneChange(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    int userId = Integer.parseInt(request.getParameter("userId"));
    String userType = request.getParameter("userType");
    String newPhone = request.getParameter("newPhone");
    String reason = request.getParameter("reason");
    
    User currentAdmin = (User) request.getSession().getAttribute("user");
    
    boolean success = verificationService.requestPhoneChange(userId, newPhone, currentAdmin.getId(), reason);
    
    if (success) {
        request.getSession().setAttribute("success", "Phone change request sent successfully!");
    } else {
        request.getSession().setAttribute("error", "Failed to send phone change request!");
    }
    
       String redirectPath = userType.equals("customer") ? "customers" : "staff";
    response.sendRedirect(request.getContextPath() + "/admin/" + redirectPath + 
                         "?action=view&id=" + userId + "&verificationSent=true");
}

private void requestPasswordChange(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    int userId = Integer.parseInt(request.getParameter("userId"));
    String userType = request.getParameter("userType");
    String newPassword = request.getParameter("newPassword");
    String reason = request.getParameter("reason");
    
    User currentAdmin = (User) request.getSession().getAttribute("user");
    
    boolean success = verificationService.requestPasswordChange(userId, newPassword, currentAdmin.getId(), reason);
    
    if (success) {
        request.getSession().setAttribute("success", "Password change request sent successfully!");
    } else {
        request.getSession().setAttribute("error", "Failed to send password change request!");
    }
    
     String redirectPath = userType.equals("customer") ? "customers" : "staff";
    response.sendRedirect(request.getContextPath() + "/admin/" + redirectPath + 
                         "?action=view&id=" + userId + "&verificationSent=true");
}
    
    private void sendReminder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Implementation for sending reminder emails
        response.setContentType("application/json");
        response.getWriter().write("{\"success\": true, \"message\": \"Reminder sent successfully\"}");
    }
   
    // Helper methods
    private boolean isSameDay(java.util.Date date1, java.util.Date date2) {
        if (date1 == null || date2 == null) return false;
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyyMMdd");
        return sdf.format(date1).equals(sdf.format(date2));
    }
    
    private boolean isSameMonth(java.util.Date date1, java.util.Date date2) {
        if (date1 == null || date2 == null) return false;
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyyMM");
        return sdf.format(date1).equals(sdf.format(date2));
    }
}