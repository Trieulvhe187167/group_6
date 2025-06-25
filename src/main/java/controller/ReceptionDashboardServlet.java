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

@WebServlet(name = "ReceptionDashboardServlet", urlPatterns = {"/reception-dashboard"})
public class ReceptionDashboardServlet extends HttpServlet {
    
    private UserDAO userDAO = new UserDAO();
    private RoomDAO roomDAO = new RoomDAO();
    private ReservationDAO reservationDAO = new ReservationDAO();
    private PaymentDAO paymentDAO = new PaymentDAO();
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
            // Create dashboard statistics object
            ReceptionDashboardStats stats = new ReceptionDashboardStats();
            
            // Get today's date
            Date today = Date.valueOf(LocalDate.now());
            
            // Today's check-ins and check-outs
            stats.setTodayCheckIns(checkInOutDAO.getTodayCheckIns(today));
            stats.setTodayCheckOuts(checkInOutDAO.getTodayCheckOuts(today));
            
            // Room statistics
            int[] roomStats = roomDAO.getRoomStatistics();
            stats.setAvailableRooms(roomStats[0]);
            stats.setOccupiedRooms(roomStats[1]);
            stats.setMaintenanceRooms(roomStats[2]);
            stats.setDirtyRooms(roomStats[3]);
            stats.setTotalRooms(roomDAO.getTotalRoomCount());
            
            // Today's expected revenue
            stats.setTodayExpectedRevenue(reservationDAO.getTodayExpectedRevenue(today));
            
            // Pending reservations
            stats.setPendingReservations(reservationDAO.getReservationCountByStatus("PENDING"));
            
            // Recent activities
            List<Activity> recentActivities = activityDAO.getRecentActivities(10);
            stats.setRecentActivities(recentActivities);
            
            // Upcoming check-ins (next 3 hours)
            List<ReservationSummary> upcomingCheckIns = checkInOutDAO.getUpcomingCheckIns(3);
            stats.setUpcomingCheckIns(upcomingCheckIns);
            
            // Upcoming check-outs (next 3 hours)
            List<ReservationSummary> upcomingCheckOuts = checkInOutDAO.getUpcomingCheckOuts(3);
            stats.setUpcomingCheckOuts(upcomingCheckOuts);
                 // Set attributes
            request.setAttribute("stats", stats);
            request.setAttribute("currentUser", currentUser);
            
            // Set template attributes
            request.setAttribute("pageTitle", "Dashboard");
            request.setAttribute("activePage", "dashboard");
            request.setAttribute("contentPage", "/jsp/reception/dashboard-content.jsp");
            
            // Forward to template
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading dashboard data: " + e.getMessage());
            request.getRequestDispatcher("/jsp/reception/dashboard.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}