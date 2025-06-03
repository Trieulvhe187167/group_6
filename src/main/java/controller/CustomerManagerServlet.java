package controller;

import dal.CustomerDAO;
import model.Customer;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "CustomerManagerServlet", urlPatterns = {"/admin/customers"})
public class CustomerManagerServlet extends HttpServlet {
    
    private CustomerDAO customerDAO = new CustomerDAO();
    
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
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
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
    }
    
    private void listCustomers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int page = 1;
        int recordsPerPage = 10;
        
        if (request.getParameter("page") != null) {
            page = Integer.parseInt(request.getParameter("page"));
        }
        
        List<Customer> customers = customerDAO.getCustomersPaginated(page, recordsPerPage);
        int totalRecords = customerDAO.getTotalCustomers();
        int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
        
        request.setAttribute("customers", customers);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        
        // Debug path
        System.out.println("Forwarding to: /jsp/customer-list.jsp");
        
        request.getRequestDispatcher("/jsp/customer-list.jsp").forward(request, response);
    }
    
    private void searchCustomers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        List<Customer> customers = customerDAO.searchCustomers(keyword);
        
        request.setAttribute("customers", customers);
        request.setAttribute("keyword", keyword);
        request.setAttribute("isSearch", true);
        
        request.getRequestDispatcher("/jsp/customer-list.jsp").forward(request, response);
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        Customer customer = customerDAO.getCustomerById(id);
        
        if (customer != null) {
            request.setAttribute("customer", customer);
            request.setAttribute("isEdit", true);
            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/customers?error=notfound");
        }
    }
    
    private void showCustomerDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        Customer customer = customerDAO.getCustomerById(id);
        
        if (customer != null) {
            request.setAttribute("customer", customer);
            request.getRequestDispatcher("/jsp/customer-detail.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/customers?error=notfound");
        }
    }
    
    private void addCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        
        // Validate email
        if (customerDAO.isEmailExists(email, null)) {
            request.setAttribute("error", "Email already exists!");
            request.setAttribute("username", username);
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);
            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
            return;
        }
        
        Customer customer = new Customer(username, password, fullName, email, phone);
        
        if (customerDAO.addCustomer(customer)) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?success=added");
        } else {
            request.setAttribute("error", "Failed to add customer!");
            request.setAttribute("customer", customer);
            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
        }
    }
    
    private void updateCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        
        // Validate email
        if (customerDAO.isEmailExists(email, id)) {
            request.setAttribute("error", "Email already exists!");
            Customer customer = customerDAO.getCustomerById(id);
            customer.setFullName(fullName);
            customer.setEmail(email);
            customer.setPhone(phone);
            request.setAttribute("customer", customer);
            request.setAttribute("isEdit", true);
            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
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
            request.getRequestDispatcher("/jsp/customer-form.jsp").forward(request, response);
        }
    }
    
    private void deleteCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        
        if (customerDAO.deleteCustomer(id)) {
            response.sendRedirect(request.getContextPath() + "/admin/customers?success=deleted");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/customers?error=delete");
        }
    }
}