package controller;

import dal.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "BookingConfirmationServlet", urlPatterns = {"/BookingConfirmation"})
public class BookingConfirmationServlet extends HttpServlet {
    
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final RoomTypeDAO roomTypeDAO = new RoomTypeDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Get reservation ID from parameter first (from payment redirect)
        String reservationIdParam = request.getParameter("reservationId");
        Integer reservationId = null;
        
        if (reservationIdParam != null) {
            try {
                reservationId = Integer.parseInt(reservationIdParam);
            } catch (NumberFormatException e) {
                // Invalid ID format
            }
        }
        
        // If no parameter, check session (from direct booking)
        if (reservationId == null) {
            reservationId = (Integer) session.getAttribute("lastReservationId");
        }
        
        if (reservationId == null) {
            response.sendRedirect("SearchAvailableRoomsServlet");
            return;
        }
        
        try {
            // Get reservation details with deposit info
            Reservation reservation = reservationDAO.getReservationById(reservationId);
            if (reservation == null) {
                response.sendRedirect("SearchAvailableRoomsServlet");
                return;
            }
            
            // Get room details
            Room room = roomDAO.getRoomById(reservation.getRoomId());
            if (room == null) {
                response.sendRedirect("SearchAvailableRoomsServlet");
                return;
            }
            
            // Get room type
            RoomType roomType = roomTypeDAO.getRoomTypesById(room.getRoomTypeId());
            
            // Get latest payment info (deposit payment)
            Payment payment = paymentDAO.getPaymentByReservationId(reservationId);
            
            // Get services if any
            List<ServiceOrder> services = serviceDAO.getServiceOrdersByReservation(reservationId);
            
            // Set attributes
            request.setAttribute("reservation", reservation);
            request.setAttribute("room", room);
            request.setAttribute("roomType", roomType);
            request.setAttribute("payment", payment);
            request.setAttribute("services", services);
            
            // Clear session attributes
            session.removeAttribute("lastReservationId");
            session.removeAttribute("bookingDetails");
            
            // Forward to confirmation page
            request.getRequestDispatcher("/jsp/bookingConfirmation.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("SearchAvailableRoomsServlet");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}