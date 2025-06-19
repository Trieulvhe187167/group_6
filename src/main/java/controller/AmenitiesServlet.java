// New AmenitiesServlet.java
package controller;

import dal.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import com.google.gson.Gson;

@WebServlet(name = "AmenitiesServlet", urlPatterns = {"/receptionist/amenities"})
public class AmenitiesServlet extends HttpServlet {
    
    private RoomAmenityDAO amenityDAO = new RoomAmenityDAO();
    private ReservationDAO reservationDAO = new ReservationDAO();
    private CheckInOutDAO checkInOutDAO = new CheckInOutDAO();
    private ActivityDAO activityDAO = new ActivityDAO();
    
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
            // Get recent amenity logs
            List<AmenityUsageLog> recentLogs = amenityDAO.getRecentAmenityLogs(20);
            
            // Set attributes
            request.setAttribute("recentLogs", recentLogs);
            request.setAttribute("currentUser", currentUser);
            
            // Set template attributes
            request.setAttribute("pageTitle", "Room Amenities Management");
            request.setAttribute("activePage", "amenities");
            request.setAttribute("contentPage", "/jsp/reception/amenities-content.jsp");
            
            // Forward to template
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading amenities page: " + e.getMessage());
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("getRoomsByFloor".equals(action)) {
            getRoomsByFloor(request, response);
        } else if ("getRoomAmenityStatus".equals(action)) {
            getRoomAmenityStatus(request, response);
        } else if ("saveAmenityUsage".equals(action)) {
            saveAmenityUsage(request, response);
        } else if ("addAmenity".equals(action)) {
            addAmenity(request, response);
        }
    }
    
    private void getRoomsByFloor(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int floor = Integer.parseInt(request.getParameter("floor"));
            List<Room> rooms = amenityDAO.getRoomsByFloor(floor);
            
            response.setContentType("application/json");
            Gson gson = new Gson();
            response.getWriter().write(gson.toJson(rooms));
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private void getRoomAmenityStatus(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            
            // Get current reservation for the room
            Reservation reservation = reservationDAO.getCurrentReservationByRoom(roomId);
            
            if (reservation == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\":\"No current reservation found\"}");
                return;
            }
            
            // Get room amenities
            List<RoomAmenity> allAmenities = amenityDAO.getRoomAmenities(roomId);
            List<RoomAmenity> minibarItems = new ArrayList<>();
            List<RoomAmenity> roomAmenities = new ArrayList<>();
            
            for (RoomAmenity amenity : allAmenities) {
                if ("MINIBAR".equals(amenity.getCategory())) {
                    minibarItems.add(amenity);
                } else {
                    roomAmenities.add(amenity);
                }
            }
            
            // Get current usage
            Map<Integer, Integer> currentUsage = amenityDAO.getCurrentAmenityUsage(reservation.getId());
            
            // Calculate days stayed
            long daysStayed = (new Date().getTime() - reservation.getCheckIn().getTime()) / (1000 * 60 * 60 * 24);
            if (daysStayed < 1) daysStayed = 1;
            
            // Create response
            Map<String, Object> result = new HashMap<>();
            Map<String, Object> reservationInfo = new HashMap<>();
            reservationInfo.put("id", reservation.getId());
            reservationInfo.put("guestName", reservation.getGuestName());
            reservationInfo.put("checkIn", reservation.getCheckIn());
            reservationInfo.put("daysStayed", daysStayed);
            
            result.put("reservation", reservationInfo);
            result.put("minibarItems", minibarItems);
            result.put("roomAmenities", roomAmenities);
            result.put("currentUsage", currentUsage);
            
            response.setContentType("application/json");
            Gson gson = new Gson();
            response.getWriter().write(gson.toJson(result));
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private void saveAmenityUsage(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            Gson gson = new Gson();
            Map<String, Object> usageData = gson.fromJson(request.getReader(), Map.class);
            
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            
            int reservationId = ((Double) usageData.get("reservationId")).intValue();
            List<Map<String, Object>> amenityUsage = (List<Map<String, Object>>) usageData.get("amenityUsage");
            
            boolean success = true;
            
            for (Map<String, Object> usage : amenityUsage) {
                int amenityId = ((Double) usage.get("amenityId")).intValue();
                int quantity = ((Double) usage.get("quantity")).intValue();
                
                // Get amenity details to get price
                RoomAmenity amenity = getAmenityById(amenityId);
                if (amenity != null && amenity.getIsChargeable()) {
                    boolean recorded = amenityDAO.recordAmenityUsage(
                        reservationId, 
                        amenityId, 
                        quantity, 
                        amenity.getUnitPrice(), 
                        currentUser.getId()
                    );
                    if (!recorded) {
                        success = false;
                        break;
                    }
                }
            }
            
            if (success) {
                // Log activity
                Activity activity = new Activity();
                activity.setType("AMENITY_USAGE");
                activity.setReservationId(reservationId);
                activity.setUserId(currentUser.getId());
                activity.setDescription("Updated amenity usage for reservation #" + reservationId);
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
    
    private void addAmenity(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            Gson gson = new Gson();
            Map<String, Object> amenityData = gson.fromJson(request.getReader(), Map.class);
            
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            
            RoomAmenity amenity = new RoomAmenity();
            amenity.setName((String) amenityData.get("name"));
            amenity.setDescription((String) amenityData.get("description"));
            amenity.setCategory((String) amenityData.get("category"));
            amenity.setIsChargeable((Boolean) amenityData.get("isChargeable"));
            
            if (amenity.getIsChargeable()) {
                amenity.setUnitPrice(((Double) amenityData.get("unitPrice")).doubleValue());
            } else {
                amenity.setUnitPrice(0);
            }
            
            amenity.setCreatedBy(currentUser.getId());
            
            boolean success = amenityDAO.createAmenity(amenity);
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false}");
        }
    }
    
    private RoomAmenity getAmenityById(int amenityId) {
        // This would need to be implemented in the DAO
        // For now, return null and handle in the calling method
        return null;
    }
}