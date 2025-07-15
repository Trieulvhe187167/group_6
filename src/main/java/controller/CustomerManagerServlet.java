package controller;

import dal.UserDAO;
import dal.VerificationDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import model.PendingChange;
import service.VerificationService;

@WebServlet(name = "CustomerManagerServlet", urlPatterns = {"/admin/customers"})
public class CustomerManagerServlet extends HttpServlet {
   
    private UserDAO userDAO = new UserDAO();
    private static final int RECORDS_PER_PAGE = 3;
      private VerificationDAO verificationDAO = new VerificationDAO(); // Add this
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        try {
            switch (action) {
                case "list":
                    listCustomers(request, response);
                    break;
                case "form":
                    showForm(request, response);
                    break;
                case "view":
                    showCustomerDetail(request, response);
                    break;
                case "delete":
                    deleteCustomer(request, response);
                    break;
                case "restore":
                    restoreCustomer(request, response);
                    break;
                case "trash":
                    showTrash(request, response);
                    break;
                default:
                    listCustomers(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "An error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/customers");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        try {
            switch (action) {
                case "create":
                    createCustomer(request, response);
                    break;
                case "update":
                    updateCustomer(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin/customers");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "An error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/customers");
        }
    }
    
    private void listCustomers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int page = getPageParameter(request);
        String search = request.getParameter("search");
        
        List<User> customers;
        int totalRecords;
        
        if (search != null && !search.trim().isEmpty()) {
            customers = userDAO.searchCustomersPaginated(search.trim(), page, RECORDS_PER_PAGE);
            totalRecords = userDAO.getTotalSearchCustomersCount(search.trim());
            request.setAttribute("searchKeyword", search.trim());
        } else {
            customers = userDAO.getCustomersPaginated(page, RECORDS_PER_PAGE);
            totalRecords = userDAO.getTotalCustomersCount();
        }
        
        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
        
        // Get statistics for dashboard cards
        int vipCustomers = getVIPCustomersCount(customers);
        int newThisMonth = getNewCustomersThisMonth();
        int activeBookings = getActiveBookingsCount();
        
        // Set template attributes
        request.setAttribute("pageTitle", "Customer Management");
        request.setAttribute("contentPage", "/jsp/admin/customers/customer-list.jsp");
        request.setAttribute("activePage", "customers");
        
        // Set data attributes
        request.setAttribute("customers", customers);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("isTrashView", false);
        
        // Set statistics
        request.setAttribute("vipCustomers", vipCustomers);
        request.setAttribute("newThisMonth", newThisMonth);
        request.setAttribute("activeBookings", activeBookings);
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void showTrash(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int page = getPageParameter(request);
        
        // For now, using the existing method - you might want to create a specific deleted customers method
        List<User> deletedCustomers = userDAO.getDeletedUsersByRolePaginated("CUSTOMER", page, RECORDS_PER_PAGE);
        int totalRecords = userDAO.getTotalDeletedUsersByRole("CUSTOMER"); 
        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
        
        // Set template attributes
        request.setAttribute("pageTitle", "Deleted Customers");
        request.setAttribute("contentPage", "/jsp/admin/customers/customer-list.jsp");
        request.setAttribute("activePage", "customers");
        
        // Set data attributes
        request.setAttribute("customers", deletedCustomers);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("isTrashView", true);
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
   private void showForm(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    String idParam = request.getParameter("id");
    boolean isEdit = idParam != null && !idParam.isEmpty();
    
    if (isEdit) {
        int id = Integer.parseInt(idParam);
        User customer = userDAO.getCustomerByIdWithDetails(id);
        
        if (customer == null || !"CUSTOMER".equals(customer.getRole())) {
            request.getSession().setAttribute("error", "Customer not found!");
            response.sendRedirect(request.getContextPath() + "/admin/customers");
            return;
        }
        
        // Format date of birth for HTML date input
        if (customer.getDateOfBirth() != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            String formattedDateOfBirth = sdf.format(customer.getDateOfBirth());
            request.setAttribute("formattedDateOfBirth", formattedDateOfBirth);
        }
        
        request.setAttribute("customer", customer);
    }
    
    // Set template attributes
    request.setAttribute("pageTitle", isEdit ? "Edit Customer" : "Add New Customer");
    request.setAttribute("contentPage", "/jsp/admin/customers/customer-form.jsp");
    request.setAttribute("activePage", "customers");
    request.setAttribute("isEdit", isEdit);
    
    request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
}
    
  private void showCustomerDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        User customer = userDAO.getCustomerByIdWithDetails(id);
        
        if (customer == null || !"CUSTOMER".equals(customer.getRole())) {
            request.getSession().setAttribute("error", "Customer not found!");
            response.sendRedirect(request.getContextPath() + "/admin/customers");
            return;
        }
        
        // Get pending changes for this customer
        try {
            List<PendingChange> pendingChanges = verificationDAO.getPendingChangesForUser(id);
            request.setAttribute("pendingChanges", pendingChanges);
            
            // Log for debugging
            System.out.println("Found " + pendingChanges.size() + " pending changes for customer ID: " + id);
            
        } catch (Exception e) {
            System.err.println("Error loading pending changes for customer ID " + id + ": " + e.getMessage());
            e.printStackTrace();
            // Don't fail the entire page if pending changes can't be loaded
            request.setAttribute("pendingChanges", java.util.Collections.emptyList());
        }
        
        // Set template attributes
        request.setAttribute("pageTitle", "Customer Details - " + customer.getFullName());
        request.setAttribute("contentPage", "/jsp/admin/customers/customer-detail.jsp");
        request.setAttribute("activePage", "customers");
        request.setAttribute("customer", customer);
        request.setAttribute("userType", "customer"); // Add this for JavaScript
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    

    
    private void createCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get form parameters
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        
        // Create customer object for form preservation
        User customer = new User();
        customer.setUsername(username);
        customer.setFullName(fullName);
        customer.setEmail(email);
        customer.setPhone(phone);
        customer.setRole("CUSTOMER");
        
        // Validate input
        String validationError = validateCustomerInput(username, password, email, phone, null);
        if (validationError != null) {
            request.setAttribute("error", validationError);
            request.setAttribute("customer", customer);
            request.setAttribute("isEdit", false);
            request.setAttribute("pageTitle", "Add New Customer");
            request.setAttribute("contentPage", "/jsp/admin/customers/customer-form.jsp");
            request.setAttribute("activePage", "customers");
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
            return;
        }
        
        // Hash password and create customer
        customer.setPassword(hashPassword(password));
        customer.setStatus(true);
        
        if (userDAO.createCustomer(customer)) {
            request.getSession().setAttribute("success", "Customer created successfully!");
        } else {
            request.getSession().setAttribute("error", "Failed to create customer!");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/customers");
    }
    
private void updateCustomer(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    int id = Integer.parseInt(request.getParameter("id"));
    String fullName = request.getParameter("fullName");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String changePassword = request.getParameter("changePassword");
    String newPassword = request.getParameter("newPassword");
    
    // Get additional customer fields
    String dateOfBirthStr = request.getParameter("dateOfBirth");
    String gender = request.getParameter("gender");
    String idType = request.getParameter("idType");
    String idNumber = request.getParameter("idNumber");
    String address = request.getParameter("address");
    String city = request.getParameter("city");
    String country = request.getParameter("country");
    
    // Get loyalty program fields (only for edit mode)
    String loyaltyPointsStr = request.getParameter("loyaltyPoints");
    String membershipLevel = request.getParameter("membershipLevel");
    String isVIPStr = request.getParameter("isVIP");
    
    // Get current admin user
    User currentAdmin = (User) request.getSession().getAttribute("user");
    if (currentAdmin == null || !"ADMIN".equals(currentAdmin.getRole())) {
        request.getSession().setAttribute("error", "Unauthorized access!");
        response.sendRedirect(request.getContextPath() + "/admin/customers");
        return;
    }
    
    // Get existing customer with all details
    User customer = userDAO.getCustomerByIdWithDetails(id);
    if (customer == null || !"CUSTOMER".equals(customer.getRole())) {
        request.getSession().setAttribute("error", "Customer not found!");
        response.sendRedirect(request.getContextPath() + "/admin/customers");
        return;
    }
    
    // Validate input
    String validationError = validateCustomerInput(null, null, email, phone, id);
    if (validationError != null) {
        request.setAttribute("error", validationError);
        request.setAttribute("customer", customer);
        request.setAttribute("isEdit", true);
        request.setAttribute("pageTitle", "Edit Customer");
        request.setAttribute("contentPage", "/jsp/admin/customers/customer-form.jsp");
        request.setAttribute("activePage", "customers");
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
        return;
    }
    
    // 🔥 Check for sensitive changes and create verification requests
    VerificationService verificationService = new VerificationService();
    boolean hasSensitiveChanges = false;
    String successMessage = "";
    
    try {
        // Check email change
        if (!email.equals(customer.getEmail())) {
            boolean emailRequestCreated = verificationService.requestEmailChange(
                id, email, currentAdmin.getId(), 
                "Admin requested email change from " + customer.getEmail() + " to " + email
            );
            if (emailRequestCreated) {
                hasSensitiveChanges = true;
                successMessage += "Email change verification sent. ";
            }
        }
        
        // Check phone change  
        String currentPhone = customer.getPhone() != null ? customer.getPhone() : "";
        String newPhone = phone != null ? phone : "";
        
        if (!newPhone.equals(currentPhone)) {
            boolean phoneRequestCreated = verificationService.requestPhoneChange(
                id, phone, currentAdmin.getId(),
                "Admin requested phone change from " + currentPhone + " to " + newPhone
            );
            if (phoneRequestCreated) {
                hasSensitiveChanges = true;
                successMessage += "Phone change verification sent. ";
            }
        }
        
        // Check password change
        if ("true".equals(changePassword) && newPassword != null && !newPassword.isEmpty()) {
            boolean passwordRequestCreated = verificationService.requestPasswordChange(
                id, newPassword, currentAdmin.getId(),
                "Admin requested password reset"
            );
            if (passwordRequestCreated) {
                hasSensitiveChanges = true;
                successMessage += "Password change verification sent. ";
            }
        }
        
        // Update non-sensitive fields directly
        boolean needsBasicUpdate = false;
        boolean needsDetailsUpdate = false;
        
        // Update basic user info
        if (!fullName.equals(customer.getFullName())) {
            customer.setFullName(fullName);
            needsBasicUpdate = true;
        }
        
        // Update customer details
        // Parse and set date of birth
        if (dateOfBirthStr != null && !dateOfBirthStr.isEmpty()) {
            try {
                Date dob = new java.text.SimpleDateFormat("yyyy-MM-dd").parse(dateOfBirthStr);
                if (!dob.equals(customer.getDateOfBirth())) {
                    customer.setDateOfBirth(dob);
                    needsDetailsUpdate = true;
                }
            } catch (Exception e) {
                System.err.println("Error parsing date of birth: " + e.getMessage());
            }
        } else if (customer.getDateOfBirth() != null) {
            customer.setDateOfBirth(null);
            needsDetailsUpdate = true;
        }
        
        // Update gender
        if ((gender != null && !gender.equals(customer.getGender())) || 
            (gender == null && customer.getGender() != null) ||
            (gender != null && gender.isEmpty() && customer.getGender() != null)) {
            customer.setGender(gender != null && !gender.isEmpty() ? gender : null);
            needsDetailsUpdate = true;
        }
        
        // Update ID information
        if ((idType != null && !idType.equals(customer.getIdType())) ||
            (idType == null && customer.getIdType() != null) ||
            (idType != null && idType.isEmpty() && customer.getIdType() != null)) {
            customer.setIdType(idType != null && !idType.isEmpty() ? idType : null);
            needsDetailsUpdate = true;
        }
        
        if ((idNumber != null && !idNumber.equals(customer.getIdNumber())) ||
            (idNumber == null && customer.getIdNumber() != null)) {
            customer.setIdNumber(idNumber != null && !idNumber.trim().isEmpty() ? idNumber.trim() : null);
            needsDetailsUpdate = true;
        }
        
        // Update address information
        if ((address != null && !address.equals(customer.getAddress())) ||
            (address == null && customer.getAddress() != null)) {
            customer.setAddress(address != null && !address.trim().isEmpty() ? address.trim() : null);
            needsDetailsUpdate = true;
        }
        
        if ((city != null && !city.equals(customer.getCity())) ||
            (city == null && customer.getCity() != null)) {
            customer.setCity(city != null && !city.trim().isEmpty() ? city.trim() : null);
            needsDetailsUpdate = true;
        }
        
        if ((country != null && !country.equals(customer.getCountry())) ||
            (country == null && customer.getCountry() != null)) {
            customer.setCountry(country != null && !country.trim().isEmpty() ? country.trim() : null);
            needsDetailsUpdate = true;
        }
        
        // Update loyalty program information
        if (loyaltyPointsStr != null && !loyaltyPointsStr.isEmpty()) {
            try {
                int loyaltyPoints = Integer.parseInt(loyaltyPointsStr);
                if (loyaltyPoints != customer.getLoyaltyPoints()) {
                    customer.setLoyaltyPoints(loyaltyPoints);
                    needsDetailsUpdate = true;
                }
            } catch (NumberFormatException e) {
                System.err.println("Invalid loyalty points: " + loyaltyPointsStr);
            }
        }
        
        if (membershipLevel != null && !membershipLevel.equals(customer.getMembershipLevel())) {
            customer.setMembershipLevel(membershipLevel);
            needsDetailsUpdate = true;
        }
        
        if (isVIPStr != null) {
            boolean isVIP = Boolean.parseBoolean(isVIPStr);
            if (isVIP != customer.isVIP()) {
                customer.setVIP(isVIP);
                needsDetailsUpdate = true;
            }
        }
        
        // Perform updates
        if (needsBasicUpdate) {
            userDAO.updateUser(customer);
        }
        
        if (needsDetailsUpdate) {
            // Ensure customer details exist
            if (!userDAO.hasCustomerDetails(id)) {
                userDAO.createCustomerDetailsIfNotExists(id);
            }
            // Update customer details
            userDAO.updateCustomerDetails(customer);
        }
        
        // Set success message
        if (hasSensitiveChanges) {
            request.getSession().setAttribute("success", 
                successMessage + "Customer will receive verification emails to approve changes.");
        } else if (needsBasicUpdate || needsDetailsUpdate) {
            request.getSession().setAttribute("success", "Customer information updated successfully!");
        } else {
            request.getSession().setAttribute("info", "No changes were made.");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("error", "Failed to process customer updates: " + e.getMessage());
        request.setAttribute("customer", customer);
        request.setAttribute("isEdit", true);
        request.setAttribute("pageTitle", "Edit Customer");
        request.setAttribute("contentPage", "/jsp/admin/customers/customer-form.jsp");
        request.setAttribute("activePage", "customers");
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
        return;
    }
    
    // Redirect to customer detail page
    if (hasSensitiveChanges) {
        response.sendRedirect(request.getContextPath() + "/admin/customers?action=view&id=" + id + "&verificationSent=true");
    } else {
        response.sendRedirect(request.getContextPath() + "/admin/customers?action=view&id=" + id);
    }
}
    
    private void deleteCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        // Check if the customer currently has active reservations/stays
        if (userDAO.hasActiveReservations(id)) {
            request.getSession().setAttribute("error",
                    "Cannot delete customer while they have active reservations or are currently staying.");
            response.sendRedirect(request.getContextPath() + "/admin/customers");
            return;
        }
        
        if (userDAO.deleteUser(id)) {
            request.getSession().setAttribute("success", "Customer deleted successfully!");
        } else {
            request.getSession().setAttribute("error", "Failed to delete customer!");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/customers");
    }
    
    private void restoreCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        
        if (userDAO.restoreUser(id)) {
            request.getSession().setAttribute("success", "Customer restored successfully!");
        } else {
            request.getSession().setAttribute("error", "Failed to restore customer!");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/customers?action=trash");
    }
    
    // Helper methods
    private int getPageParameter(HttpServletRequest request) {
        String pageParam = request.getParameter("page");
        int page = 1;
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        return page;
    }
    
    private String validateCustomerInput(String username, String password, String email, String phone, Integer excludeId) {
        // Username validation (only for new customers)
        if (username != null && !username.matches("^[a-zA-Z0-9_]{3,20}$")) {
            return "Username must be 3-20 characters and contain only letters, numbers, and underscores.";
        }
        
        // Password validation (only when provided)
        if (password != null && !password.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&+=!]).{8,}$")) {
            return "Password must be at least 8 characters with uppercase, lowercase, digit, and special character.";
        }
        
        // Email validation
        if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            return "Please enter a valid email address.";
        }
        
        // Phone validation (optional)
        if (phone != null && !phone.isEmpty() && !phone.matches("^0\\d{9}$")) {
            return "Phone number must start with 0 and be exactly 10 digits.";
        }
        
        // Check duplicates
        if (username != null && userDAO.isUsernameExists(username, excludeId)) {
            return "Username already exists.";
        }
        
        if (userDAO.isEmailExists(email, excludeId)) {
            return "Email already exists.";
        }
        
        return null;
    }
    
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
            throw new RuntimeException("Error hashing password", e);
        }
    }
    
    // Statistics helper methods
    private int getVIPCustomersCount(List<User> customers) {
        int count = 0;
        for (User customer : customers) {
            if (customer.isVIPCustomer()) {
                count++;
            }
        }
        return count;
    }
    
    private int getNewCustomersThisMonth() {
        // This would ideally be a database query
        // For now, returning 0 - implement based on your needs
        return 0;
    }
    
    private int getActiveBookingsCount() {
        // This would ideally be a database query for active bookings by customers
        // For now, returning 0 - implement based on your needs
        return 0;
    }

}