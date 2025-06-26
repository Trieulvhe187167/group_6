package controller;

import com.google.gson.Gson;
import dal.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Reservation;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/admin/api/booking-detail")
public class BookingDetailApiServlet extends HttpServlet {
    private BookingDAO bookingDAO;

    @Override
    public void init() throws ServletException {
        bookingDAO = new BookingDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");

        // Kiểm tra param
        if (idParam == null || !idParam.matches("\\d+")) {
            System.err.println("❌ BookingDetailApiServlet: invalid id param = " + idParam);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid or missing booking ID");
            return;
        }

        try {
            int bookingId = Integer.parseInt(idParam);
            Reservation reservation = bookingDAO.getReservationById(bookingId);

            if (reservation != null) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");

                String json = new Gson().toJson(reservation);
                PrintWriter out = response.getWriter();
                out.print(json);
                out.flush();
            } else {
                System.err.println("⚠️ BookingDetailApiServlet: booking not found for id = " + bookingId);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Booking not found");
            }
        } catch (Exception e) {
            e.printStackTrace(); // log stacktrace chi tiết
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server error occurred");
        }
    }
}
