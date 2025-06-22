package controller;

import dal.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "BookingConfirmationServlet", urlPatterns = {"/BookingConfirmation"})
public class BookingConfirmationServlet extends HttpServlet {
    
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final RoomTypeDAO roomTypeDAO = new RoomTypeDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer reservationId = (Integer) session.getAttribute("lastReservationId");
        
        if (reservationId == null) {
            response.sendRedirect("RoomListServlet");
            return;
        }
        
        try {
            // Get reservation details
            Reservation reservation = reservationDAO.getReservationById(reservationId);
            if (reservation == null) {
                response.sendRedirect("RoomListServlet");
                return;
            }
            
            // Get room details
            Room room = roomDAO.getRoomById(reservation.getRoomId());
            RoomType roomType = roomTypeDAO.getRoomTypesById(room.getRoomTypeId());
            
            // Get payment info
            Payment payment = paymentDAO.getLatestPaymentByReservation(reservationId);
            
            // Get services
            List<ServiceOrder> services = new ServiceDAO().getServiceOrdersByReservation(reservationId);
            
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
            response.sendRedirect("RoomListServlet");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}