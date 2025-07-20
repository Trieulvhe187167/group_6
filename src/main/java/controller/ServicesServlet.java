// Updated ServicesServlet.java
package controller;

import dal.*;
import model.*;
import model.ReservationService;
import jakarta.mail.MessagingException;
import util.MailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import com.google.gson.Gson;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "ServicesServlet", urlPatterns = {"/receptionist/services"})
public class ServicesServlet extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(ServicesServlet.class.getName());
    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check receptionist authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"RECEPTIONIST".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        try {
            // Get all services
            List<Service> services = serviceDAO.getAllActiveServices();
            
            // Get recent service orders
            List<ServiceOrder> recentOrders = serviceDAO.getRecentServiceOrders(20);
            
                        // Get rooms with active reservations
            List<ReservationSummary> checkedInRooms = reservationDAO.getActiveReservations();
            // Set attributes
            request.setAttribute("services", services);
            request.setAttribute("recentOrders", recentOrders);
             request.setAttribute("checkedInRooms", checkedInRooms);
            request.setAttribute("currentUser", currentUser);
            
            // Set template attributes
            request.setAttribute("pageTitle", "Services Management");
            request.setAttribute("activePage", "services");
            // No need to set contentPage anymore as we're using direct includes
            
            // Forward to template
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading services page: " + e.getMessage());
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
          Map<String, Object> jsonRequest = null;

        // When using fetch/AJAX with JSON payload, parameters won't be available
        if ((action == null || action.isEmpty())
                && request.getContentType() != null
                && request.getContentType().contains("application/json")) {
            jsonRequest = new Gson().fromJson(request.getReader(), Map.class);
            if (jsonRequest != null) {
                action = (String) jsonRequest.get("action");
            }
        }
        try {
            switch (action) {
                case "findReservationByRoom":
                    findReservationByRoom(request, response);
                    break;
                case "addService":
                   addService(request, response, jsonRequest);
                    break;
                case "servicesByCategory":
                    getServicesByCategory(request, response);
                    break;
                case "updateServiceStatus":
                    updateServiceStatus(request, response);
                    break;
                case "createService":
                    createService(request, response);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"error\":\"Invalid action\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing request", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private void findReservationByRoom(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        String roomNumber = request.getParameter("roomNumber");
        if (roomNumber == null || roomNumber.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Room number is required\"}");
            return;
        }
        
        try {
            // Find active reservation for the room
            Reservation reservation = reservationDAO.getActiveReservationByRoom(roomNumber);
            
            if (reservation != null) {
                // Create response object with guest info
                Map<String, Object> result = new HashMap<>();
                result.put("id", reservation.getId());
                result.put("customerName", reservation.getCustomerName());
                result.put("roomNumber", roomNumber);
                result.put("checkIn", reservation.getCheckIn());
                result.put("checkOut", reservation.getCheckOut());
                
                response.setContentType("application/json");
                Gson gson = new Gson();
                response.getWriter().write(gson.toJson(result));
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\":\"No active reservation found\"}");
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error finding reservation by room", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private void addService(HttpServletRequest request, HttpServletResponse response,
                            Map<String, Object> serviceRequest)
            throws IOException {
        try {
            // Parse JSON request if not already provided
            if (serviceRequest == null) {
                Gson gson = new Gson();
                serviceRequest = gson.fromJson(request.getReader(), Map.class);
            }
            
            // Validate required fields
            if (!validateServiceRequest(serviceRequest)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"Missing required fields\"}");
                return;
            }
            
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            
            // Create reservation service
            ReservationService resService = new ReservationService();
            resService.setReservationId(parseInt(serviceRequest.get("reservationId")));
            resService.setServiceId(parseInt(serviceRequest.get("serviceId")));
            resService.setQuantity(parseInt(serviceRequest.get("quantity")));
            resService.setCreatedBy(currentUser.getId());
            resService.setStatus("CONFIRMED");
            resService.setNotes((String) serviceRequest.get("notes"));
            
            // Save service
            boolean success = serviceDAO.addServiceToReservation(resService);
            
            if (success) {
                // Get service details for activity log
                Service service = serviceDAO.getServiceById(resService.getServiceId());
                double totalAmount = service.getPrice() * resService.getQuantity();
                
                // Log activity
                Activity activity = new Activity();
                activity.setType("SERVICE_ADDED");
                activity.setReservationId(resService.getReservationId());
                activity.setUserId(currentUser.getId());
                activity.setDescription("Added " + service.getName() + " x" + resService.getQuantity());
                activity.setAmount(totalAmount);
                activity.setIpAddress(request.getRemoteAddr());
                activityDAO.logActivity(activity);
            }
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error adding service", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private boolean validateServiceRequest(Map<String, Object> request) {
        return request.containsKey("reservationId") 
            && request.containsKey("serviceId") 
            && request.containsKey("quantity");
    }
    
    private void getServicesByCategory(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String category = request.getParameter("category");
            List<Service> services;
            
            if (category == null || category.isEmpty()) {
                services = serviceDAO.getAllActiveServices();
            } else {
                services = serviceDAO.getServicesByCategory(category);
            }
            
            response.setContentType("application/json");
            Gson gson = new Gson();
            response.getWriter().write(gson.toJson(services));
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting services by category", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private void updateServiceStatus(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String orderIdStr = request.getParameter("orderId");
            String status = request.getParameter("status");
            
            if (orderIdStr == null || status == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"Order ID and status are required\"}");
                return;
            }
            
            int orderId = Integer.parseInt(orderIdStr);
            boolean success = serviceDAO.updateServiceOrderStatus(orderId, status);
             if (success && ("CONFIRMED".equalsIgnoreCase(status) || "CANCELLED".equalsIgnoreCase(status))) {
                try {
                    ServiceOrder order = serviceDAO.getServiceOrderById(orderId);
                    if (order != null) {
                        String email = null;
                        String customerName = null;
                        if (order.getCustomerEmail() != null) {
                            email = order.getCustomerEmail();
                            customerName = order.getCustomerName();
                        } else {
                            Reservation res = reservationDAO.getReservationById(order.getReservationId());
                            if (res != null) {
                                email = res.getCustomerEmail();
                                customerName = res.getCustomerName();
                            }
                        }
                        if (email != null && !email.isEmpty()) {
                            String subject;
                            String content;
                            if ("CONFIRMED".equalsIgnoreCase(status)) {
                                subject = "Service Request Confirmed";
                                content = String.format("Dear %s,\n\nYour requested service '%s' has been confirmed.\n\nBest regards,\nLuxury Hotel Team",
                                        customerName != null ? customerName : "Customer", order.getServiceName());
                            } else {
                                subject = "Service Request Cancelled";
                                content = String.format("Dear %s,\n\nYour service request '%s' has been cancelled.\n\nBest regards,\nLuxury Hotel Team",
                                        customerName != null ? customerName : "Customer", order.getServiceName());
                            }
                            MailUtil.sendEmail(email, subject, content);
                        }
                    }
                } catch (MessagingException me) {
                    LOGGER.log(Level.SEVERE, "Failed to send service status email", me);
                } catch (Exception e) {
                    LOGGER.log(Level.SEVERE, "Failed to notify customer", e);
                }
            }
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Invalid order ID format\"}");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating service status", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private void createService(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            Gson gson = new Gson();
            Map<String, Object> serviceData = gson.fromJson(request.getReader(), Map.class);
            
            // Validate required fields
            if (!validateCreateServiceRequest(serviceData)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"Missing required fields\"}");
                return;
            }
            
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            
            Service service = new Service();
            service.setName((String) serviceData.get("name"));
            service.setDescription((String) serviceData.get("description"));
            service.setCategory((String) serviceData.get("category"));
            service.setPrice(((Double) serviceData.get("price")).doubleValue());
            service.setCreatedBy(currentUser.getId());
            
            boolean success = serviceDAO.createService(service);
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error creating service", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private boolean validateCreateServiceRequest(Map<String, Object> request) {
         return request.containsKey("name")
            && request.containsKey("category")
            && request.containsKey("price");
    }
        /**
     * Parse an object to int regardless of whether it is a Number or String.
     */
    private int parseInt(Object value) {
        if (value == null) return 0;
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        return Integer.parseInt(value.toString());
    }
}

