package controller;
// HouseKeepingServlet.java


import dal.RoomDAO;
import model.Room;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "HouseKeepingServlet", urlPatterns = {"/HouseKeeping", "/housekeeping"})
public class HouseKeepingServlet extends HttpServlet {
    
    private RoomDAO roomDAO = new RoomDAO();
    
    @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    String search = request.getParameter("search");
    String status = request.getParameter("status");
    
    List<Room> rooms;
    
    if (search != null && !search.trim().isEmpty()) {
        rooms = roomDAO.searchRoomsByNumber(search.trim());
    } else if (status != null && !status.equals("ALL")) {
        rooms = roomDAO.getRoomsWithFilter(status);
    } else {    
        rooms = roomDAO.getRoomsWithFilter("ALL");
    }
    
    request.setAttribute("rooms", rooms);
    request.setAttribute("search", search);
    request.setAttribute("status", status);
    
    // Set template attributes
    request.setAttribute("pageTitle", "Housekeeping");
    request.setAttribute("activePage", "housekeeping");
    request.setAttribute("contentPage", "/jsp/housekeeping-content.jsp");
    
    request.getRequestDispatcher("/jsp/admin-template.jsp").forward(request, response);
}
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String roomIdStr = request.getParameter("roomId");
        String newStatus = request.getParameter("newStatus");
        
        if (roomIdStr != null && newStatus != null) {
            try {
                int roomId = Integer.parseInt(roomIdStr);
                boolean updated = roomDAO.updateRoomStatus(roomId, newStatus);
                
                if (updated) {
                    request.getSession().setAttribute("message", "Room status updated successfully!");
                } else {
                    request.getSession().setAttribute("error", "Failed to update room status!");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("error", "Invalid room ID!");
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/HouseKeeping");
    }
}