package controller;

import dal.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;

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

        // Get single or multiple reservation IDs
        String reservationIdsParam = request.getParameter("reservationIds");
        String reservationIdParam = request.getParameter("reservationId");

        List<Integer> reservationIds = new ArrayList<>();

        if (reservationIdsParam != null && !reservationIdsParam.isEmpty()) {
            for (String s : reservationIdsParam.split(",")) {
                try {
                    reservationIds.add(Integer.parseInt(s.trim()));
                } catch (NumberFormatException ignore) {
                }
            }
        }

        if (reservationIds.isEmpty() && reservationIdParam != null) {
            try {
                reservationIds.add(Integer.parseInt(reservationIdParam));
            } catch (NumberFormatException ignore) {
            }
        }

        if (reservationIds.isEmpty()) {
            List<Integer> sessionIds = (List<Integer>) session.getAttribute("lastReservationIds");
            if (sessionIds != null) {
                reservationIds.addAll(sessionIds);
                // Invalid ID format
            }
        }

        // If no parameter, check session (from direct booking)
        if (reservationIds.isEmpty()) {
            Integer lastId = (Integer) session.getAttribute("lastReservationId");
            if (lastId != null) {
                reservationIds.add(lastId);
            }
        }

        if (reservationIds.isEmpty()) {
            response.sendRedirect("SearchAvailableRoomsServlet");
            return;
        }

        try {
            List<Reservation> reservations = new ArrayList<>();
            double totalAmount = 0;
            double totalDeposit = 0;
            Payment payment = null;

            for (int rid : reservationIds) {
                Reservation r = paymentDAO.getReservationWithDeposit(rid);
                if (r != null) {
                    reservations.add(r);
                    totalAmount += r.getTotalAmount();
                    if (r.getDepositAmount() != null) {
                        totalDeposit += r.getDepositAmount();
                    }
                    if (payment == null) {
                        payment = paymentDAO.getPaymentByReservationId(rid);
                    }
                }
            }

            if (reservations.isEmpty()) {
                response.sendRedirect("SearchAvailableRoomsServlet");
                return;
            }

            Reservation first = reservations.get(0);
            List<ServiceOrder> services = serviceDAO.getServiceOrdersByReservation(first.getId());

            request.setAttribute("reservations", reservations);
              request.setAttribute("reservationList", reservations);
            request.setAttribute("reservation", first);
            request.setAttribute("payment", payment);
            request.setAttribute("services", services);
            request.setAttribute("totalAmount", totalAmount);
            request.setAttribute("depositAmount", totalDeposit);

            // Clear session attributes
            session.removeAttribute("lastReservationId");
            session.removeAttribute("lastReservationIds");
            session.removeAttribute("lastPaymentIds");
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
