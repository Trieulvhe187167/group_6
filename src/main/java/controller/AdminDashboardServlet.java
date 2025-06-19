package controller;

import dal.UserDAO;
import dal.RoomDAO;
import dal.ReservationDAO;
import dal.PaymentDAO;
import model.User;
import model.DashboardStats;
import model.ReservationSummary;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Calendar;
import java.util.Date;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin-dashboard"})
public class AdminDashboardServlet extends HttpServlet {
    
    private UserDAO userDAO = new UserDAO();
    private RoomDAO roomDAO = new RoomDAO();
    private ReservationDAO reservationDAO = new ReservationDAO();
    private PaymentDAO paymentDAO = new PaymentDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check admin authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        try {
            // Create dashboard statistics object
            DashboardStats stats = new DashboardStats();
            
            // Get customer statistics
            stats.setTotalCustomers(userDAO.getTotalUsersByRole("GUEST"));
            
            // Get room statistics
            int[] roomStats = roomDAO.getRoomStatistics();
            stats.setAvailableRooms(roomStats[0]);
            stats.setOccupiedRooms(roomStats[1]);
            stats.setMaintenanceRooms(roomStats[2]);
            stats.setTotalRooms(roomDAO.getTotalRoomCount());
            
            // Get today's check-ins
            stats.setTodayCheckIns(reservationDAO.getTodayCheckIns());
            
            // Get revenue statistics
            Calendar cal = Calendar.getInstance();
            int currentMonth = cal.get(Calendar.MONTH) + 1;
            int currentYear = cal.get(Calendar.YEAR);
            
            stats.setMonthlyRevenue(paymentDAO.getMonthlyRevenue(currentMonth, currentYear));
            stats.setYearlyRevenue(paymentDAO.getYearlyRevenue(currentYear));
            
            // Get recent reservations (last 5)
            List<ReservationSummary> recentReservations = reservationDAO.getRecentReservations(5);
            stats.setRecentReservations(recentReservations);
            
            // Set attributes
            request.setAttribute("stats", stats);
            request.setAttribute("pageTitle", "Dashboard");
            request.setAttribute("activePage", "dashboard");
            request.setAttribute("contentPage", "/jsp/admin/admin-dashboard-content.jsp");
            
            // Forward to template
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading dashboard data: " + e.getMessage());
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}