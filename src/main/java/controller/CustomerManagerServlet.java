package controller;

import dal.CustomerDAO;
import dal.CustomerDAO.CustomerStats;
import model.Customer;
import model.Reservation;
import model.Feedback;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "CustomerManagerServlet", urlPatterns = {"/admin/customers"})
public class CustomerManagerServlet extends HttpServlet {
    
    private CustomerDAO customerDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        customerDAO = new CustomerDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "list";
        }
        
        try {
            switch (action) {
                case "list":
                    listCustomers(request, response);
                    break;
                case "add":
                    showAddForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "detail":
                    showCustomerDetail(request, response);
                    break;
                case "search":
                    searchCustomers(request, response);
                    break;
                default:
                    listCustomers(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/customers");
            return;
        }
        
        try {
            switch (action) {
                case "add":
                    addCustomer(request, response);
                    break;
                case "update":
                    updateCustomer(request, response);
                    break;
                case "delete":
                    deleteCustomer(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin/customers");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }
    
    private void listCustomers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int page = 1;
        int recordsPerPage = 10;
        
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        List<Customer> customers = customerDAO.getCustomersPaginated(page, recordsPerPage);
        int totalRecords = customerDAO.getTotalCustomers();
        int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
        
        request.setAttribute("customers", customers);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        
        // Set template attributes
        request.setAttribute("pageTitle", "Customer Management");
        request.setAttribute("activePage", "customers");
        request.setAttribute("contentPage", "/jsp/customer-list-content.jsp");
        
        request.getRequestDispatcher("/jsp/admin-template.jsp").forward(request, response);
    }
    
    private void searchCustomers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        if (keyword == null) keyword = "";
        
        List<Customer> customers = customerDAO.searchCustomers(keyword);
        
        request.setAttribute("customers", customers);
        request.setAttribute("keyword", keyword);
        request.setAttribute("isSearch", true);
        
        // Set template attributes
        request.setAttribute("pageTitle", "Customer Search Results");
        request.setAttribute("activePage", "customers");
        request.setAttribute("contentPage", "/jsp/customer-list-content.jsp");
        
        request.getRequestDispatcher("/jsp/admin-template.jsp").forward(request, response);
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setAttribute("pageTitle", "Add New Customer");
        request.setAttribute("activePage", "customers");
        request.setAttribute("contentPage", "/jsp/customer-form-content.jsp");
        request.setAttribute("isEdit", false);
        
        request.getRequestDispatcher("/jsp/admin-template.jsp").forward(request, response);
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?error=invalidid");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            Customer customer = customerDAO.getCustomerById(id);
            
            if (customer != null) {
                request.setAttribute("customer", customer);
                request.setAttribute("isEdit", true);
                request.setAttribute("pageTitle", "Edit Customer");
                request.setAttribute("activePage", "customers");
                request.setAttribute("contentPage", "/jsp/customer-form-content.jsp");
                
                request.getRequestDispatcher("/jsp/admin-template.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/customers?error=notfound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?error=invalidid");
        }
    }
    
    private void showCustomerDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?error=invalidid");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            Customer customer = customerDAO.getCustomerById(id);
            
            if (customer != null) {
                // Get customer statistics
                CustomerStats stats = customerDAO.getCustomerStats(id);
                
                // Get booking history and feedback
                List<Reservation> bookingHistory = customerDAO.getCustomerBookingHistory(id);
                List<Feedback> feedbacks = customerDAO.getCustomerFeedback(id);
                
                request.setAttribute("customer", customer);
                request.setAttribute("totalSpent", stats.totalSpent);
                request.setAttribute("completedBookings", stats.completedBookings);
                request.setAttribute("averageRating", String.format("%.1f", stats.averageRating));
                request.setAttribute("bookingHistory", bookingHistory);
                request.setAttribute("feedbacks", feedbacks);
                
                request.setAttribute("pageTitle", "Customer Detail");
                request.setAttribute("activePage", "customers");
                request.setAttribute("contentPage", "/jsp/customer-detail-content.jsp");
                
                request.getRequestDispatcher("/jsp/admin-template.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/customers?error=notfound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?error=invalidid");
        }
    }
    
    private void addCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        
        // Validate required fields
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            fullName == null || fullName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty()) {
            
            request.setAttribute("error", "All fields are required!");
            request.setAttribute("customer", new Customer(username, "", fullName, email, phone));
            request.setAttribute("pageTitle", "Add New Customer");
            request.setAttribute("activePage", "customers");
            request.setAttribute("contentPage", "/jsp/customer-form-content.jsp");
            request.setAttribute("isEdit", false);
            request.getRequestDispatcher("/jsp/admin-template.jsp").forward(request, response);
            return;
        }
        
        // Validate username
        if (customerDAO.isUsernameExists(username)) {
            request.setAttribute("error", "Username already exists!");
            request.setAttribute("customer", new Customer(username, "", fullName, email, phone));
            request.setAttribute("pageTitle", "Add New Customer");
            request.setAttribute("activePage", "customers");
            request.setAttribute("contentPage", "/jsp/customer-form-content.jsp");
            request.setAttribute("isEdit", false);
            request.getRequestDispatcher("/jsp/admin-template.jsp").forward(request, response);
            return;
        }
        
        // Validate email
        if (customerDAO.isEmailExists(email, null)) {
            request.setAttribute("error", "Email already exists!");
            request.setAttribute("customer", new Customer(username, "", fullName, email, phone));
            request.setAttribute("pageTitle", "Add New Customer");
            request.setAttribute("activePage", "customers");
            request.setAttribute("contentPage", "/jsp/customer-form-content.jsp");
            request.setAttribute("isEdit", false);
            request.getRequestDispatcher("/jsp/admin-template.jsp").forward(request, response);
            return;
        }
        
        Customer customer = new Customer(username, password, fullName, email, phone);
        
        if (customerDAO.addCustomer(customer)) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?success=added");
        } else {
            request.setAttribute("error", "Failed to add customer!");
            request.setAttribute("customer", customer);
            request.setAttribute("pageTitle", "Add New Customer");
            request.setAttribute("activePage", "customers");
            request.setAttribute("contentPage", "/jsp/customer-form-content.jsp");
            request.setAttribute("isEdit", false);
            request.getRequestDispatcher("/jsp/admin-template.jsp").forward(request, response);
        }
    }
    
    private void updateCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?error=invalidid");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            
            // Validate email
            if (customerDAO.isEmailExists(email, id)) {
                request.setAttribute("error", "Email already exists!");
                Customer customer = customerDAO.getCustomerById(id);
                if (customer != null) {
                    customer.setFullName(fullName);
                    customer.setEmail(email);
                    customer.setPhone(phone);
                    request.setAttribute("customer", customer);
                }
                request.setAttribute("isEdit", true);
                request.setAttribute("pageTitle", "Edit Customer");
                request.setAttribute("activePage", "customers");
                request.setAttribute("contentPage", "/jsp/customer-form-content.jsp");
                request.getRequestDispatcher("/jsp/admin-template.jsp").forward(request, response);
                return;
            }
            
            Customer customer = new Customer();
            customer.setId(id);
            customer.setFullName(fullName);
            customer.setEmail(email);
            customer.setPhone(phone);
            
            if (customerDAO.updateCustomer(customer)) {
                response.sendRedirect(request.getContextPath() + "/admin/customers?success=updated");
            } else {
                request.setAttribute("error", "Failed to update customer!");
                request.setAttribute("customer", customer);
                request.setAttribute("isEdit", true);
                request.setAttribute("pageTitle", "Edit Customer");
                request.setAttribute("activePage", "customers");
                request.setAttribute("contentPage", "/jsp/customer-form-content.jsp");
                request.getRequestDispatcher("/jsp/admin-template.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?error=invalidid");
        }
    }
    
    private void deleteCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?error=invalidid");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            
            if (customerDAO.deleteCustomer(id)) {
                response.sendRedirect(request.getContextPath() + "/admin/customers?success=deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/customers?error=delete");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?error=invalidid");
        }
    }
}