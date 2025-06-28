package controller;

import dal.*;
import model.*;
import util.MailUtil;
import util.OTPUtil;
import service.EmailNotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.util.*;
import java.util.concurrent.TimeUnit;
import com.google.gson.Gson;
import jakarta.mail.MessagingException;
import java.util.Calendar;
import model.Room;
import java.util.List;

@WebServlet(name = "BookingServlet", urlPatterns = {"/BookingServlet", "/ValidateOTP", "/ResendOTP"})
public class BookingServlet extends HttpServlet {
    
    private final RoomDAO roomDAO = new RoomDAO();
    private final RoomTypeDAO roomTypeDAO = new RoomTypeDAO();
    private final UserDAO userDAO = new UserDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();
    private EmailNotificationService emailService = new EmailNotificationService();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("checkLogin".equals(action)) {
            // AJAX call to check if user is logged in
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            Gson gson = new Gson();
            Map<String, Object> result = new HashMap<>();
            result.put("isLoggedIn", currentUser != null);
            if (currentUser != null) {
                result.put("user", Map.of(
                    "id", currentUser.getId(),
                    "fullName", currentUser.getFullName(),
                    "email", currentUser.getEmail(),
                    "phone", currentUser.getPhone()
                ));
            }
            response.getWriter().write(gson.toJson(result));
            return;
        }
        
        // Redirect to room list if accessed directly
        response.sendRedirect("RoomListServlet");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        
        if ("/ValidateOTP".equals(path)) {
            validateOTP(request, response);
        } else if ("/ResendOTP".equals(path)) {
            resendOTP(request, response);
        } else {
            processBooking(request, response);
        }
    }
    
    private void processBooking(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            // Debug logging - check content type
            System.out.println("=== BOOKING REQUEST DEBUG ===");
            System.out.println("Content-Type: " + request.getContentType());
            System.out.println("Request Method: " + request.getMethod());
            
            // Log all parameters
            System.out.println("All Parameters:");
            request.getParameterMap().forEach((key, values) -> {
                System.out.println(key + ": " + String.join(", ", values));
            });
            
            System.out.println("Room Type ID: " + request.getParameter("roomTypeId"));
            System.out.println("Selected Room: " + request.getParameter("selectedRoom"));
            System.out.println("Check-in: " + request.getParameter("checkinDate"));
            System.out.println("Check-out: " + request.getParameter("checkoutDate"));
            System.out.println("Payment Method: " + request.getParameter("paymentMethod"));
            System.out.println("Services: " + Arrays.toString(request.getParameterValues("services")));
            System.out.println("Full Name: " + request.getParameter("fullName"));
            System.out.println("Email: " + request.getParameter("email"));
            System.out.println("Phone: " + request.getParameter("phone"));
            
            // Get form data with better error handling
            BookingFormData formData;
            try {
                formData = extractFormData(request);
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Invalid form data: " + escapeJson(e.getMessage()) + "\"}");
                return;
            }
            
            // Validate dates
            if (formData.checkoutDate.before(formData.checkinDate) || formData.checkoutDate.equals(formData.checkinDate)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Check-out date must be after check-in date\"}");
                return;
            }
            
            // Allow booking from today
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.DAY_OF_MONTH, -1); // Allow from yesterday to handle timezone issues
            Date yesterday = new Date(cal.getTimeInMillis());
            
            if (formData.checkinDate.before(yesterday)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Check-in date cannot be in the past\"}");
                return;
            }
            
            // Validate room availability
            Room room = roomDAO.getRoomById(formData.selectedRoomId);
            if (room == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Selected room not found\"}");
                return;
            }
            
            if (!"AVAILABLE".equals(room.getStatus())) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Selected room is no longer available\"}");
                return;
            }
            
            // Check if room is available for the date range
            if (!reservationDAO.isRoomAvailable(formData.selectedRoomId, 
                    formData.checkinDate, formData.checkoutDate, null)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Room is not available for selected dates\"}");
                return;
            }
            
            int userId;
            boolean isGuest = false;
            
            if (currentUser != null) {
                // A. LOGGED IN USER FLOW
                userId = currentUser.getId();
                
                // Update user info if changed
                if (!formData.fullName.equals(currentUser.getFullName()) || 
                    !formData.email.equals(currentUser.getEmail()) || 
                    !formData.phone.equals(currentUser.getPhone())) {
                    currentUser.setFullName(formData.fullName);
                    currentUser.setEmail(formData.email);
                    currentUser.setPhone(formData.phone);
                    userDAO.updateUser(currentUser);
                }
                
            } else {
                // B. GUEST BOOKING FLOW
                
                // Check if this is after OTP validation
                String otpValidated = (String) session.getAttribute("otpValidated");
                if (!"true".equals(otpValidated)) {
                    // First time - need OTP validation
                    
                    // Generate and send OTP
                    String otp = OTPUtil.generateOTP();
                    session.setAttribute("pendingOTP", otp);
                    session.setAttribute("pendingBookingData", formData);
                    session.setAttribute("otpExpiry", System.currentTimeMillis() + 300000); // 5 minutes
                    
                    // Send OTP via email
                    try {
                        sendOTPEmail(formData.email, formData.fullName, otp);
                    } catch (Exception e) {
                        e.printStackTrace();
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        response.getWriter().write("{\"error\": \"Failed to send OTP email: " + e.getMessage() + "\"}");
                        return;
                    }
                    
                    // Return response for OTP modal
                    response.getWriter().write("{\"requireOTP\": true, \"email\": \"" + 
                        maskEmail(formData.email) + "\"}");
                    return;
                }
                
                // OTP validated - create guest account
                isGuest = true;
                try {
                    userId = createGuestAccount(formData);
                    if (userId == 0) {
                        throw new Exception("Failed to create user account");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"error\": \"Failed to create guest account: " + e.getMessage() + "\"}");
                    return;
                }
                
                // Clear OTP session data
                session.removeAttribute("otpValidated");
                session.removeAttribute("pendingOTP");
                session.removeAttribute("pendingBookingData");
            }
            
            // Calculate total amount including services
            double servicesTotal = calculateServicesTotal(formData.serviceIds);
            formData.servicesTotal = servicesTotal;
            
            // Create reservation (same for both flows)
            Reservation reservation = createReservation(formData, userId, currentUser);
            int reservationId = reservationDAO.createReservationAndGetId(reservation);
            
            if (reservationId > 0) {
                reservation.setId(reservationId);
                
                // Add selected services
                if (formData.serviceIds != null && formData.serviceIds.length > 0) {
                    addServicesToReservation(reservationId, formData.serviceIds, userId);
                }
                
                // Create initial payment record
                Payment payment = new Payment();
                payment.setReservationId(reservationId);
                payment.setAmount(reservation.getTotalAmount());
                payment.setMethod(formData.paymentMethod);
                payment.setStatus("PENDING");
                payment.setTransactionId(generateTransactionId());
                
                int paymentId = paymentDAO.createPaymentAndGetId(payment);
                
                // Log activity
                logBookingActivity(reservation, room, request.getRemoteAddr());
                
                // Send notification
                sendBookingNotification(reservation, userId);
                
                // Send confirmation email
                try {
                    RoomType roomType = roomTypeDAO.getRoomTypesById(room.getRoomTypeId());
                    sendConfirmationEmail(reservation, room, roomType, isGuest, formData);
                } catch (Exception e) {
                    e.printStackTrace();
                    // Don't fail the booking if email fails
                }
                
                // Store in session for next steps
                session.setAttribute("lastReservationId", reservationId);
                session.setAttribute("lastPaymentId", paymentId);
                session.setAttribute("isGuestBooking", isGuest);
                
                // Return success response
                response.getWriter().write("{\"success\": true, \"reservationId\": " + 
                    reservationId + ", \"paymentId\": " + paymentId + "}");
                
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Failed to create reservation in database\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            
            // Send detailed error for debugging
            String errorMessage = e.getMessage();
            if (errorMessage == null) {
                errorMessage = "Unknown error occurred";
            }
            
            response.getWriter().write("{\"error\": \"" + escapeJson(errorMessage) + "\", \"type\": \"" + e.getClass().getSimpleName() + "\"}");
        }
    }
    
    private void validateOTP(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        HttpSession session = request.getSession();
        String inputOTP = request.getParameter("otp");
        String sessionOTP = (String) session.getAttribute("pendingOTP");
        Long otpExpiry = (Long) session.getAttribute("otpExpiry");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        if (sessionOTP == null || otpExpiry == null || System.currentTimeMillis() > otpExpiry) {
            response.getWriter().write("{\"success\": false, \"message\": \"OTP expired\"}");
            return;
        }
        
        if (sessionOTP.equals(inputOTP)) {
            session.setAttribute("otpValidated", "true");
            response.getWriter().write("{\"success\": true}");
        } else {
            response.getWriter().write("{\"success\": false, \"message\": \"Invalid OTP\"}");
        }
    }
    
    private void resendOTP(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        HttpSession session = request.getSession();
        BookingFormData formData = (BookingFormData) session.getAttribute("pendingBookingData");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        if (formData == null) {
            response.getWriter().write("{\"success\": false, \"message\": \"Session expired\"}");
            return;
        }
        
        try {
            // Generate new OTP
            String otp = OTPUtil.generateOTP();
            session.setAttribute("pendingOTP", otp);
            session.setAttribute("otpExpiry", System.currentTimeMillis() + 300000);
            
            // Send OTP
            sendOTPEmail(formData.email, formData.fullName, otp);
            
            response.getWriter().write("{\"success\": true}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Failed to send OTP\"}");
        }
    }
    
    
    private double calculateServicesTotal(String[] serviceIds) {
        double total = 0;
        if (serviceIds != null) {
            for (String serviceId : serviceIds) {
                try {
                    Service service = serviceDAO.getServiceById(Integer.parseInt(serviceId));
                    if (service != null) {
                        total += service.getPrice();
                    }
                } catch (NumberFormatException e) {
                    // Skip invalid service ID
                }
            }
        }
        return total;
    }
    
   private int createGuestAccount(BookingFormData formData) throws Exception {
    try {
        // Check if email already exists
        User existingUser = userDAO.getUserByEmail(formData.email);
        if (existingUser != null) {
            System.out.println("User already exists with email: " + formData.email);
            return existingUser.getId();
        }
        
        User guestUser = new User();
        guestUser.setUsername("guest_" + System.currentTimeMillis());
        guestUser.setPassword(hashPassword(generateRandomPassword()));
        guestUser.setFullName(formData.fullName);
        guestUser.setEmail(formData.email);
        guestUser.setPhone(formData.phone);
        guestUser.setRole("CUSTOMER");
        guestUser.setStatus(true);
        
        System.out.println("Creating guest account for: " + formData.email);
        
        int userId = userDAO.createUserAndGetId(guestUser);
        if (userId == 0) {
            throw new Exception("Failed to create guest account in database");
        }
        
        System.out.println("Guest account created with ID: " + userId);
        
      
        try {
            // Kiểm tra CustomerDetails table có tồn tại không
            System.out.println("Creating customer details for user ID: " + userId);
            
            Customer customer = new Customer();
            customer.setId(userId);
            customer.setIsGuest(true);
            
            // Nếu updateCustomerDetails fail, có thể cần createCustomerDetails
            boolean success = customerDAO.updateCustomerDetails(customer);
            if (!success) {
                System.err.println("Failed to update customer details, trying to create new...");
                // Có thể cần method createCustomerDetails thay vì update
            }
        } catch (Exception e) {
            System.err.println("Error creating customer details: " + e.getMessage());
            e.printStackTrace();
            // Không throw exception vì user đã được tạo
        }
        
        return userId;
        
    } catch (Exception e) {
        System.err.println("Error in createGuestAccount: " + e.getMessage());
        e.printStackTrace();
        throw e;
    }
}
    private Reservation createReservation(BookingFormData formData, int userId, User currentUser) {
        Reservation reservation = new Reservation();
        reservation.setUserId(userId);
        reservation.setRoomId(formData.selectedRoomId);
        reservation.setCheckIn(formData.checkinDate);
        reservation.setCheckOut(formData.checkoutDate);
        reservation.setStatus("PENDING");
        reservation.setTotalAmount(formData.getTotalAmount());
        
        // Build notes
        StringBuilder notes = new StringBuilder();
        notes.append("Adults: ").append(formData.adults);
        notes.append(", Children: ").append(formData.children);
        notes.append(", Nationality: ").append(formData.nationality != null ? formData.nationality : "N/A");
        reservation.setNotes(notes.toString());
        
        reservation.setSpecialRequests(formData.specialRequests);
        reservation.setNumberOfCustomers(formData.adults + formData.children);
        
        if (currentUser != null && !"CUSTOMER".equals(currentUser.getRole())) {
            reservation.setCreatedBy(currentUser.getId());
        }
        
        return reservation;
    }
    
    private void sendOTPEmail(String email, String name, String otp) throws MessagingException {
        String subject = "Luxury Hotel - Booking Verification Code";
        String content = String.format(
            "Dear %s,\n\n" +
            "Your verification code for Luxury Hotel booking is:\n\n" +
            "%s\n\n" +
            "This code will expire in 5 minutes.\n\n" +
            "If you didn't request this code, please ignore this email.\n\n" +
            "Best regards,\n" +
            "Luxury Hotel Team",
            name, otp
        );
        
        MailUtil.sendEmail(email, subject, content);
    }
    
    private void sendConfirmationEmail(Reservation reservation, Room room, 
                                      RoomType roomType, boolean isGuest, BookingFormData formData) {
        try {
            // For now, send a simple confirmation email
            String subject = "Luxury Hotel - Booking Pending #" + reservation.getId();
            String content = String.format(
                "Dear %s,\n\n" +
                "Your booking has been Pending can you payment 10% to confirmed!\n\n" +
                "Booking Details:\n" +
                "- Booking ID: #%d\n" +
                "- Room: %s (%s)\n" +
                "- Check-in: %s\n" +
                "- Check-out: %s\n" +
                "- Total Amount: %,.0f VND\n\n" +
                "We look forward to welcoming you!\n\n" +
                "Best regards,\n" +
                "Luxury Hotel Team",
                formData.fullName,
                reservation.getId(),
                room.getRoomNumber(),
                roomType.getName(),
                reservation.getCheckIn(),
                reservation.getCheckOut(),
                reservation.getTotalAmount()
            );
            
            MailUtil.sendEmail(formData.email, subject, content);
            
            if (isGuest) {
                // Send additional email for account completion
                sendAccountCompletionEmail(reservation, formData);
            }
        } catch (Exception e) {
              System.err.println("✗ FAILED to send email to: " + formData.email);
        System.err.println("Error: " + e.getMessage());
        e.printStackTrace();
        }
    }
    
    private void sendAccountCompletionEmail(Reservation reservation, BookingFormData formData) {
        try {
            String subject = "Complete Your Luxury Hotel Account";
            String content = String.format(
                "Dear %s,\n\n" +
                "Thank you for booking with Luxury Hotel!\n\n" +
                "To enhance your experience and access exclusive benefits, " +
                "we invite you to complete your account registration.\n\n" +
                "Benefits of becoming a member:\n" +
                "- Earn loyalty points with every stay\n" +
                "- Access to exclusive member rates\n" +
                "- Priority check-in/check-out\n" +
                "- Special birthday offers\n\n" +
                "Click here to set your password and complete registration:\n" +
                "http://localhost:8080/hotel/complete-registration?token=%s\n\n" +
                "Best regards,\n" +
                "Luxury Hotel Team",
                formData.fullName,
                generateRegistrationToken(reservation.getUserId())
            );
            
            MailUtil.sendEmail(formData.email, subject, content);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private String maskEmail(String email) {
        String[] parts = email.split("@");
        if (parts.length != 2) return email;
        
        String name = parts[0];
        if (name.length() <= 3) return email;
        
        return name.substring(0, 2) + "***@" + parts[1];
    }
    
    private String generateTransactionId() {
        return "TXN" + System.currentTimeMillis() + new Random().nextInt(1000);
    }
    
    private String generateRandomPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$";
        StringBuilder password = new StringBuilder();
        Random random = new Random();
        
        for (int i = 0; i < 12; i++) {
            password.append(chars.charAt(random.nextInt(chars.length())));
        }
        
        return password.toString();
    }
    
    private String hashPassword(String password) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(password.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    private String generateRegistrationToken(int userId) {
        // In production, use JWT or secure token generation
        return Base64.getEncoder().encodeToString(
            (userId + ":" + System.currentTimeMillis()).getBytes()
        );
    }
    
    private void logBookingActivity(Reservation reservation, Room room, String ipAddress) {
        try {
            Activity activity = new Activity();
            activity.setType("RESERVATION_CREATE");
            activity.setReservationId(reservation.getId());
            activity.setUserId(reservation.getUserId());
            activity.setDescription("New reservation created for room " + room.getRoomNumber());
            activity.setAmount(reservation.getTotalAmount());
            activity.setIpAddress(ipAddress);
            activityDAO.logActivity(activity);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private void sendBookingNotification(Reservation reservation, int userId) {
        try {
            Notification notification = new Notification();
            notification.setUserId(userId);
            notification.setReservationId(reservation.getId());
            notification.setType("BOOKING_CONFIRM");
            notification.setMessage("Your booking #" + reservation.getId() + " has been created. " +
                                  "Please proceed to payment to confirm your reservation.");
            notificationDAO.sendNotification(notification);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private void addServicesToReservation(int reservationId, String[] serviceIds, int userId) {
        if (serviceIds != null) {
            for (String serviceId : serviceIds) {
                try {
                    Service service = serviceDAO.getServiceById(Integer.parseInt(serviceId));
                    if (service != null) {
                        ReservationService rs = new ReservationService();
                        rs.setReservationId(reservationId);
                        rs.setServiceId(service.getId());
                        rs.setQuantity(1);
                        rs.setCreatedBy(userId);
                        serviceDAO.addServiceToReservation(rs);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    // Helper method to send JSON response
    private void sendJsonResponse(HttpServletResponse response, int status, String json) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(json);
    }
    
    // Helper method to send error response
    private void sendErrorResponse(HttpServletResponse response, int status, String message) throws IOException {
        sendJsonResponse(response, status, "{\"error\": \"" + escapeJson(message) + "\"}");
    }
    
    // Helper method to escape JSON string
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
    private static class BookingFormData implements java.io.Serializable {
        int roomTypeId;
        double basePrice;
        Date checkinDate;
        Date checkoutDate;
        int adults;
        int children;
        int selectedRoomId;
        String fullName;
        String email;
        String phone;
        String nationality;
        String specialRequests;
        String paymentMethod;
        String[] serviceIds;
        
        // Calculated fields
        int nights;
        double roomTotal;
        double tax;
        double servicesTotal;
        
        double getTotalAmount() {
            return roomTotal + tax + servicesTotal;
        }
    }
    
    private BookingFormData extractFormData(HttpServletRequest request) throws Exception {
    BookingFormData data = new BookingFormData();
    
    // Debug log
    System.out.println("Extracting form data...");
    
    // Validate and parse room type ID
    String roomTypeIdStr = request.getParameter("roomTypeId");
    System.out.println("roomTypeIdStr from request: '" + roomTypeIdStr + "'");
    
    if (roomTypeIdStr == null || roomTypeIdStr.trim().isEmpty()) {
        // Log all parameters for debugging
        System.out.println("roomTypeId is null or empty. All parameters:");
        request.getParameterMap().forEach((key, values) -> {
            System.out.println("  " + key + ": " + String.join(", ", values));
        });
        throw new Exception("Room type ID is required");
    }
    
    try {
        data.roomTypeId = Integer.parseInt(roomTypeIdStr.trim());
    } catch (NumberFormatException e) {
        throw new Exception("Invalid room type ID format: " + roomTypeIdStr);
    }
    
    // Validate and parse base price
    String basePriceStr = request.getParameter("basePrice");
    if (basePriceStr == null || basePriceStr.trim().isEmpty()) {
        throw new Exception("Base price is required");
    }
    try {
        data.basePrice = Double.parseDouble(basePriceStr);
    } catch (NumberFormatException e) {
        throw new Exception("Invalid base price format");
    }
    
    // Parse dates
    String checkinDateStr = request.getParameter("checkinDate");
    String checkoutDateStr = request.getParameter("checkoutDate");
    
    if (checkinDateStr == null || checkinDateStr.trim().isEmpty() ||
        checkoutDateStr == null || checkoutDateStr.trim().isEmpty()) {
        throw new Exception("Check-in and check-out dates are required");
    }
    
    try {
        data.checkinDate = Date.valueOf(checkinDateStr);
        data.checkoutDate = Date.valueOf(checkoutDateStr);
    } catch (IllegalArgumentException e) {
        throw new Exception("Invalid date format");
    }
    
    // Parse guests
    try {
        String adultsStr = request.getParameter("adults");
        String childrenStr = request.getParameter("children");
        data.adults = (adultsStr != null) ? Integer.parseInt(adultsStr) : 1;
        data.children = (childrenStr != null) ? Integer.parseInt(childrenStr) : 0;
    } catch (NumberFormatException e) {
        data.adults = 1;
        data.children = 0;
    }
    
    // Parse selected room - MAKE IT OPTIONAL
    String selectedRoomStr = request.getParameter("selectedRoom");
    if (selectedRoomStr != null && !selectedRoomStr.trim().isEmpty()) {
        try {
            data.selectedRoomId = Integer.parseInt(selectedRoomStr);
        } catch (NumberFormatException e) {
            // If room selection fails, we'll auto-select later
            data.selectedRoomId = 0;
        }
    } else {
        // No room selected - we'll auto-select an available room
        data.selectedRoomId = 0;
    }
    
    // If no room selected, try to find an available room
    if (data.selectedRoomId == 0) {
        System.out.println("No room selected, auto-selecting available room...");
        List<Room> availableRooms = roomDAO.getAvailableRoomsByTypeAndDate(
            data.roomTypeId, data.checkinDate, data.checkoutDate);
        
        if (availableRooms.isEmpty()) {
            throw new Exception("No rooms available for selected dates");
        }
        
        // Auto-select the first available room
        data.selectedRoomId = availableRooms.get(0).getId();
        System.out.println("Auto-selected room ID: " + data.selectedRoomId);
    }
    
    // Get contact info
    data.fullName = request.getParameter("fullName");
    data.email = request.getParameter("email");
    data.phone = request.getParameter("phone");
    
    if (data.fullName == null || data.fullName.trim().isEmpty() ||
        data.email == null || data.email.trim().isEmpty() ||
        data.phone == null || data.phone.trim().isEmpty()) {
        throw new Exception("All contact information fields are required");
    }
    
    data.fullName = data.fullName.trim();
    data.email = data.email.trim();
    data.phone = data.phone.trim();
    
    // Validate email format
    if (!data.email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
        throw new Exception("Invalid email format: " + data.email);
    }
    
    data.nationality = request.getParameter("nationality");
    data.specialRequests = request.getParameter("specialRequests");
    data.paymentMethod = request.getParameter("paymentMethod");
    
    if (data.paymentMethod == null || data.paymentMethod.trim().isEmpty()) {
        data.paymentMethod = "CASH"; // Default
    }
    
    data.serviceIds = request.getParameterValues("services");
    
    // Calculate totals
    long diffInMillies = data.checkoutDate.getTime() - data.checkinDate.getTime();
    data.nights = (int) TimeUnit.DAYS.convert(diffInMillies, TimeUnit.MILLISECONDS);
    
    if (data.nights <= 0) {
        throw new Exception("Invalid date range - checkout must be after checkin");
    }
    
    data.roomTotal = data.basePrice * data.nights;
    data.tax = data.roomTotal * 0.1;
    
    return data;
}
}