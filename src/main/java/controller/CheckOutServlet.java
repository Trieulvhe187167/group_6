package controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import dal.BookingDAO;
import dal.RoomDAO;
import model.Booking;
import model.Room;
import model.RoomStatus;
import model.User;
import util.JsonResponse;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
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
            Booking booking = bookingDAO.getBookingById(reservationId);
            
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
                booking.getCheckInDate().toLocalDate(),
                booking.getCheckOutDate().toLocalDate()
            );
            
            // Create response data
            Map<String, Object> data = new HashMap<>();
            data.put("id", booking.getId());
            data.put("customerName", booking.getCustomer().getFullName());
            data.put("customerPhone", booking.getCustomer().getPhone());
            data.put("customerEmail", booking.getCustomer().getEmail());
            data.put("roomNumber", room.getRoomNumber());
            data.put("roomTypeName", room.getRoomType().getName());
            data.put("checkIn", booking.getCheckInDate().toString());
            data.put("checkOut", booking.getCheckOutDate().toString());
            data.put("nights", nights);
            data.put("roomCharges", booking.getTotalAmount().doubleValue());
            data.put("additionalServices", 0); // Get from services if available
            data.put("taxes", booking.getTotalAmount().multiply(new BigDecimal("0.1")).doubleValue()); // 10% tax example
            data.put("totalAmount", booking.getTotalAmount().multiply(new BigDecimal("1.1")).doubleValue()); // Including tax
            data.put("amountPaid", booking.getAmountPaid().doubleValue());
            
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
            Booking booking = bookingDAO.getBookingById(reservationId);
            if (booking == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write(objectMapper.writeValueAsString(
                    new JsonResponse(false, "Reservation not found")));
                return;
            }
            
            // Update booking status to COMPLETED
            booking.setStatus("COMPLETED");
            booking.setActualCheckOutDate(java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()));
            
            // If balance is paid, update payment status
            if (balancePaid) {
                BigDecimal totalAmount = booking.getTotalAmount().multiply(new BigDecimal("1.1")); // Including tax
                booking.setAmountPaid(totalAmount);
                booking.setPaymentStatus("PAID");
            }
            
            // Update booking
            bookingDAO.updateBooking(booking);
            
            // Update room status
            Room room = roomDAO.getRoomById(booking.getRoomId());
            room.setStatus(RoomStatus.valueOf(roomStatus));
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
