package controller;

import dal.*;
import model.*;
import service.EmailNotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Random;

@WebServlet(name = "PaymentGateway", urlPatterns = {"/PaymentGateway"})
public class PaymentGatewayServlet extends HttpServlet {
    
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();
    private final EmailNotificationService emailService = new EmailNotificationService(); // Thêm EmailNotificationService
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== PaymentGatewayServlet.doGet() START ===");
        
        try {
            // Get parameters
            String reservationIdStr = request.getParameter("reservationId");
            String method = request.getParameter("method");
            
            System.out.println("Received parameters:");
            System.out.println("- reservationId: " + reservationIdStr);
            System.out.println("- method: " + method);
            
            if (reservationIdStr == null || method == null) {
                System.out.println("ERROR: Missing required parameters");
                response.sendRedirect("RoomListServlet");
                return;
            }
            
            int reservationId = Integer.parseInt(reservationIdStr);
            
            // Get reservation details
            Reservation reservation = reservationDAO.getReservationById(reservationId);
            if (reservation == null) {
                System.out.println("ERROR: Reservation not found with ID: " + reservationId);
                response.sendRedirect("RoomListServlet");
                return;
            }
            
            System.out.println("Found reservation: #" + reservation.getId() + 
                             " - Total: " + reservation.getTotalAmount());
            
            // Get existing payment record
            Payment payment = paymentDAO.getPaymentByReservationId(reservationId);
            if (payment == null) {
                System.out.println("ERROR: No payment record found for reservation: " + reservationId);
                response.sendRedirect("RoomListServlet");
                return;
            }
            
            System.out.println("Found payment record: #" + payment.getId());
            
            // Calculate deposit amount (10% of total)
            double depositAmount = reservation.getTotalAmount() * 0.1;
            
            // Set request attributes
            request.setAttribute("reservation", reservation);
            request.setAttribute("paymentId", payment.getId());
            request.setAttribute("method", method);
            request.setAttribute("amount", reservation.getTotalAmount());
            request.setAttribute("depositAmount", depositAmount);
            
            System.out.println("Attributes set successfully");
            System.out.println("- Total amount: " + reservation.getTotalAmount());
            System.out.println("- Deposit amount (10%): " + depositAmount);
            
            // Forward to appropriate payment page based on method
            String paymentPage = getPaymentPage(method);
            System.out.println("Forwarding to: " + paymentPage);
            
            request.getRequestDispatcher(paymentPage).forward(request, response);
            
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
        
        // Get reservation details
        Reservation reservation = reservationDAO.getReservationById(reservationId);
        
        // Calculate deposit amount (10% of total)
        double depositAmount = reservation.getTotalAmount() * 0.1;
        
        // Simulate payment processing
        boolean paymentSuccess = simulatePaymentProcessing(method);
        
        if (paymentSuccess) {
            // Generate transaction ID
            String transactionId = generateTransactionId(method);
            
            // Update the initial payment record to be a deposit payment
            Payment payment = paymentDAO.getPaymentById(paymentId);
            payment.setAmount(depositAmount); // Update to deposit amount
            payment.setStatus("SUCCESS");
            payment.setTransactionId(transactionId);
            payment.setPaymentType("DEPOSIT"); //  Set payment type là DEPOSIT
            
            // Update payment in database
            paymentDAO.updatePayment(payment);
            
            // Update reservation deposit info and status
            reservation.setDepositAmount(depositAmount);
            reservation.setDepositPaidDate(new java.sql.Date(System.currentTimeMillis()));
            reservation.setDepositStatus("PAID");
            reservation.setStatus("CONFIRMED");

            // Persist deposit info
            paymentDAO.updateReservationDeposit(reservationId, depositAmount, "PAID");
            reservationDAO.updateReservationStatus(reservationId, "CONFIRMED");
            
            // Log activity
            Activity activity = new Activity();
            activity.setType("DEPOSIT_PAYMENT");
            activity.setReservationId(reservationId);
            activity.setUserId(currentUser != null ? currentUser.getId() : reservation.getUserId());
            activity.setDescription("Deposit payment received for reservation #" + reservationId + 
                                  " - Amount: " + depositAmount + " (10% of total)");
            activity.setAmount(depositAmount);
            activity.setIpAddress(request.getRemoteAddr());
            activityDAO.logActivity(activity);
            
            // GỬI EMAIL XÁC NHẬN THANH TOÁN
            try {
                emailService.sendPaymentConfirmation(reservation, payment);
                System.out.println("Payment confirmation email sent to: " + reservation.getCustomerEmail());
            } catch (Exception e) {
                // Log lỗi nhưng không làm thất bại quá trình thanh toán
                System.err.println("Failed to send payment confirmation email: " + e.getMessage());
                e.printStackTrace();
            }
            
            // Clear session booking data
            session.removeAttribute("pendingBookingData");
            session.removeAttribute("pendingOTP");
            
            // Add success message to session
            session.setAttribute("successMessage", 
                "Deposit payment of " + String.format("%,.0f", depositAmount) + 
                " VND (10%) has been received. Your reservation is confirmed!");
            
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
        return prefix + "-DEPOSIT-" + System.currentTimeMillis() + new Random().nextInt(1000);
    }
}