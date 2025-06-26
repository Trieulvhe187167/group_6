package controller;

import dal.UserDAO;
import dal.VerificationDAO; 
import model.User;
import model.PendingChange; 
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Arrays;
import service.VerificationService;

@WebServlet(name = "StaffServlet", urlPatterns = {"/admin/staff"})
public class StaffServlet extends HttpServlet {
    
    private UserDAO userDAO = new UserDAO();
     private VerificationDAO verificationDAO = new VerificationDAO();
    private static final List<String> STAFF_ROLES = Arrays.asList("ADMIN", "RECEPTIONIST", "HOUSEKEEPER", "ROOM_INSPECTOR");
    private static final int RECORDS_PER_PAGE = 3;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        try {
            switch (action) {
                case "list":
                    listStaff(request, response);
                    break;
                case "form":
                    showForm(request, response);
                    break;
                case "view":
                    showStaffDetail(request, response);
                    break;
                case "delete":
                    deleteStaff(request, response);
                    break;
                case "restore":
                    restoreStaff(request, response);
                    break;
                case "trash":
                    showTrash(request, response);
                    break;
                default:
                    listStaff(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "An error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/staff");
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
                    createStaff(request, response);
                    break;
                case "update":
                    updateStaff(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin/staff");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "An error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/staff");
        }
    }
    
    private void listStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int page = getPageParameter(request);
        String roleFilter = request.getParameter("role");
        String search = request.getParameter("search");
        
        // Validate role filter
        if (roleFilter != null && !roleFilter.equals("ALL") && !STAFF_ROLES.contains(roleFilter)) {
            roleFilter = "ALL";
        }
        
        List<User> staff;
        int totalRecords;
        
        if (search != null && !search.trim().isEmpty()) {
            staff = userDAO.searchEmployeesPaginated(search.trim(), roleFilter, page, RECORDS_PER_PAGE);
            totalRecords = userDAO.getTotalSearchEmployeesCount(search.trim(), roleFilter);
            request.setAttribute("searchKeyword", search.trim());
        } else {
            staff = userDAO.getEmployeesByRolePaginated(roleFilter, page, RECORDS_PER_PAGE);
            totalRecords = userDAO.getTotalEmployeesByRole(roleFilter);
        }
        
        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
        
        // Get statistics for dashboard cards
        int adminCount = userDAO.getTotalEmployeesByRole("ADMIN");
        int receptionistCount = userDAO.getTotalEmployeesByRole("RECEPTIONIST");
        int housekeeperCount = userDAO.getTotalEmployeesByRole("HOUSEKEEPER");
        int inspectorCount = userDAO.getTotalEmployeesByRole("ROOM_INSPECTOR");
        
        // Set template attributes
        request.setAttribute("pageTitle", "Staff Management");
        request.setAttribute("contentPage", "/jsp/admin/staff/staff-list.jsp");
        request.setAttribute("activePage", "staff");
        
        // Set data attributes
        request.setAttribute("staff", staff);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("roleFilter", roleFilter != null ? roleFilter : "ALL");
        request.setAttribute("isTrashView", false);
        
        // Set statistics
        request.setAttribute("adminCount", adminCount);
        request.setAttribute("receptionistCount", receptionistCount);
        request.setAttribute("housekeeperCount", housekeeperCount);
        request.setAttribute("inspectorCount", inspectorCount);
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void showTrash(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int page = getPageParameter(request);
        String roleFilter = request.getParameter("role");
        
        if (roleFilter != null && !roleFilter.equals("ALL") && !STAFF_ROLES.contains(roleFilter)) {
            roleFilter = "ALL";
        }
        
        List<User> deletedStaff = getDeletedStaffByRole(roleFilter, page);
        int totalRecords = getTotalDeletedStaffByRole(roleFilter);
        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
        
        // Set template attributes
        request.setAttribute("pageTitle", "Deleted Staff");
        request.setAttribute("contentPage", "/jsp/admin/staff/staff-list.jsp");
        request.setAttribute("activePage", "staff");
        
        // Set data attributes
        request.setAttribute("staff", deletedStaff);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("roleFilter", roleFilter != null ? roleFilter : "ALL");
        request.setAttribute("isTrashView", true);
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void showForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        boolean isEdit = idParam != null && !idParam.isEmpty();
        
        if (isEdit) {
            int id = Integer.parseInt(idParam);
            User staff = userDAO.getEmployeeByIdWithDetails(id);
            
            if (staff == null || !STAFF_ROLES.contains(staff.getRole())) {
                request.getSession().setAttribute("error", "Staff member not found!");
                response.sendRedirect(request.getContextPath() + "/admin/staff");
                return;
            }
            
            request.setAttribute("staff", staff);
        }
        
        // Set template attributes
        request.setAttribute("pageTitle", isEdit ? "Edit Staff Member" : "Add New Staff Member");
        request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
        request.setAttribute("activePage", "staff");
        request.setAttribute("isEdit", isEdit);
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
  private void showStaffDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        User staff = userDAO.getEmployeeByIdWithDetails(id);
        
        if (staff == null || !STAFF_ROLES.contains(staff.getRole())) {
            request.getSession().setAttribute("error", "Staff member not found!");
            response.sendRedirect(request.getContextPath() + "/admin/staff");
            return;
        }
        
        // Get pending changes for this staff member
        try {
            List<PendingChange> pendingChanges = verificationDAO.getPendingChangesForUser(id);
            request.setAttribute("pendingChanges", pendingChanges);
            
            // Log for debugging
            System.out.println("Found " + pendingChanges.size() + " pending changes for staff ID: " + id);
            
            // Additional security check for current user
            User currentUser = (User) request.getSession().getAttribute("user");
            if (currentUser != null && currentUser.getId() == id) {
                request.setAttribute("isCurrentUser", true);
            }
            
        } catch (Exception e) {
            System.err.println("Error loading pending changes for staff ID " + id + ": " + e.getMessage());
            e.printStackTrace();
            // Don't fail the entire page if pending changes can't be loaded
            request.setAttribute("pendingChanges", java.util.Collections.emptyList());
        }
        
        // Set template attributes
        request.setAttribute("pageTitle", "Staff Details - " + staff.getFullName());
        request.setAttribute("contentPage", "/jsp/admin/staff/staff-detail.jsp");
        request.setAttribute("activePage", "staff");
        request.setAttribute("staff", staff);
        request.setAttribute("userType", "staff"); // Add this for JavaScript
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void createStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get form parameters
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String role = request.getParameter("role");
        
        // Validate role
        if (!STAFF_ROLES.contains(role)) {
            request.getSession().setAttribute("error", "Invalid role selected!");
            response.sendRedirect(request.getContextPath() + "/admin/staff?action=form");
            return;
        }
        
        // Create staff object for form preservation
        User staff = new User();
        staff.setUsername(username);
        staff.setFullName(fullName);
        staff.setEmail(email);
        staff.setPhone(phone);
        staff.setRole(role);
        
        // Validate input
        String validationError = validateStaffInput(username, password, email, phone, role, null);
        if (validationError != null) {
            request.setAttribute("error", validationError);
            request.setAttribute("staff", staff);
            request.setAttribute("isEdit", false);
            request.setAttribute("pageTitle", "Add New Staff Member");
            request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
            request.setAttribute("activePage", "staff");
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
            return;
        }
        
        // Hash password and create staff
        staff.setPassword(hashPassword(password));
        staff.setStatus(true);
        
        if (userDAO.createEmployee(staff)) {
            request.getSession().setAttribute("success", "Staff member created successfully!");
        } else {
            request.getSession().setAttribute("error", "Failed to create staff member!");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/staff");
    }
    
  private void updateStaff(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    int id = Integer.parseInt(request.getParameter("id"));
    String fullName = request.getParameter("fullName");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String role = request.getParameter("role");
    String changePassword = request.getParameter("changePassword");
    String newPassword = request.getParameter("newPassword");
    
    // Get current admin user
    User currentAdmin = (User) request.getSession().getAttribute("user");
    if (currentAdmin == null || !"ADMIN".equals(currentAdmin.getRole())) {
        request.getSession().setAttribute("error", "Unauthorized access!");
        response.sendRedirect(request.getContextPath() + "/admin/staff");
        return;
    }
    
    // Get existing staff
    User staff = userDAO.getEmployeeByIdWithDetails(id);
    if (staff == null || !STAFF_ROLES.contains(staff.getRole())) {
        request.getSession().setAttribute("error", "Staff member not found!");
        response.sendRedirect(request.getContextPath() + "/admin/staff");
        return;
    }
    
    // **ADMIN ROLE PROTECTION**: Prevent changing admin role
    if ("ADMIN".equals(staff.getRole()) && !"ADMIN".equals(role)) {
        request.getSession().setAttribute("error", "Administrator role cannot be changed for security reasons!");
        response.sendRedirect(request.getContextPath() + "/admin/staff?action=form&id=" + id);
        return;
    }
    
    // For admin accounts, preserve the role regardless of form input
    if ("ADMIN".equals(staff.getRole())) {
        role = "ADMIN";
    }
    
    // 🔥 NEW: Check for sensitive changes and create verification requests
    VerificationService verificationService = new VerificationService();
    boolean hasSensitiveChanges = false;
    String successMessage = "";
    
    try {
        // Check email change
        if (!email.equals(staff.getEmail())) {
            boolean emailRequestCreated = verificationService.requestEmailChange(
                id, email, currentAdmin.getId(), 
                "Admin requested email change from " + staff.getEmail() + " to " + email
            );
            if (emailRequestCreated) {
                hasSensitiveChanges = true;
                successMessage += "Email change verification sent. ";
            }
        }
        
        // Check phone change  
        String currentPhone = staff.getPhone() != null ? staff.getPhone() : "";
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
        boolean needsUpdate = false;
        if (!fullName.equals(staff.getFullName())) {
            staff.setFullName(fullName);
            needsUpdate = true;
        }
        if (!role.equals(staff.getRole()) && !"ADMIN".equals(staff.getRole())) {
            staff.setRole(role);
            needsUpdate = true;
        }
        
        if (needsUpdate) {
            userDAO.updateUser(staff);
        }
        
        if (hasSensitiveChanges) {
            request.getSession().setAttribute("success", 
                successMessage + "Staff member will receive verification emails to approve changes.");
        } else {
            request.getSession().setAttribute("success", "Staff member updated successfully!");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("error", "Failed to process staff updates: " + e.getMessage());
        request.setAttribute("staff", staff);
        request.setAttribute("isEdit", true);
        request.setAttribute("pageTitle", "Edit Staff Member");
        request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
        request.setAttribute("activePage", "staff");
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
        return;
    }
    
  response.sendRedirect(request.getContextPath() + "/admin/staff?action=view&id=" + id + "&verificationSent=true");
}
    
    private void deleteStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        User currentUser = (User) request.getSession().getAttribute("user");
        
        // Prevent self-deletion
        if (currentUser != null && currentUser.getId() == id) {
            request.getSession().setAttribute("error", "You cannot delete your own account!");
            response.sendRedirect(request.getContextPath() + "/admin/staff");
            return;
        }
        
        // **ADDITIONAL PROTECTION**: Check if trying to delete an admin account
        User staffToDelete = userDAO.getEmployeeByIdWithDetails(id);
        if (staffToDelete != null && "ADMIN".equals(staffToDelete.getRole())) {
            // Count total admin accounts
            int adminCount = userDAO.getTotalEmployeesByRole("ADMIN");
            if (adminCount <= 1) {
                request.getSession().setAttribute("error", "Cannot delete the last administrator account!");
                response.sendRedirect(request.getContextPath() + "/admin/staff");
                return;
            }
            
            // Optional: Only allow other admins to delete admin accounts
            if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
                request.getSession().setAttribute("error", "Only administrators can delete other administrator accounts!");
                response.sendRedirect(request.getContextPath() + "/admin/staff");
                return;
            }
        }
        
        if (userDAO.deleteUser(id)) {
            request.getSession().setAttribute("success", "Staff member deleted successfully!");
        } else {
            request.getSession().setAttribute("error", "Failed to delete staff member!");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/staff");
    }
    
    private void restoreStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        
        if (userDAO.restoreUser(id)) {
            request.getSession().setAttribute("success", "Staff member restored successfully!");
        } else {
            request.getSession().setAttribute("error", "Failed to restore staff member!");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/staff?action=trash");
    }
    
    // Helper methods for staff-specific queries (placeholder implementations)
    private List<User> getDeletedStaffByRole(String role, int page) {
        if ("ALL".equals(role)) {
            return userDAO.getDeletedUsersByRolePaginated("ALL", page, RECORDS_PER_PAGE)
                    .stream()
                    .filter(user -> STAFF_ROLES.contains(user.getRole()))
                    .toList();
        } else {
            return userDAO.getDeletedUsersByRolePaginated(role, page, RECORDS_PER_PAGE);
        }
    }
    
    private int getTotalDeletedStaffByRole(String role) {
        if ("ALL".equals(role)) {
            return STAFF_ROLES.stream()
                    .mapToInt(r -> userDAO.getTotalDeletedUsersByRole(r))
                    .sum();
        } else {
            return userDAO.getTotalDeletedUsersByRole(role);
        }
    }
    
    // Other helper methods
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
    
    private String validateStaffInput(String username, String password, String email, String phone, String role, Integer excludeId) {
        // Username validation (only for new staff)
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
        
        // Role validation (but skip for admin role protection)
        if (!STAFF_ROLES.contains(role)) {
            return "Invalid role selected.";
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
}