package controller;

import dal.DBContext;
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
import java.math.BigDecimal;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Arrays;
import service.VerificationService;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

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
    
    // Debug logging
    System.out.println("=== Staff List Debug ===");
    System.out.println("Page: " + page);
    System.out.println("Role Filter: " + roleFilter);
    System.out.println("Search: " + search);
    
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
    
    // Debug logging
    System.out.println("Staff found: " + (staff != null ? staff.size() : "null"));
    System.out.println("Total records: " + totalRecords);
    
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
        
        // Format dates for HTML date inputs
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        
        if (staff.getDateOfBirth() != null) {
            String formattedDateOfBirth = sdf.format(staff.getDateOfBirth());
            request.setAttribute("formattedDateOfBirth", formattedDateOfBirth);
            // THÊM DÒNG NÀY để set vào staff object
            staff.setFormattedDateOfBirth(formattedDateOfBirth);
        }
        
        if (staff.getHireDate() != null) {
            String formattedHireDate = sdf.format(staff.getHireDate());
            request.setAttribute("formattedHireDate", formattedHireDate);
            // THÊM DÒNG NÀY để set vào staff object
            staff.setFormattedHireDate(formattedHireDate);
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
        
        // Get employment information
        String department = request.getParameter("department");
        String hireDateStr = request.getParameter("hireDate");
        String salaryStr = request.getParameter("salary");
        
        // Get personal information
        String dateOfBirthStr = request.getParameter("dateOfBirth");
        String gender = request.getParameter("gender");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String country = request.getParameter("country");
        
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
        staff.setDepartment(department);
        staff.setAddress(address);
        staff.setCity(city);
        staff.setCountry(country);
        staff.setGender(gender);
        
        // Parse and validate dates
        Date dateOfBirth = null;
        Date hireDate = null;
        
        // Validate and parse date of birth (REQUIRED for staff)
        if (dateOfBirthStr == null || dateOfBirthStr.isEmpty()) {
            request.setAttribute("error", "Date of birth is required for staff members!");
            request.setAttribute("staff", staff);
            request.setAttribute("isEdit", false);
            request.setAttribute("pageTitle", "Add New Staff Member");
            request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
            request.setAttribute("activePage", "staff");
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
            return;
        }
        
        try {
            dateOfBirth = new SimpleDateFormat("yyyy-MM-dd").parse(dateOfBirthStr);
            staff.setDateOfBirth(dateOfBirth);
            
            // Calculate age
            Calendar today = Calendar.getInstance();
            Calendar birthDate = Calendar.getInstance();
            birthDate.setTime(dateOfBirth);
            
            int age = today.get(Calendar.YEAR) - birthDate.get(Calendar.YEAR);
            if (today.get(Calendar.DAY_OF_YEAR) < birthDate.get(Calendar.DAY_OF_YEAR)) {
                age--;
            }
            
            if (age < 18) {
                request.setAttribute("error", "Staff member must be at least 18 years old!");
                request.setAttribute("staff", staff);
                request.setAttribute("isEdit", false);
                request.setAttribute("pageTitle", "Add New Staff Member");
                request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
                request.setAttribute("activePage", "staff");
                request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
                return;
            }
            
            // Check if date is in the future
            if (dateOfBirth.after(new Date())) {
                request.setAttribute("error", "Date of birth cannot be in the future!");
                request.setAttribute("staff", staff);
                request.setAttribute("isEdit", false);
                request.setAttribute("pageTitle", "Add New Staff Member");
                request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
                request.setAttribute("activePage", "staff");
                request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
                return;
            }
        } catch (ParseException e) {
            request.setAttribute("error", "Invalid date of birth format!");
            request.setAttribute("staff", staff);
            request.setAttribute("isEdit", false);
            request.setAttribute("pageTitle", "Add New Staff Member");
            request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
            request.setAttribute("activePage", "staff");
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
            return;
        }
        
        // Parse hire date
        if (hireDateStr != null && !hireDateStr.isEmpty()) {
            try {
                hireDate = new SimpleDateFormat("yyyy-MM-dd").parse(hireDateStr);
                staff.setHireDate(hireDate);
                
                // Check if hire date is in the future
                if (hireDate.after(new Date())) {
                    request.setAttribute("error", "Hire date cannot be in the future!");
                    request.setAttribute("staff", staff);
                    request.setAttribute("isEdit", false);
                    request.setAttribute("pageTitle", "Add New Staff Member");
                    request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
                    request.setAttribute("activePage", "staff");
                    request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
                    return;
                }
                
                // Check if hire date is before birth date + 18 years
                Calendar minHireDate = Calendar.getInstance();
                minHireDate.setTime(dateOfBirth);
                minHireDate.add(Calendar.YEAR, 18);
                
                if (hireDate.before(minHireDate.getTime())) {
                    request.setAttribute("error", "Hire date cannot be before the employee turns 18!");
                    request.setAttribute("staff", staff);
                    request.setAttribute("isEdit", false);
                    request.setAttribute("pageTitle", "Add New Staff Member");
                    request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
                    request.setAttribute("activePage", "staff");
                    request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
                    return;
                }
            } catch (ParseException e) {
                request.setAttribute("error", "Invalid hire date format!");
                request.setAttribute("staff", staff);
                request.setAttribute("isEdit", false);
                request.setAttribute("pageTitle", "Add New Staff Member");
                request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
                request.setAttribute("activePage", "staff");
                request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
                return;
            }
        }
        
        // Parse salary
        double salary = 0;
        if (salaryStr != null && !salaryStr.isEmpty()) {
            try {
                salary = Double.parseDouble(salaryStr);
                staff.setSalary(salary);
                
                if (salary < 0) {
                    request.setAttribute("error", "Salary cannot be negative!");
                    request.setAttribute("staff", staff);
                    request.setAttribute("isEdit", false);
                    request.setAttribute("pageTitle", "Add New Staff Member");
                    request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
                    request.setAttribute("activePage", "staff");
                    request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid salary format!");
                request.setAttribute("staff", staff);
                request.setAttribute("isEdit", false);
                request.setAttribute("pageTitle", "Add New Staff Member");
                request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
                request.setAttribute("activePage", "staff");
                request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
                return;
            }
        }
        
        // Validate input
        String validationError = validateStaffInput(username, password, email,
                phone, role, department, address, city, country, null);
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
        
        // Hash password
        staff.setPassword(hashPassword(password));
        staff.setStatus(true);
        
        // Check if using stored procedure or direct DAO
        boolean useStoredProcedure = true; // Set to false if you want to use DAO directly
        
        if (useStoredProcedure) {
            // Create employee using stored procedure
            Connection conn = null;
            CallableStatement cs = null;
            
            try {
                conn = DBContext.getConnection();
                cs = conn.prepareCall("{call sp_CreateEmployee(?,?,?,?,?,?,?,?,?,?,?,?,?,?)}");
                
                cs.setString(1, username);
                cs.setString(2, staff.getPassword()); // Already hashed
                cs.setString(3, fullName);
                cs.setString(4, email);
                cs.setString(5, phone);
                cs.setString(6, role);
                cs.setString(7, department);
                
                if (hireDate != null) {
                    cs.setDate(8, new java.sql.Date(hireDate.getTime()));
                } else {
                    cs.setNull(8, java.sql.Types.DATE);
                }
                
                if (salary > 0) {
                    cs.setBigDecimal(9, new BigDecimal(salary));
                } else {
                    cs.setNull(9, java.sql.Types.DECIMAL);
                }
                
                // Set new fields
                cs.setDate(10, new java.sql.Date(dateOfBirth.getTime())); // Always has value
                cs.setString(11, gender);
                cs.setString(12, address);
                cs.setString(13, city);
                cs.setString(14, country);
                
                cs.execute();
                
                request.getSession().setAttribute("success", "Staff member created successfully!");
                
            } catch (SQLException e) {
                e.printStackTrace();
                if (e.getMessage().contains("at least 18 years old")) {
                    request.setAttribute("error", "Staff member must be at least 18 years old!");
                } else if (e.getMessage().contains("Username already exists")) {
                    request.setAttribute("error", "Username already exists!");
                } else if (e.getMessage().contains("Email already exists")) {
                    request.setAttribute("error", "Email already exists!");
                } else {
                    request.setAttribute("error", "Failed to create staff member: " + e.getMessage());
                }
                request.setAttribute("staff", staff);
                request.setAttribute("isEdit", false);
                request.setAttribute("pageTitle", "Add New Staff Member");
                request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
                request.setAttribute("activePage", "staff");
                request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
                return;
            } finally {
                try {
                    if (cs != null) cs.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        } else {
            // Use DAO method directly
            if (userDAO.createEmployee(staff)) {
                request.getSession().setAttribute("success", "Staff member created successfully!");
            } else {
                request.setAttribute("error", "Failed to create staff member!");
                request.setAttribute("staff", staff);
                request.setAttribute("isEdit", false);
                request.setAttribute("pageTitle", "Add New Staff Member");
                request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
                request.setAttribute("activePage", "staff");
                request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
                return;
            }
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
        
        // Get employment information fields
        String department = request.getParameter("department");
        String hireDateStr = request.getParameter("hireDate");
        String salaryStr = request.getParameter("salary");
        
        // Get personal information fields
        String dateOfBirthStr = request.getParameter("dateOfBirth");
        String gender = request.getParameter("gender");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String country = request.getParameter("country");
        
        // Get current admin user
        User currentAdmin = (User) request.getSession().getAttribute("user");
        if (currentAdmin == null || !"ADMIN".equals(currentAdmin.getRole())) {
            request.getSession().setAttribute("error", "Unauthorized access!");
            response.sendRedirect(request.getContextPath() + "/admin/staff");
            return;
        }
        
        // Get existing staff with all details
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
        
        // Parse and validate dates
        Date dateOfBirth = null;
        Date hireDate = null;
        
        // Validate and parse date of birth (REQUIRED for staff)
        if (dateOfBirthStr == null || dateOfBirthStr.isEmpty()) {
            request.setAttribute("error", "Date of birth is required for staff members!");
            request.setAttribute("staff", staff);
            request.setAttribute("isEdit", true);
            request.setAttribute("pageTitle", "Edit Staff Member");
            request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
            request.setAttribute("activePage", "staff");
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
            return;
        }
        
        try {
            dateOfBirth = new SimpleDateFormat("yyyy-MM-dd").parse(dateOfBirthStr);
            
            // Calculate age
            Calendar today = Calendar.getInstance();
            Calendar birthDate = Calendar.getInstance();
            birthDate.setTime(dateOfBirth);
            
            int age = today.get(Calendar.YEAR) - birthDate.get(Calendar.YEAR);
            if (today.get(Calendar.DAY_OF_YEAR) < birthDate.get(Calendar.DAY_OF_YEAR)) {
                age--;
            }
            
            if (age < 18) {
                request.setAttribute("error", "Staff member must be at least 18 years old!");
                request.setAttribute("staff", staff);
                request.setAttribute("isEdit", true);
                request.setAttribute("pageTitle", "Edit Staff Member");
                request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
                request.setAttribute("activePage", "staff");
                request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
                return;
            }
            
            // Check if date is in the future
            if (dateOfBirth.after(new Date())) {
                request.setAttribute("error", "Date of birth cannot be in the future!");
                request.setAttribute("staff", staff);
                request.setAttribute("isEdit", true);
                request.setAttribute("pageTitle", "Edit Staff Member");
                request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
                request.setAttribute("activePage", "staff");
                request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
                return;
            }
        } catch (ParseException e) {
            request.setAttribute("error", "Invalid date of birth format!");
            request.setAttribute("staff", staff);
            request.setAttribute("isEdit", true);
            request.setAttribute("pageTitle", "Edit Staff Member");
            request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
            request.setAttribute("activePage", "staff");
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
            return;
        }
        
        // Parse hire date
        if (hireDateStr != null && !hireDateStr.isEmpty()) {
            try {
                hireDate = new SimpleDateFormat("yyyy-MM-dd").parse(hireDateStr);
                
                // Check if hire date is in the future
                if (hireDate.after(new Date())) {
                    request.setAttribute("error", "Hire date cannot be in the future!");
                    request.setAttribute("staff", staff);
                    request.setAttribute("isEdit", true);
                    request.setAttribute("pageTitle", "Edit Staff Member");
                    request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
                    request.setAttribute("activePage", "staff");
                    request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
                    return;
                }
                
                // Check if hire date is before birth date + 18 years
                Calendar minHireDate = Calendar.getInstance();
                minHireDate.setTime(dateOfBirth);
                minHireDate.add(Calendar.YEAR, 18);
                
                if (hireDate.before(minHireDate.getTime())) {
                    request.setAttribute("error", "Hire date cannot be before the employee turns 18!");
                    request.setAttribute("staff", staff);
                    request.setAttribute("isEdit", true);
                    request.setAttribute("pageTitle", "Edit Staff Member");
                    request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
                    request.setAttribute("activePage", "staff");
                    request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
                    return;
                }
            } catch (ParseException e) {
                request.setAttribute("error", "Invalid hire date format!");
                request.setAttribute("staff", staff);
                request.setAttribute("isEdit", true);
                request.setAttribute("pageTitle", "Edit Staff Member");
                request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
                request.setAttribute("activePage", "staff");
                request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
                return;
            }
        }
        
        // Parse salary
        double salary = 0;
        if (salaryStr != null && !salaryStr.isEmpty()) {
            try {
                salary = Double.parseDouble(salaryStr);
                
                if (salary < 0) {
                    request.setAttribute("error", "Salary cannot be negative!");
                    request.setAttribute("staff", staff);
                    request.setAttribute("isEdit", true);
                    request.setAttribute("pageTitle", "Edit Staff Member");
                    request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
                    request.setAttribute("activePage", "staff");
                    request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid salary format!");
                request.setAttribute("staff", staff);
                request.setAttribute("isEdit", true);
                request.setAttribute("pageTitle", "Edit Staff Member");
                request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
                request.setAttribute("activePage", "staff");
                request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
                return;
            }
        }
        
        // Validate input
        String validationError = validateStaffInput(null, null, email, phone,
                role, department, address, city, country, id);
        if (validationError != null) {
            request.setAttribute("error", validationError);
            request.setAttribute("staff", staff);
            request.setAttribute("isEdit", true);
            request.setAttribute("pageTitle", "Edit Staff Member");
            request.setAttribute("contentPage", "/jsp/admin/staff/staff-form.jsp");
            request.setAttribute("activePage", "staff");
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
            return;
        }
        
        // 🔥 Check for sensitive changes and create verification requests
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
            boolean needsBasicUpdate = false;
            boolean needsDetailsUpdate = false;
            
            // Update basic user info
            if (!fullName.equals(staff.getFullName())) {
                staff.setFullName(fullName);
                needsBasicUpdate = true;
            }
            
            if (!role.equals(staff.getRole()) && !"ADMIN".equals(staff.getRole())) {
                staff.setRole(role);
                needsBasicUpdate = true;
            }
            
            // Perform updates
            if (needsBasicUpdate) {
                userDAO.updateUser(staff);
            }
            
            // Always update employee details (including personal information)
            // Ensure employee details exist
            if (!userDAO.hasEmployeeDetails(id)) {
                userDAO.createEmployeeDetailsIfNotExists(id);
            }
            
            // Update all employee details fields
            staff.setDepartment(department);
            staff.setHireDate(hireDate);
            staff.setSalary(salary);
            staff.setDateOfBirth(dateOfBirth);
            staff.setGender(gender);
            staff.setAddress(address);
            staff.setCity(city);
            staff.setCountry(country);
            
            // Check if using stored procedure or direct DAO
            boolean useStoredProcedure = true; // Set to false if you want to use DAO directly
            
            if (useStoredProcedure) {
                // Update using stored procedure
                Connection conn = null;
                CallableStatement cs = null;
                
                try {
                    conn = DBContext.getConnection();
                    cs = conn.prepareCall("{call sp_UpdateEmployeeDetails(?,?,?,?,?,?,?,?,?)}");
                    
                    cs.setInt(1, id);
                    cs.setString(2, department);
                    
                    if (hireDate != null) {
                        cs.setDate(3, new java.sql.Date(hireDate.getTime()));
                    } else {
                        cs.setNull(3, java.sql.Types.DATE);
                    }
                    
                    if (salary > 0) {
                        cs.setBigDecimal(4, new BigDecimal(salary));
                    } else {
                        cs.setNull(4, java.sql.Types.DECIMAL);
                    }
                    
                    // Always set date of birth (required for staff)
                    cs.setDate(5, new java.sql.Date(dateOfBirth.getTime()));
                    
                    cs.setString(6, gender);
                    cs.setString(7, address);
                    cs.setString(8, city);
                    cs.setString(9, country);
                    
                    cs.execute();
                    
                } catch (SQLException e) {
                    e.printStackTrace();
                    throw new RuntimeException("Failed to update employee details: " + e.getMessage());
                } finally {
                    try {
                        if (cs != null) cs.close();
                        if (conn != null) conn.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            } else {
                // Update employee details using DAO
                userDAO.updateEmployeeDetails(staff);
            }
            
            // Set success message
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
        
        // Redirect to staff detail page
        response.sendRedirect(request.getContextPath() + "/admin/staff?action=view&id=" + id + 
                              (hasSensitiveChanges ? "&verificationSent=true" : ""));
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
    
    // Helper methods for staff-specific queries
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
    
    private String validateStaffInput(String username, String password,
                                      String email, String phone, String role,
                                      String department, String address,
                                      String city, String country,
                                      Integer excludeId) {
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
        if (department != null && department.length() > 30) {
            return "Department cannot exceed 30 characters.";
        }

        if (address != null && address.length() > 30) {
            return "Address cannot exceed 30 characters.";
        }

        if (city != null && city.length() > 30) {
            return "City cannot exceed 30 characters.";
        }

        if (country != null && country.length() > 30) {
            return "Country cannot exceed 30 characters.";
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