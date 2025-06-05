package controller;

import dal.ReservationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;

@WebServlet(name = "BookingManagementServlet", urlPatterns = {"/admin/bookings"})
public class BookingManagementServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authentication
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
//        if (user == null || (!"ADMIN".equals(user.getRole()) && !"RECEPTIONIST".equals(user.getRole()))) {
//            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
//            return;
//        }
        
        String action = request.getParameter("action");
        
        if ("new".equals(action)) {
            // Show new booking form
            showNewBookingForm(request, response);
        } else if ("edit".equals(action)) {
            // Show edit form
            showEditForm(request, response);
        } else if ("view".equals(action)) {
            // Show booking details
            showBookingDetails(request, response);
        } else {
            // Show booking list
            showBookingList(request, response);
        }
    }
    
    private void showBookingList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        ReservationDAO dao = new ReservationDAO();
        request.setAttribute("bookings", dao.getAllReservations());
        
        // Set page attributes for template
        request.setAttribute("pageTitle", "Booking Management");
        request.setAttribute("activePage", "bookings");
        request.setAttribute("contentPage", "/jsp/booking-list-content.jsp");
        
        request.getRequestDispatcher("/jsp/admin-template.jsp").forward(request, response);
    }
    
    private void showNewBookingForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Implementation for new booking form
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Implementation for edit form
    }
    
    private void showBookingDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Implementation for booking details
    }
}