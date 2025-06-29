package controller;

import dal.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.util.*;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;
import dal.ServiceDAO;
import model.Service;
import model.ServiceOrder;
import model.ReservationService;

@WebServlet(name = "ReceptionistBookingServlet", urlPatterns = {"/receptionist/booking"})
public class ReceptionistBookingServlet extends HttpServlet {
    
    private RoomDAO roomDAO = new RoomDAO();
    private RoomTypeDAO roomTypeDAO = new RoomTypeDAO();
    private UserDAO userDAO = new UserDAO();
    private ReservationDAO reservationDAO = new ReservationDAO();
    private ServiceDAO serviceDAO = new ServiceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"RECEPTIONIST".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("checkAvailability".equals(action)) {
            checkRoomAvailability(request, response);
        } else {
            showBookingForm(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"RECEPTIONIST".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("createBooking".equals(action)) {
            createBooking(request, response, currentUser);
        }
    }
    
    private void showBookingForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Get all active room types
            List<RoomType> roomTypes = roomTypeDAO.getAvailableRoomTypes();
            
            // Get all customers
            List<User> customers = userDAO.getUsersByRole("CUSTOMER");
            
            // Get all available services
            List<Service> services = serviceDAO.getAllActiveServices();
            
            // Optional: Group services by category if needed
            Map<String, List<Service>> servicesByCategory = new HashMap<>();
            if (services != null) {
                for (Service service : services) {
                    String category = service.getCategory() != null ? service.getCategory() : "OTHER";
                    servicesByCategory.computeIfAbsent(category, k -> new ArrayList<>()).add(service);
                }
            }
            
            request.setAttribute("roomTypes", roomTypes);
            request.setAttribute("customers", customers);
            request.setAttribute("services", services);
            request.setAttribute("pageTitle", "New Booking");
            request.setAttribute("activePage", "booking");
            
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading booking form: " + e.getMessage());
            request.getRequestDispatcher("/reception-dashboard").forward(request, response);
        }
    }
    
    private void checkRoomAvailability(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            String checkInStr = request.getParameter("checkIn");
            String checkOutStr = request.getParameter("checkOut");
            String roomTypeIdStr = request.getParameter("roomTypeId");
            
            // Validate input
            if (checkInStr == null || checkOutStr == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"Missing date parameters\"}");
                return;
            }
            
            Date checkIn = Date.valueOf(checkInStr);
            Date checkOut = Date.valueOf(checkOutStr);
            
            // Validate date range
            if (!checkOut.after(checkIn)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"Check-out date must be after check-in date\"}");
                return;
            }
            
            List<Room> availableRooms;
            
            if (roomTypeIdStr != null && !roomTypeIdStr.isEmpty()) {
                int roomTypeId = Integer.parseInt(roomTypeIdStr);
                availableRooms = roomDAO.getAvailableRoomsByTypeAndDate(roomTypeId, checkIn, checkOut);
            } else {
                availableRooms = roomDAO.getAvailableRoomsForDateRange(checkIn, checkOut);
            }
            
            // Return as JSON
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < availableRooms.size(); i++) {
                Room room = availableRooms.get(i);
                if (i > 0) json.append(",");
                json.append("{")
                    .append("\"id\":").append(room.getId()).append(",")
                    .append("\"roomNumber\":\"").append(escapeJson(room.getRoomNumber())).append("\",")
                    .append("\"roomType\":\"").append(escapeJson(room.getRoomTypeName())).append("\",")
                    .append("\"price\":").append(room.getBasePrice())
                    .append("}");
            }
            json.append("]");
            
            response.getWriter().write(json.toString());
            
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Invalid number format\"}");
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Invalid date format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Internal server error\"}");
        }
    }
    
    private void createBooking(HttpServletRequest request, HttpServletResponse response, User receptionist)
            throws ServletException, IOException {
        
        try {
            // Get parameters
            String guestType = request.getParameter("guestType");
            String customerIdStr = request.getParameter("customerId");
            String newCustomerName = request.getParameter("newCustomerName");
            String newCustomerEmail = request.getParameter("newCustomerEmail");
            String newCustomerPhone = request.getParameter("newCustomerPhone");
            String roomIdStr = request.getParameter("roomId");
            String checkInStr = request.getParameter("checkIn");
            String checkOutStr = request.getParameter("checkOut");
            String notes = request.getParameter("notes");
            
            // Get selected services
            String[] serviceIds = request.getParameterValues("services");
            
            // Validate required parameters
            if (roomIdStr == null || roomIdStr.isEmpty()) {
                throw new Exception("Please select a room");
            }
            
            if (checkInStr == null || checkOutStr == null) {
                throw new Exception("Please select check-in and check-out dates");
            }
            
            int customerId;
            
            // Handle customer creation/selection
            if ("new".equals(guestType)) {
                // Validate new customer information
                if (newCustomerName == null || newCustomerName.trim().isEmpty() ||
                    newCustomerEmail == null || newCustomerEmail.trim().isEmpty() ||
                    newCustomerPhone == null || newCustomerPhone.trim().isEmpty()) {
                    throw new Exception("Please fill in all customer information");
                }
                
                // Check if email already exists
                if (userDAO.isEmailExists(newCustomerEmail.trim(), null)) {
                    throw new Exception("Email already exists in the system");
                }
                
                // Check if phone already exists
                if (userDAO.phoneExists(newCustomerPhone.trim())) {
                    throw new Exception("Phone number already exists in the system");
                }
                
                // Create new customer
                User newCustomer = new User();
                newCustomer.setUsername(generateUsername(newCustomerEmail.trim()));
                newCustomer.setPassword(hashPassword("Pass123!")); // Default password, already hashed
                newCustomer.setFullName(newCustomerName.trim());
                newCustomer.setEmail(newCustomerEmail.trim());
                newCustomer.setPhone(newCustomerPhone.trim());
                newCustomer.setRole("CUSTOMER");
                newCustomer.setStatus(true);
                
                customerId = userDAO.createUserAndGetId(newCustomer);
                if (customerId == 0) {
                    throw new Exception("Failed to create customer account");
                }
            } else {
                // Existing customer
                if (customerIdStr == null || customerIdStr.isEmpty()) {
                    throw new Exception("Please select a customer");
                }
                customerId = Integer.parseInt(customerIdStr);
                
                // Verify customer exists
                User existingCustomer = userDAO.getUserById(customerId);
                if (existingCustomer == null) {
                    throw new Exception("Selected customer not found");
                }
            }
            
            // Parse and validate dates
            Date checkIn = Date.valueOf(checkInStr);
            Date checkOut = Date.valueOf(checkOutStr);
            
            if (!checkOut.after(checkIn)) {
                throw new Exception("Check-out date must be after check-in date");
            }
            
            // Validate room selection and availability
            int roomId = Integer.parseInt(roomIdStr);
            Room room = roomDAO.getRoomById(roomId);
            if (room == null) {
                throw new Exception("Selected room not found");
            }
            
            // Double-check room availability
            if (!roomDAO.isRoomAvailableForDateRange(roomId, checkIn, checkOut)) {
                throw new Exception("Selected room is no longer available for these dates");
            }
            
            // Create reservation
            Reservation reservation = new Reservation();
            reservation.setUserId(customerId);
            reservation.setRoomId(roomId);
            reservation.setCheckIn(checkIn);
            reservation.setCheckOut(checkOut);
            reservation.setStatus("CONFIRMED");
            reservation.setCreatedBy(receptionist.getId());
            reservation.setNotes(notes != null ? notes.trim() : null);
            
            // Calculate room total
            long days = (checkOut.getTime() - checkIn.getTime()) / (1000 * 60 * 60 * 24);
            if (days <= 0) {
                throw new Exception("Invalid date range");
            }
            
            double roomTotal = room.getBasePrice() * days;
            
            // Calculate services total
            double servicesTotal = calculateServicesTotal(serviceIds);
            
            // Set total amount (room + services)
            reservation.setTotalAmount(roomTotal + servicesTotal);
            
            // Create the reservation
            int reservationId = reservationDAO.createReservationAndGetId(reservation);
            
            if (reservationId > 0) {
                reservation.setId(reservationId);
                
                // Add selected services to reservation
                if (serviceIds != null && serviceIds.length > 0) {
                    addServicesToReservation(reservationId, serviceIds, receptionist.getId());
                }
                
                request.getSession().setAttribute("success", 
                    String.format("Booking created successfully! Reservation ID: #%d (Total: %,.0f₫)", 
                    reservationId, reservation.getTotalAmount()));
                
                response.sendRedirect(request.getContextPath() + "/receptionist/check-in");
                
            } else {
                throw new Exception("Failed to create reservation in database");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid number format in form data");
            showBookingForm(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Invalid date format: " + e.getMessage());
            showBookingForm(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error creating booking: " + e.getMessage());
            showBookingForm(request, response);
        }
    }
    
    // Helper method to calculate total for selected services
    private double calculateServicesTotal(String[] serviceIds) {
        double total = 0;
        if (serviceIds != null) {
            for (String serviceId : serviceIds) {
                try {
                    Service service = serviceDAO.getServiceById(Integer.parseInt(serviceId));
                    if (service != null && service.isActive()) {
                        total += service.getPrice();
                    }
                } catch (NumberFormatException e) {
                    // Skip invalid service ID
                    System.err.println("Invalid service ID: " + serviceId);
                }
            }
        }
        return total;
    }
    
    // Helper method to add services to reservation
    private void addServicesToReservation(int reservationId, String[] serviceIds, int createdBy) {
        if (serviceIds != null) {
            for (String serviceId : serviceIds) {
                try {
                    Service service = serviceDAO.getServiceById(Integer.parseInt(serviceId));
                    if (service != null && service.isActive()) {
                        ReservationService rs = new ReservationService();
                        rs.setReservationId(reservationId);
                        rs.setServiceId(service.getId());
                        rs.setQuantity(1);
                        rs.setUnitPrice(service.getPrice()); // Store price at time of booking
                        rs.setCreatedBy(createdBy);
                        
                        boolean success = serviceDAO.addServiceToReservation(rs);
                        if (success) {
                            System.out.println("Added service " + service.getName() + 
                                             " to reservation " + reservationId);
                        } else {
                            System.err.println("Failed to add service " + service.getName() + 
                                              " to reservation " + reservationId);
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    System.err.println("Error adding service ID " + serviceId + 
                                      " to reservation: " + e.getMessage());
                }
            }
        }
    }
    
    // Helper method to generate unique username
    private String generateUsername(String email) {
        String baseUsername = email.split("@")[0];
        String timestamp = String.valueOf(System.currentTimeMillis()).substring(8); // Last 5 digits
        return baseUsername + timestamp;
    }
    
    // Helper method to hash password
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return password; // Fallback (not recommended for production)
        }
    }
    
    // Helper method to escape JSON strings
    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\"", "\\\"").replace("\\", "\\\\");
    }
}