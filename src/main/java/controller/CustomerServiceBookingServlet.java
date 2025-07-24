/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;
import dal.ActivityDAO;
import dal.ReservationDAO;
import dal.ServiceDAO;
import dal.NotificationDAO;
import dal.UserDAO;
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
import model.Notification;

@WebServlet(name = "CustomerServiceBookingServlet", urlPatterns = {"/customer/services"})
public class CustomerServiceBookingServlet extends HttpServlet {

    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final UserDAO userDAO = new UserDAO();

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
                    String[] qtys = request.getParameterValues("quantities");
                    if (ids == null || ids.length == 0) {
                        session.setAttribute("error", "Please select at least one service to add");
                        response.sendRedirect(request.getContextPath() + "/customer/services?resId=" + reservationId);
                        return;
                    }
                        for (int i = 0; i < ids.length; i++) {
                        int sId = Integer.parseInt(ids[i]);
                        int qty = 1;
                        if (qtys != null && qtys.length > i) {
                            try {
                                qty = Integer.parseInt(qtys[i]);
                            } catch (NumberFormatException ex) {
                                qty = 1;
                            }
                        }
                        ReservationService existing = serviceDAO.getReservationService(reservationId, sId);
                        if (existing != null) {
                           serviceDAO.updateReservationServiceQuantity(existing.getId(), existing.getQuantity() + qty);
                        } else {
                            ReservationService rs = new ReservationService(reservationId, sId, qty);
                            rs.setCreatedBy(user.getId());
                            rs.setStatus("CONFIRMED");
                            serviceDAO.addServiceToReservation(rs);
                        }

                        
                        Activity act = new Activity();
                        act.setType("SERVICE_ORDERED");
                        act.setReservationId(reservationId);
                        act.setUserId(user.getId());
                          act.setDescription("Requested service " + sId);
                        act.setTimestamp(new Timestamp(System.currentTimeMillis()));
                        activityDAO.logActivity(act);
                        
                          // Notify all receptionists
                        List<User> recps = userDAO.getUsersByRole("RECEPTIONIST");
                        for (User rcp : recps) {
                            Notification notif = new Notification();
                            notif.setUserId(rcp.getId());
                            notif.setReservationId(reservationId);
                            notif.setType("SERVICE_REQUEST");
                            notif.setMessage(user.getFullName() + " requested service " + sId);
                            notificationDAO.sendNotification(notif);
                        }
                    }
                    success = true;
                    message = "Service request submitted";
                    break;
                }
        
                case "delete": {
                    int lineId = Integer.parseInt(request.getParameter("lineId"));
                    success = serviceDAO.updateServiceOrderStatus(lineId, "CANCELLED");
                    message = success ? "Service cancelled" : "Failed to cancel";
                    if (success) {
                        Activity act = new Activity();
                        act.setType("SERVICE_CANCELLED");
                        act.setReservationId(reservationId);
                        act.setUserId(user.getId());
                        act.setDescription("Cancelled service " + lineId);
                        act.setTimestamp(new Timestamp(System.currentTimeMillis()));
                        activityDAO.logActivity(act);

                        List<User> recps = userDAO.getUsersByRole("RECEPTIONIST");
                        for (User rcp : recps) {
                            Notification notif = new Notification();
                            notif.setUserId(rcp.getId());
                            notif.setReservationId(reservationId);
                            notif.setType("SERVICE_CANCELLED");
                            notif.setMessage(user.getFullName() + " cancelled service " + lineId);
                            notificationDAO.sendNotification(notif);
                        }
                    }
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