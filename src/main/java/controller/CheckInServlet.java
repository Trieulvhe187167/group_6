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
import java.time.DayOfWeek;
import java.time.format.DateTimeFormatter;
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
    private final RoomAmenityDAO amenityDAO = new RoomAmenityDAO();
    
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
   
            // Get today's check-ins including already completed ones
            List<Reservation> todayCheckIns = reservationDAO.getTodayCheckIns();
            
            // Add checked-in status
            for (Reservation res : todayCheckIns) {
                res.setCheckedIn(checkInOutDAO.isCheckedIn(res.getId()));
            }
            
            // Get available rooms count
            int availableRooms = roomDAO.getAvailableRoomsCount();
            
            // Set attributes
            request.setAttribute("todayCheckIns", todayCheckIns);
            request.setAttribute("currentUser", currentUser);
            request.setAttribute("availableRooms", availableRooms);
            
            // Set template attributes
            request.setAttribute("pageTitle", "Check-in Management");
            request.setAttribute("activePage", "checkin");
            request.setAttribute("contentPage", "/jsp/reception/check-in-content.jsp");
            
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
        if (action == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Action parameter is required\"}");
            return;
        }
        
        try {
            switch (action) {
                case "searchReservation":
                    searchReservation(request, response);
                    break;
                case "getReservationDetails":
                    getReservationDetails(request, response);
                    break;
                case "getRoomAmenities":
                    getRoomAmenities(request, response);
                    break;
                case "processCheckIn":
                    processCheckIn(request, response);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"error\":\"Invalid action\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing request", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"An error occurred while processing your request\"}");
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
    
    private void getReservationDetails(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String idStr = request.getParameter("reservationId");
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
            List<RoomAmenity> amenities = amenityDAO.getRoomAmenities(roomId);
            
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
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            
            // Get form parameters (not JSON)
            int reservationId = Integer.parseInt(request.getParameter("reservationId"));
            String idType = request.getParameter("idType");
            String idNumber = request.getParameter("idNumber");
            int additionalGuests = Integer.parseInt(request.getParameter("additionalGuests") != null ? 
                request.getParameter("additionalGuests") : "0");
            double securityDeposit = Double.parseDouble(request.getParameter("securityDeposit") != null ? 
                request.getParameter("securityDeposit") : "0");
            int keyCards = Integer.parseInt(request.getParameter("keyCards"));
            String keyCardNumbers = request.getParameter("keyCardNumbers");
            String checkInNotes = request.getParameter("checkInNotes");
            
            // Validate required fields
            if (idType == null || idType.trim().isEmpty() || 
                idNumber == null || idNumber.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\":false,\"message\":\"Missing required fields\"}");
                return;
            }
            
            // Create check-in detail
            CheckInDetail checkIn = new CheckInDetail();
            checkIn.setReservationId(reservationId);
            checkIn.setIdType(idType);
            checkIn.setIdNumber(idNumber);
            checkIn.setAdditionalGuests(additionalGuests);
            checkIn.setSecurityDeposit(securityDeposit);
            checkIn.setKeyCards(keyCards);
            checkIn.setKeyCardNumbers(keyCardNumbers);
            checkIn.setCheckInNotes(checkInNotes);
            checkIn.setCheckInBy(currentUser.getId());
            
            // Save check-in
            boolean success = checkInOutDAO.createCheckIn(checkIn);
            
            if (success) {
                // Update room status to OCCUPIED
                Reservation reservation = reservationDAO.getReservationById(reservationId);
                roomDAO.updateRoomStatus(reservation.getRoomId(), "OCCUPIED");
                
                // Update reservation status
                reservationDAO.updateReservationStatus(reservationId, "CONFIRMED");
                
                // Create housekeeping task for room preparation
                HousekeepingTask task = new HousekeepingTask();
                task.setRoomId(reservation.getRoomId());
                task.setStatus("PENDING");
                task.setPriority("MEDIUM");
                task.setNotes("Guest checked in - daily cleaning required");
                housekeepingDAO.createTask(task);
                
                // Log activity
                Activity activity = new Activity();
                activity.setType("CHECK_IN");
                activity.setReservationId(reservationId);
                activity.setUserId(currentUser.getId());
                activity.setDescription("Checked in guest to room " + roomDAO.getRoomById(reservation.getRoomId()).getRoomNumber());
                activity.setIpAddress(request.getRemoteAddr());
                activityDAO.logActivity(activity);
                
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":true,\"message\":\"Check-in completed successfully\"}");
            } else {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false,\"message\":\"Failed to process check-in\"}");
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing check-in", e);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"message\":\"Error: " + e.getMessage() + "\"}");
        }
    }
}