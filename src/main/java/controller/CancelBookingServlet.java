package controller;

import dal.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Reservation;
import model.User;
import util.MailUtil;

import java.io.IOException;

@WebServlet("/customer/cancel-booking")
public class CancelBookingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("id"));

            // Lấy thông tin user từ session
            User user = (User) request.getSession().getAttribute("user");
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }

            BookingDAO dao = new BookingDAO();

            // Lấy thông tin đơn đặt phòng để gửi mail
            Reservation booking = dao.getReservationById(bookingId);
            if (booking == null || booking.getUserId() != user.getId()) {
                response.sendRedirect(request.getContextPath() + "/customer/bookings?cancel=unauthorized");
                return;
            }

            boolean success = dao.cancelBooking(bookingId);
            if (success) {
                // Gửi mail huỷ thành công
                String to = user.getEmail();
                String subject = "Booking Cancellation Confirmation";
                String message = "Dear " + user.getFullName() + ",\n\n" +
                        "Your booking with ID #" + bookingId + " has been successfully cancelled.\n\n" +
                        "Room: " + booking.getRoomName() + " (" + booking.getRoomTypeName() + ")\n" +
                        "Check-in: " + booking.getCheckIn() + "\n" +
                        "Check-out: " + booking.getCheckOut() + "\n\n" +
                        "If you have any questions, feel free to contact us.\n\n" +
                        "Best regards,\nHotel Management";

                MailUtil.sendEmail(to, subject, message);
                response.sendRedirect(request.getContextPath() + "/customer/bookings?cancel=success");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/bookings?cancel=failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customer/bookings?cancel=error");
        }
    }
}
