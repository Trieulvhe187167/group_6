package controller;

import dal.UserDAO;
import model.User;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Timestamp;

@WebServlet(name = "AdminUserManagementServlet", urlPatterns = {"/admin/users"})
public class AdminUserManagementServlet extends HttpServlet {
    
    private UserDAO userDAO = new UserDAO();
    private static final int RECORDS_PER_PAGE = 5; // Changed to 5 users per page
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check admin authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        try {
            switch (action) {
                case "list":
                    listUsers(request, response);
                    break;
                case "form":
                    showUserForm(request, response);
                    break;
                case "view":
                    viewUser(request, response);
                    break;
                case "delete":
                    deleteUser(request, response);
                    break;
                case "restore":
                    restoreUser(request, response);
                    break;
                case "trash":
                    listDeletedUsers(request, response);
                    break;
                default:
                    listUsers(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            listUsers(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check admin authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
              response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) action = "";
        
        try {
            switch (action) {
                case "create":
                    createUser(request, response);
                    break;
                case "update":
                    updateUser(request, response);
                    break;
                default:
                    response.sendRedirect("users");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            showUserForm(request, response);
        }
    }
    
    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get parameters
        String roleFilter = request.getParameter("role");
        String searchKeyword = request.getParameter("search");
        String sortBy = request.getParameter("sort");
        int page = 1;
        
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                page = Integer.parseInt(pageStr);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }
        
        // Default values
        if (roleFilter == null || roleFilter.isEmpty()) roleFilter = "ALL";
        if (searchKeyword == null) searchKeyword = "";
        if (sortBy == null) sortBy = "createdAt";
        
        List<User> users;
        int totalRecords;
        
        // Get users based on filters
        if (!searchKeyword.isEmpty()) {
            if ("ALL".equals(roleFilter)) {
                // Search all users - pass "ALL" as role parameter
                users = userDAO.searchUsersByRolePaginated(searchKeyword, "ALL", page, RECORDS_PER_PAGE);
                totalRecords = userDAO.getTotalSearchUsersByRole(searchKeyword, "ALL");
            } else {
                // Search by specific role
                users = userDAO.searchUsersByRolePaginated(searchKeyword, roleFilter, page, RECORDS_PER_PAGE);
                totalRecords = userDAO.getTotalSearchUsersByRole(searchKeyword, roleFilter);
            }
        } else {
            if ("ALL".equals(roleFilter)) {
                // Get all users - pass "ALL" as role parameter
                users = userDAO.getUsersByRolePaginated("ALL", page, RECORDS_PER_PAGE);
                totalRecords = userDAO.getTotalUsersByRole("ALL");
            } else {
                // Get by specific role
                users = userDAO.getUsersByRolePaginated(roleFilter, page, RECORDS_PER_PAGE);
                totalRecords = userDAO.getTotalUsersByRole(roleFilter);
            }
        }
        
        // Calculate pagination
        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
        
        // Set attributes
        request.setAttribute("users", users);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("roleFilter", roleFilter);
        request.setAttribute("searchKeyword", searchKeyword);
        request.setAttribute("sortBy", sortBy);
        
        // Set page info for template
        request.setAttribute("pageTitle", "User Management");
        request.setAttribute("activePage", "users");
        request.setAttribute("contentPage", "/jsp/admin/user-list.jsp");
        
        // Forward to template
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void listDeletedUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String roleFilter = request.getParameter("role");
        int page = 1;
        
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                page = Integer.parseInt(pageStr);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }
        
        if (roleFilter == null || roleFilter.isEmpty()) roleFilter = "ALL";
        
        List<User> users;
        int totalRecords;
        
        if ("ALL".equals(roleFilter)) {
            users = userDAO.getDeletedUsersByRolePaginated("ALL", page, RECORDS_PER_PAGE);
            totalRecords = userDAO.getTotalDeletedUsersByRole("ALL");
        } else {
            users = userDAO.getDeletedUsersByRolePaginated(roleFilter, page, RECORDS_PER_PAGE);
            totalRecords = userDAO.getTotalDeletedUsersByRole(roleFilter);
        }
        
        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
        
        request.setAttribute("users", users);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("roleFilter", roleFilter);
        request.setAttribute("isTrashView", true);
        
        request.setAttribute("pageTitle", "Deleted Users");
        request.setAttribute("activePage", "users");
        request.setAttribute("contentPage", "/jsp/admin/user-list.jsp");
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void showUserForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        User user = null;
        boolean isEdit = false;
        
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                user = userDAO.getUserById(id);
                isEdit = true;
            } catch (NumberFormatException e) {
                // Invalid ID
            }
        }
        
        request.setAttribute("user", user);
        request.setAttribute("isEdit", isEdit);
        request.setAttribute("pageTitle", isEdit ? "Edit User" : "Create User");
        request.setAttribute("activePage", "users");
        request.setAttribute("contentPage", "/jsp/admin/user-form.jsp");
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void viewUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("users");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            User user = userDAO.getUserById(id);
            
            if (user == null) {
                request.setAttribute("error", "User not found");
                listUsers(request, response);
                return;
            }
            
            request.setAttribute("user", user);
            request.setAttribute("pageTitle", "User Details");
            request.setAttribute("activePage", "users");
            request.setAttribute("contentPage", "/jsp/admin/user-detail.jsp");
            
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect("users");
        }
    }
    
    private void createUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get parameters
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String role = request.getParameter("role");
        
        // Validate required fields
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            fullName == null || fullName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            role == null || role.trim().isEmpty()) {
            
            request.setAttribute("error", "All required fields must be filled");
            showUserForm(request, response);
            return;
        }
        
        // Validate username format
        if (!isValidUsername(username)) {
            request.setAttribute("error", "Username must be 3-20 characters long and contain only letters, numbers, and underscores");
            showUserForm(request, response);
            return;
        }
        
        // Validate password strength
        if (!isStrongPassword(password)) {
            request.setAttribute("error", "Password must be at least 8 characters long and contain uppercase, lowercase, number, and special character");
            showUserForm(request, response);
            return;
        }
        
        // Validate email format
        if (!isValidEmail(email)) {
            request.setAttribute("error", "Invalid email format");
            showUserForm(request, response);
            return;
        }
        
        // Validate phone format if provided
        if (phone != null && !phone.trim().isEmpty() && !isValidPhone(phone)) {
            request.setAttribute("error", "Phone number must start with 0 and be exactly 10 digits");
            showUserForm(request, response);
            return;
        }
        
        // Check if username or email exists
        if (userDAO.isUsernameExists(username, null)) {
            request.setAttribute("error", "Username already exists");
            showUserForm(request, response);
            return;
        }
        
        if (userDAO.isEmailExists(email, null)) {
            request.setAttribute("error", "Email already exists");
            showUserForm(request, response);
            return;
        }
        
        // Create user
        User user = new User(username, password, fullName, email, phone, role);
        
        if (userDAO.addUser(user)) {
            request.getSession().setAttribute("success", "User created successfully");
            response.sendRedirect("users");
        } else {
            request.setAttribute("error", "Failed to create user");
            showUserForm(request, response);
        }
    }
    
    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("users");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String role = request.getParameter("role");
            
            // Password change parameters
            String changePassword = request.getParameter("changePassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");
            
            // Validate required fields
            if (fullName == null || fullName.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                role == null || role.trim().isEmpty()) {
                
                request.setAttribute("error", "All required fields must be filled");
                showUserForm(request, response);
                return;
            }
            
            // Validate email format
            if (!isValidEmail(email)) {
                request.setAttribute("error", "Invalid email format");
                showUserForm(request, response);
                return;
            }
            
            // Validate phone format if provided
            if (phone != null && !phone.trim().isEmpty() && !isValidPhone(phone)) {
                request.setAttribute("error", "Phone number must start with 0 and be exactly 10 digits");
                showUserForm(request, response);
                return;
            }
            
            // Check if email exists for other users
            if (userDAO.isEmailExists(email, id)) {
                request.setAttribute("error", "Email already exists for another user");
                showUserForm(request, response);
                return;
            }
            
            // Get existing user and update
            User user = userDAO.getUserById(id);
            if (user == null) {
                request.setAttribute("error", "User not found");
                response.sendRedirect("users");
                return;
            }
            
            // Update basic information
            user.setFullName(fullName);
            user.setEmail(email);
            user.setPhone(phone);
            user.setRole(role);
            user.setUpdatedAt(new Timestamp(System.currentTimeMillis()));
            
            // Handle password change if requested
            boolean passwordChanged = false;
            if ("true".equals(changePassword)) {
                // Validate new password
                if (newPassword == null || newPassword.trim().isEmpty()) {
                    request.setAttribute("error", "New password is required when changing password");
                    showUserForm(request, response);
                    return;
                }
                
                if (confirmPassword == null || !newPassword.equals(confirmPassword)) {
                    request.setAttribute("error", "Password confirmation does not match");
                    showUserForm(request, response);
                    return;
                }
                
                if (!isStrongPassword(newPassword)) {
                    request.setAttribute("error", "New password must be at least 8 characters long and contain uppercase, lowercase, number, and special character");
                    showUserForm(request, response);
                    return;
                }
                
                // Hash and set new password
                String hashedPassword = hashPassword(newPassword);
                user.setPassword(hashedPassword);
                
                passwordChanged = true;
            }
            
            // Update user in database
            boolean updateSuccess;
            if (passwordChanged) {
                updateSuccess = userDAO.updateUserWithPassword(user);
            } else {
                updateSuccess = userDAO.updateUser(user);
            }
            
            if (updateSuccess) {
                String successMessage = "User updated successfully";
                if (passwordChanged) {
                    successMessage += ". Password has been changed and user will be notified.";
                    
                    // Here you would typically:
                    // 1. Send email notification to user about password change
                    // 2. Log the password change event
                    // 3. Invalidate user's sessions if they're logged in
                    logPasswordChange(user, (User) request.getSession().getAttribute("user"));
                }
                
                request.getSession().setAttribute("success", successMessage);
                response.sendRedirect("users");
            } else {
                request.setAttribute("error", "Failed to update user");
                showUserForm(request, response);
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("users");
        }
    }
    
    // Password hashing method
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder();
            
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }
    
    // Log password change for security audit
    private void logPasswordChange(User targetUser, User adminUser) {
        try {
            // Log password change event
            System.out.println("SECURITY LOG: Admin " + adminUser.getUsername() + 
                " changed password for user " + targetUser.getUsername() + 
                " at " + new Timestamp(System.currentTimeMillis()));
            
            // Here you would typically write to a security log file or database
            // and send email notification to the user
            
        } catch (Exception e) {
            System.err.println("Failed to log password change: " + e.getMessage());
        }
    }
    
    // Validation methods
    private boolean isStrongPassword(String password) {
        return password.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&+=!]).{8,}$");
    }
    
    private boolean isValidEmail(String email) {
        return email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    }
    
    private boolean isValidPhone(String phone) {
        return phone != null && phone.matches("^0\\d{9}$");
    }
    
    private boolean isValidUsername(String username) {
        return username != null && username.matches("^[a-zA-Z0-9_]{3,20}$");
    }
    
    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("users");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            
            // Don't allow deleting yourself
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            if (currentUser.getId() == id) {
                session.setAttribute("error", "You cannot delete your own account");
                response.sendRedirect("users");
                return;
            }
            
            if (userDAO.deleteUser(id)) {
                session.setAttribute("success", "User deleted successfully");
            } else {
                session.setAttribute("error", "Failed to delete user");
            }
            
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "Invalid user ID");
        }
        
        response.sendRedirect("users");
    }
    
    private void restoreUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("users?action=trash");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            
            if (userDAO.restoreUser(id)) {
                request.getSession().setAttribute("success", "User restored successfully");
            } else {
                request.getSession().setAttribute("error", "Failed to restore user");
            }
            
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "Invalid user ID");
        }
        
        response.sendRedirect("users?action=trash");
    }
}