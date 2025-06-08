//package controller;
//
//import dal.UserDAO;
//import model.User;
//import jakarta.servlet.ServletException;
//import jakarta.servlet.annotation.WebServlet;
//import jakarta.servlet.http.HttpServlet;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import java.io.IOException;
//import java.util.ArrayList;
//import java.util.List;
//
//@WebServlet(name = "CustomerManagerServlet", urlPatterns = {"/admin/customers"})
//public class CustomerManagerServlet extends HttpServlet {
//    
//    private UserDAO userDAO = new UserDAO();
//    private static final String CUSTOMER_ROLE = "GUEST";
//    private static final int RECORDS_PER_PAGE = 5; // Changed from 10 to 5
//    
//    @Override
//    protected void doGet(HttpServletRequest   request, HttpServletResponse response)
//            throws ServletException, IOException {
//        
//        String action = request.getParameter("action");
//        
//        if (action == null) {
//            action = "list";
//        }
//        
//        try {
//            switch (action) {
//                case "list":
//                    listCustomers(request, response);
//                    break;
//                case "add":
//                    showAddForm(request, response);
//                    break;
//                case "edit":
//                    showEditForm(request, response);
//                    break;
//                case "detail":
//                    showCustomerDetail(request, response);
//                    break;
//                case "search":
//                    searchCustomers(request, response);
//                    break;
//                case "deleted":
//                    showDeletedCustomers(request, response);
//                    break;
//                default:
//                    listCustomers(request, response);
//                    break;
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
//        }
//    }
//    
//    @Override
//    protected void doPost(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//        
//        request.setCharacterEncoding("UTF-8");
//        String action = request.getParameter("action");
//        
//        switch (action) {
//            case "add":
//                addCustomer(request, response);
//                break;
//            case "update":
//                updateCustomer(request, response);
//                break;
//            case "delete":
//                deleteCustomer(request, response);
//                break;
//            case "restore":
//                restoreCustomer(request, response);
//                break;
//            default:
//                response.sendRedirect(request.getContextPath() + "/admin/customers");
//                break;
//        }
//    }
//    
//    private void listCustomers(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//        
//        int page = 1;
//        
//        // Get page parameter
//        String pageParam = request.getParameter("page");
//        if (pageParam != null && !pageParam.isEmpty()) {
//            try {
//                page = Integer.parseInt(pageParam);
//                // Validate page number
//                if (page < 1) {
//                    page = 1;
//                }
//            } catch (NumberFormatException e) {
//                page = 1;
//            }
//        }
//        
//        // Get paginated customers
//        List<User> customers = userDAO.getUsersByRolePaginated(CUSTOMER_ROLE, page, RECORDS_PER_PAGE);
//        
//        // Get total records and calculate total pages
//        int totalRecords = userDAO.getTotalUsersByRole(CUSTOMER_ROLE);
//        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
//        
//        // Validate current page doesn't exceed total pages
//        if (page > totalPages && totalPages > 0) {
//            page = totalPages;
//            // Re-fetch customers for the corrected page
//            customers = userDAO.getUsersByRolePaginated(CUSTOMER_ROLE, page, RECORDS_PER_PAGE);
//        }
//        
//        // Calculate start and end record numbers for display
//        int startRecord = (page - 1) * RECORDS_PER_PAGE + 1;
//        int endRecord = Math.min(page * RECORDS_PER_PAGE, totalRecords);
//        
//        // Set attributes for JSP
//        request.setAttribute("customers", customers);
//        request.setAttribute("currentPage", page);
//        request.setAttribute("totalPages", totalPages);
//        request.setAttribute("totalRecords", totalRecords);
//        request.setAttribute("recordsPerPage", RECORDS_PER_PAGE);
//        request.setAttribute("startRecord", startRecord);
//        request.setAttribute("endRecord", endRecord);
//        
//        request.getRequestDispatcher("/jsp/customer-list.jsp").forward(request, response);
//    }
//    
//    private void searchCustomers(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//        
//        String keyword = request.getParameter("keyword");
//        
//        // Implement pagination for search
//        int page = 1;
//        String pageParam = request.getParameter("page");
//        if (pageParam != null && !pageParam.isEmpty()) {
//            try {
//                page = Integer.parseInt(pageParam);
//                if (page < 1) {
//                    page = 1;
//                }
//            } catch (NumberFormatException e) {
//                page = 1;
//            }
//        }
//        
//        // Use paginated search if UserDAO supports it
//        // If not, we'll use the existing method and paginate manually
//        List<User> customers = userDAO.searchUsersByRole(keyword, CUSTOMER_ROLE);
//        
//        // Calculate pagination manually
//        int totalRecords = customers.size();
//        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
//        
//        // Validate current page
//        if (page > totalPages && totalPages > 0) {
//            page = totalPages;
//        }
//        
//        // Get sublist for current page
//        int fromIndex = (page - 1) * RECORDS_PER_PAGE;
//        int toIndex = Math.min(fromIndex + RECORDS_PER_PAGE, totalRecords);
//        
//        List<User> paginatedCustomers = totalRecords > 0 ? 
//            customers.subList(fromIndex, toIndex) : new ArrayList<>();
//        
//        // Calculate display info
//        int startRecord = totalRecords > 0 ? fromIndex + 1 : 0;
//        int endRecord = toIndex;
//        
//        request.setAttribute("customers", paginatedCustomers);
//        request.setAttribute("keyword", keyword);
//        request.setAttribute("isSearch", true);
//        request.setAttribute("currentPage", page);
//        request.setAttribute("totalPages", totalPages);
//        request.setAttribute("totalRecords", totalRecords);
//        request.setAttribute("startRecord", startRecord);
//        request.setAttribute("endRecord", endRecord);
//        
//        request.getRequestDispatcher("/jsp/customer-list.jsp").forward(request, response);
//    }
//    
//    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//        request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
//    }
//    
//    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//        
//        int id = Integer.parseInt(request.getParameter("id"));
//        User customer = userDAO.getUserById(id);
//        
//        if (customer != null && CUSTOMER_ROLE.equals(customer.getRole())) {
//            request.setAttribute("customer", customer);
//            request.setAttribute("isEdit", true);
//            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
//        } else {
//            response.sendRedirect(request.getContextPath() + "/admin/customers?error=notfound");
//        }
//    }
//    
//    private void showCustomerDetail(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//        
//        int id = Integer.parseInt(request.getParameter("id"));
//        User customer = userDAO.getUserById(id);
//        
//        if (customer != null && CUSTOMER_ROLE.equals(customer.getRole())) {
//            // You might want to get additional details like booking history
//            request.setAttribute("customer", customer);
//            request.getRequestDispatcher("/jsp/customer-detail.jsp").forward(request, response);
//        } else {
//            response.sendRedirect(request.getContextPath() + "/admin/customers?error=notfound");
//        }
//    }
//    
//    private void addCustomer(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//        
//        String username = request.getParameter("username");
//        String password = request.getParameter("password");
//        String fullName = request.getParameter("fullName");
//        String email = request.getParameter("email");
//        String phone = request.getParameter("phone");
//        
//        // Create temporary user object for form data preservation
//        User tempUser = new User();
//        tempUser.setUsername(username);
//        tempUser.setFullName(fullName);
//        tempUser.setEmail(email);
//        tempUser.setPhone(phone);
//        tempUser.setRole(CUSTOMER_ROLE);
//        
//        // Validate username format
//        if (!isValidUsername(username)) {
//            request.setAttribute("error", "Username must be 3-20 characters long and contain only letters, numbers, and underscores!");
//            request.setAttribute("customer", tempUser);
//            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
//            return;
//        }
//        
//        // Validate password strength
//        if (!isStrongPassword(password)) {
//            request.setAttribute("error", "Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one digit, and one special character (@#$%^&+=!)");
//            request.setAttribute("customer", tempUser);
//            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
//            return;
//        }
//        
//        // Validate email format
//        if (!isValidEmail(email)) {
//            request.setAttribute("error", "Invalid email format!");
//            request.setAttribute("customer", tempUser);
//            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
//            return;
//        }
//        
//        // Validate phone number
//        if (!isValidPhone(phone)) {
//            request.setAttribute("error", "Phone number must be exactly 10 digits!");
//            request.setAttribute("customer", tempUser);
//            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
//            return;
//        }
//        
//        // Validate email exists
//        if (userDAO.isEmailExists(email, null)) {
//            request.setAttribute("error", "Email already exists!");
//            request.setAttribute("customer", tempUser);
//            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
//            return;
//        }
//        
//        // Validate username exists
//        if (userDAO.isUsernameExists(username, null)) {
//            request.setAttribute("error", "Username already exists!");
//            request.setAttribute("customer", tempUser);
//            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
//            return;
//        }
//        
//        User customer = new User(username, password, fullName, email, phone, CUSTOMER_ROLE);
//        
//        if (userDAO.addUser(customer)) {
//            response.sendRedirect(request.getContextPath() + "/admin/customers?success=added");
//        } else {
//            request.setAttribute("error", "Failed to add customer!");
//            request.setAttribute("customer", tempUser);
//            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
//        }
//    }
//    
//    private void updateCustomer(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//        
//        int id = Integer.parseInt(request.getParameter("id"));
//        String fullName = request.getParameter("fullName");
//        String email = request.getParameter("email");
//        String phone = request.getParameter("phone");
//        
//        // Get current customer for data preservation
//        User customer = userDAO.getUserById(id);
//        if (customer == null || !CUSTOMER_ROLE.equals(customer.getRole())) {
//            response.sendRedirect(request.getContextPath() + "/admin/customers?error=notfound");
//            return;
//        }
//        
//        // Update with new values
//        customer.setFullName(fullName);
//        customer.setEmail(email);
//        customer.setPhone(phone);
//        
//        // Validate email format
//        if (!isValidEmail(email)) {
//            request.setAttribute("error", "Invalid email format!");
//            request.setAttribute("customer", customer);
//            request.setAttribute("isEdit", true);
//            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
//            return;
//        }
//        
//        // Validate phone number
//        if (!isValidPhone(phone)) {
//            request.setAttribute("error", "Phone number must be exactly 10 digits!");
//            request.setAttribute("customer", customer);
//            request.setAttribute("isEdit", true);
//            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
//            return;
//        }
//        
//        // Validate email exists
//        if (userDAO.isEmailExists(email, id)) {
//            request.setAttribute("error", "Email already exists!");
//            request.setAttribute("customer", customer);
//            request.setAttribute("isEdit", true);
//            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
//            return;
//        }
//        
//        if (userDAO.updateUser(customer)) {
//            response.sendRedirect(request.getContextPath() + "/admin/customers?success=updated");
//        } else {
//            request.setAttribute("error", "Failed to update customer!");
//            request.setAttribute("customer", customer);
//            request.setAttribute("isEdit", true);
//            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
//        }
//    }
//    
//    private void deleteCustomer(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//        
//        int id = Integer.parseInt(request.getParameter("id"));
//        
//        if (userDAO.deleteUser(id)) {
//            response.sendRedirect(request.getContextPath() + "/admin/customers?success=deleted");
//        } else {
//            response.sendRedirect(request.getContextPath() + "/admin/customers?error=delete");
//        }
//    }
//    
//    private void showDeletedCustomers(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//        
//        // Implement pagination for deleted customers
//        int page = 1;
//        String pageParam = request.getParameter("page");
//        if (pageParam != null && !pageParam.isEmpty()) {
//            try {
//                page = Integer.parseInt(pageParam);
//                if (page < 1) {
//                    page = 1;
//                }
//            } catch (NumberFormatException e) {
//                page = 1;
//            }
//        }
//        
//        List<User> deletedCustomers = userDAO.getDeletedUsersByRole(CUSTOMER_ROLE);
//        
//        // Calculate pagination
//        int totalRecords = deletedCustomers.size();
//        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
//        
//        if (page > totalPages && totalPages > 0) {
//            page = totalPages;
//        }
//        
//        // Get sublist for current page
//        int fromIndex = (page - 1) * RECORDS_PER_PAGE;
//        int toIndex = Math.min(fromIndex + RECORDS_PER_PAGE, totalRecords);
//        
//        List<User> paginatedDeletedCustomers = totalRecords > 0 ? 
//            deletedCustomers.subList(fromIndex, toIndex) : new ArrayList<>();
//        
//        request.setAttribute("deletedCustomers", paginatedDeletedCustomers);
//        request.setAttribute("currentPage", page);
//        request.setAttribute("totalPages", totalPages);
//        request.setAttribute("totalRecords", totalRecords);
//        
//        request.getRequestDispatcher("/jsp/deleted-customers.jsp").forward(request, response);
//    }
//    
//    private void restoreCustomer(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//        
//        int id = Integer.parseInt(request.getParameter("id"));
//        
//        if (userDAO.restoreUser(id)) {
//            response.sendRedirect(request.getContextPath() + "/admin/customers?action=deleted&success=restored");
//        } else {
//            response.sendRedirect(request.getContextPath() + "/admin/customers?action=deleted&error=restore");
//        }
//    }
//    
//    // Validation methods
//    private boolean isStrongPassword(String password) {
//        return password.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&+=!]).{8,}$");
//    }
//    
//    private boolean isValidEmail(String email) {
//        return email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
//    }
//    
//    private boolean isValidPhone(String phone) {
//        return phone != null && phone.matches("^\\d{10}$");
//    }
//    
//    private boolean isValidUsername(String username) {
//        return username != null && username.matches("^[a-zA-Z0-9_]{3,20}$");
//    }
//}