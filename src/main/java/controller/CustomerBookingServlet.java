package controller;

import dal.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Reservation;
import model.User;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
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
            // ✅ Lấy tham số filter
            String status = req.getParameter("status");
            String fromDate = req.getParameter("fromDate");
            String toDate = req.getParameter("toDate");

            // ✅ Gọi đúng hàm trong DAO
            List<Reservation> historyBookings = dao.getPastBookings(userId, status, fromDate, toDate);

            // ✅ Truyền filter lại view
            req.setAttribute("historyBookings", historyBookings);
            req.setAttribute("selectedStatus", status);
            req.setAttribute("selectedDateFrom", fromDate);
            req.setAttribute("selectedDateTo", toDate);
            req.getRequestDispatcher("/jsp/customer/booking-history.jsp").forward(req, resp);
        }
    }
}
