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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@WebServlet(name = "PaymentsServlet", urlPatterns = {"/receptionist/payments"})
public class PaymentsServlet extends HttpServlet {
    
    private static final Logger logger = LoggerFactory.getLogger(PaymentsServlet.class);
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final UserDAO userDAO = new UserDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();
    private final CheckInOutDAO checkInOutDAO = new CheckInOutDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"RECEPTIONIST".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        try {
            // Get filter parameters
            String status = request.getParameter("status");
            String method = request.getParameter("method");
            String paymentType = request.getParameter("paymentType");
            String fromDate = request.getParameter("fromDate");
            String toDate = request.getParameter("toDate");
            String search = request.getParameter("search");
            
            // Get filtered payments
            List<Payment> payments = paymentDAO.getFilteredPayments(status, method, paymentType, fromDate, toDate, search);
            
            // Get payment statistics
            Map<String, Object> paymentStats = new HashMap<>();
            Date today = new Date(System.currentTimeMillis());
            
            // Today's total
            double todayTotal = paymentDAO.getDailyRevenue(today);
            paymentStats.put("todayTotal", todayTotal);
            
            // Count by status
            int pendingCount = paymentDAO.getPaymentCountByStatus("PENDING");
            int successCount = paymentDAO.getPaymentCountByStatus("SUCCESS");
            int failedCount = paymentDAO.getPaymentCountByStatus("FAILED");
            paymentStats.put("pendingCount", pendingCount);
            paymentStats.put("successCount", successCount);
            paymentStats.put("failedCount", failedCount);
            
            // Count by payment type
            int depositCount = paymentDAO.getPaymentCountByType("DEPOSIT");
            int refundCount = paymentDAO.getPaymentCountByType("REFUND");
            paymentStats.put("depositCount", depositCount);
            paymentStats.put("refundsCount", refundCount);
            
            // Card vs Cash percentage
            int totalPayments = successCount + pendingCount + failedCount;
            int cardPayments = paymentDAO.getPaymentCountByMethodGroup("CARD");
            int cardPercentage = totalPayments > 0 ? (cardPayments * 100 / totalPayments) : 0;
            paymentStats.put("cardPayments", cardPercentage);
            
            // Calculate total amount
            double totalAmount = 0;
            for (Payment p : payments) {
                if ("SUCCESS".equals(p.getStatus()) && !"REFUND".equals(p.getPaymentType())) {
                    totalAmount += p.getAmount();
                } else if ("REFUND".equals(p.getPaymentType())) {
                    totalAmount -= p.getAmount();
                }
            }
            
            // Set attributes
            request.setAttribute("payments", payments);
            request.setAttribute("paymentStats", paymentStats);
            request.setAttribute("totalAmount", totalAmount);
            request.setAttribute("currentUser", currentUser);
            
            // Set template attributes
            request.setAttribute("pageTitle", "Payments Management");
            request.setAttribute("activePage", "payments");
            
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
            
        } catch (Exception e) {
            logger.error("Error loading payments", e);
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
                case "quickPayment":
                    processQuickPayment(request, response);
                    break;
                case "recordPayment":
                    recordPayment(request, response);
                    break;
                case "processRefund":
                    processRefund(request, response);
                    break;
                case "updatePaymentStatus":
                    updatePaymentStatus(request, response);
                    break;
                case "getPaymentDetails":
                    getPaymentDetails(request, response);
                    break;
                case "searchReservation":
                    searchReservation(request, response);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\":false,\"message\":\"Invalid action\"}");
            }
        } catch (Exception e) {
            logger.error("Error processing payment request", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private void processQuickPayment(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            // Get parameters
            String searchTerm = request.getParameter("searchTerm");
            String paymentMethod = request.getParameter("paymentMethod");
            double amount = Double.parseDouble(request.getParameter("amount"));
            String notes = request.getParameter("notes");
            
            // Search for reservation
            List<ReservationSummary> reservations = reservationDAO.searchReservations(searchTerm);
            if (reservations.isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"No reservation found\"}");
                return;
            }
            
            ReservationSummary reservation = reservations.get(0);
            
            // Determine payment type
            String paymentType = determinePaymentType(reservation.getId(), amount);
            
            // Create payment
            Payment payment = new Payment();
            payment.setReservationId(reservation.getId());
            payment.setAmount(amount);
            payment.setMethod(paymentMethod);
            payment.setStatus("SUCCESS");
            payment.setPaymentType(paymentType);
            payment.setTransactionId(generateTransactionId());
            
            boolean success = paymentDAO.createPayment(payment);
            
            if (success) {
                // Log activity
                HttpSession session = request.getSession();
                User currentUser = (User) session.getAttribute("user");
                logPaymentActivity(currentUser, payment, "Quick payment processed");
                
                response.getWriter().write("{\"success\":true,\"message\":\"Payment processed successfully\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Failed to process payment\"}");
            }
            
        } catch (Exception e) {
            logger.error("Error processing quick payment", e);
            response.getWriter().write("{\"success\":false,\"message\":\"Error: " + e.getMessage() + "\"}");
        }
    }
    
    private void recordPayment(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            // Get payment details
            int reservationId = Integer.parseInt(request.getParameter("reservationId"));
            double amount = Double.parseDouble(request.getParameter("amount"));
            String method = request.getParameter("paymentMethod");
            String paymentType = request.getParameter("paymentType");
            String notes = request.getParameter("notes");
            
            // Create payment
            Payment payment = new Payment();
            payment.setReservationId(reservationId);
            payment.setAmount(amount);
            payment.setMethod(method);
            payment.setStatus("SUCCESS");
            payment.setPaymentType(paymentType);
            payment.setTransactionId(generateTransactionId());
            
            boolean success = paymentDAO.createPayment(payment);
            
            if (success) {
                // Update reservation deposit status if it's a deposit payment
                if ("DEPOSIT".equals(paymentType)) {
                    reservationDAO.updateDepositStatus(reservationId, "PAID");
                }
                
                // Log activity
                HttpSession session = request.getSession();
                User currentUser = (User) session.getAttribute("user");
                logPaymentActivity(currentUser, payment, notes);
                
                response.getWriter().write("{\"success\":true,\"message\":\"Payment recorded successfully\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Failed to record payment\"}");
            }
            
        } catch (Exception e) {
            logger.error("Error recording payment", e);
            response.getWriter().write("{\"success\":false,\"message\":\"Error: " + e.getMessage() + "\"}");
        }
    }
    
    private void processRefund(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int paymentId = Integer.parseInt(request.getParameter("paymentId"));
            double refundAmount = Double.parseDouble(request.getParameter("refundAmount"));
            String refundMethod = request.getParameter("refundMethod");
            String refundReason = request.getParameter("refundReason");
            
            // Get original payment
            Payment originalPayment = paymentDAO.getPaymentById(paymentId);
            if (originalPayment == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Payment not found\"}");
                return;
            }
            
            // Create refund payment
            Payment refund = new Payment();
            refund.setReservationId(originalPayment.getReservationId());
            refund.setAmount(refundAmount);
            refund.setMethod(refundMethod);
            refund.setStatus("SUCCESS");
            refund.setPaymentType("REFUND");
            refund.setTransactionId("REFUND-" + generateTransactionId());
            
            boolean success = paymentDAO.createPayment(refund);
            
            if (success) {
                // Update original payment status if full refund
                if (refundAmount >= originalPayment.getAmount()) {
                    originalPayment.setStatus("REFUNDED");
                    paymentDAO.updatePayment(originalPayment);
                }
                
                // Log activity
                HttpSession session = request.getSession();
                User currentUser = (User) session.getAttribute("user");
                logPaymentActivity(currentUser, refund, "Refund processed: " + refundReason);
                
                response.getWriter().write("{\"success\":true,\"message\":\"Refund processed successfully\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Failed to process refund\"}");
            }
            
        } catch (Exception e) {
            logger.error("Error processing refund", e);
            response.getWriter().write("{\"success\":false,\"message\":\"Error: " + e.getMessage() + "\"}");
        }
    }
    
    private void updatePaymentStatus(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int paymentId = Integer.parseInt(request.getParameter("paymentId"));
            String status = request.getParameter("status");
            
            Payment payment = paymentDAO.getPaymentById(paymentId);
            if (payment == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Payment not found\"}");
                return;
            }
            
            payment.setStatus(status);
            boolean success = paymentDAO.updatePayment(payment);
            
            if (success) {
                // Log activity
                HttpSession session = request.getSession();
                User currentUser = (User) session.getAttribute("user");
                logPaymentActivity(currentUser, payment, "Payment status updated to " + status);
                
                response.getWriter().write("{\"success\":true,\"message\":\"Payment status updated\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Failed to update payment status\"}");
            }
            
        } catch (Exception e) {
            logger.error("Error updating payment status", e);
            response.getWriter().write("{\"success\":false,\"message\":\"Error: " + e.getMessage() + "\"}");
        }
    }
    
    private void getPaymentDetails(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int paymentId = Integer.parseInt(request.getParameter("paymentId"));
            Payment payment = paymentDAO.getPaymentById(paymentId);
            
            if (payment != null) {
                // Get additional details
                ReservationDetail reservation = reservationDAO.getReservationDetail(payment.getReservationId());
                payment.setCustomerName(reservation.getCustomerName());
                payment.setRoomNumber(reservation.getRoomNumber());
                
                response.setContentType("application/json");
                new Gson().toJson(payment, response.getWriter());
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\":\"Payment not found\"}");
            }
        } catch (Exception e) {
            logger.error("Error getting payment details", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private void searchReservation(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String query = request.getParameter("query");
            List<ReservationSummary> results = reservationDAO.searchReservations(query);
            
            // Filter active reservations
            results.removeIf(r -> "CANCELLED".equals(r.getStatus()) || "COMPLETED".equals(r.getStatus()));
            
            // Add payment info
            for (ReservationSummary res : results) {
                double totalPaid = paymentDAO.getReservationPaidAmount(res.getId());
                double balance = res.getTotalAmount() - totalPaid;
                res.setAmountPaid(totalPaid);
                res.setBalance(balance);
                
                // Check if deposit is paid
                boolean depositPaid = paymentDAO.isDepositPaid(res.getId());
                res.setDepositPaid(depositPaid);
            }
            
            response.setContentType("application/json");
            new Gson().toJson(results, response.getWriter());
            
        } catch (Exception e) {
            logger.error("Error searching reservations", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private String determinePaymentType(int reservationId, double amount) {
        try {
            ReservationDetail reservation = reservationDAO.getReservationDetail(reservationId);
            double totalPaid = paymentDAO.getReservationPaidAmount(reservationId);
            
            // Check if this is a deposit (typically 10% of total)
            double depositAmount = reservation.getTotalAmount() * 0.1;
            if (Math.abs(amount - depositAmount) < 1 && totalPaid == 0) {
                return "DEPOSIT";
            }
            
            // Check if this completes the payment
            if (totalPaid + amount >= reservation.getTotalAmount()) {
                return totalPaid > 0 ? "REMAINING_BALANCE" : "FULL_PAYMENT";
            }
            
            return "PARTIAL_PAYMENT";
        } catch (Exception e) {
            return "FULL_PAYMENT";
        }
    }
    
    private String generateTransactionId() {
        return "TXN" + System.currentTimeMillis();
    }
    
    private void logPaymentActivity(User user, Payment payment, String description) {
        try {
            Activity activity = new Activity();
            activity.setType("PAYMENT");
            activity.setReservationId(payment.getReservationId());
            activity.setUserId(user.getId());
            activity.setDescription(description);
            activity.setAmount(payment.getAmount());
            activity.setIpAddress("127.0.0.1"); // Get from request in real app
            activityDAO.logActivity(activity);
        } catch (Exception e) {
            logger.error("Error logging payment activity", e);
        }
    }
}