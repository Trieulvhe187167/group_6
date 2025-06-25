package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Reservation;
import dal.BookingDAO;

@WebServlet("/admin/bookings")
public class AdminBookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check admin authentication
        

        // Get filter parameters
        String statusFilter = request.getParameter("status");
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");
        
        // Debug: Print filter parameters
        System.out.println("Status Filter: " + statusFilter);
        System.out.println("From Date: " + fromDate);
        System.out.println("To Date: " + toDate);
        
        // Get page parameters for pagination
        int page = 1;
        int recordsPerPage = 20;
        
        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) {
                page = Integer.parseInt(pageParam);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }
        
        int offset = (page - 1) * recordsPerPage;

        try {
            // Use the new DAO
            List<Reservation> reservations = bookingDAO.getReservations(statusFilter, fromDate, toDate, offset, recordsPerPage);
            int totalRecords = bookingDAO.getTotalReservationCount(statusFilter, fromDate, toDate);
            int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);

            // Debug: Print results
            System.out.println("Total Records Found: " + totalRecords);
            System.out.println("Reservations List Size: " + reservations.size());
            
            if (reservations != null && !reservations.isEmpty()) {
                System.out.println("First reservation ID: " + reservations.get(0).getId());
            }

            // Set attributes for JSP
            request.setAttribute("reservations", reservations);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalRecords", totalRecords);
            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("fromDate", fromDate);
            request.setAttribute("toDate", toDate);

            // Forward to JSP
            request.getRequestDispatcher("/jsp/admin/booking-list.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Error in AdminBookingServlet: " + e.getMessage());
            request.setAttribute("errorMessage", "Error loading bookings: " + e.getMessage());
            request.getRequestDispatcher("/jsp/admin/booking-list.jsp").forward(request, response);
        }
    }
}