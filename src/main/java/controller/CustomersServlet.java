package controller;

import dal.CustomerDAO;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import com.google.gson.Gson;

@WebServlet(name = "CustomersServlet", urlPatterns = {"/receptionist/customers"})
public class CustomersServlet extends HttpServlet {
    
    private CustomerDAO customerDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        try {
            customerDAO = new CustomerDAO();
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Failed to initialize CustomerDAO", e);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("DEBUG: CustomersServlet doGet method entered.");
        
        // Check receptionist authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"RECEPTIONIST".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        // Handle view customer detail action
        if ("view".equals(action)) {
            String customerId = request.getParameter("id");
            if (customerId != null) {
                try {
                    System.out.println("DEBUG: Viewing customer detail for ID: " + customerId);
                    viewCustomerDetail(request, response, Integer.parseInt(customerId));
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                    System.out.println("ERROR viewing customer detail: " + e.getMessage());
                }
            }
        }
        
        // Handle export action
        if ("exportCustomers".equals(action)) {
            exportCustomers(request, response);
            return;
        }
        
        try {
            // Get all customers with stats
            List<Customer> customers = customerDAO.getCustomersWithStats();
            System.out.println("DEBUG: Found " + customers.size() + " customers");
            
            // Get statistics
            int totalCustomers = customerDAO.getCustomerCount();
            int activeCustomers = customerDAO.getActiveCustomerCount();
            int vipCustomers = customerDAO.getVIPCustomerCount();
            int newCustomersThisMonth = customerDAO.getNewCustomersThisMonth();
            
            System.out.println("DEBUG: Stats - Total: " + totalCustomers + ", Active: " + activeCustomers + 
                             ", VIP: " + vipCustomers + ", New: " + newCustomersThisMonth);
            
            // Set attributes
            request.setAttribute("customers", customers);
            request.setAttribute("totalCustomers", totalCustomers);
            request.setAttribute("activeCustomers", activeCustomers);
            request.setAttribute("vipCustomers", vipCustomers);
            request.setAttribute("newCustomersThisMonth", newCustomersThisMonth);
            request.setAttribute("currentUser", currentUser);
            
            // Set template attributes
            request.setAttribute("pageTitle", "Customers Management");
            request.setAttribute("activePage", "customers");
            // No need to set contentPage anymore as we're using direct includes
            
            System.out.println("DEBUG: Forwarding to template");
            
            // Forward to template
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("ERROR: " + e.getMessage());
            request.setAttribute("error", "Error loading customers page: " + e.getMessage());
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = null;
        Map<String, Object> jsonRequest = null;
        
        // Check if content type is JSON
        if (request.getContentType() != null && request.getContentType().contains("application/json")) {
            try {
                // Read JSON from request body
                Gson gson = new Gson();
                jsonRequest = gson.fromJson(request.getReader(), Map.class);
                if (jsonRequest != null && jsonRequest.containsKey("action")) {
                    action = (String) jsonRequest.get("action");
                }
            } catch (Exception e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid JSON format");
                return;
            }
        } else {
            // Fallback to getParameter for form-urlencoded or other types
            action = request.getParameter("action");
        }

        if (action == null || action.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action parameter is required");
            return;
        }
        
        try {
            switch (action) {
                case "createCustomer":
                    createCustomer(request, response, jsonRequest);
                    break;
                case "updateCustomer":
                    updateCustomer(request, response, jsonRequest);
                    break;
                case "customerDetails":
                    getCustomerDetails(request, response, jsonRequest);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred while processing your request");
        }
    }
    
    private void viewCustomerDetail(HttpServletRequest request, HttpServletResponse response, int customerId) 
            throws ServletException, IOException {
        try {
            Customer customer = customerDAO.getCustomerById(customerId);
            if (customer == null) {
                response.sendRedirect(request.getContextPath() + "/receptionist/customers");
                return;
            }
            
            // Get booking history
            customer.setBookingHistory(customerDAO.getCustomerBookingHistory(customerId));
            
            request.setAttribute("customer", customer);
            request.setAttribute("pageTitle", "Customer Details");
            request.setAttribute("activePage", "customers");
            request.setAttribute("contentPage", "/jsp/reception/customer-detail.jsp");
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/receptionist/customers");
        }
    }
    
    private void createCustomer(HttpServletRequest request, HttpServletResponse response, Map<String, Object> jsonRequest) 
            throws IOException {
        Customer newCustomer = new Customer();
        
        if (jsonRequest != null) {
            // Extract from JSON
            newCustomer.setFullName((String) jsonRequest.get("fullName"));
            newCustomer.setEmail((String) jsonRequest.get("email"));
            newCustomer.setPhone((String) jsonRequest.get("phone"));
            newCustomer.setNotes((String) jsonRequest.get("notes"));
        } else {
            // Fallback to form parameters
            newCustomer.setFullName(request.getParameter("fullName"));
            newCustomer.setEmail(request.getParameter("email"));
            newCustomer.setPhone(request.getParameter("phone"));
            newCustomer.setNotes(request.getParameter("notes"));
        }
        
        if (!validateCustomerData(newCustomer)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid customer data");
            return;
        }
        
        // Generate username from full name
        newCustomer.setUsername(generateUsername(newCustomer.getFullName()));
        
        // Check if email or phone already exists
        if (customerDAO.emailExists(newCustomer.getEmail())) {
            response.setStatus(409); // Conflict
            response.getWriter().write("{\"error\":\"Email already exists\"}");
            return;
        }
        
        if (customerDAO.phoneExists(newCustomer.getPhone())) {
            response.setStatus(409); // Conflict
            response.getWriter().write("{\"error\":\"Phone already exists\"}");
            return;
        }
        
        // Create customer with default password
        int customerId = customerDAO.createCustomer(newCustomer, "Pass123!");
        
        response.setContentType("application/json");
        response.getWriter().write("{\"success\":" + (customerId > 0) + ", \"customerId\":" + customerId + "}");
    }
    
    private void updateCustomer(HttpServletRequest request, HttpServletResponse response, Map<String, Object> jsonRequest) 
            throws IOException {
        try {
            int customerId;
            String fullName, email, phone, notes;
            
            if (jsonRequest != null) {
                // Extract from JSON
                Object idObj = jsonRequest.get("id");
                if (idObj instanceof Double) {
                    customerId = ((Double) idObj).intValue();
                } else {
                    customerId = Integer.parseInt(idObj.toString());
                }
                fullName = (String) jsonRequest.get("fullName");
                email = (String) jsonRequest.get("email");
                phone = (String) jsonRequest.get("phone");
                notes = (String) jsonRequest.get("notes");
            } else {
                // Fallback to form parameters
                customerId = Integer.parseInt(request.getParameter("id"));
                fullName = request.getParameter("fullName");
                email = request.getParameter("email");
                phone = request.getParameter("phone");
                notes = request.getParameter("notes");
            }
            
            Customer customer = customerDAO.getCustomerById(customerId);
            if (customer == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Customer not found");
                return;
            }
            
            // Check if email is changed and already exists
            if (!customer.getEmail().equals(email) && customerDAO.emailExists(email)) {
                response.setStatus(409); // Conflict
                response.getWriter().write("{\"error\":\"Email already exists\"}");
                return;
            }
            
            // Check if phone is changed and already exists
            if (!customer.getPhone().equals(phone) && customerDAO.phoneExists(phone)) {
                response.setStatus(409); // Conflict
                response.getWriter().write("{\"error\":\"Phone already exists\"}");
                return;
            }
            
            customer.setFullName(fullName);
            customer.setEmail(email);
            customer.setPhone(phone);
            customer.setNotes(notes);
            
            boolean success = customerDAO.updateCustomer(customer);
            
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid customer ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error updating customer");
        }
    }
    
    private void getCustomerDetails(HttpServletRequest request, HttpServletResponse response, Map<String, Object> jsonRequest) 
            throws ServletException, IOException {
        try {
            int customerId;
            
            if (jsonRequest != null) {
                Object idObj = jsonRequest.get("id");
                if (idObj instanceof Double) {
                    customerId = ((Double) idObj).intValue();
                } else {
                    customerId = Integer.parseInt(idObj.toString());
                }
            } else {
                customerId = Integer.parseInt(request.getParameter("id"));
            }
            
            Customer customer = customerDAO.getCustomerById(customerId);
            if (customer == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Customer not found");
                return;
            }
            
            // Convert to JSON and send response
            Gson gson = new Gson();
            String jsonResponse = gson.toJson(customer);
            
            response.setContentType("application/json");
            response.getWriter().write(jsonResponse);
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid customer ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error retrieving customer details");
        }
    }
    
    private void exportCustomers(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            List<Customer> customers = customerDAO.getAllCustomers();
            
            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", "attachment; filename=\"customers.csv\"");
            
            StringBuilder csv = new StringBuilder();
            csv.append("ID,Full Name,Email,Phone,Status,Created Date\n");
            
            for (Customer customer : customers) {
                csv.append(customer.getId()).append(",")
                   .append(escapeCsvField(customer.getFullName())).append(",")
                   .append(escapeCsvField(customer.getEmail())).append(",")
                   .append(escapeCsvField(customer.getPhone())).append(",")
                   .append(escapeCsvField(String.valueOf(customer.isStatus()))).append(",")
                   .append(customer.getCreatedAt()).append("\n");
            }
            
            response.getWriter().write(csv.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error exporting customers");
        }
    }
    
    private boolean validateCustomerData(Customer customer) {
        return customer.getFullName() != null && !customer.getFullName().trim().isEmpty() &&
               customer.getEmail() != null && !customer.getEmail().trim().isEmpty() &&
               customer.getPhone() != null && !customer.getPhone().trim().isEmpty();
    }
    
    private String generateUsername(String fullName) {
        // Remove special characters and spaces, convert to lowercase
        String username = fullName.replaceAll("[^a-zA-Z0-9]", "").toLowerCase();
        // Add random number to make it unique
        username += String.format("%04d", new Random().nextInt(10000));
        return username;
    }
    
    private String escapeCsvField(String field) {
        if (field == null) return "";
        if (field.contains(",") || field.contains("\"") || field.contains("\n")) {
            return "\"" + field.replace("\"", "\"\"") + "\"";
        }
        return field;
    }
}