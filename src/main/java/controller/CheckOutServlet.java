package controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import dal.BookingDAO;
import dal.RoomDAO;
import model.Reservation;
import model.Room;
import model.User;
import util.JsonResponse;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "CheckOutServlet", urlPatterns = {"/receptionist/check-out"})
public class CheckOutServlet extends HttpServlet {
    private final BookingDAO bookingDAO = new BookingDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // Check if user is logged in and has receptionist role
        if (user == null || !user.getRole().equals("RECEPTIONIST")) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write(objectMapper.writeValueAsString(new JsonResponse(false, "Unauthorized access")));
            return;
        }

        String action = request.getParameter("action");
        
        // Handle different actions
        if ("getReservation".equals(action)) {
            handleGetReservation(request, response);
        } else {
            // Process check-out
            handleCheckOut(request, response);
        }
    }

    private void handleGetReservation(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("id"));
            Reservation booking = bookingDAO.getReservationById(reservationId);
            
            if (booking == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write(objectMapper.writeValueAsString(
                    new JsonResponse(false, "Reservation not found")));
                return;
            }
            
            // Get room details
            Room room = roomDAO.getRoomById(booking.getRoomId());
            
            // Calculate nights
            long nights = ChronoUnit.DAYS.between(
                booking.getCheckIn().toLocalDate(),
                booking.getCheckOut().toLocalDate()
            );
            
            // Create response data
            Map<String, Object> data = new HashMap<>();
            data.put("id", booking.getId());
            data.put("customerName", booking.getUserFullName());
            data.put("customerPhone", booking.getCustomerPhone());
            data.put("customerEmail", booking.getUserEmail());
            data.put("roomNumber", room.getRoomNumber());
            data.put("roomTypeName", room.getRoomTypeName());
            data.put("checkIn", booking.getCheckIn().toString());
            data.put("checkOut", booking.getCheckOut().toString());
            data.put("nights", nights);
            data.put("roomCharges", booking.getTotalAmount().doubleValue());
            data.put("additionalServices", 0); // Get from services if available
            data.put("taxes", booking.getTotalAmount() * 0.1); // 10% tax example
            data.put("totalAmount", booking.getTotalAmount() * 1.1); // Including tax
            data.put("amountPaid", booking.getAmountPaid());
            
            response.getWriter().write(objectMapper.writeValueAsString(data));
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(objectMapper.writeValueAsString(
                new JsonResponse(false, "Invalid reservation ID")));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(objectMapper.writeValueAsString(
                new JsonResponse(false, "Error retrieving reservation details: " + e.getMessage())));
        }
    }

    private void handleCheckOut(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            // Parse request body
            Map<String, Object> checkOutData = objectMapper.readValue(request.getReader(), Map.class);
            
            int reservationId = Integer.parseInt(checkOutData.get("reservationId").toString());
            String roomStatus = (String) checkOutData.get("roomStatus");
            String notes = (String) checkOutData.get("notes");
            boolean balancePaid = (boolean) checkOutData.get("balancePaid");
            
            // Get booking
            Reservation booking = bookingDAO.getReservationById(reservationId);
            if (booking == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write(objectMapper.writeValueAsString(
                    new JsonResponse(false, "Reservation not found")));
                return;
            }
            
            // Update booking status to COMPLETED
            booking.setStatus("COMPLETED");
            booking.setUpdatedAt(new java.sql.Timestamp(System.currentTimeMillis()));
            
            // If balance is paid, update payment status
            if (balancePaid) {
                double totalAmount = booking.getTotalAmount() * 1.1; // Including tax
                booking.setAmountPaid(totalAmount);
                booking.setPaymentStatus("PAID");
            }
            
            // Update booking
            bookingDAO.updateReservation(booking);
            
            // Update room status
            Room room = roomDAO.getRoomById(booking.getRoomId());
            room.setStatus(roomStatus);
            roomDAO.updateRoom(room);
            
            // Return success response
            response.getWriter().write(objectMapper.writeValueAsString(
                new JsonResponse(true, "Check-out completed successfully")));
            
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(objectMapper.writeValueAsString(
                new JsonResponse(false, "Error processing check-out: " + e.getMessage())));
        }
    }
}
