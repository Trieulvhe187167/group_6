package controller;

import dal.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
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
            
            // Add payment status and check if already checked out
            for (ReservationSummary res : todayCheckOuts) {
                res.setCheckedOut(checkInOutDAO.isCheckedOut(res.getId()));
                res.setPaymentStatus(paymentDAO.getReservationPaymentStatus(res.getId()));
                
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
                case "getAmenitiesUsage":
                    getAmenitiesUsage(request, response);
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
        String idParam = request.getParameter("id");
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
            
            // Calculate charges
            CheckOutDetail details = new CheckOutDetail();
            details.setId(reservation.getId());
            details.setRoomNumber(reservation.getRoomNumber());
            details.setCustomerName(reservation.getCustomerName());
            details.setCheckIn(reservation.getCheckIn());
            details.setCheckOut(reservation.getCheckOut());
            details.setRoomId(reservation.getRoomId());
            
            // Calculate nights
            long nights = (reservation.getCheckOut().getTime() - reservation.getCheckIn().getTime()) / (1000 * 60 * 60 * 24);
            details.setNights((int) nights);
            
            // Room charges
            details.setRoomCharges(reservation.getTotalAmount());
            
            // Service charges
            double serviceCharges = serviceDAO.getReservationServiceTotal(reservationId);
            details.setServiceCharges(serviceCharges);
            
            // Amount paid
            double amountPaid = paymentDAO.getReservationPaidAmount(reservationId);
            details.setAmountPaid(amountPaid);
            
            // Security deposit
            if (checkIn != null) {
                details.setSecurityDeposit(checkIn.getSecurityDeposit());
            }
            
            response.setContentType("application/json");
            new Gson().toJson(details, response.getWriter());
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid reservation ID format");
        }
    }
    
    private void getAmenitiesUsage(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String roomIdParam = request.getParameter("roomId");
        if (roomIdParam == null || roomIdParam.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Room ID is required");
            return;
        }
        
        try {
            int roomId = Integer.parseInt(roomIdParam);
            List<RoomAmenity> amenities = amenityDAO.getChargeableAmenities(roomId);
            
            response.setContentType("application/json");
            new Gson().toJson(amenities, response.getWriter());
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid room ID format");
        }
    }
    
    private void processCheckOut(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        // Parse JSON request
        CheckOutRequest checkOutRequest = new Gson().fromJson(request.getReader(), CheckOutRequest.class);
        
        if (!validateCheckOutRequest(checkOutRequest)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid check-out request");
            return;
        }
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        try {
            // Calculate total charges
            double amenityCharges = calculateAmenityCharges(checkOutRequest);
            
            // Get reservation details for final calculation
            Reservation reservation = reservationDAO.getReservationById(checkOutRequest.getReservationId());
            if (reservation == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Reservation not found");
                return;
            }
            
            double serviceCharges = serviceDAO.getReservationServiceTotal(checkOutRequest.getReservationId());
            double totalAmount = reservation.getTotalAmount() + serviceCharges + amenityCharges + checkOutRequest.getDamageCharges();
            double amountPaid = paymentDAO.getReservationPaidAmount(checkOutRequest.getReservationId());
            double finalAmount = totalAmount - amountPaid;
            
            // Get security deposit
            CheckInDetail checkIn = checkInOutDAO.getCheckInDetails(checkOutRequest.getReservationId());
            double refundAmount = 0;
            if (checkIn != null) {
                refundAmount = checkIn.getSecurityDeposit() - checkOutRequest.getDamageCharges();
            }
            
            // Create check-out record
            CheckOutDetail checkOut = createCheckOutDetail(checkOutRequest, currentUser.getId(), 
                    amenityCharges, serviceCharges, finalAmount, refundAmount);
            
            // Save check-out
            boolean success = checkInOutDAO.createCheckOut(checkOut);
            
            if (success) {
                // Update room status to DIRTY
                roomDAO.updateRoomStatus(reservation.getRoomId(), "DIRTY");
                
                // Update reservation status to COMPLETED
                reservationDAO.updateReservationStatus(checkOutRequest.getReservationId(), "COMPLETED");
                
                // Create housekeeping task for cleaning
                createHousekeepingTask(reservation.getRoomId());
                
                // Create final payment record if there's a balance
                if (finalAmount > 0) {
                    createFinalPayment(checkOutRequest, finalAmount);
                }
                
                // Log activity
                logCheckOutActivity(currentUser, reservation, finalAmount, request.getRemoteAddr());
            }
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (Exception e) {
            logger.error("Error processing check-out", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error processing check-out");
        }
    }
    
    private boolean validateCheckOutRequest(CheckOutRequest request) {
        return request != null && request.getReservationId() > 0;
    }
    
    private double calculateAmenityCharges(CheckOutRequest request) {
        double total = 0;
        if (request.getAmenitiesUsage() != null) {
            for (AmenityUsage usage : request.getAmenitiesUsage()) {
                total += usage.getQuantity() * usage.getUnitPrice();
                
                // Record amenity usage
                amenityDAO.recordAmenityUsage(
                    request.getReservationId(),
                    usage.getAmenityId(),
                    usage.getQuantity(),
                    usage.getUnitPrice(),
                    request.getReservationId()
                );
            }
        }
        return total;
    }
    
    private CheckOutDetail createCheckOutDetail(CheckOutRequest request, int userId,
            double amenityCharges, double serviceCharges, double finalAmount, double refundAmount) {
        CheckOutDetail checkOut = new CheckOutDetail();
        checkOut.setReservationId(request.getReservationId());
        checkOut.setRoomCondition(request.getRoomCondition());
        checkOut.setDamageDescription(request.getDamageDescription());
        checkOut.setDamageCharges(request.getDamageCharges());
        checkOut.setAmenityCharges(amenityCharges);
        checkOut.setServiceCharges(serviceCharges);
        checkOut.setFinalAmount(finalAmount);
        checkOut.setRefundAmount(refundAmount);
        checkOut.setPaymentMethod(request.getPaymentMethod());
        checkOut.setCheckOutNotes(request.getCheckOutNotes());
        checkOut.setCheckOutBy(userId);
        return checkOut;
    }
    
    private void createHousekeepingTask(int roomId) {
        HousekeepingTask task = new HousekeepingTask();
        task.setRoomId(roomId);
        task.setStatus("PENDING");
        task.setNotes("Room checked out - deep cleaning required");
        housekeepingDAO.createTask(task);
    }
    
    private void createFinalPayment(CheckOutRequest request, double finalAmount) {
        Payment payment = new Payment();
        payment.setReservationId(request.getReservationId());
        payment.setAmount(finalAmount);
        payment.setMethod(request.getPaymentMethod());
        payment.setStatus("SUCCESS");
        paymentDAO.createPayment(payment);
    }
    
    private void logCheckOutActivity(User user, Reservation reservation, double amount, String ipAddress) {
        Activity activity = new Activity();
        activity.setType("CHECK_OUT");
        activity.setReservationId(reservation.getId());
        activity.setUserId(user.getId());
        activity.setDescription("Checked out room " + roomDAO.getRoomById(reservation.getRoomId()).getRoomNumber());
        activity.setAmount(amount);
        activity.setIpAddress(ipAddress);
        activityDAO.logActivity(activity);
    }
}

// Helper classes for JSON parsing
class CheckOutRequest {
    private int reservationId;
    private String roomCondition;
    private String damageDescription;
    private double damageCharges;
    private List<AmenityUsage> amenitiesUsage;
    private String paymentMethod;
    private String checkOutNotes;
    
    // Getters and setters
    public int getReservationId() { return reservationId; }
    public void setReservationId(int reservationId) { this.reservationId = reservationId; }
    public String getRoomCondition() { return roomCondition; }
    public void setRoomCondition(String roomCondition) { this.roomCondition = roomCondition; }
    public String getDamageDescription() { return damageDescription; }
    public void setDamageDescription(String damageDescription) { this.damageDescription = damageDescription; }
    public double getDamageCharges() { return damageCharges; }
    public void setDamageCharges(double damageCharges) { this.damageCharges = damageCharges; }
    public List<AmenityUsage> getAmenitiesUsage() { return amenitiesUsage; }
    public void setAmenitiesUsage(List<AmenityUsage> amenitiesUsage) { this.amenitiesUsage = amenitiesUsage; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getCheckOutNotes() { return checkOutNotes; }
    public void setCheckOutNotes(String checkOutNotes) { this.checkOutNotes = checkOutNotes; }
}

class AmenityUsage {
    private int amenityId;
    private int quantity;
    private double unitPrice;
    
    public int getAmenityId() { return amenityId; }
    public void setAmenityId(int amenityId) { this.amenityId = amenityId; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }
}