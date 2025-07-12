package controller;

import dal.*;
import model.*;
import service.EmailNotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.Map;
import java.util.HashMap;

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
            String reservationIdsStr = request.getParameter("reservationIds");
            String reservationIdStr = request.getParameter("reservationId");
            String paymentIdsStr = request.getParameter("paymentIds");
            String method = request.getParameter("method");

            System.out.println("Received parameters:");
            System.out.println("- reservationIds: " + reservationIdsStr);
            System.out.println("- reservationId: " + reservationIdStr);
            System.out.println("- paymentIds: " + paymentIdsStr);
            System.out.println("- method: " + method);

            List<Integer> reservationIds = new ArrayList<>();
            List<Integer> paymentIds = new ArrayList<>();

            if (reservationIdsStr != null && !reservationIdsStr.isEmpty()) {
                for (String s : reservationIdsStr.split(",")) {
                    reservationIds.add(Integer.parseInt(s.trim()));
                }
            } else if (reservationIdStr != null) {
                reservationIds.add(Integer.parseInt(reservationIdStr));
            }

            if (paymentIdsStr != null && !paymentIdsStr.isEmpty()) {
                for (String s : paymentIdsStr.split(",")) {
                    paymentIds.add(Integer.parseInt(s.trim()));
                }
            }

            if (reservationIds.isEmpty() || method == null) {
                System.out.println("ERROR: Missing required parameters");
                response.sendRedirect("SearchAvailableRoomsServlet");
                return;
            }

            double totalAmount = 0;
            List<Reservation> reservations = new ArrayList<>();
            for (int id : reservationIds) {
                Reservation res = reservationDAO.getReservationById(id);
                if (res != null) {
                    reservations.add(res);
                    totalAmount += res.getTotalAmount();
                }
            }

            if (reservations.isEmpty()) {
                System.out.println("ERROR: No reservations found");
                response.sendRedirect("SearchAvailableRoomsServlet");
                return;
            }
            Reservation reservation = reservations.get(0);

            Payment payment = paymentDAO.getPaymentByReservationId(reservation.getId());
            if (payment == null && !paymentIds.isEmpty()) {
                payment = paymentDAO.getPaymentById(paymentIds.get(0));
            }
            if (payment == null) {
                System.out.println("ERROR: No payment record found");
                response.sendRedirect("SearchAvailableRoomsServlet");
                return;
            }

             double depositAmount = Math.round(totalAmount * 0.1 * 100.0) / 100.0;
            // Set request attributes
            request.setAttribute("reservation", reservation);
             request.setAttribute("reservations", reservations);
             request.setAttribute("reservationList", reservations);
            request.setAttribute("paymentId", payment.getId());
            request.setAttribute("reservationIdsStr", reservationIdsStr);
            request.setAttribute("paymentIdsStr", paymentIdsStr);
            request.setAttribute("method", method);
            request.setAttribute("amount", totalAmount);
            request.setAttribute("depositAmount", depositAmount);

            System.out.println("Attributes set successfully");
            System.out.println("- Total amount: " + totalAmount);
            System.out.println("- Deposit amount (10%): " + depositAmount);

            // Forward to appropriate payment page based on method
            String paymentPage = getPaymentPage(method);
            System.out.println("Forwarding to: " + paymentPage);

            request.getRequestDispatcher(paymentPage).forward(request, response);

        } catch (NumberFormatException e) {
            System.out.println("ERROR: NumberFormatException - " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("SearchAvailableRoomsServlet");
        } catch (Exception e) {
            System.out.println("ERROR: General Exception - " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("SearchAvailableRoomsServlet");
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
            response.sendRedirect("SearchAvailableRoomsServlet");
        }
    }

    private void processPayment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        try {
             String reservationIdsStr = request.getParameter("reservationIds");
             String paymentIdsStr = request.getParameter("paymentIds");
            String method = request.getParameter("method");

        
        List<Integer> reservationIds = new ArrayList<>();
        List<Integer> paymentIds = new ArrayList<>();

        if (reservationIdsStr != null && !reservationIdsStr.isEmpty()) {
            for (String s : reservationIdsStr.split(",")) {
                reservationIds.add(Integer.parseInt(s.trim()));
            }
        } else {
            reservationIds.add(Integer.parseInt(request.getParameter("reservationId")));
        }

        if (paymentIdsStr != null && !paymentIdsStr.isEmpty()) {
            for (String s : paymentIdsStr.split(",")) {
                paymentIds.add(Integer.parseInt(s.trim()));
            }
        } else {
            paymentIds.add(Integer.parseInt(request.getParameter("paymentId")));
        }

        double totalAmount = 0;
        List<Reservation> reservations = new ArrayList<>();
        for (int id : reservationIds) {
            Reservation r = reservationDAO.getReservationById(id);
            if (r != null) {
                reservations.add(r);
                totalAmount += r.getTotalAmount();
            }
        }

        if (reservations.isEmpty()) {
            response.sendRedirect("SearchAvailableRoomsServlet");
            return;
        }

           // Calculate total deposit (10% of the whole booking)
        double totalDeposit = Math.round(totalAmount * 0.1 * 100.0) / 100.0;
       
        
        java.util.Map<Integer, Double> depositMap = new java.util.HashMap<>();
        
        for (Reservation r : reservations) {
            double deposit = Math.round(r.getTotalAmount() * 0.1 * 100.0) / 100.0;
            depositMap.put(r.getId(), deposit);
        }
        

            // Simulate payment processing
            boolean paymentSuccess = simulatePaymentProcessing(method);

            if (paymentSuccess) {
                // Generate transaction ID
                String transactionId = generateTransactionId(method);

              
            for (int i = 0; i < reservations.size(); i++) {
                Reservation res = reservations.get(i);
                double perReservationDeposit = depositMap.get(res.getId());
                int payId = (i < paymentIds.size()) ? paymentIds.get(i) : paymentIds.get(0);
              
                
                Payment payment = paymentDAO.getPaymentById(payId);
                if (payment != null) {
                    payment.setAmount(perReservationDeposit);
                    payment.setStatus("SUCCESS");
                    payment.setTransactionId(transactionId);
                    payment.setPaymentType("DEPOSIT");
                    paymentDAO.updatePayment(payment);
                } 

                res.setDepositAmount(perReservationDeposit);
                res.setDepositPaidDate(new java.sql.Date(System.currentTimeMillis()));
                res.setDepositStatus("PAID");
                res.setStatus("CONFIRMED");

                paymentDAO.updateReservationDeposit(res.getId(), perReservationDeposit, "PAID");
                reservationDAO.updateReservationStatus(res.getId(), "CONFIRMED");

                Activity activity = new Activity();
                activity.setType("DEPOSIT_PAYMENT");
                activity.setReservationId(res.getId());
                activity.setUserId(currentUser != null ? currentUser.getId() : res.getUserId());
                activity.setDescription("Deposit payment received for reservation #" + res.getId() +
                                      " - Amount: " + perReservationDeposit);
                activity.setAmount(perReservationDeposit);
                activity.setIpAddress(request.getRemoteAddr());
                activityDAO.logActivity(activity);
            }

                  // Send payment confirmation email
                try {
                   if (reservations.size() > 1) {
                   emailService.sendGroupPaymentConfirmation(reservations, totalDeposit, method, transactionId);
                } else {
                    emailService.sendPaymentConfirmation(reservations.get(0), paymentDAO.getPaymentById(paymentIds.get(0)));
                }
                    System.out.println("Payment confirmation email sent" );
                } catch (Exception e) {
                     // Log but do not fail payment process
                    System.err.println("Failed to send payment confirmation email: " + e.getMessage());
                    e.printStackTrace();
                }

                // Clear session booking data
                session.removeAttribute("pendingBookingData");
                session.removeAttribute("pendingOTP");

                // Add success message to session
               session.setAttribute("successMessage",
                "Deposit payment of " + String.format("%,.0f", totalDeposit)
                        + " VND (10%) has been received. Your reservation is confirmed!");

                             // Redirect to confirmation page
            if (reservations.size() > 1) {
                response.sendRedirect("BookingConfirmation?reservationIds=" + reservationIdsStr);
            } else {
                response.sendRedirect("BookingConfirmation?reservationId=" + reservations.get(0).getId());
            }

            } else {
                // Payment failed
                for (int pid : paymentIds) {
                paymentDAO.updatePaymentStatus(pid, "FAILED", null);
            }

                request.setAttribute("error", "Payment failed. Please try again.");
                request.getRequestDispatcher("/jsp/payment-failed.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("SearchAvailableRoomsServlet");
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
