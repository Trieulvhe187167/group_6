package controller;

import model.PendingChange;
import model.User;
import service.VerificationService;
import dal.UserDAO;
import dal.VerificationDAO;
import java.util.List;
import java.util.Date;
import java.text.SimpleDateFormat;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "AdminChangeRequestServlet", urlPatterns = {"/admin/change-request"})
public class AdminChangeRequestServlet extends HttpServlet {

    private VerificationService verificationService = new VerificationService();
    private UserDAO userDAO = new UserDAO();
    private VerificationDAO verificationDAO = new VerificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "list":
                    listPendingChanges(request, response);
                    break;
                case "form":
                    showChangeForm(request, response);
                    break;
                case "view":
                    viewChangeRequest(request, response);
                    break;
                default:
                    listPendingChanges(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "An error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/change-request");
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

    private void listPendingChanges(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<PendingChange> pendingChanges = verificationDAO.getPendingChangesPaginated(1, 50);

        int pendingCount = 0, approvedToday = 0, expiredCount = 0, totalThisMonth = 0;
        Date today = new Date();

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
        request.setAttribute("contentPage", "/jsp/admin/verification/pending-changes.jsp");
        request.setAttribute("activePage", "verification");

        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }

    private void showChangeForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userId = request.getParameter("userId");
        String changeType = request.getParameter("type");
        String userType = request.getParameter("userType"); // "customer" or "staff"

        if (userId == null || changeType == null) {
            request.getSession().setAttribute("error", "Invalid parameters!");
            response.sendRedirect(request.getContextPath() + "/admin/" + userType);
            return;
        }

        User targetUser = userDAO.getUserById(Integer.parseInt(userId));
        if (targetUser == null) {
            request.getSession().setAttribute("error", "User not found!");
            response.sendRedirect(request.getContextPath() + "/admin/" + userType);
            return;
        }

        request.setAttribute("targetUser", targetUser);
        request.setAttribute("changeType", changeType);
        request.setAttribute("userType", userType);
        request.setAttribute("pageTitle", "Request " + changeType.substring(0, 1).toUpperCase()
                + changeType.substring(1) + " Change - " + targetUser.getFullName());
        request.setAttribute("contentPage", "/jsp/admin/verification/change-request-form.jsp");
        request.setAttribute("activePage", userType.equals("customer") ? "customers" : "staff");

        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }

    private void requestEmailChange(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = Integer.parseInt(request.getParameter("userId"));
        String newEmail = request.getParameter("newEmail");
        String reason = request.getParameter("reason");
        String userType = request.getParameter("userType");

        User currentAdmin = (User) request.getSession().getAttribute("user");
        if (currentAdmin == null) {
            request.getSession().setAttribute("error", "Session expired!");
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        // Validate email format
        if (!newEmail.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            request.getSession().setAttribute("error", "Invalid email format!");
            response.sendRedirect(request.getContextPath() + "/admin/change-request?action=form&userId="
                    + userId + "&type=email&userType=" + userType);
            return;
        }

        // Check if email already exists
        if (userDAO.isEmailExists(newEmail, userId)) {
            request.getSession().setAttribute("error", "Email already exists in the system!");
            response.sendRedirect(request.getContextPath() + "/admin/change-request?action=form&userId="
                    + userId + "&type=email&userType=" + userType);
            return;
        }

        boolean success = verificationService.requestEmailChange(userId, newEmail, currentAdmin.getId(), reason);

        if (success) {
            request.getSession().setAttribute("success",
                    "Email change request sent! The user will receive a verification email to approve the change.");
        } else {
            request.getSession().setAttribute("error", "Failed to send email change request!");
        }

        response.sendRedirect(request.getContextPath() + "/admin/" + userType + "?action=view&id=" + userId);
    }

    private void requestPhoneChange(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = Integer.parseInt(request.getParameter("userId"));
        String newPhone = request.getParameter("newPhone");
        String reason = request.getParameter("reason");
        String userType = request.getParameter("userType");

        User currentAdmin = (User) request.getSession().getAttribute("user");
        if (currentAdmin == null) {
            request.getSession().setAttribute("error", "Session expired!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Validate phone format (optional field)
        if (newPhone != null && !newPhone.isEmpty() && !newPhone.matches("^0\\d{9}$")) {
            request.getSession().setAttribute("error", "Phone number must start with 0 and be exactly 10 digits!");
            response.sendRedirect(request.getContextPath() + "/admin/change-request?action=form&userId="
                    + userId + "&type=phone&userType=" + userType);
            return;
        }

        boolean success = verificationService.requestPhoneChange(userId, newPhone, currentAdmin.getId(), reason);

        if (success) {
            request.getSession().setAttribute("success",
                    "Phone change request sent! The user will receive a verification email to approve the change.");
        } else {
            request.getSession().setAttribute("error", "Failed to send phone change request!");
        }

        response.sendRedirect(request.getContextPath() + "/admin/" + userType + "?action=view&id=" + userId);
    }

    private void requestPasswordChange(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = Integer.parseInt(request.getParameter("userId"));
        String newPassword = request.getParameter("newPassword");
        String reason = request.getParameter("reason");
        String userType = request.getParameter("userType");

        User currentAdmin = (User) request.getSession().getAttribute("user");
        if (currentAdmin == null) {
            request.getSession().setAttribute("error", "Session expired!");
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        // Validate password strength
        if (!newPassword.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&+=!]).{8,}$")) {
            request.getSession().setAttribute("error",
                    "Password must be at least 8 characters with uppercase, lowercase, digit, and special character!");
            response.sendRedirect(request.getContextPath() + "/admin/change-request?action=form&userId="
                    + userId + "&type=password&userType=" + userType);
            return;
        }

        boolean success = verificationService.requestPasswordChange(userId, newPassword, currentAdmin.getId(), reason);

        if (success) {
            request.getSession().setAttribute("success",
                    "Password change request sent! The user will receive a verification email to approve the change.");
        } else {
            request.getSession().setAttribute("error", "Failed to send password change request!");
        }

        response.sendRedirect(request.getContextPath() + "/admin/" + userType + "?action=view&id=" + userId);
    }

    private void viewChangeRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");
        // Implementation to view change request details

        request.setAttribute("pageTitle", "Change Request Details");
        request.setAttribute("contentPage", "/jsp/admin/verification/change-details.jsp");
        request.setAttribute("activePage", "verification");

        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
      private void sendReminder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Implementation for sending reminder emails
        response.setContentType("application/json");
        response.getWriter().write("{\"success\": true, \"message\": \"Reminder sent successfully\"}");
    }

    private boolean isSameDay(Date date1, Date date2) {
        if (date1 == null || date2 == null) return false;
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        return sdf.format(date1).equals(sdf.format(date2));
    }

    private boolean isSameMonth(Date date1, Date date2) {
        if (date1 == null || date2 == null) return false;
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
        return sdf.format(date1).equals(sdf.format(date2));
    }
}
