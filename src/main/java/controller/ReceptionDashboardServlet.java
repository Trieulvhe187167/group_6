package controller;

import dal.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "ReceptionDashboardServlet", urlPatterns = {"/reception-dashboard"})
public class ReceptionDashboardServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
//        // Check if user is logged in and is RECEPTIONIST
//        if (user == null || !"RECEPTIONIST".equals(user.getRole())) {
//            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
//            return;
//        }
//        
        // Get statistics data for receptionist
        Map<String, Object> stats = new HashMap<>();
        
        try {
            // Get DAOs
            RoomDAO roomDAO = new RoomDAO();
            ReservationDAO reservationDAO = new ReservationDAO();
            CustomerDAO customerDAO = new CustomerDAO();
            
            // Room statistics
            stats.put("availableRooms", roomDAO.getAvailableRoomsCount());
            stats.put("occupiedRooms", roomDAO.getOccupiedRoomsCount());
            stats.put("dirtyRooms", roomDAO.getDirtyRoomsCount());
            stats.put("maintenanceRooms", roomDAO.getMaintenanceRoomsCount());
            
            // Today's activities
            stats.put("todayCheckIns", reservationDAO.getTodayCheckInsCount());
            stats.put("todayCheckOuts", reservationDAO.getTodayCheckOutsCount());
            stats.put("pendingCheckIns", reservationDAO.getPendingCheckInsToday());
            stats.put("pendingCheckOuts", reservationDAO.getPendingCheckOutsToday());
            
            // Reservation counts
            stats.put("pendingReservations", reservationDAO.getPendingReservationsCount());
            stats.put("confirmedReservations", reservationDAO.getConfirmedReservationsCount());
            
            // Get lists for display
            stats.put("todayCheckInsList", reservationDAO.getTodayCheckInsList());
            stats.put("todayCheckOutsList", reservationDAO.getTodayCheckOutsList());
            stats.put("availableRoomsList", roomDAO.getAvailableRoomsList());
            
        } catch (Exception e) {
            e.printStackTrace();
            // Set default values
            stats.put("availableRooms", 0);
            stats.put("occupiedRooms", 0);
            stats.put("dirtyRooms", 0);
            stats.put("maintenanceRooms", 0);
            stats.put("todayCheckIns", 0);
            stats.put("todayCheckOuts", 0);
            stats.put("pendingCheckIns", 0);
            stats.put("pendingCheckOuts", 0);
            stats.put("pendingReservations", 0);
            stats.put("confirmedReservations", 0);
        }
        
        request.setAttribute("stats", stats);
        request.getRequestDispatcher("/jsp/reception-dashboard.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}