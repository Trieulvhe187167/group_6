package controller;

import dal.*;
import model.*;
import util.HashUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Base64;

@WebServlet(name = "CompleteRegistrationServlet", urlPatterns = {"/complete-registration"})
public class CompleteRegistrationServlet extends HttpServlet {
    
    private final UserDAO userDAO = new UserDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String token = request.getParameter("token");
        
        if (token == null || token.isEmpty()) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            // Decode token
            String decodedToken = new String(Base64.getDecoder().decode(token));
            String[] parts = decodedToken.split(":");
            
            if (parts.length < 2) {
                request.setAttribute("error", "Invalid token");
                request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
                return;
            }
            
            int userId = Integer.parseInt(parts[0]);
            long timestamp = Long.parseLong(parts[1]);
            
            // Check if token is expired (7 days)
            if (System.currentTimeMillis() - timestamp > 7 * 24 * 60 * 60 * 1000) {
                request.setAttribute("error", "This link has expired");
                request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
                return;
            }
            
            // Get user details
            User user = userDAO.getUserById(userId);
            if (user == null) {
                request.setAttribute("error", "User not found");
                request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
                return;
            }
            
            // Set attributes
            request.setAttribute("user", user);
            request.setAttribute("token", token);
            
            // Check if there's a type parameter for special offers
            String type = request.getParameter("type");
            if (type != null) {
                request.setAttribute("offerType", type);
            }
            
            // Forward to registration completion page
            request.getRequestDispatcher("/jsp/completeRegistration.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Invalid token");
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String token = request.getParameter("token");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Validate input
        if (token == null || password == null || confirmPassword == null) {
            request.setAttribute("error", "All fields are required");
            doGet(request, response);
            return;
        }
        
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match");
            doGet(request, response);
            return;
        }
        
        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters");
            doGet(request, response);
            return;
        }
        
        try {
            // Decode token
            String decodedToken = new String(Base64.getDecoder().decode(token));
            String[] parts = decodedToken.split(":");
            int userId = Integer.parseInt(parts[0]);
            
            // Get user
            User user = userDAO.getUserById(userId);
            if (user == null) {
                request.setAttribute("error", "User not found");
                doGet(request, response);
                return;
            }
            
            // Update password
            String hashedPassword = HashUtil.hashPassword(password);
            boolean passwordUpdated = userDAO.resetPassword(userId, hashedPassword);
            
            if (passwordUpdated) {
                // Update customer details - mark as no longer guest
                Customer customer = customerDAO.getCustomerById(userId);
                if (customer != null) {
                    customer.setIsGuest(false);
                    customer.setHasCompletedRegistration(true);
                    customerDAO.updateCustomerDetails(customer);
                }
                
                // Log activity
                Activity activity = new Activity();
                activity.setType("ACCOUNT_UPGRADED");
                activity.setUserId(userId);
                activity.setDescription("Guest account upgraded to full member");
                activity.setIpAddress(request.getRemoteAddr());
                activityDAO.logActivity(activity);
                
                // Check for special offer type
                String offerType = request.getParameter("offerType");
                if (offerType != null) {
                    applySpecialOffer(customer, offerType);
                }
                
                // Auto-login the user
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                session.setAttribute("accountUpgraded", true);
                
                // Redirect to success page or dashboard
                response.sendRedirect("customer/profile?upgraded=true");
                
            } else {
                request.setAttribute("error", "Failed to update password. Please try again.");
                doGet(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred. Please try again.");
            doGet(request, response);
        }
    }
    
    private void applySpecialOffer(Customer customer, String offerType) {
        try {
            switch (offerType.toLowerCase()) {
                case "vip":
                    customer.setLoyaltyStatus("VIP");
                    // Add 5000 bonus points
                    customerDAO.updateCustomerDetails(customer);
                    break;
                    
                case "gold":
                    customer.setLoyaltyStatus("GOLD");
                    // Add 2000 bonus points
                    customerDAO.updateCustomerDetails(customer);
                    break;
                    
                default:
                    // Standard member - add 1000 welcome points
                    customer.setLoyaltyStatus("BRONZE");
                    customerDAO.updateCustomerDetails(customer);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}