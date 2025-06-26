package controller;


import dal.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import com.google.gson.Gson;

@WebServlet(name = "NotificationsServlet", urlPatterns = {"/receptionist/notifications"})
public class NotificationsServlet extends HttpServlet {
    
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final UserDAO userDAO = new UserDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"RECEPTIONIST".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        try {
            // Get all notifications
            List<Notification> notifications = notificationDAO.getAllNotifications();
            
            // Get notification statistics
            int totalNotifications = notificationDAO.getTotalNotifications();
            int sentNotifications = notificationDAO.getNotificationCountByStatus("SENT");
            int failedNotifications = notificationDAO.getNotificationCountByStatus("FAILED");
            
            // Set attributes
            request.setAttribute("notifications", notifications);
            request.setAttribute("totalNotifications", totalNotifications);
            request.setAttribute("sentNotifications", sentNotifications);
            request.setAttribute("failedNotifications", failedNotifications);
            request.setAttribute("currentUser", currentUser);
            
            // Set template attributes
            request.setAttribute("pageTitle", "Notifications Management");
            request.setAttribute("activePage", "notifications");
            // No need to set contentPage anymore as we're using direct includes
            
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading notifications: " + e.getMessage());
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        try {
            switch (action) {
                case "sendNotification":
                    sendNotification(request, response);
                    break;
                case "sendBulkNotifications":
                    sendBulkNotifications(request, response);
                    break;
                case "resendNotification":
                    resendNotification(request, response);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"error\":\"Invalid action\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private void sendNotification(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            Gson gson = new Gson();
            Map<String, Object> notificationData = gson.fromJson(request.getReader(), Map.class);
            
            Notification notification = new Notification();
            notification.setUserId(((Double) notificationData.get("userId")).intValue());
            notification.setReservationId(notificationData.get("reservationId") != null ? 
                ((Double) notificationData.get("reservationId")).intValue() : null);
            notification.setType((String) notificationData.get("type"));
            notification.setMessage((String) notificationData.get("message"));
            
            boolean success = notificationDAO.sendNotification(notification);
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false}");
        }
    }
    
    private void sendBulkNotifications(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String type = request.getParameter("type");
            String message = request.getParameter("message");
            
            List<User> customers = userDAO.getUsersByRole("CUSTOMER");
            int successCount = 0;
            
            for (User customer : customers) {
                Notification notification = new Notification();
                notification.setUserId(customer.getId());
                notification.setType(type);
                notification.setMessage(message);
                
                if (notificationDAO.sendNotification(notification)) {
                    successCount++;
                }
            }
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":true, \"sentCount\":" + successCount + "}");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false}");
        }
    }
    
    private void resendNotification(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int notificationId = Integer.parseInt(request.getParameter("notificationId"));
            boolean success = notificationDAO.resendNotification(notificationId);
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false}");
        }
    }
}