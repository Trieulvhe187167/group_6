package controller;

import dal.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin-dashboard"})
public class AdminDashboardServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // Get statistics data
        Map<String, Object> stats = new HashMap<>();
        
        try {
            CustomerDAO customerDAO = new CustomerDAO();
            RoomTypeDAO roomTypeDAO = new RoomTypeDAO();
            ReservationDAO reservationDAO = new ReservationDAO();
            RoomDAO roomDAO = new RoomDAO();
            
            // Basic statistics
            stats.put("totalCustomers", customerDAO.getTotalCustomers());
            stats.put("totalRoomTypes", roomTypeDAO.getTotalRoomTypes());
            stats.put("totalRooms", roomDAO.getTotalRooms());
            stats.put("availableRooms", roomDAO.getAvailableRoomsCount());
            stats.put("occupiedRooms", roomDAO.getOccupiedRoomsCount());
            stats.put("maintenanceRooms", roomDAO.getMaintenanceRoomsCount());
            
            // Reservation statistics
            stats.put("todayCheckIns", reservationDAO.getTodayCheckInsCount());
            stats.put("todayCheckOuts", reservationDAO.getTodayCheckOutsCount());
            
            // Revenue statistics
            stats.put("monthlyRevenue", reservationDAO.getMonthlyRevenue());
            stats.put("yearlyRevenue", reservationDAO.getYearlyRevenue());
            
            // Recent activities
            stats.put("recentReservations", reservationDAO.getRecentReservations(5));
            
        } catch (Exception e) {
            e.printStackTrace();
            // Set default values
            stats.put("totalCustomers", 0);
            stats.put("totalRoomTypes", 0);
            stats.put("totalRooms", 0);
            stats.put("availableRooms", 0);
            stats.put("occupiedRooms", 0);
            stats.put("maintenanceRooms", 0);
            stats.put("todayCheckIns", 0);
            stats.put("todayCheckOuts", 0);
            stats.put("monthlyRevenue", 0.0);
            stats.put("yearlyRevenue", 0.0);
        }
        
        request.setAttribute("stats", stats);
    request.setAttribute("pageTitle", "Dashboard");
    request.setAttribute("activePage", "dashboard");
    request.setAttribute("contentPage", "/jsp/admin-dashboard-content.jsp");
    
    request.getRequestDispatcher("/jsp/admin-template.jsp").forward(request, response);
}
}