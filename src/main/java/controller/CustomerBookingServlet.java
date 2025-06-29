package controller;

import dal.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Reservation;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet({"/customer/bookings", "/customer/history"})
public class CustomerBookingServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"CUSTOMER".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int userId = user.getId();
        BookingDAO dao = new BookingDAO();

        String uri = req.getRequestURI();

        if (uri.endsWith("/bookings")) {
            List<Reservation> bookings = dao.getUpcomingBookings(userId);
            req.setAttribute("bookings", bookings);
            req.getRequestDispatcher("/jsp/customer/my-booking.jsp").forward(req, resp);
        } else if (uri.endsWith("/history")) {
            List<Reservation> historyBookings = dao.getPastBookings(userId);
            req.setAttribute("historyBookings", historyBookings);
            req.getRequestDispatcher("/jsp/customer/booking-history.jsp").forward(req, resp);
        }
    }
}
