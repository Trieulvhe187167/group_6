package controller;

import dal.RoomDAO;
import dal.ReservationDAO;
import dal.RoomTypeDAO;
import model.Room;
import model.RoomType;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.util.List;
import com.google.gson.Gson;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "CheckRoomAvailabilityServlet", urlPatterns = {"/CheckRoomAvailability"})
public class CheckRoomAvailabilityServlet extends HttpServlet {
    
    private final RoomDAO roomDAO = new RoomDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final RoomTypeDAO roomTypeDAO = new RoomTypeDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            // Get parameters
            String roomTypeIdStr = request.getParameter("roomTypeId");
            String checkInStr = request.getParameter("checkIn");
            String checkOutStr = request.getParameter("checkOut");
            
            // Validate parameters
            if (roomTypeIdStr == null || checkInStr == null || checkOutStr == null) {
                sendErrorResponse(response, "Missing required parameters");
                return;
            }
            
            int roomTypeId = Integer.parseInt(roomTypeIdStr);
            Date checkIn = Date.valueOf(checkInStr);
            Date checkOut = Date.valueOf(checkOutStr);
            
            // Log for debugging
            System.out.println("=== AVAILABILITY CHECK ===");
            System.out.println("Room Type ID: " + roomTypeId);
            System.out.println("Check-in: " + checkIn);
            System.out.println("Check-out: " + checkOut);
            
            // First, get all rooms of this type (without date filtering)
            List<Room> allRoomsOfType = roomDAO.getRoomsByType(roomTypeId);
            System.out.println("Total rooms of this type: " + allRoomsOfType.size());
            
            // Filter only AVAILABLE status rooms
            int availableStatusCount = 0;
            for (Room room : allRoomsOfType) {
                if ("AVAILABLE".equals(room.getStatus())) {
                    availableStatusCount++;
                }
            }
            System.out.println("Rooms with AVAILABLE status: " + availableStatusCount);
            
            // Now check which of these rooms are available for the date range
            List<Room> availableRooms = roomDAO.getAvailableRoomsByTypeAndDate(roomTypeId, checkIn, checkOut);
            System.out.println("Available rooms for dates: " + availableRooms.size());
            
            // Debug: Check reservations that might be blocking
            if (availableRooms.isEmpty() && !allRoomsOfType.isEmpty()) {
                System.out.println("\nDEBUG: Checking what's blocking the rooms...");
                for (Room room : allRoomsOfType) {
                    boolean isAvailable = reservationDAO.isRoomAvailable(room.getId(), checkIn, checkOut, null);
                    System.out.println("Room " + room.getRoomNumber() + " (ID: " + room.getId() + 
                                     ") - Status: " + room.getStatus() + 
                                     " - Available for dates: " + isAvailable);
                }
            }
            
            // Create response
            Map<String, Object> result = new HashMap<>();
            result.put("available", !availableRooms.isEmpty());
            result.put("availableCount", availableRooms.size());
            result.put("roomTypeId", roomTypeId);
            result.put("checkIn", checkInStr);
            result.put("checkOut", checkOutStr);
            
            // Add room details if needed
            if (!availableRooms.isEmpty()) {
                result.put("message", availableRooms.size() + " rooms available");
            } else {
                result.put("message", "No rooms available for selected dates");
                
                // Get room type name for better message
                RoomType roomType = roomTypeDAO.getRoomTypesById(roomTypeId);
                if (roomType != null) {
                    result.put("roomTypeName", roomType.getName());
                }
            }
            
            // Send response
            Gson gson = new Gson();
            response.getWriter().write(gson.toJson(result));
            
        } catch (Exception e) {
            e.printStackTrace();
            sendErrorResponse(response, "Error checking availability: " + e.getMessage());
        }
    }
    
    private void sendErrorResponse(HttpServletResponse response, String message) throws IOException {
        Map<String, Object> error = new HashMap<>();
        error.put("error", true);
        error.put("message", message);
        
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        Gson gson = new Gson();
        response.getWriter().write(gson.toJson(error));
    }
}