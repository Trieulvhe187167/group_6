package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.BufferedReader;
import java.util.List;
import java.util.Map;
import java.sql.Date;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;

import model.*;
import dal.*;
import util.MailUtil;

@WebServlet(urlPatterns = {
    "/admin/bookings",
    "/admin/api/booking-detail", 
    "/customer/bookings",
    "/customer/history",
    "/customer/booking-detail",
    "/customer/cancel-booking",
    "/receptionist/reservations"
})
public class ReservationsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final UserDAO userDAO = new UserDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final RoomTypeDAO roomTypeDAO = new RoomTypeDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = uri.substring(contextPath.length());

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        try {
            switch (path) {
                case "/admin/bookings":
                    if (!"ADMIN".equals(user.getRole())) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    handleAdminBookings(request, response);
                    break;

                case "/admin/api/booking-detail":
                    if (!"ADMIN".equals(user.getRole())) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    handleAdminBookingDetail(request, response);
                    break;

                case "/customer/bookings":
                    if (!"CUSTOMER".equals(user.getRole())) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    handleCustomerBookings(request, response);
                    break;

                case "/customer/history":
                    if (!"CUSTOMER".equals(user.getRole())) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    handleCustomerHistory(request, response);
                    break;

                case "/customer/booking-detail":
                    if (!"CUSTOMER".equals(user.getRole())) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    handleCustomerBookingDetail(request, response);
                    break;

                case "/receptionist/reservations":
                    if (!"RECEPTIONIST".equals(user.getRole())) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    handleReceptionistReservations(request, response);
                    break;

                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = uri.substring(contextPath.length());

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        try {
            switch (path) {
                case "/customer/cancel-booking":
                    if (!"CUSTOMER".equals(user.getRole())) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    handleCustomerCancelBooking(request, response);
                    break;

                case "/receptionist/reservations":
                    if (!"RECEPTIONIST".equals(user.getRole())) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                    handleReceptionistReservationsPost(request, response);
                    break;

                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error: " + e.getMessage());
        }
    }

    // ======================= ADMIN =======================
    private void handleAdminBookings(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String statusFilter = request.getParameter("status");
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");

        int page = 1;
        int recordsPerPage = 5;

        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) {
                page = Integer.parseInt(pageParam);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }

        int offset = (page - 1) * recordsPerPage;

        try {
            List<Reservation> reservations = reservationDAO.getReservations(statusFilter, fromDate, toDate, offset, recordsPerPage);
            int totalRecords = reservationDAO.getTotalReservationCount(statusFilter, fromDate, toDate);
            int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);

            request.setAttribute("reservations", reservations);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalRecords", totalRecords);
            request.setAttribute("recordsPerPage", recordsPerPage);
            request.setAttribute("statusFilter", statusFilter);
            request.setAttribute("fromDate", fromDate);
            request.setAttribute("toDate", toDate);

            request.getRequestDispatcher("/jsp/admin/booking-list.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading bookings: " + e.getMessage());
            request.getRequestDispatcher("/jsp/admin/booking-list.jsp").forward(request, response);
        }
    }

    private void handleAdminBookingDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        if (idParam == null || !idParam.matches("\\d+")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid or missing booking ID");
            return;
        }

        try {
            int bookingId = Integer.parseInt(idParam);
            Reservation reservation = reservationDAO.getReservationById(bookingId);

            if (reservation != null) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");

                String json = new Gson().toJson(reservation);
                PrintWriter out = response.getWriter();
                out.print(json);
                out.flush();
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Booking not found");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server error occurred");
        }
    }

    // ======================= CUSTOMER =======================
    private void handleCustomerBookings(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        int userId = user.getId();
        List<Reservation> bookings = reservationDAO.getUpcomingBookings(userId);
        request.setAttribute("bookings", bookings);
        request.getRequestDispatcher("/jsp/customer/my-booking.jsp").forward(request, response);
    }

    private void handleCustomerHistory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        int userId = user.getId();

        String status = request.getParameter("status");
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");

        List<Reservation> historyBookings = reservationDAO.getPastBookings(userId, status, fromDate, toDate);
        FeedbackDAO feedbackDAO = new FeedbackDAO();
        for (Reservation r : historyBookings) {
            Feedback feedback = feedbackDAO.getFeedbackByReservationId(r.getId());
            if (feedback != null) {
                r.setRating(feedback.getRating());
                r.setComment(feedback.getComment());
            } else {
                r.setRating(0);
                r.setComment("");
            }
        }
        request.setAttribute("historyBookings", historyBookings);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedDateFrom", fromDate);
        request.setAttribute("selectedDateTo", toDate);
        request.getRequestDispatcher("/jsp/customer/booking-history.jsp").forward(request, response);
    }

    private void handleCustomerBookingDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        try {
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/customer/bookings");
                return;
            }

            int bookingId = Integer.parseInt(idParam);
            Reservation booking = reservationDAO.getReservationById(bookingId);

            if (booking == null || booking.getUserId() != user.getId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                return;
            }

            request.setAttribute("booking", booking);
            request.getRequestDispatcher("/jsp/customer/customer-booking-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void handleCustomerCancelBooking(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    HttpSession session = request.getSession();
    User user = (User) session.getAttribute("user");

    try {
        int bookingId = Integer.parseInt(request.getParameter("id"));

        Reservation booking = reservationDAO.getReservationById(bookingId);
        if (booking == null || booking.getUserId() != user.getId()) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings?cancel=unauthorized");
            return;
        }

        boolean success = reservationDAO.cancelBooking(bookingId);

        if (success) {
            // Tải lại trạng thái mới sau khi hủy
            Reservation updatedBooking = reservationDAO.getReservationById(bookingId);

            String depositNote = "";
            if ("LOST".equals(updatedBooking.getDepositStatus())) {
                depositNote = "\nNote: You have cancelled too close to your check-in time, and your deposit has been forfeited.";
            } else if ("REFUNDED".equals(updatedBooking.getDepositStatus())) {
                depositNote = "\nNote: Your deposit has been refunded.";
            }

            String to = user.getEmail();
            String subject = "Booking Cancellation Confirmation";
            String message = "Dear " + user.getFullName() + ",\n\n" +
                    "Your booking with ID #" + bookingId + " has been successfully cancelled.\n\n" +
                    "Room: " + updatedBooking.getRoomName() + " (" + updatedBooking.getRoomTypeName() + ")\n" +
                    "Check-in: " + updatedBooking.getCheckIn() + "\n" +
                    "Check-out: " + updatedBooking.getCheckOut() + "\n" +
                    depositNote + "\n\n" +
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

    // =========================== RECEPTIONIST METHODS ===========================
    
    private void handleReceptionistReservations(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // Handle export action
            String action = request.getParameter("action");
            if ("export".equals(action)) {
                exportReservations(request, response);
                return;
            } else if ("print".equals(action)) {
                printReservation(request, response);
                return;
            }
            
            // Get filter parameters
            String status = request.getParameter("status");
            String checkInDate = request.getParameter("checkInDate");
            String checkOutDate = request.getParameter("checkOutDate");
            String search = request.getParameter("search");
            
            // Get reservations with filters
            List<ReservationSummary> reservations;
            if (status != null || checkInDate != null || checkOutDate != null || search != null) {
                reservations = reservationDAO.getReservationsWithFilters(status, checkInDate, checkOutDate, search);
            } else {
                reservations = reservationDAO.getRecentReservations(100);
            }
            
            // Get all customers for dropdown
            List<User> customers = userDAO.getUsersByRole("CUSTOMER");
            
            // Get all room types
            List<RoomType> roomTypes = roomTypeDAO.getAllActiveRoomTypes();
            
            // Get statistics
            int totalReservations = reservationDAO.getTotalReservations();
            int pendingReservations = reservationDAO.getReservationCountByStatus("PENDING");
            int confirmedReservations = reservationDAO.getReservationCountByStatus("CONFIRMED");
            int todayCheckIns = reservationDAO.getTodayCheckInsCount();
            
            // Set attributes
            request.setAttribute("reservations", reservations);
            request.setAttribute("customers", customers);
            request.setAttribute("roomTypes", roomTypes);
            request.setAttribute("totalReservations", totalReservations);
            request.setAttribute("pendingReservations", pendingReservations);
            request.setAttribute("confirmedReservations", confirmedReservations);
            request.setAttribute("todayCheckIns", todayCheckIns);
            request.setAttribute("currentUser", request.getSession().getAttribute("user"));
            
            // Forward to JSP
           request.setAttribute("activePage", "reservations");
request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);

            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading reservations: " + e.getMessage());
            request.getRequestDispatcher("/jsp/reception/reservations-content.jsp").forward(request, response);
        }
    }
    
    private void handleReceptionistReservationsPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        request.setCharacterEncoding("UTF-8");

        try {
            // First check if action is in URL parameters
            String action = request.getParameter("action");
            
            // If no action in parameters, try to get from JSON body
            if (action == null) {
                String contentType = request.getContentType();
                if (contentType != null && contentType.contains("application/json")) {
                    BufferedReader reader = request.getReader();
                    StringBuilder sb = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                    String jsonBody = sb.toString();
                    
                    if (jsonBody != null && !jsonBody.trim().isEmpty()) {
                        Gson gson = new Gson();
                        Map<String, Object> requestData = gson.fromJson(jsonBody, Map.class);
                        action = (String) requestData.get("action");
                        
                        // Handle actions that need JSON data
                        if ("createReservation".equals(action) || "updateReservation".equals(action)) {
                            handleJsonAction(action, requestData, request, response);
                            return;
                        }
                    }
                }
            }
            
            if (action == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\":false,\"message\":\"Missing action parameter\"}");
                return;
            }

            // Handle actions that use URL parameters
            switch (action) {
                case "confirmReservation":
                    confirmReservation(request, response);
                    break;
                case "cancelReservation":
                    cancelReservation(request, response);
                    break;
                case "getReservationDetails":
                    getReservationDetails(request, response);
                    break;
                case "getAvailableRooms":
                    getAvailableRooms(request, response);
                    break;
                case "sendConfirmation":
                    sendConfirmationEmail(request, response);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\":false,\"message\":\"Invalid action\"}");
            }
        } catch (JsonSyntaxException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"message\":\"Invalid JSON format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        }
        
    }
    
    // =========================== HELPER METHODS ===========================
    
    private void handleJsonAction(String action, Map<String, Object> requestData, 
            HttpServletRequest request, HttpServletResponse response) throws IOException {
        switch (action) {
            case "createReservation":
                createReservation(requestData, request, response);
                break;
            case "updateReservation":
                updateReservation(requestData, request, response);
                break;
            default:
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\":false,\"message\":\"Invalid JSON action\"}");
        }
    }
    
    private void confirmReservation(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("reservationId"));
            boolean success = reservationDAO.updateReservationStatus(reservationId, "CONFIRMED");
            
            if (success) {
                // Update room status if check-in is today
                Reservation reservation = reservationDAO.getReservationById(reservationId);
                Date today = new Date(System.currentTimeMillis());
                if (reservation.getCheckIn().equals(today)) {
                    roomDAO.updateRoomStatus(reservation.getRoomId(), "OCCUPIED");
                }
                
                // Log activity
                HttpSession session = request.getSession();
                User currentUser = (User) session.getAttribute("user");
                Activity activity = new Activity();
                activity.setType("RESERVATION_CONFIRM");
                activity.setReservationId(reservationId);
                activity.setUserId(currentUser.getId());
                activity.setDescription("Confirmed reservation #" + reservationId);
                activity.setIpAddress(request.getRemoteAddr());
                activityDAO.logActivity(activity);
            }
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false}");
        }
    }
    
    private void cancelReservation(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("reservationId"));
            boolean success = reservationDAO.updateReservationStatus(reservationId, "CANCELLED");
            
            if (success) {
                // Update room status back to AVAILABLE
                Reservation reservation = reservationDAO.getReservationById(reservationId);
                roomDAO.updateRoomStatus(reservation.getRoomId(), "AVAILABLE");
                
                // Log activity
                HttpSession session = request.getSession();
                User currentUser = (User) session.getAttribute("user");
                Activity activity = new Activity();
                activity.setType("RESERVATION_CANCEL");
                activity.setReservationId(reservationId);
                activity.setUserId(currentUser.getId());
                activity.setDescription("Cancelled reservation #" + reservationId);
                activity.setIpAddress(request.getRemoteAddr());
                activityDAO.logActivity(activity);
            }
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false}");
        }
    }
    
    private void createReservation(Map<String, Object> reservationData, HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            
            // Create new customer if needed
            int customerId;
            if (reservationData.get("customerId") != null) {
                customerId = ((Double) reservationData.get("customerId")).intValue();
            } else {
                // Create new customer
                Map<String, String> newCustomerData = (Map<String, String>) reservationData.get("newCustomer");
                User newCustomer = new User();
                newCustomer.setFullName(newCustomerData.get("fullName"));
                newCustomer.setEmail(newCustomerData.get("email"));
                newCustomer.setPhone(newCustomerData.get("phone"));
                newCustomer.setRole("CUSTOMER");
                newCustomer.setStatus(true);
                newCustomer.setPassword("Pass123!"); // Default password
                newCustomer.setUsername(generateUsername(newCustomer.getFullName()));
                
                customerId = userDAO.createUserAndGetId(newCustomer);
                if (customerId == 0) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\":false,\"message\":\"Failed to create customer\"}");
                    return;
                }
            }
            
            // Create reservation
            Reservation reservation = new Reservation();
            reservation.setUserId(customerId);
            
            Object roomIdObj = reservationData.get("roomId");
            int roomId = 0;
            if (roomIdObj instanceof Double) {
                roomId = ((Double) roomIdObj).intValue();
            } else if (roomIdObj instanceof String) {
                roomId = Integer.parseInt((String) roomIdObj);
            }
            reservation.setRoomId(roomId);

            reservation.setCheckIn(Date.valueOf((String) reservationData.get("checkIn")));
            reservation.setCheckOut(Date.valueOf((String) reservationData.get("checkOut")));
            reservation.setStatus("CONFIRMED");
            reservation.setCreatedBy(currentUser.getId());
            reservation.setSpecialRequests((String) reservationData.get("specialRequests"));
            
            if (reservationData.get("numberOfCustomers") != null) {
                Object numCustomersObj = reservationData.get("numberOfCustomers");
                if (numCustomersObj instanceof Double) {
                    reservation.setNumberOfCustomers(((Double) numCustomersObj).intValue());
                } else if (numCustomersObj instanceof String) {
                    reservation.setNumberOfCustomers(Integer.parseInt((String) numCustomersObj));
                }
            }
            
            // Calculate total amount
            Room room = roomDAO.getRoomById(reservation.getRoomId());
            long days = (reservation.getCheckOut().getTime() - reservation.getCheckIn().getTime()) / (1000 * 60 * 60 * 24);
            double totalAmount = days * room.getBasePrice();
            reservation.setTotalAmount(totalAmount);
            
            // Save reservation
            boolean success = reservationDAO.createReservation(reservation);
            
            if (success) {
                // Log activity
                Activity activity = new Activity();
                activity.setType("RESERVATION_CREATE");
                activity.setUserId(currentUser.getId());
                activity.setDescription("Created new reservation for " + userDAO.getUserById(customerId).getFullName());
                activity.setAmount(totalAmount);
                activity.setIpAddress(request.getRemoteAddr());
                activityDAO.logActivity(activity);
            }
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private void updateReservation(Map<String, Object> reservationData, HttpServletRequest request, HttpServletResponse response)
        throws IOException {
    try {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        Object idObj = reservationData.get("id");
        int reservationId = 0;
        if (idObj instanceof Double) {
            reservationId = ((Double) idObj).intValue();
        } else if (idObj instanceof String) {
            reservationId = Integer.parseInt((String) idObj);
        }

        // Fetch existing reservation
        Reservation reservation = reservationDAO.getReservationById(reservationId);
        if (reservation == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().write("{\"success\":false,\"message\":\"Reservation not found\"}");
            return;
        }

        // Only allow update if status is PENDING
        if (!"PENDING".equalsIgnoreCase(reservation.getStatus())) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"message\":\"Only PENDING reservations can be updated\"}");
            return;
        }

        // Parse and set new dates
        Date newCheckIn = Date.valueOf((String) reservationData.get("checkIn"));
        Date newCheckOut = Date.valueOf((String) reservationData.get("checkOut"));

        // Check room availability (excluding this reservation)
        boolean isAvailable = reservationDAO.isRoomAvailableForUpdate(
                reservation.getRoomId(),
                newCheckIn,
                newCheckOut,
                reservation.getId()
        );

       if (!isAvailable) {
    response.setStatus(HttpServletResponse.SC_CONFLICT);
    response.setContentType("application/json");
    response.getWriter().write("{\"success\":false," +
            "\"message\":\"This room is already booked during the selected dates. " +
            "Please choose another date or room.\"}");
    return;
}


        // Update allowed fields
        reservation.setCheckIn(newCheckIn);
        reservation.setCheckOut(newCheckOut);
        reservation.setStatus((String) reservationData.get("status"));
        reservation.setSpecialRequests((String) reservationData.get("specialRequests"));

        // Recalculate total amount
        Room room = roomDAO.getRoomById(reservation.getRoomId());
        long days = (reservation.getCheckOut().getTime() - reservation.getCheckIn().getTime()) / (1000 * 60 * 60 * 24);
        double totalAmount = days * room.getBasePrice();
        reservation.setTotalAmount(totalAmount);

        boolean success = reservationDAO.updateReservation(reservation);

        if (success) {
            Activity activity = new Activity();
            activity.setType("RESERVATION_UPDATE");
            activity.setReservationId(reservationId);
            activity.setUserId(currentUser.getId());
            activity.setDescription("Updated booking #" + reservationId);
            activity.setIpAddress(request.getRemoteAddr());
            activityDAO.logActivity(activity);
        }

        response.setContentType("application/json");
        response.getWriter().write("{\"success\":" + success + "}");

    } catch (Exception e) {
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        response.setContentType("application/json");
        response.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
    }
}

    
    private void getReservationDetails(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("id"));
            ReservationDetail reservation = reservationDAO.getReservationDetail(reservationId);
            
            if (reservation != null) {
               
                
                Gson gson = new Gson();
                response.getWriter().write(gson.toJson(reservation));
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\":\"Reservation not found\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
     private void getAvailableRooms(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int roomTypeId = Integer.parseInt(request.getParameter("roomTypeId"));
            Date checkIn = Date.valueOf(request.getParameter("checkIn"));
            Date checkOut = Date.valueOf(request.getParameter("checkOut"));
            
            List<Room> availableRooms = roomDAO.getAvailableRoomsForDateRange(checkIn, checkOut);
            // Filter by room type
            availableRooms.removeIf(room -> room.getRoomTypeId() != roomTypeId);
            
            response.setContentType("application/json");
            Gson gson = new Gson();
            response.getWriter().write(gson.toJson(availableRooms));
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private void sendConfirmationEmail(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("id"));
            
            // TODO: Implement email sending logic
            // For now, just return success
            boolean success = true;
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false}");
        }
    }
    
    private void exportReservations(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            // Get filter parameters
            String status = request.getParameter("status");
            String checkInDate = request.getParameter("checkInDate");
            String checkOutDate = request.getParameter("checkOutDate");
            String search = request.getParameter("search");
            
            List<ReservationSummary> reservations = reservationDAO.getReservationsWithFilters(status, checkInDate, checkOutDate, search);
            
            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", "attachment; filename=\"reservations_export.csv\"");
            
            StringBuilder csv = new StringBuilder();
            csv.append("Booking ID,Guest Name,Phone,Room,Check-in,Check-out,Nights,Status,Total Amount,Created Date\n");
            
            for (ReservationSummary reservation : reservations) {
                long nights = (reservation.getCheckOut().getTime() - reservation.getCheckIn().getTime()) / (1000 * 60 * 60 * 24);
                csv.append(reservation.getId()).append(",");
                csv.append("\"").append(reservation.getCustomerName()).append("\",");
                csv.append(reservation.getCustomerPhone()).append(",");
                csv.append(reservation.getRoomNumber()).append(",");
                csv.append(reservation.getCheckIn()).append(",");
                csv.append(reservation.getCheckOut()).append(",");
                csv.append(nights).append(",");
                csv.append(reservation.getStatus()).append(",");
                csv.append(reservation.getTotalAmount()).append(",");
                csv.append(reservation.getCreatedAt()).append("\n");
            }
            
            response.getWriter().write(csv.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private void printReservation(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("id"));
            ReservationDetail reservation = reservationDAO.getReservationDetail(reservationId);
            
            if (reservation != null) {
                // Generate print-friendly HTML
                String html = generatePrintableReservation(reservation);
                response.setContentType("text/html");
                response.getWriter().write(html);
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private String generateUsername(String fullName) {
        String username = fullName.toLowerCase().replaceAll("\\s+", "");
        
        int suffix = 1;
        String finalUsername = username;
        while (userDAO.usernameExists(finalUsername)) {
            finalUsername = username + suffix;
            suffix++;
        }
        
        return finalUsername;
    }
    
    private String generatePrintableReservation(ReservationDetail reservation) {
        // Generate a simple HTML for printing
        StringBuilder html = new StringBuilder();
        html.append("<!DOCTYPE html><html><head>");
        html.append("<title>Reservation Confirmation</title>");
        html.append("<style>body{font-family:Arial,sans-serif;margin:20px;}</style>");
        html.append("</head><body>");
        html.append("<h1>Reservation Confirmation</h1>");
        html.append("<p><strong>Booking ID:</strong> #").append(reservation.getId()).append("</p>");
        html.append("<p><strong>Guest:</strong> ").append(reservation.getCustomerName()).append("</p>");
        html.append("<p><strong>Room:</strong> ").append(reservation.getRoomNumber()).append("</p>");
        html.append("<p><strong>Check-in:</strong> ").append(reservation.getCheckIn()).append("</p>");
        html.append("<p><strong>Check-out:</strong> ").append(reservation.getCheckOut()).append("</p>");
        html.append("<p><strong>Total Amount:</strong> ").append(reservation.getTotalAmount()).append("₫</p>");
        html.append("</body></html>");
        return html.toString();
    }
}
