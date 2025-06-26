package controller;


import dal.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import java.sql.Date;
import com.google.gson.Gson;

@WebServlet(name = "PaymentsServlet", urlPatterns = {"/receptionist/payments"})
public class PaymentsServlet extends HttpServlet {
    
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final UserDAO userDAO = new UserDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();
    
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
            // Get pending payments
            List<Payment> pendingPayments = paymentDAO.getPendingPayments();
            
            // Get today's revenue
            Date today = new Date(System.currentTimeMillis());
            double todayRevenue = paymentDAO.getDailyRevenue(today);
            
            // Get payment statistics
            int pendingCount = paymentDAO.getPaymentCountByStatus("PENDING");
            int successCount = paymentDAO.getPaymentCountByStatus("SUCCESS");
            int failedCount = paymentDAO.getPaymentCountByStatus("FAILED");
            
            // Set attributes
            request.setAttribute("pendingPayments", pendingPayments);
            request.setAttribute("todayRevenue", todayRevenue);
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("successCount", successCount);
            request.setAttribute("failedCount", failedCount);
            request.setAttribute("currentUser", currentUser);
            
            // Set template attributes
            request.setAttribute("pageTitle", "Payments Management");
            request.setAttribute("activePage", "payments");
            // No need to set contentPage anymore as we're using direct includes
            
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading payments: " + e.getMessage());
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        try {
            switch (action) {
                case "recordPayment":
                    recordPayment(request, response);
                    break;
                case "updatePaymentStatus":
                    updatePaymentStatus(request, response);
                    break;
                case "getPaymentDetails":
                    getPaymentDetails(request, response);
                    break;
                case "searchPayments":
                    searchPayments(request, response);
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
    
    private void recordPayment(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            Gson gson = new Gson();
            Map<String, Object> paymentData = gson.fromJson(request.getReader(), Map.class);
            
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            
            Payment payment = new Payment();
            payment.setReservationId(((Double) paymentData.get("reservationId")).intValue());
            payment.setAmount(((Double) paymentData.get("amount")).doubleValue());
            payment.setMethod((String) paymentData.get("method"));
            payment.setStatus("SUCCESS");
            payment.setTransactionId((String) paymentData.get("transactionId"));
            
            boolean success = paymentDAO.createPayment(payment);
            
            if (success) {
                // Log activity
                Activity activity = new Activity();
                activity.setType("PAYMENT_RECEIVED");
                activity.setReservationId(payment.getReservationId());
                activity.setUserId(currentUser.getId());
                activity.setDescription("Payment received: " + payment.getAmount() + " via " + payment.getMethod());
                activity.setAmount(payment.getAmount());
                activity.setIpAddress(request.getRemoteAddr());
                activityDAO.logActivity(activity);
            }
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false}");
        }
    }
    
    private void updatePaymentStatus(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int paymentId = Integer.parseInt(request.getParameter("paymentId"));
            String newStatus = request.getParameter("status");
            String transactionId = request.getParameter("transactionId");
            
            boolean success = paymentDAO.updatePaymentStatus(paymentId, newStatus, transactionId);
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false}");
        }
    }
    
    private void getPaymentDetails(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("reservationId"));
            List<Payment> payments = paymentDAO.getPaymentsByReservation(reservationId);
            
            response.setContentType("application/json");
            Gson gson = new Gson();
            response.getWriter().write(gson.toJson(payments));
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private void searchPayments(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        // Implementation for searching payments
        response.setContentType("application/json");
        response.getWriter().write("{\"payments\":[]}");
    }
}