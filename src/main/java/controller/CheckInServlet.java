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
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "CheckInServlet", urlPatterns = {"/receptionist/check-in"})
public class CheckInServlet extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(CheckInServlet.class.getName());
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final CheckInOutDAO checkInOutDAO = new CheckInOutDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();
    private final HousekeepingTaskDAO housekeepingDAO = new HousekeepingTaskDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check receptionist authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"RECEPTIONIST".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        try {
            // Get today's check-ins
            Date today = Date.valueOf(LocalDate.now());
            List<ReservationSummary> todayCheckIns = checkInOutDAO.getUpcomingCheckIns(24); // Next 24 hours
            
            // Add checked-in status
            for (ReservationSummary res : todayCheckIns) {
                res.setCheckedIn(checkInOutDAO.isCheckedIn(res.getId()));
            }
            
            // Set attributes
            request.setAttribute("todayCheckIns", todayCheckIns);
            request.setAttribute("currentUser", currentUser);
            
            // Set template attributes
            request.setAttribute("pageTitle", "Check-in Management");
            request.setAttribute("activePage", "checkin");
            
              // Forward to template
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading check-in page: " + e.getMessage());
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        try {
            switch (action) {
                case "searchReservation":
                    searchReservation(request, response);
                    break;
                case "processCheckIn":
                    processCheckIn(request, response);
                    break;
                case "getReservation":
                    getReservation(request, response);
                    break;
                case "getRoomAmenities":
                    getRoomAmenities(request, response);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"error\":\"Invalid action\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing request", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private void searchReservation(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String query = request.getParameter("query");
        if (query == null || query.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Search query is required\"}");
            return;
        }
        
        try {
            List<ReservationSummary> results = reservationDAO.searchReservations(query);
            
            // Filter only today's check-ins or pending check-ins
            Date today = Date.valueOf(LocalDate.now());
            results.removeIf(r -> !r.getCheckIn().equals(today) || "CANCELLED".equals(r.getStatus()));
            
            // Add checked-in status
            for (ReservationSummary res : results) {
                res.setCheckedIn(checkInOutDAO.isCheckedIn(res.getId()));
            }
            
            response.setContentType("application/json");
            Gson gson = new Gson();
            response.getWriter().write(gson.toJson(results));
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error searching reservations", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private void getReservation(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Reservation ID is required\"}");
            return;
        }
        
        try {
            int reservationId = Integer.parseInt(idStr);
            ReservationDetail reservation = reservationDAO.getReservationDetail(reservationId);
            
            if (reservation == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\":\"Reservation not found\"}");
                return;
            }
            
            response.setContentType("application/json");
            Gson gson = new Gson();
            response.getWriter().write(gson.toJson(reservation));
            
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Invalid reservation ID format\"}");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting reservation", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private void getRoomAmenities(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String roomIdStr = request.getParameter("roomId");
        if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Room ID is required\"}");
            return;
        }
        
        try {
            int roomId = Integer.parseInt(roomIdStr);
            List<RoomAmenity> amenities = new RoomAmenityDAO().getRoomAmenities(roomId);
            
            response.setContentType("application/json");
            Gson gson = new Gson();
            response.getWriter().write(gson.toJson(amenities));
            
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Invalid room ID format\"}");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting room amenities", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private void processCheckIn(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            // Parse JSON request
            Gson gson = new Gson();
            CheckInRequest checkInRequest = gson.fromJson(request.getReader(), CheckInRequest.class);
            
            // Validate required fields
            if (!validateCheckInRequest(checkInRequest)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"Missing required fields\"}");
                return;
            }
            
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            
            // Create check-in detail
            CheckInDetail checkIn = new CheckInDetail();
            checkIn.setReservationId(checkInRequest.getReservationId());
            checkIn.setIdType(checkInRequest.getIdType());
            checkIn.setIdNumber(checkInRequest.getIdNumber());
            checkIn.setAdditionalGuests(checkInRequest.getAdditionalGuests());
            checkIn.setSecurityDeposit(checkInRequest.getSecurityDeposit());
            checkIn.setKeyCards(checkInRequest.getKeyCards());
            checkIn.setKeyCardNumbers(checkInRequest.getKeyCardNumbers());
            checkIn.setCheckInNotes(checkInRequest.getCheckInNotes());
            checkIn.setCheckInBy(currentUser.getId());
            
            // Save check-in
            boolean success = checkInOutDAO.createCheckIn(checkIn);
            
            if (success) {
                // Update room status to OCCUPIED
                Reservation reservation = reservationDAO.getReservationById(checkInRequest.getReservationId());
                roomDAO.updateRoomStatus(reservation.getRoomId(), "OCCUPIED");
                
                // Create housekeeping task for room preparation
                HousekeepingTask task = new HousekeepingTask();
                task.setRoomId(reservation.getRoomId());
                task.setStatus("PENDING");
                task.setNotes("Guest checked in - daily cleaning required");
                housekeepingDAO.createTask(task);
                
                // Save amenity inventory
                if (checkInRequest.getAmenities() != null) {
                    RoomAmenityDAO amenityDAO = new RoomAmenityDAO();
                    for (AmenityCheck amenity : checkInRequest.getAmenities()) {
                        amenityDAO.recordAmenityInventory(
                            checkInRequest.getReservationId(),
                            amenity.getAmenityId(),
                            amenity.isPresent() ? 1 : 0,
                            currentUser.getId()
                        );
                    }
                }
                
                // Log activity
                Activity activity = new Activity();
                activity.setType("CHECK_IN");
                activity.setReservationId(checkInRequest.getReservationId());
                activity.setUserId(currentUser.getId());
                activity.setDescription("Checked in guest to room " + roomDAO.getRoomById(reservation.getRoomId()).getRoomNumber());
                activity.setIpAddress(request.getRemoteAddr());
                activityDAO.logActivity(activity);
            }
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing check-in", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private boolean validateCheckInRequest(CheckInRequest request) {
        return request != null 
            && request.getReservationId() > 0
            && request.getIdType() != null && !request.getIdType().trim().isEmpty()
            && request.getIdNumber() != null && !request.getIdNumber().trim().isEmpty()
            && request.getKeyCards() > 0
            && request.getKeyCardNumbers() != null && !request.getKeyCardNumbers().trim().isEmpty();
    }
}

// Helper classes for JSON parsing
class CheckInRequest {
    private int reservationId;
    private String idType;
    private String idNumber;
    private int additionalGuests;
    private double securityDeposit;
    private int keyCards;
    private String keyCardNumbers;
    private String checkInNotes;
    private List<AmenityCheck> amenities;
    
    // Getters and setters
    public int getReservationId() { return reservationId; }
    public void setReservationId(int reservationId) { this.reservationId = reservationId; }
    public String getIdType() { return idType; }
    public void setIdType(String idType) { this.idType = idType; }
    public String getIdNumber() { return idNumber; }
    public void setIdNumber(String idNumber) { this.idNumber = idNumber; }
    public int getAdditionalGuests() { return additionalGuests; }
    public void setAdditionalGuests(int additionalGuests) { this.additionalGuests = additionalGuests; }
    public double getSecurityDeposit() { return securityDeposit; }
    public void setSecurityDeposit(double securityDeposit) { this.securityDeposit = securityDeposit; }
    public int getKeyCards() { return keyCards; }
    public void setKeyCards(int keyCards) { this.keyCards = keyCards; }
    public String getKeyCardNumbers() { return keyCardNumbers; }
    public void setKeyCardNumbers(String keyCardNumbers) { this.keyCardNumbers = keyCardNumbers; }
    public String getCheckInNotes() { return checkInNotes; }
    public void setCheckInNotes(String checkInNotes) { this.checkInNotes = checkInNotes; }
    public List<AmenityCheck> getAmenities() { return amenities; }
    public void setAmenities(List<AmenityCheck> amenities) { this.amenities = amenities; }
}

class AmenityCheck {
    private int amenityId;
    private boolean present;
    
    public int getAmenityId() { return amenityId; }
    public void setAmenityId(int amenityId) { this.amenityId = amenityId; }
    public boolean isPresent() { return present; }
    public void setPresent(boolean present) { this.present = present; }
}