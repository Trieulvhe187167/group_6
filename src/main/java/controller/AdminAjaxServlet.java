// AdminAjaxServlet.java
package controller;

import dal.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import model.User;

@WebServlet(name = "AdminAjaxServlet", urlPatterns = {"/admin/ajax/*"})
public class AdminAjaxServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authentication
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        // Get the requested page
        String pathInfo = request.getPathInfo();
        String page = pathInfo != null ? pathInfo.substring(1) : "dashboard";
        
        // Route to appropriate content
        switch (page) {
            case "dashboard":
                loadDashboard(request, response);
                break;
            case "rooms":
                loadRooms(request, response);
                break;
            case "customers":
                loadCustomers(request, response);
                break;
            case "bookings":
                loadBookings(request, response);
                break;
            case "housekeeping":
                loadHousekeeping(request, response);
                break;
            case "reports":
                loadReports(request, response);
                break;
            case "blogs":
                loadBlogs(request, response);
                break;
            case "events":
                loadEvents(request, response);
                break;
            case "settings":
                loadSettings(request, response);
                break;
            default:
                loadDashboard(request, response);
        }
    }
    
    private void loadDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get statistics
        Map<String, Object> stats = new HashMap<>();
        
        try {
            CustomerDAO customerDAO = new CustomerDAO();
            RoomDAO roomDAO = new RoomDAO();
            ReservationDAO reservationDAO = new ReservationDAO();
            
            stats.put("totalCustomers", customerDAO.getTotalCustomers());
            stats.put("availableRooms", roomDAO.getAvailableRoomsCount());
            stats.put("occupiedRooms", roomDAO.getOccupiedRoomsCount());
            stats.put("todayCheckIns", reservationDAO.getTodayCheckInsCount());
            stats.put("monthlyRevenue", reservationDAO.getMonthlyRevenue());
            stats.put("yearlyRevenue", reservationDAO.getYearlyRevenue());
            stats.put("recentReservations", reservationDAO.getRecentReservations(5));
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        request.setAttribute("stats", stats);
        request.getRequestDispatcher("/jsp/admin-dashboard-content.jsp").forward(request, response);
    }
    
    private void loadRooms(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Forward to room list content
        request.getRequestDispatcher("/jsp/admin-room-list-content.jsp").forward(request, response);
    }
    
    private void loadCustomers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        CustomerDAO customerDAO = new CustomerDAO();
        request.setAttribute("customers", customerDAO.getAllCustomers());
        request.getRequestDispatcher("/jsp/customer-list-content.jsp").forward(request, response);
    }
    
    private void loadBookings(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("new".equals(action)) {
            request.getRequestDispatcher("/jsp/booking-form-content.jsp").forward(request, response);
        } else if ("calendar".equals(action)) {
            request.getRequestDispatcher("/jsp/booking-calendar-content.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/jsp/booking-list-content.jsp").forward(request, response);
        }
    }
    
    private void loadHousekeeping(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        RoomDAO roomDAO = new RoomDAO();
        request.setAttribute("rooms", roomDAO.getRoomsWithFilter("ALL"));
        request.getRequestDispatcher("/jsp/housekeeping-content.jsp").forward(request, response);
    }
    
    private void loadReports(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.getRequestDispatcher("/jsp/reports-content.jsp").forward(request, response);
    }
    
    private void loadBlogs(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        BlogDAO blogDAO = new BlogDAO();
        request.setAttribute("blogs", blogDAO.getPublishedBlogs());
        request.getRequestDispatcher("/jsp/blog-list-content.jsp").forward(request, response);
    }
    
    private void loadEvents(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        EventDAO eventDAO = new EventDAO();
        request.setAttribute("events", eventDAO.getAllEvents());
        request.getRequestDispatcher("/jsp/event-list-content.jsp").forward(request, response);
    }
    
    private void loadSettings(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String type = request.getParameter("type");
        
        switch (type) {
            case "profile":
                request.getRequestDispatcher("/jsp/settings-profile-content.jsp").forward(request, response);
                break;
            case "security":
                request.getRequestDispatcher("/jsp/settings-security-content.jsp").forward(request, response);
                break;
            default:
                request.getRequestDispatcher("/jsp/settings-general-content.jsp").forward(request, response);
        }
    }
}