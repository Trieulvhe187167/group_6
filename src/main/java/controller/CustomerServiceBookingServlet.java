/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;
import dal.ActivityDAO;
import dal.ReservationDAO;
import dal.ServiceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;
import model.Activity;
import model.Reservation;
import model.ReservationService;
import model.User;

@WebServlet(name = "CustomerServiceBookingServlet", urlPatterns = {"/customer/services"})
public class CustomerServiceBookingServlet extends HttpServlet {

    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"CUSTOMER".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
 List<Reservation> reservations = reservationDAO.getActiveStays(user.getId());
        request.setAttribute("reservations", reservations);

        int selectedId = 0;
        String resParam = request.getParameter("resId");
        if (resParam != null) {
            try { selectedId = Integer.parseInt(resParam); } catch (NumberFormatException ignored) {}
        }
        if (selectedId == 0 && !reservations.isEmpty()) {
            selectedId = reservations.get(0).getId();
        }

        if (selectedId != 0) {
            request.setAttribute("cart", serviceDAO.getServiceOrdersByReservation(selectedId));
        }
        request.setAttribute("selectedId", selectedId);
        request.setAttribute("services", serviceDAO.getAllActiveServices());
        request.getRequestDispatcher("/jsp/customer/service-booking.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"CUSTOMER".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String action = request.getParameter("action");
        String reservationIdStr = request.getParameter("reservationId");
           int reservationId = reservationIdStr != null ? Integer.parseInt(reservationIdStr) : 0;
        boolean success = false;
         String message = null;

        if (reservationId == 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
         try {
            switch (action) {
                case "add": {
                 String[] ids = request.getParameterValues("serviceIds");
                       if (ids == null || ids.length == 0) {
                        session.setAttribute("error", "Please select at least one service to add");
                        response.sendRedirect(request.getContextPath() + "/customer/services?resId=" + reservationId);
                        return;
                    }
                        for (String sid : ids) {
                        int sId = Integer.parseInt(sid);
                        ReservationService rs = new ReservationService(reservationId, sId, 1);
                        serviceDAO.addServiceToReservation(rs);
                        Activity act = new Activity();
                        act.setType("SERVICE_ORDERED");
                        act.setReservationId(reservationId);
                        act.setUserId(user.getId());
                        act.setDescription("Ordered service " + sId);
                        act.setTimestamp(new Timestamp(System.currentTimeMillis()));
                        activityDAO.logActivity(act);
                    }
                    success = true;
                    message = "Services added successfully";
                    break;
                }
                case "update": {
                    int lineId = Integer.parseInt(request.getParameter("lineId"));
                    int quantity = Integer.parseInt(request.getParameter("quantity"));
                    success = serviceDAO.updateReservationServiceQuantity(lineId, quantity);
                    message = success ? "Service updated" : "Failed to update";
                    break;
                }
                case "delete": {
                    int lineId = Integer.parseInt(request.getParameter("lineId"));
                    success = serviceDAO.deleteServiceFromReservation(lineId);
                        message = success ? "Service removed" : "Failed to remove";
                    break;
                }
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                    return;
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
            if (message != null) {
            session.setAttribute(success ? "success" : "error", message);
        }
        response.sendRedirect(request.getContextPath() + "/customer/services?resId=" + reservationId);
    }
}