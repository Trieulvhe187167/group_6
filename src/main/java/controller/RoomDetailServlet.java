package controller;

import dal.RoomTypeDAO;
import dal.RoomDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import model.RoomType;
import model.Room;

/**
 * Servlet for handling user room detail view
 */
@WebServlet(name = "RoomDetailServlet", urlPatterns = {"/RoomDetailServlet"})
public class RoomDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect("RoomListServlet");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            
            RoomTypeDAO roomTypeDAO = new RoomTypeDAO();
            RoomDAO roomDAO = new RoomDAO();
            
            // Get room type details
            RoomType roomType = roomTypeDAO.getRoomTypesById(id);
            
            if (roomType == null) {
                request.setAttribute("error", "Room type not found");
                response.sendRedirect("RoomListServlet");
                return;
            }
            
            // Only show active room types to users
            if (!"active".equals(roomType.getStatus())) {
                request.setAttribute("error", "Room type is not available");
                response.sendRedirect("RoomListServlet");
                return;
            }
            
            // Get available rooms for this room type
            List<Room> allRooms = roomDAO.getRoomsByType(id);
            List<Room> availableRooms = roomDAO.getAvailableRoomsByType(id);
            
            // Calculate room statistics
            int totalRooms = allRooms.size();
            int availableCount = availableRooms.size();
            int occupiedCount = 0;
            int maintenanceCount = 0;
            
            for (Room room : allRooms) {
                switch (room.getStatus()) {
                    case "OCCUPIED":
                        occupiedCount++;
                        break;
                    case "MAINTENANCE":
                    case "DIRTY":
                        maintenanceCount++;
                        break;
                }
            }
            
            // Set attributes for JSP
            request.setAttribute("id", idStr);
            request.setAttribute("roomTypes", roomType);
            request.setAttribute("allRooms", allRooms);
            request.setAttribute("availableRooms", availableRooms);
            request.setAttribute("totalRooms", totalRooms);
            request.setAttribute("availableCount", availableCount);
            request.setAttribute("occupiedCount", occupiedCount);
            request.setAttribute("maintenanceCount", maintenanceCount);
            
            // Forward to JSP
            request.getRequestDispatcher("jsp/roomDetail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect("RoomListServlet");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while loading room details");
            response.sendRedirect("RoomListServlet");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet for displaying room type details to users";
    }
}   