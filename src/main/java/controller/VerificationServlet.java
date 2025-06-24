package controller;

import model.PendingChange;
import model.User;
import service.VerificationService;
import dal.VerificationDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

// 🔥 IMPORTANT: Make sure this annotation is present
@WebServlet(name = "VerificationServlet", urlPatterns = {"/verify-change"})
public class VerificationServlet extends HttpServlet {
    
    private VerificationService verificationService = new VerificationService();
    private VerificationDAO verificationDAO = new VerificationDAO();
    private UserDAO userDAO = new UserDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String token = request.getParameter("token");
        String action = request.getParameter("action");
        
        System.out.println("🔍 VerificationServlet - Token received: " + token);
        System.out.println("🔍 VerificationServlet - Action: " + action);
        
        if (token == null || token.isEmpty()) {
            System.err.println("No token provided");
            request.setAttribute("error", "Invalid verification link!");
            request.getRequestDispatcher("/jsp/public/verification-result.jsp").forward(request, response);
            return;
        }
        
        try {
            PendingChange change = verificationDAO.getPendingChangeByToken(token);
            
            if (change == null) {
                System.err.println("No pending change found for token: " + token);
                request.setAttribute("error", "Invalid or expired verification link!");
                request.getRequestDispatcher("/jsp/public/verification-result.jsp").forward(request, response);
                return;
            }
            
            System.out.println("Found pending change: " + change.getChangeType() + " for user: " + change.getUserId());
            
            if (change.isExpired()) {
                System.err.println("Token expired: " + change.getTokenExpiry());
                request.setAttribute("error", "This verification link has expired!");
                request.getRequestDispatcher("/jsp/public/verification-result.jsp").forward(request, response);
                return;
            }
            
            User user = userDAO.getUserById(change.getUserId());
            if (user == null) {
                System.err.println("User not found: " + change.getUserId());
                request.setAttribute("error", "User not found!");
                request.getRequestDispatcher("/jsp/public/verification-result.jsp").forward(request, response);
                return;
            }
            
            System.out.println("✅ User found: " + user.getFullName() + " (" + user.getEmail() + ")");
            
            if ("reject".equals(action)) {
                showRejectForm(request, response, change, user);
            } else {
                showVerificationForm(request, response, change, user);
            }
            
        } catch (Exception e) {
            System.err.println("Error in VerificationServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while processing your request: " + e.getMessage());
            request.getRequestDispatcher("/jsp/public/verification-result.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String token = request.getParameter("token");
        
        System.out.println("🔍 VerificationServlet POST - Action: " + action + ", Token: " + token);
        
        if (token == null || token.isEmpty()) {
            request.setAttribute("error", "Invalid verification token!");
            request.getRequestDispatcher("/jsp/public/verification-result.jsp").forward(request, response);
            return;
        }
        
        try {
            switch (action) {
                case "approve":
                    approveChange(request, response, token);
                    break;
                case "reject":
                    rejectChange(request, response, token);
                    break;
                default:
                    request.setAttribute("error", "Invalid action!");
                    request.getRequestDispatcher("/jsp/public/verification-result.jsp").forward(request, response);
                    break;
            }
        } catch (Exception e) {
            System.err.println("❌ Error processing verification: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while processing your request: " + e.getMessage());
            request.getRequestDispatcher("/jsp/public/verification-result.jsp").forward(request, response);
        }
    }
    
    private void showVerificationForm(HttpServletRequest request, HttpServletResponse response,
                                    PendingChange change, User user)
            throws ServletException, IOException {
        
        request.setAttribute("change", change);
        request.setAttribute("user", user);
        request.setAttribute("pageTitle", "Verify Account Change Request");
        
        request.getRequestDispatcher("/jsp/public/verification-form.jsp").forward(request, response);
    }
    
    private void showRejectForm(HttpServletRequest request, HttpServletResponse response,
                              PendingChange change, User user)
            throws ServletException, IOException {
        
        request.setAttribute("change", change);
        request.setAttribute("user", user);
        request.setAttribute("pageTitle", "Reject Account Change Request");
        request.setAttribute("isReject", true);
        
        request.getRequestDispatcher("/jsp/public/verification-form.jsp").forward(request, response);
    }
    
    private void approveChange(HttpServletRequest request, HttpServletResponse response, String token)
            throws ServletException, IOException {
        
        boolean success = verificationService.approveChange(token);
        
        if (success) {
            request.setAttribute("success", "Your account information has been successfully updated!");
            request.setAttribute("message", "The changes have been applied to your account. " +
                                          "You will receive a confirmation email shortly.");
        } else {
            request.setAttribute("error", "Failed to approve the change. The link may have expired or already been used.");
        }
        
        request.getRequestDispatcher("/jsp/public/verification-result.jsp").forward(request, response);
    }
    
    private void rejectChange(HttpServletRequest request, HttpServletResponse response, String token)
            throws ServletException, IOException {
        
        String reason = request.getParameter("rejectionReason");
        if (reason == null || reason.trim().isEmpty()) {
            reason = "User rejected the change request";
        }
        
        boolean success = verificationService.rejectChange(token, reason);
        
        if (success) {
            request.setAttribute("success", "Change request has been rejected!");
            request.setAttribute("message", "The requested changes will not be applied to your account. " +
                                          "If this was done in error, please contact support.");
        } else {
            request.setAttribute("error", "Failed to reject the change request.");
        }
        
        request.getRequestDispatcher("/jsp/public/verification-result.jsp").forward(request, response);
    }
}