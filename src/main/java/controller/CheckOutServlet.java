package controller;

import dal.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;
import java.sql.Date;
import java.time.LocalDate;
import com.google.gson.Gson;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@WebServlet(name = "CheckOutServlet", urlPatterns = {"/receptionist/check-out"})
public class CheckOutServlet extends HttpServlet {
    
    private static final Logger logger = LoggerFactory.getLogger(CheckOutServlet.class);
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final CheckInOutDAO checkInOutDAO = new CheckInOutDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();
    private final HousekeepingTaskDAO housekeepingDAO = new HousekeepingTaskDAO();
    private final RoomAmenityDAO amenityDAO = new RoomAmenityDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final RoomInspectionDAO inspectionDAO = new RoomInspectionDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check receptionist authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"RECEPTIONIST".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        try {
            // Get today's check-outs
            Date today = Date.valueOf(LocalDate.now());
            List<ReservationSummary> todayCheckOuts = checkInOutDAO.getUpcomingCheckOuts(24);
            
            // Add payment status, inspection status and check if already checked out
            for (ReservationSummary res : todayCheckOuts) {
                res.setCheckedOut(checkInOutDAO.isCheckedOut(res.getId()));
                res.setPaymentStatus(paymentDAO.getReservationPaymentStatus(res.getId()));
                
                // Get inspection status
                RoomInspection inspection = inspectionDAO.getInspectionByReservationId(res.getId());
                if (inspection != null) {
                    res.setInspectionStatus(inspection.getStatus());
                }
                
                // Check if late checkout
                if (res.getCheckOut().before(today)) {
                    res.setLate(true);
                }
            }
            
            // Set attributes
            request.setAttribute("todayCheckOuts", todayCheckOuts);
            request.setAttribute("currentUser", currentUser);
            
            // Set template attributes
            request.setAttribute("pageTitle", "Check-out Management");
            request.setAttribute("activePage", "checkout");
            
            // Forward to template
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
            
        } catch (Exception e) {
            logger.error("Error loading check-out data", e);
            request.setAttribute("error", "Error loading check-out data: " + e.getMessage());
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action parameter is required");
            return;
        }
        
        try {
            switch (action) {
                case "searchCheckOut":
                    searchCheckOut(request, response);
                    break;
                case "getCheckOutDetails":
                    getCheckOutDetails(request, response);
                    break;
                case "processCheckOut":
                    processCheckOut(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (Exception e) {
            logger.error("Error processing request", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred while processing your request");
        }
    }
    
    private void searchCheckOut(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String query = request.getParameter("query");
        if (query == null || query.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Search query is required");
            return;
        }
        
        List<ReservationSummary> results = reservationDAO.searchReservations(query);
        
        // Filter only occupied rooms
        results.removeIf(r -> !"CONFIRMED".equals(r.getStatus()) || !checkInOutDAO.isCheckedIn(r.getId()));
        
        response.setContentType("application/json");
        new Gson().toJson(results, response.getWriter());
    }
    
    private void getCheckOutDetails(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String idParam = request.getParameter("reservationId");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Reservation ID is required");
            return;
        }
        
        try {
            int reservationId = Integer.parseInt(idParam);
            
            // Get reservation details
            ReservationDetail reservation = reservationDAO.getReservationDetail(reservationId);
            if (reservation == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Reservation not found");
                return;
            }
            
            // Get check-in details for security deposit
            CheckInDetail checkIn = checkInOutDAO.getCheckInDetails(reservationId);
            
            // Get inspection data
            RoomInspection inspection = inspectionDAO.getInspectionByReservationId(reservationId);
            
            // Get confirmed service orders for this reservation
            List<ServiceOrder> serviceOrders = serviceDAO.getServiceOrdersByReservation(reservationId)
                    .stream()
                    .filter(o -> "CONFIRMED".equalsIgnoreCase(o.getStatus()))
                    .collect(Collectors.toList());
            // Create response object
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("reservation", reservation);
            responseData.put("checkIn", checkIn);
            responseData.put("serviceOrders", serviceOrders);
            
            // Add inspection data if available
            if (inspection != null) {
                // Get full inspection details including items and damages
                inspection = inspectionDAO.getInspectionById(inspection.getId());
                
                Map<String, Object> inspectionData = new HashMap<>();
                inspectionData.put("id", inspection.getId());
                inspectionData.put("inspectorName", inspection.getInspector() != null ? 
                inspection.getInspector().getFullName() : "Unknown");
                inspectionData.put("inspectionTime", inspection.getInspectionTime());
                inspectionData.put("roomCondition", inspection.getRoomCondition());
                inspectionData.put("cleanlinessScore", inspection.getCleanlinessScore());
                inspectionData.put("notes", inspection.getNotes());
                inspectionData.put("status", inspection.getStatus());
                
                // Add inspection items (minibar, amenities, services)
                if (inspection.getInspectionItems() != null) {
                    inspectionData.put("inspectionItems", inspection.getInspectionItems());
                }
                
                // Add room damages
                if (inspection.getRoomDamages() != null) {
                    inspectionData.put("roomDamages", inspection.getRoomDamages());
                }
                
                responseData.put("inspection", inspectionData);
                
                // Calculate charges from inspection
                Map<String, Double> charges = new HashMap<>();
                charges.put("minibar", inspection.getTotalItemCharges().doubleValue());
                charges.put("damages", inspection.getTotalDamageCharges().doubleValue());
                double serviceTotal = serviceOrders.stream().mapToDouble(ServiceOrder::getTotalAmount).sum();
                charges.put("services", serviceTotal);
                responseData.put("charges", charges);
            } else {
                // No inspection data - set default charges
                Map<String, Double> charges = new HashMap<>();
                charges.put("minibar", 0.0);
                charges.put("damages", 0.0);
                 double serviceTotal = serviceOrders.stream().mapToDouble(ServiceOrder::getTotalAmount).sum();
                charges.put("services", serviceTotal);
                responseData.put("charges", charges);
            }
            
    
            // Add payment info
            double amountPaid = paymentDAO.getReservationPaidAmount(reservationId);
            responseData.put("amountPaid", amountPaid);
             // Add reservation deposit amount if paid
            double depositPaid = paymentDAO.getTotalDepositPaid(reservationId);
            responseData.put("depositPaid", depositPaid);
            
            // Add security deposit if available
            if (checkIn != null) {
                responseData.put("securityDeposit", checkIn.getSecurityDeposit());
            }
            
            response.setContentType("application/json");
            new Gson().toJson(responseData, response.getWriter());
            
        } catch (Exception e) {
            logger.error("Error getting checkout details", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading checkout details");
        }
    }
    
    private void processCheckOut(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
          // Validate current user
        if (currentUser == null || !"RECEPTIONIST".equals(currentUser.getRole())) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false, \"message\":\"Unauthorized\"}");
            return;
        }
        
        try {
            // Get form parameters
            int reservationId = Integer.parseInt(request.getParameter("reservationId"));
            String paymentMethod = request.getParameter("paymentMethod");
            String checkOutNotes = request.getParameter("checkOutNotes");
            
            // Get reservation and inspection data
            Reservation reservation = reservationDAO.getReservationById(reservationId);
            if (reservation == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Reservation not found");
                return;
            }
            
            RoomInspection inspection = inspectionDAO.getInspectionByReservationId(reservationId);
            
            // Calculate total charges
            double roomCharges = reservation.getTotalAmount();
            double serviceCharges = serviceDAO.getReservationServiceTotal(reservationId);
            double inspectionCharges = 0;
            double damageCharges = 0;
            
            if (inspection != null) {
                // Get full inspection details
                inspection = inspectionDAO.getInspectionById(inspection.getId());
                inspectionCharges = inspection.getTotalItemCharges().doubleValue();
                damageCharges = inspection.getTotalDamageCharges().doubleValue();
            }
            
            double totalAmount = roomCharges + serviceCharges + inspectionCharges + damageCharges;

             // Deduct any deposit paid separately so it reflects in the final balance
            double depositPaid = paymentDAO.getTotalDepositPaid(reservationId);
            
            // Previous payments are only the guest deposit so deduct that from the total
            double finalAmount = totalAmount - depositPaid;
            
            // Get security deposit and calculate refund
            CheckInDetail checkIn = checkInOutDAO.getCheckInDetails(reservationId);
            double securityDeposit = checkIn != null ? checkIn.getSecurityDeposit() : 0;
            double refundAmount = Math.max(0, securityDeposit - damageCharges);
            
            // Adjust final amount if there's a refund
            if (refundAmount > 0) {
                finalAmount = finalAmount - refundAmount;
            }
            
            // Create check-out record
            CheckOutDetail checkOut = new CheckOutDetail();
            checkOut.setReservationId(reservationId);
            checkOut.setRoomCondition(inspection != null ? inspection.getRoomCondition() : "GOOD");
            checkOut.setAmenityCharges(inspectionCharges);
            checkOut.setServiceCharges(serviceCharges);
            checkOut.setDamageCharges(damageCharges);
            checkOut.setFinalAmount(Math.max(0, finalAmount));
            checkOut.setRefundAmount(refundAmount);
            checkOut.setPaymentMethod(paymentMethod);
            checkOut.setCheckOutNotes(checkOutNotes);
            checkOut.setCheckOutBy(currentUser.getId());
            
            // Save check-out
            boolean success = checkInOutDAO.createCheckOut(checkOut);
            
            if (success) {
                // Update room status to DIRTY
                roomDAO.updateRoomStatus(reservation.getRoomId(), "DIRTY");
                
                // Update reservation status to COMPLETED
                reservationDAO.updateReservationStatus(reservationId, "COMPLETED");
                
                // Create housekeeping task for cleaning
                createHousekeepingTask(reservation.getRoomId());
                
                // Create final payment record if there's a balance
                if (finalAmount > 0) {
                    createFinalPayment(reservationId, finalAmount, paymentMethod);
                }
                
                // Process refund if applicable
                if (refundAmount > 0) {
                    processRefund(reservationId, refundAmount, paymentMethod);
                }
                
                // Log activity
                logCheckOutActivity(currentUser, reservation, totalAmount, request.getRemoteAddr());
                
                // Update inspection status to COMPLETED if exists
                if (inspection != null) {
                    inspectionDAO.updateInspectionStatus(inspection.getId(), "COMPLETED");
                }
            }
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + ", \"message\":\"Check-out completed successfully\"}");
            
        } catch (Exception e) {
            logger.error("Error processing check-out", e);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false, \"message\":\"Error processing check-out: " + e.getMessage() + "\"}");
        }
    }
    
    private void createHousekeepingTask(int roomId) {
        try {
            HousekeepingTask task = new HousekeepingTask();
            task.setRoomId(roomId);
            task.setStatus("PENDING");
            task.setNotes("Room checked out - deep cleaning required");
            housekeepingDAO.createTask(task);
        } catch (Exception e) {
            logger.error("Error creating housekeeping task", e);
        }
    }
    
    private void createFinalPayment(int reservationId, double amount, String paymentMethod) {
        try {
            Payment payment = new Payment();
            payment.setReservationId(reservationId);
            payment.setAmount(amount);
            payment.setMethod(paymentMethod);
            payment.setStatus("SUCCESS");
             // Use the enum value supported by the Payments table
            // FINAL_PAYMENT is stored as REMAINING_BALANCE
            payment.setPaymentType("REMAINING_BALANCE");
            paymentDAO.createPayment(payment);
        } catch (Exception e) {
            logger.error("Error creating final payment", e);
        }
    }
    
    private void processRefund(int reservationId, double refundAmount, String refundMethod) {
        try {
            Payment refund = new Payment();
            refund.setReservationId(reservationId);
            refund.setAmount(-refundAmount); // Negative amount for refund
            refund.setMethod(refundMethod);
            refund.setStatus("SUCCESS");
            refund.setPaymentType("REFUND");
            paymentDAO.createPayment(refund);
        } catch (Exception e) {
            logger.error("Error processing refund", e);
        }
    }
    
    private void logCheckOutActivity(User user, Reservation reservation, double amount, String ipAddress) {
        try {
            Activity activity = new Activity();
            activity.setType("CHECK_OUT");
            activity.setReservationId(reservation.getId());
            activity.setUserId(user.getId());
            activity.setDescription("Checked out room " + roomDAO.getRoomById(reservation.getRoomId()).getRoomNumber());
            activity.setAmount(amount);
            activity.setIpAddress(ipAddress);
            activityDAO.logActivity(activity);
        } catch (Exception e) {
            logger.error("Error logging activity", e);
        }
    }
}