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

@WebServlet(name = "ReservationsServlet", urlPatterns = {"/receptionist/reservations"})
public class ReservationsServlet extends ReceptionistBaseServlet {
    
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final UserDAO userDAO = new UserDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final RoomTypeDAO roomTypeDAO = new RoomTypeDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkReceptionistAuth(request, response)) {
            return;
        }
        
        try {
            // Handle export action
            String action = request.getParameter("action");
            if ("export".equals(action)) {
                exportReservations(request, response);
                return;
            } else if ("print".equals(action)) {
                printReservation(request, response);
                return;
            }
            
            // Get filter parameters
            String status = request.getParameter("status");
            String checkInDate = request.getParameter("checkInDate");
            String checkOutDate = request.getParameter("checkOutDate");
            String search = request.getParameter("search");
            
            // Get reservations with filters
            List<ReservationSummary> reservations;
            if (status != null || checkInDate != null || checkOutDate != null || search != null) {
                reservations = reservationDAO.getReservationsWithFilters(status, checkInDate, checkOutDate, search);
            } else {
                reservations = reservationDAO.getRecentReservations(100);
            }
            
            // Get all guests for dropdown
            List<User> guests = userDAO.getUsersByRole("GUEST");
            
            // Get all room types
            List<RoomType> roomTypes = roomTypeDAO.getAllActiveRoomTypes();
            
            // Get statistics
            int totalReservations = reservationDAO.getTotalReservations();
            int pendingReservations = reservationDAO.getReservationCountByStatus("PENDING");
            int confirmedReservations = reservationDAO.getReservationCountByStatus("CONFIRMED");
            int todayCheckIns = reservationDAO.getTodayCheckInsCount();
            
            // Set attributes
            request.setAttribute("reservations", reservations);
            request.setAttribute("guests", guests);
            request.setAttribute("roomTypes", roomTypes);
            request.setAttribute("totalReservations", totalReservations);
            request.setAttribute("pendingReservations", pendingReservations);
            request.setAttribute("confirmedReservations", confirmedReservations);
            request.setAttribute("todayCheckIns", todayCheckIns);
            request.setAttribute("currentUser", request.getSession().getAttribute("user"));
            
            // Forward to template
            forwardToTemplate(request, response, "Reservations Management", "reservations", 
                    "/jsp/reception/reservations-content.jsp");
            
        } catch (Exception e) {
            handleError(request, response, e, "Error loading reservations");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!checkReceptionistAuth(request, response)) {
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            switch (action) {
                case "confirmReservation":
                    confirmReservation(request, response);
                    break;
                case "cancelReservation":
                    cancelReservation(request, response);
                    break;
                case "createReservation":
                    createReservation(request, response);
                    break;
                case "updateReservation":
                    updateReservation(request, response);
                    break;
                case "getReservationDetails":
                    getReservationDetails(request, response);
                    break;
                case "getAvailableRooms":
                    getAvailableRooms(request, response);
                    break;
                case "sendConfirmation":
                    sendConfirmationEmail(request, response);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\":false,\"message\":\"Invalid action\"}");
            }
        } catch (Exception e) {
            handleError(request, response, e, "Error processing reservation action");
        }
    }
    
    private void confirmReservation(HttpServletRequest request, HttpServletResponse response) 
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
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false}");
        }
    }
    
    private void cancelReservation(HttpServletRequest request, HttpServletResponse response) 
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
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false}");
        }
    }
    
    private void createReservation(HttpServletRequest request, HttpServletResponse response) 
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
                    return;
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
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private void updateReservation(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            Gson gson = new Gson();
            Map<String, Object> reservationData = gson.fromJson(request.getReader(), Map.class);
            
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            
            int reservationId = ((Double) reservationData.get("id")).intValue();
            
            // Get existing reservation
            Reservation reservation = reservationDAO.getReservationById(reservationId);
            if (reservation == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"success\":false,\"message\":\"Reservation not found\"}");
                return;
            }
            
            // Update fields
            reservation.setCheckIn(Date.valueOf((String) reservationData.get("checkIn")));
            reservation.setCheckOut(Date.valueOf((String) reservationData.get("checkOut")));
            reservation.setStatus((String) reservationData.get("status"));
            reservation.setSpecialRequests((String) reservationData.get("specialRequests"));
            
            if (reservationData.get("numberOfGuests") != null) {
                reservation.setNumberOfGuests(((Double) reservationData.get("numberOfGuests")).intValue());
            }
            
            // Recalculate total amount
            Room room = roomDAO.getRoomById(reservation.getRoomId());
            long days = (reservation.getCheckOut().getTime() - reservation.getCheckIn().getTime()) / (1000 * 60 * 60 * 24);
            double totalAmount = days * room.getBasePrice();
            reservation.setTotalAmount(totalAmount);
            
            boolean success = reservationDAO.updateReservation(reservation);
            
            if (success) {
                // Log activity
                Activity activity = new Activity();
                activity.setType("RESERVATION_UPDATE");
                activity.setReservationId(reservationId);
                activity.setUserId(currentUser.getId());
                activity.setDescription("Updated reservation #" + reservationId);
                activity.setIpAddress(request.getRemoteAddr());
                activityDAO.logActivity(activity);
            }
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private void getReservationDetails(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("id"));
            ReservationDetail reservation = reservationDAO.getReservationDetail(reservationId);
            
            if (reservation != null) {
                response.setContentType("application/json");
                Gson gson = new Gson();
                response.getWriter().write(gson.toJson(reservation));
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\":\"Reservation not found\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private void getAvailableRooms(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int roomTypeId = Integer.parseInt(request.getParameter("roomTypeId"));
            Date checkIn = Date.valueOf(request.getParameter("checkIn"));
            Date checkOut = Date.valueOf(request.getParameter("checkOut"));
            
            List<Room> availableRooms = roomDAO.getAvailableRoomsForDateRange(checkIn, checkOut);
            // Filter by room type
            availableRooms.removeIf(room -> room.getRoomTypeId() != roomTypeId);
            
            response.setContentType("application/json");
            Gson gson = new Gson();
            response.getWriter().write(gson.toJson(availableRooms));
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private void sendConfirmationEmail(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("id"));
            
            // TODO: Implement email sending logic
            // For now, just return success
            boolean success = true;
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false}");
        }
    }
    
    private void exportReservations(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            // Get filter parameters
            String status = request.getParameter("status");
            String checkInDate = request.getParameter("checkInDate");
            String checkOutDate = request.getParameter("checkOutDate");
            String search = request.getParameter("search");
            
            List<ReservationSummary> reservations = reservationDAO.getReservationsWithFilters(status, checkInDate, checkOutDate, search);
            
            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", "attachment; filename=\"reservations_export.csv\"");
            
            StringBuilder csv = new StringBuilder();
            csv.append("Booking ID,Guest Name,Phone,Room,Check-in,Check-out,Nights,Status,Total Amount,Created Date\n");
            
            for (ReservationSummary reservation : reservations) {
                long nights = (reservation.getCheckOut().getTime() - reservation.getCheckIn().getTime()) / (1000 * 60 * 60 * 24);
                csv.append(reservation.getId()).append(",");
                csv.append("\"").append(reservation.getCustomerName()).append("\",");
                csv.append(reservation.getCustomerPhone()).append(",");
                csv.append(reservation.getRoomNumber()).append(",");
                csv.append(reservation.getCheckIn()).append(",");
                csv.append(reservation.getCheckOut()).append(",");
                csv.append(nights).append(",");
                csv.append(reservation.getStatus()).append(",");
                csv.append(reservation.getTotalAmount()).append(",");
                csv.append(reservation.getCreatedAt()).append("\n");
            }
            
            response.getWriter().write(csv.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private void printReservation(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("id"));
            ReservationDetail reservation = reservationDAO.getReservationDetail(reservationId);
            
            if (reservation != null) {
                // Generate print-friendly HTML
                String html = generatePrintableReservation(reservation);
                response.setContentType("text/html");
                response.getWriter().write(html);
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
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
    
    private String generatePrintableReservation(ReservationDetail reservation) {
        // Generate a simple HTML for printing
        StringBuilder html = new StringBuilder();
        html.append("<!DOCTYPE html><html><head>");
        html.append("<title>Reservation Confirmation</title>");
        html.append("<style>body{font-family:Arial,sans-serif;margin:20px;}</style>");
        html.append("</head><body>");
        html.append("<h1>Reservation Confirmation</h1>");
        html.append("<p><strong>Booking ID:</strong> #").append(reservation.getId()).append("</p>");
        html.append("<p><strong>Guest:</strong> ").append(reservation.getCustomerName()).append("</p>");
        html.append("<p><strong>Room:</strong> ").append(reservation.getRoomNumber()).append("</p>");
        html.append("<p><strong>Check-in:</strong> ").append(reservation.getCheckIn()).append("</p>");
        html.append("<p><strong>Check-out:</strong> ").append(reservation.getCheckOut()).append("</p>");
        html.append("<p><strong>Total Amount:</strong> ").append(reservation.getTotalAmount()).append("₫</p>");
        html.append("</body></html>");
        return html.toString();
    }
}