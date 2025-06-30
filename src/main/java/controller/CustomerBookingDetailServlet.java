package controller;

import dal.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Reservation;

import java.io.IOException;

@WebServlet("/customer/booking-detail")
public class CustomerBookingDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/customer/bookings");
                return;
            }

            int bookingId = Integer.parseInt(idParam);
            BookingDAO dao = new BookingDAO();
            Reservation booking = dao.getReservationById(bookingId);

            if (booking == null) {
                // Đơn không tồn tại → về lại danh sách
                response.sendRedirect(request.getContextPath() + "/customer/bookings");
                return;
            }

            // Có thể thêm check quyền nếu muốn:
            // HttpSession session = request.getSession(false);
            // User currentUser = (User) session.getAttribute("user");
            // if (!booking.getUserId().equals(currentUser.getId())) return 403/404

            request.setAttribute("booking", booking);
            request.getRequestDispatcher("/jsp/customer/customer-booking-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
