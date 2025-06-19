package controller;

import dal.*;
import model.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.util.Map;
import com.google.gson.Gson;

public class ReservationActionHandler {
    private final ReservationDAO reservationDAO;
    private final UserDAO userDAO;
    private final RoomDAO roomDAO;
    private final ActivityDAO activityDAO;
    
    public ReservationActionHandler() {
        this.reservationDAO = new ReservationDAO();
        this.userDAO = new UserDAO();
        this.roomDAO = new RoomDAO();
        this.activityDAO = new ActivityDAO();
    }
    
    public boolean confirmReservation(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("reservationId"));
            boolean success = reservationDAO.updateReservationStatus(reservationId, "CONFIRMED");
            
            if (success) {
                // Update room status if check-in is today
                Reservation reservation = reservationDAO.getReservationById(reservationId);
                Date today = new Date(System.currentTimeMillis());
                if (reservation.getCheckIn().equals(today)) {
                    roomDAO.updateRoomStatus(reservation.getRoomId(), "OCCUPIED");
                }
                
                // Log activity
                HttpSession session = request.getSession();
                User currentUser = (User) session.getAttribute("user");
                Activity activity = new Activity();
                activity.setType("RESERVATION_CONFIRM");
                activity.setReservationId(reservationId);
                activity.setUserId(currentUser.getId());
                activity.setDescription("Confirmed reservation #" + reservationId);
                activity.setIpAddress(request.getRemoteAddr());
                activityDAO.logActivity(activity);
            }
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            return success;
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false}");
            return false;
        }
    }
    
    public boolean cancelReservation(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("reservationId"));
            boolean success = reservationDAO.updateReservationStatus(reservationId, "CANCELLED");
            
            if (success) {
                // Update room status back to AVAILABLE
                Reservation reservation = reservationDAO.getReservationById(reservationId);
                roomDAO.updateRoomStatus(reservation.getRoomId(), "AVAILABLE");
                
                // Log activity
                HttpSession session = request.getSession();
                User currentUser = (User) session.getAttribute("user");
                Activity activity = new Activity();
                activity.setType("RESERVATION_CANCEL");
                activity.setReservationId(reservationId);
                activity.setUserId(currentUser.getId());
                activity.setDescription("Cancelled reservation #" + reservationId);
                activity.setIpAddress(request.getRemoteAddr());
                activityDAO.logActivity(activity);
            }
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            return success;
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false}");
            return false;
        }
    }
    
    public boolean createReservation(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            // Parse JSON request body
            Gson gson = new Gson();
            Map<String, Object> reservationData = gson.fromJson(request.getReader(), Map.class);
            
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            
            // Create new guest if needed
            int guestId;
            if (reservationData.get("guestId") != null) {
                guestId = ((Double) reservationData.get("guestId")).intValue();
            } else {
                // Create new guest
                Map<String, String> newGuestData = (Map<String, String>) reservationData.get("newGuest");
                User newGuest = new User();
                newGuest.setFullName(newGuestData.get("fullName"));
                newGuest.setEmail(newGuestData.get("email"));
                newGuest.setPhone(newGuestData.get("phone"));
                newGuest.setRole("GUEST");
                newGuest.setStatus(true);
                newGuest.setPassword("Pass123!"); // Default password
                newGuest.setUsername(generateUsername(newGuest.getFullName()));
                
                guestId = userDAO.createUserAndGetId(newGuest);
                if (guestId == 0) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\":false,\"message\":\"Failed to create guest\"}");
                    return false;
                }
            }
            
            // Create reservation
            Reservation reservation = new Reservation();
            reservation.setUserId(guestId);
            reservation.setRoomId(((Double) reservationData.get("roomId")).intValue());
            reservation.setCheckIn(Date.valueOf((String) reservationData.get("checkIn")));
            reservation.setCheckOut(Date.valueOf((String) reservationData.get("checkOut")));
            reservation.setStatus("CONFIRMED");
            reservation.setCreatedBy(currentUser.getId());
            reservation.setSpecialRequests((String) reservationData.get("specialRequests"));
            
            if (reservationData.get("numberOfGuests") != null) {
                reservation.setNumberOfGuests(((Double) reservationData.get("numberOfGuests")).intValue());
            }
            
            // Calculate total amount
            Room room = roomDAO.getRoomById(reservation.getRoomId());
            long days = (reservation.getCheckOut().getTime() - reservation.getCheckIn().getTime()) / (1000 * 60 * 60 * 24);
            double totalAmount = days * room.getBasePrice();
            reservation.setTotalAmount(totalAmount);
            
            // Save reservation
            boolean success = reservationDAO.createReservation(reservation);
            
            if (success) {
                // Log activity
                Activity activity = new Activity();
                activity.setType("RESERVATION_CREATE");
                activity.setUserId(currentUser.getId());
                activity.setDescription("Created new reservation for " + userDAO.getUserById(guestId).getFullName());
                activity.setAmount(totalAmount);
                activity.setIpAddress(request.getRemoteAddr());
                activityDAO.logActivity(activity);
            }
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            return success;
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
            return false;
        }
    }
    
    private String generateUsername(String fullName) {
        String username = fullName.toLowerCase().replaceAll("\\s+", "");
        
        int suffix = 1;
        String finalUsername = username;
        while (userDAO.usernameExists(finalUsername)) {
            finalUsername = username + suffix;
            suffix++;
        }
        
        return finalUsername;
    }
} 