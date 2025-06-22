package controller;

import dal.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Random;

@WebServlet(name = "PaymentGatewayServlet", urlPatterns = {"/PaymentGateway"})
public class PaymentGatewayServlet extends HttpServlet {
    
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();
    
 @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    System.out.println("=== PaymentGatewayServlet.doGet() START ===");
    
    HttpSession session = request.getSession();
    String reservationIdStr = request.getParameter("reservationId");
    String paymentIdStr = request.getParameter("paymentId");
    String method = request.getParameter("method");
    
    System.out.println("Parameters received:");
    System.out.println("- reservationId: " + reservationIdStr);
    System.out.println("- paymentId: " + paymentIdStr);
    System.out.println("- method: " + method);
    System.out.println("- Session user: " + session.getAttribute("user"));
    
    // Validate parameters
    if (reservationIdStr == null || paymentIdStr == null || method == null) {
        System.out.println("ERROR: Missing required parameters!");
        System.out.println("- reservationIdStr is null: " + (reservationIdStr == null));
        System.out.println("- paymentIdStr is null: " + (paymentIdStr == null));
        System.out.println("- method is null: " + (method == null));
        response.sendRedirect("RoomListServlet");
        return;
    }
    
    try {
        int reservationId = Integer.parseInt(reservationIdStr);
        int paymentId = Integer.parseInt(paymentIdStr);
        
        System.out.println("Parsed successfully:");
        System.out.println("- reservationId: " + reservationId);
        System.out.println("- paymentId: " + paymentId);
        
        // Check if reservationDAO is initialized
        if (reservationDAO == null) {
            System.out.println("ERROR: reservationDAO is NULL!");
            response.sendRedirect("RoomListServlet");
            return;
        }
        
        System.out.println("Getting reservation from database...");
        
        // Get reservation details
        Reservation reservation = reservationDAO.getReservationById(reservationId);
        
        if (reservation == null) {
            System.out.println("ERROR: Reservation not found for ID: " + reservationId);
            System.out.println("Check if reservation exists in database");
            response.sendRedirect("RoomListServlet");
            return;
        }
        
        System.out.println("Reservation found:");
        System.out.println("- ID: " + reservation.getId());
        System.out.println("- Customer: " + reservation.getCustomerName());
        System.out.println("- Amount: " + reservation.getTotalAmount());
        System.out.println("- Room: " + reservation.getRoomNumber());
        System.out.println("- Status: " + reservation.getStatus());
        
        // Set attributes for payment page
        request.setAttribute("reservation", reservation);
        request.setAttribute("paymentId", paymentId);
        request.setAttribute("method", method);
        request.setAttribute("amount", reservation.getTotalAmount());
        
        System.out.println("Attributes set successfully");
        
        // Forward to appropriate payment page based on method
        String paymentPage = getPaymentPage(method);
        System.out.println("Forwarding to: " + paymentPage);
        
        // Check if JSP file exists
        String realPath = getServletContext().getRealPath(paymentPage);
        System.out.println("JSP real path: " + realPath);
        
        if (realPath != null) {
            java.io.File file = new java.io.File(realPath);
            System.out.println("JSP file exists: " + file.exists());
            if (!file.exists()) {
                System.out.println("ERROR: JSP file not found at: " + realPath);
                response.sendRedirect("RoomListServlet");
                return;
            }
        }
        
        System.out.println("About to forward to JSP...");
        request.getRequestDispatcher(paymentPage).forward(request, response);
        System.out.println("Forward completed successfully");
        
    } catch (NumberFormatException e) {
        System.out.println("ERROR: NumberFormatException - " + e.getMessage());
        e.printStackTrace();
        response.sendRedirect("RoomListServlet");
    } catch (Exception e) {
        System.out.println("ERROR: General Exception - " + e.getMessage());
        e.printStackTrace();
        response.sendRedirect("RoomListServlet");
    }
    
    System.out.println("=== PaymentGatewayServlet.doGet() END ===");
}

private String getPaymentPage(String method) {
    System.out.println("Getting payment page for method: " + method);
    
    String page;
    switch (method) {
        case "CREDIT_CARD":
            page = "/jsp/payment/credit-card.jsp";
            break;
        case "BANK_TRANSFER":
            page = "/jsp/payment/bank-transfer.jsp";
            break;
        case "VNPay":
            page = "/jsp/payment/vnpay.jsp";
            break;
        case "MoMo":
            page = "/jsp/payment/momo.jsp";
            break;
        default:
            System.out.println("Unknown method: " + method + ", using general payment page");
            page = "/jsp/payment/payment-general.jsp";
    }
    
    System.out.println("Selected page: " + page);
    return page;
}
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("processPayment".equals(action)) {
            processPayment(request, response);
        } else {
            response.sendRedirect("RoomListServlet");
        }
    }
    
    private void processPayment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        try {
            int paymentId = Integer.parseInt(request.getParameter("paymentId"));
            int reservationId = Integer.parseInt(request.getParameter("reservationId"));
            String method = request.getParameter("method");
            
            // Simulate payment processing
            boolean paymentSuccess = simulatePaymentProcessing(method);
            
            if (paymentSuccess) {
                // Generate transaction ID
                String transactionId = generateTransactionId(method);
                
                // Update payment status
                paymentDAO.updatePaymentStatus(paymentId, "SUCCESS", transactionId);
                
                // Update reservation status to CONFIRMED
                reservationDAO.updateReservationStatus(reservationId, "CONFIRMED");
                
                // Log activity
                Reservation reservation = reservationDAO.getReservationById(reservationId);
                Activity activity = new Activity();
                activity.setType("PAYMENT_RECEIVE");
                activity.setReservationId(reservationId);
                activity.setUserId(currentUser != null ? currentUser.getId() : reservation.getUserId());
                activity.setDescription("Payment received for reservation #" + reservationId);
                activity.setAmount(reservation.getTotalAmount());
                activity.setIpAddress(request.getRemoteAddr());
                activityDAO.logActivity(activity);
                
                // Clear session booking data
                session.removeAttribute("pendingBookingData");
                session.removeAttribute("pendingOTP");
                
                // Redirect to confirmation page
                response.sendRedirect("BookingConfirmation?reservationId=" + reservationId);
                
            } else {
                // Payment failed
                paymentDAO.updatePaymentStatus(paymentId, "FAILED", null);
                
                request.setAttribute("error", "Payment failed. Please try again.");
                request.setAttribute("reservationId", reservationId);
                request.getRequestDispatcher("/jsp/payment-failed.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("RoomListServlet");
        }
    }
    

 
    private boolean simulatePaymentProcessing(String method) {
        // In production, integrate with actual payment gateways
        // For now, simulate with 95% success rate
        Random random = new Random();
        return random.nextInt(100) < 95;
    }
    
    private String generateTransactionId(String method) {
        String prefix = method.toUpperCase().replace("_", "");
        return prefix + System.currentTimeMillis() + new Random().nextInt(1000);
    }
}